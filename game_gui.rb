require 'gosu'
require './gui_elements/button.rb'
require './gui_elements/game_stats.rb'
require './gui_elements/dialog.rb'
require './game.rb'
require './gui_input_manager.rb'
require './new_game_driver.rb'

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
                end
            end
            if @are_you_sure_dialog.is_visible?
                @are_you_sure_dialog.handle_result do |clicked|
                    if clicked == :yes_clicked
                        puts "I am starting a game then"
                        @game = Game.new(3, @logger, GuiInputManager.new(self))
                        @new_game_driver = NewGameDriver.new(@game, @logger)
                        @game_driver = GameDriver.new(@game, @logger)
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
            end
            clickedCard = 0
            @current_displayed_cards.each do |cardButton|
                if cardButton.is_clicked?
                    activePlayer = @new_game_driver.await.active_player.value

                    cardToPlay = activePlayer.remove_card_from_hand(clickedCard)
                    puts "you clicked a card button #{cardToPlay}"

                    @play_card_future = @new_game_driver.async.post_card_play_clean_up(activePlayer, cardToPlay)
                    @play_card_future.add_observer do |time, value|
                        @logger.debug "Executing play_card_future observer"
                        is_turn_over = @new_game_driver.await.turn_over?
                        @logger.debug "What is the this #{is_turn_over}"
                        @logger.debug "What is its state this #{is_turn_over.state}"

                        @logger.debug "Is the turn over?"
                        if is_turn_over.value
                            @game_driver.end_turn_cleanup
                            @player_changed = true
                            setup_cached_player
                        end
                    end
                    # @game_driver.async.post_card_play_clean_up(activePlayer, cardToPlay)

                    @redraw_hand = true

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
                    @game_driver.await.setup_new_turn
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

    # "TrueGuiInterface" stuff
    def select_a_card(card_list, prompt="Select a card", &block)
        puts "does this even get called?"
        @current_dialog.set_cards(card_list)
        @current_dialog.set_selection_callback(&block)
        @current_dialog.show
    end

    private
    def setup_cached_player
        @current_player_future = @new_game_driver.async.active_player
        @current_player_future.add_observer do |time, value|
            @logger.debug "Here is the time #{time}"
            @logger.debug "Here is the value #{value}"
            @current_cached_player = value
        end
    end

end