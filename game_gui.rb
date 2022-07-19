require 'gosu'
require './gui_elements/button.rb'
require './gui_elements/game_stats.rb'
require './gui_elements/dialog.rb'
require './gui_elements/player_permanents.rb'
require './game.rb'
require './gui_input_manager.rb'
require './game_driver.rb'
require './state/game_state.rb'

class GameGui < Gosu::Window
    def initialize(logger, prompt_strings, user_prompt_templates, deck)
        super 1200, 900
        self.caption = "Fluxx"

        @game_background = Gosu::record(10, 10) do
            my_purple = Gosu::Color.new(255, 120, 40, 139)
            Gosu::draw_rect(0,0, 10, 10, my_purple, ZOrder::BAKGROUND)
        end
        @font = Gosu::Font.new(20)

        @left_click_down = false
        @button_options = {pressed_color: Gosu::Color::BLACK, unpressed_color: Gosu::Color::WHITE, is_pressed: method(:is_left_button_pressed)}
        @new_game_button = Button.new(self, Gosu::Image.from_text("New Game?", 20), 10, 10, ZOrder::GAME_ITEMS, @button_options)
        @game_stats = GameStats.new(400, 10)
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

        @button_images = {
            "Yes" => Gosu::Image.from_text("Yes", 20),
            "No" => Gosu::Image.from_text("No", 20),
            "Clockwise" => Gosu::Image.from_text("Clockwise", 20),
            "Counter Clockwise" => Gosu::Image.from_text("Counter Clockwise", 20),
            "Back to Main Menu" => Gosu::Image.from_text("Back to Main Menu", 20),
            "no_one" => Gosu::Image.from_text("No One", 20),
        }

        @simple_dialog.set_options(SimpleDialog.generate_dialog_options(["Yes", "No"], @button_images))
        @simple_dialog.set_prompt :play_a_game_prompt

        @list_dialog = CardDialog.new(
            self,
            dialog_background,
            Gosu::Font.new(20),
            logger,
            dialog_prompts,
            @button_options)

        @current_players_permanents = PlayerPermanents.new(@font)

        @user_prompt_templates = user_prompt_templates
        @deck = deck

        @game_state = GameState.new(deck.count)
        @button_images = @button_images.merge(create_card_images(@deck))

        @new_game_driver = nil

        @play_card_future = nil
    end

    def create_card_images(deck)
        result = {}
        deck.each do |card|
            result[card.name] = Gosu::Image.from_text(card.name.to_s, 20)
        end

        return result
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
        players.each do |player|
            @button_images[player.name] = Gosu::Image.from_text(player.name, 20)
        end
        PlayerPromptGenerator.generate_prompts(players, @user_prompt_templates).each do |key, prompt|
            # TODO:: should check to make sure @list_dialog exists
            @list_dialog.add_prompt(key, Gosu::Image.from_text(prompt, 20))
        end
        game = Game.new(@logger, GuiInputManager.new(self), players, @deck)
        game.setup
        @new_game_driver = GameDriver.new(game, @logger)
        game_state_result = @new_game_driver.await.get_game_state
        if game_state_result.state != :fulfilled
            @logger.warn "GameGui::start_a_new_game: Was not able to initialize game_state because #{game_state_result.reason}"
        end
        @game_state = game_state_result.value
        @logger.debug "GameGui::start_a_new_game: New game started"
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
                    @logger.debug "Getting card from players hand"
                    card_selected_future = @new_game_driver.async.remove_card_from_active_player(clickedCard)
                    card_selected_future.add_observer(self, :update_after_card_selected)
                    return
                end
                clickedCard += 1
            end
        end
    end

    def update_after_card_selected(time, value, reason)
        # value is the selected card to play
        @logger.info "GameGui::update: you clicked a card button #{value}"
        @play_card_future = @new_game_driver.async.play_card(value)
        @play_card_future.add_observer(self, :update_after_play)
    end

    def update_after_play(time, value, reason)
        @logger.debug "GameGui::update_after_play: Starting to execute"
        @card_played = true
        update_game_state
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
            # NOTE:: We are trying to minimize the number of times we make calls
            #        to the driver so we have a system of boolean flags so that
            #        it will only fire off a call to the driver when it makes
            #        sense to do so.
            if @card_played
                @logger.debug "GameGui::update: Card has been played, update accordingly"
                @card_played = false
                game_has_winner_future = @new_game_driver.async.has_winner
                game_has_winner_future.add_observer do |time, value|
                    if value
                        # win flow
                        dialog_options = SimpleDialog.generate_dialog_options(["Back to Main Menu"], @button_images)
                        @simple_dialog.set_options(dialog_options)
                        @simple_dialog.set_prompt(:exit)
                        @simple_dialog.show
                    else
                        clean_up_future = @new_game_driver.async.post_card_play_clean_up
                        clean_up_future.add_observer do |time, value|
                            if value # this means the turn is over
                                @player_changed = true
                            end
                            update_game_state
                        end
                    end
                end

            elsif @player_changed
                @logger.debug "GameGui::update Player has changed setting up new turn"
                @player_changed = false
                new_turn_future = @new_game_driver.async.setup_new_turn
                new_turn_future.add_observer do |time, value|
                    update_game_state
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
        @game_stats.draw(@game_state)

        @font.draw_text("It is player #{@game_state.active_player.name}'s turn", 400, 500, 1, 1.0, 1.0, Gosu::Color::WHITE)

        @current_players_permanents.draw(@game_state.active_player, 400, 575)

        # draw hand
        y_start = 700  # this should really be a function of the permanents
        @font.draw_text("Pick a card to play:", 400 , y_start, 1, 1.0, 1.0, Gosu::Color::WHITE)

        if @redraw_hand

            cardsDisplayed = 0
            @current_displayed_cards = []
            hand_x = 0
            left_shift = (@game_state.active_player.cards_in_hand.count / 5) * 40
            hand_x = 420 - left_shift
            @game_state.active_player.cards_in_hand.each do |card|
                if cardsDisplayed >= 5
                    cardsDisplayed = 0
                    hand_x += 185
                end
                newCardButton = Button.new(self,
                    Gosu::Image.from_text("#{card}", 20),
                    hand_x,
                    (730) + 10 * cardsDisplayed + @font.height * cardsDisplayed,
                    ZOrder::GAME_ITEMS,
                    @button_options)
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
        dialog_options = SimpleDialog.generate_dialog_options(list, @button_images)
        @list_dialog.set_options(dialog_options)
        @list_dialog.set_prompt prompt_key
        @list_dialog.reset_result
        @list_dialog.show
    end

    private
    def update_game_state
        game_state_future = @new_game_driver.async.get_game_state
        game_state_future.add_observer do |time, value|
            @game_state = value
            @redraw_hand = true
        end
    end

end
