require 'gosu'
require './gui_elements/button.rb'
require './gui_elements/game_stats.rb'
require './gui_elements/dialog.rb'
require './game.rb'
require './gui_input_manager.rb'

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
        @current_dialog_lock = Concurrent::ReadWriteLock.new
        @timer_set = Concurrent::TimerSet.new
    end

    def button_up(id)
        if @left_click_down
            puts "left button released"
            @left_click_down = false

            @current_dialog_lock.with_write_lock do
                if @current_dialog != nil && @current_dialog.is_visible?
                    if @current_dialog.handle_result
                        @current_dialog.hide
                    end
                end
            end
            if @are_you_sure_dialog.is_visible?
                @are_you_sure_dialog.handle_result do |clicked|
                    if clicked == :yes_clicked
                        puts "I am starting a game then"
                        @game = Game.new(3, @logger, GuiInputManager.new(self))
                        @game_driver = GameDriver.new(@game, @logger)
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
                    activePlayer = @game_driver.await.active_player.value

                    cardToPlay = activePlayer.remove_card_from_hand(clickedCard)
                    puts "you clicked a card button #{cardToPlay}"

                    @game_driver.async.post_card_play_clean_up(activePlayer, cardToPlay)

                    # @redraw_hand = true

                    # if @game_driver.turn_over?
                    #     @game_driver.end_turn_cleanup
                    #     @player_changed = true
                    # end
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
        @current_dialog_lock.with_read_lock do
            if @current_dialog != nil
                @current_dialog.draw
            end
        end
        if !@game_driver
        # for main menu
            @new_game_button.draw
        else
            @new_game_button.set_visibility(false)
            @are_you_sure_dialog.hide
            @game_stats.draw(@game)

            activePlayer = @game_driver.await.active_player.value
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

    # "TrueGuiInterface" stuff
    def select_a_card(card_list, prompt="Select a card", &block)
        puts "does this even get called?"
        @current_dialog_lock.with_write_lock do
            @logger.debug "inside lock..."
            @current_dialog.set_cards(card_list)
            @logger.debug "set cards"
            response = IVar.new()
            @logger.debug "create ivar"
            @current_dialog.set_response(response)
            @logger.debug "set response"
            @current_dialog.set_selection_callback(&block)
            @logger.debug "set selection call back"
            @current_dialog.show
            @logger.debug "call show"
        end
        @logger.debug "dialog showed...?"
        response.value
        # found_result = nil
        # current_task = nil
        # sleep 10
        # while !found_result
        #     if !current_task || (current_task && current_task.state == :fulfilled)
        #         current_task = @timer_set.post(100) do
        #             puts "stuck in a loop"
        #             found_result = @current_dialog.get_result
        #         end
        #     end
        # end
        # @current_dialog_lock.with_write_lock do
        #     found_result = @current_dialog.reset_result
        # end
    end

end