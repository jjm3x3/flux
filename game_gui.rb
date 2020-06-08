require 'gosu'
require './gui_elements/button.rb'
require './gui_elements/game_stats.rb'
require './gui_elements/dialog.rb'
require './game.rb'
require './gui_input_manager.rb'
require './game_driver.rb'

class GameGui < Gosu::Window
    def initialize(logger)
        super 640, 960
        self.caption = "Fluxx"

        @bakground_image = Gosu::Image.new("assets/onlinePurpleSquare.jpg", tileable: true)
        @font = Gosu::Font.new(20)

        @left_click_down = false
        @new_game_button = Button.new(self, "New Game?", 10, 10, ZOrder::GAME_ITEMS)
        @game_stats = GameStats.new(10, 10)
        @game = nil
        @current_displayed_cards = []

        @player_changed = true
        @redraw_hand = true

        @logger = logger

        @are_you_sure_dialog = Dialog.new(self)
        @current_dialog = CardDialog.new(self)
        @new_game_driver = nil

        @current_cached_player = nil
        @current_player_future = nil

        @play_card_future = nil
    end

    def button_up(id)
        if @left_click_down
            puts "left button released"
            @left_click_down = false
            if @current_dialog != nil && @current_dialog.is_visible?
                if @current_dialog.handle_result
                    @current_dialog.hide
                    return
                end
            end
            if @are_you_sure_dialog.is_visible?
                @are_you_sure_dialog.handle_result do |clicked|
                    if clicked == :yes_clicked
                        puts "I am starting a game then"
                        numberOfPlayers = 3
                        players = []
                        (1..numberOfPlayers).select do |playerId|
                            players << Player.new("player" + playerId.to_s)
                        end
                        @game = Game.new(3, @logger, GuiInputManager.new(self), players)
                        @new_game_driver = GameDriver.new(@game, @logger)
                        @current_cached_player = @new_game_driver.await.active_player.value
                    elsif clicked == :no_clicked
                        puts "no selected"
                    else
                        puts "nothing selected"
                    end
                end
                return
            end
            if @new_game_button.is_clicked?
                @are_you_sure_dialog.show
                return
            end
            clickedCard = 0
            @current_displayed_cards.each do |cardButton|
                if cardButton.is_clicked?
                    activePlayer = @new_game_driver.await.active_player.value

                    cardToPlay = activePlayer.remove_card_from_hand(clickedCard)
                    puts "you clicked a card button #{cardToPlay}"

                    @play_card_future = @new_game_driver.async.post_card_play_clean_up(activePlayer, cardToPlay)
                    @play_card_future.add_observer do |time, value|
                        if value # this means the turn is over
                            @player_changed = true
                            setup_cached_player
                        end
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
            puts "left button click"
            @left_click_down = true

        end
    end

    def needs_cursor?
        true
    end

    def draw
        @bakground_image.draw(0,0,0)

        @are_you_sure_dialog.draw
        if @current_dialog != nil
            @current_dialog.draw
        end
        if !@new_game_driver
        # for main menu
            @new_game_button.draw
        else
            @new_game_button.set_visibility(false)
            @are_you_sure_dialog.hide
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
                    newCardButton = Button.new(self, "#{card}", 20, (permanents_start_y + permanents_height + 10 + @font.height) + 10 * cardsDisplayed + @font.height * cardsDisplayed, ZOrder::GAME_ITEMS)
                    newCardButton.draw
                    @current_displayed_cards << newCardButton
                    cardsDisplayed += 1
                end

                @redraw_hand = false

                if @player_changed
                    # TODO:: Make sure not to await anything here
                    #
                    #       after thinking more about this we can repro a bug
                    #       by making sure the first player starts the game with
                    #       two creepeprs one of them death
                    #
                    @new_game_driver.await.setup_new_turn
                    @redraw_hand = true

                    @player_changed = false
                end
            else
                @current_displayed_cards.each do |cardButton|
                    cardButton.draw
                end
            end
        end
    end

    def get_dialog_result
        @current_dialog.get_result
    end

    # "TrueGuiInterface" stuff... well it used to be
    def display_list_dialog(list, prompt="Select an option")
        @logger.debug "does this even get called?"
        @current_dialog.set_prompt prompt
        @current_dialog.reset_result
        @current_dialog.set_cards(list)
        @current_dialog.show
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