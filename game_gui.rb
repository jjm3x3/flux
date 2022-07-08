require 'gosu'
require './gui_elements/button.rb'
require './gui_elements/game_stats.rb'
require './gui_elements/dialog.rb'
require './game.rb'
require './gui_input_manager.rb'
require './game_driver.rb'

class GameGui < Gosu::Window
    def initialize(logger, prompt_strings, user_prompt_templates, deck)
        super 1200, 900
        self.caption = "Fluxx"

        @bakground_image = Gosu::Image.new("assets/onlinePurpleSquare.jpg", tileable: true)
        @game_background = Gosu::record(10, 10) do
            my_purple = Gosu::Color.new(255, 120, 40, 139)
            Gosu::draw_rect(0,0, 10, 10, my_purple, ZOrder::BAKGROUND)
        end
        @font = Gosu::Font.new(20)

        @left_click_down = false
        @button_options = {pressed_color: Gosu::Color::BLACK, unpressed_color: Gosu::Color::WHITE, is_pressed: method(:is_left_button_pressed)}
        @new_game_button = Button.new(self, @font, "New Game?", 10, 10, ZOrder::GAME_ITEMS, @button_options)
        @game_stats = GameStats.new(10, 10)
        @game = nil
        @current_displayed_cards = []

        @player_changed = true
        @redraw_hand = true
        @card_played = false

        @logger = logger

        dialog_background = Gosu::record(10,10) do
            my_green = Gosu::Color.new(255,0, 128, 0)
            Gosu::draw_rect(0, 0, 10, 10, my_green, ZOrder::DIALOG)
        end

        dialog_prompts = initialize_dialog_prompts(prompt_strings)

        @simple_dialog = SimpleDialog.new(
            self,
            dialog_background,
            Gosu::Font.new(20),
            logger,
            dialog_prompts,
            @button_options)

        @simple_dialog.set_options(["Yes", "No"])
        @simple_dialog.set_prompt :play_a_game_prompt

        @list_dialog = CardDialog.new(
            self,
            dialog_background,
            Gosu::Font.new(20),
            logger,
            dialog_prompts,
            @button_options)

        @user_prompt_templates = user_prompt_templates
        @deck = deck

        @new_game_driver = nil

        @current_cached_player = nil
        @current_player_future = nil

        @play_card_future = nil
    end

    def initialize_dialog_prompts(prompt_strings)
        result = {}
        prompt_strings.map do |key, prompt_string|
            result[key] = Gosu::Image.from_text(prompt_string, 20)
        end

        return result
    end

    def is_left_button_pressed
        @left_click_down
    end

    def start_a_new_game
       @logger.debug "I am starting a game then"
       numberOfPlayers = 3
       players = Player.generate_players(numberOfPlayers)
       PlayerPromptGenerator.generate_prompts(players, @user_prompt_templates).each do |key, prompt|
           # TODO:: should check to make sure @list_dialog exists
           @list_dialog.add_prompt(key, Gosu::Image.from_text(prompt, 20))
       end
       @game = Game.new(@logger, GuiInputManager.new(self), players, Random.new, @deck)
       @game.setup
       @new_game_driver = GameDriver.new(@game, @logger)
       @current_cached_player = @new_game_driver.await.active_player.value
    end

    def button_up(id)
        if @left_click_down
            @logger.debug "left button released"
            @left_click_down = false
            if @list_dialog != nil && @list_dialog.is_visible?
                @logger.debug "There is a current dialog"
                if @list_dialog.handle_result
                    @logger.debug "Handling dialog result"
                    @list_dialog.hide
                end
                @logger.debug "Handle result call false so return"
                return
            end
            if @simple_dialog && @simple_dialog.is_visible?
                @simple_dialog.handle_result do |result|
                    @logger.debug "GameGui:button_up: are you sure dialog result is: #{result}"
                    @simple_dialog.hide
                    if result == "Yes"
                        @new_game_button.set_visibility false
                        start_a_new_game
                    elsif result == "Back to Main Menu"
                        @new_game_driver = nil
                    end
                    # TODO:: do things for other cases
                end
                return
            end
            if @new_game_button.is_clicked?
                @simple_dialog.show
                return
            end
            clickedCard = 0
            @current_displayed_cards.each do |cardButton|
                @logger.debug "Checking card '#{cardButton}'"
                if cardButton.is_clicked?
                    @logger.debug "Starting awaiting active_player from game_driver"
                    active_player_result = @new_game_driver.await.active_player
                    @logger.debug "Get activePlayer value out of await result"
                    activePlayer = active_player_result.value

                    @logger.debug "Getting card from players hand"
                    cardToPlay = activePlayer.remove_card_from_hand(clickedCard)
                    @logger.debug "you clicked a card button #{cardToPlay}"

                    @play_card_future = @new_game_driver.async.play_card(activePlayer, cardToPlay)
                    @play_card_future.add_observer do |time, value|
                        @card_played = true
                        @redraw_hand = true
                    end

                    @redraw_hand = true

                    return
                end
                clickedCard += 1
            end
        end
    end

    def update

        if Gosu.button_down? Gosu::MS_LEFT and !@left_click_down
            @logger.debug "left button click"
            @left_click_down = true
            @list_dialog_clicked = @list_dialog.check_clicked
            @simple_dialog_clicked = @simple_dialog.check_clicked
        end

        if @left_click_down 
            if @list_dialog_clicked
                @list_dialog.set_relative_position(mouse_x, mouse_y)
            elsif @simple_dialog_clicked
                @simple_dialog.set_relative_position(mouse_x, mouse_y)
            end
        end

        if @new_game_driver
            if @card_played
                @card_played = false
                if @new_game_driver.await.has_winner.value
                    # win flow
                    @simple_dialog.set_options(["Back to Main Menu"])
                    @simple_dialog.set_prompt(:exit)
                    @simple_dialog.show
                elsif
                    clean_up_future = @new_game_driver.async.post_card_play_clean_up
                    clean_up_future.add_observer do |time, value|
                        if value # this means the turn is over
                            @player_changed = true
                            setup_cached_player
                        end
                        @redraw_hand =true
                    end
                end

            elsif @player_changed
                @logger.debug "GameGui::update Player has changed setting up new turn"
                @player_changed = false
                new_turn_future = @new_game_driver.async.setup_new_turn
                new_turn_future.add_observer do |time, value|
                    @redraw_hand = true
                end
            end
        end
    end

    def needs_cursor?
        true
    end

    def draw
        @game_background.draw(0, 0, ZOrder::BAKGROUND, width/10, height/10)

        if !@new_game_driver
            # for main menu
            @new_game_button.draw
            @simple_dialog.draw
            return
        end
        @game_stats.draw(@game)

        activePlayer = @current_cached_player
        @font.draw_text("It is player #{activePlayer}'s turn'", 10, 10 + @game_stats.height + 10, 1, 1.0, 1.0, Gosu::Color::WHITE)

        @font.draw_text("Here are the permanents they have:", 10, 10 + @game_stats.height + 10 + @font.height + 10, 1, 1.0, 1.0, Gosu::Color::WHITE)

        permanentsDisplayed = 0
        permananent_margin = 5
        permanents_start_y = 10 + @game_stats.height + 10 + @font.height + 10 + @font.height + permananent_margin
        activePlayer.permanents.each do |card|
            next_y = permanents_start_y + @font.height * permanentsDisplayed + permananent_margin * permanentsDisplayed
            @font.draw_text("#{card}", 20, next_y, 1, 1.0, 1.0, Gosu::Color::WHITE)
            permanentsDisplayed += 1
        end
        permanents_height = activePlayer.permanents.length * @font.height + activePlayer.permanents.length * permananent_margin

        @font.draw_text("Pick a card to play:", 10, permanents_start_y + permanents_height + 10, 1, 1.0, 1.0, Gosu::Color::WHITE)

        if @redraw_hand

            cardsDisplayed = 0
            @current_displayed_cards = []
            activePlayer.hand.each do |card|
                newCardButton = Button.new(self, @font, "#{card}", 20, (permanents_start_y + permanents_height + 10 + @font.height) + 10 * cardsDisplayed + @font.height * cardsDisplayed, ZOrder::GAME_ITEMS, @button_options)
                newCardButton.draw
                @current_displayed_cards << newCardButton
                cardsDisplayed += 1
            end

            @redraw_hand = false

        else
            @current_displayed_cards.each do |cardButton|
                cardButton.draw
            end
        end
        @simple_dialog.draw
        @list_dialog.draw
    end

    def get_dialog_result
        @list_dialog.get_result
    end

    # "TrueGuiInterface" stuff... well it used to be
    def display_list_dialog(list, prompt_key)
        @logger.debug "GameGui::display_list_dialog called with prompt_key: '#{prompt_key}'"
        @list_dialog.set_options(list)
        @list_dialog.set_prompt prompt_key
        @list_dialog.reset_result
        @list_dialog.show
    end

    private
    def setup_cached_player
        @current_player_future = @new_game_driver.async.active_player
        @current_player_future.add_observer do |time, value|
            @logger.debug "Here is the time #{time}"
            @logger.debug "Here is the value #{value}"
            @current_cached_player = value
            @player_changed = true
            @redraw_hand = true
        end
    end

end