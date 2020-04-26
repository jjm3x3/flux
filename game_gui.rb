require 'gosu'
require './gui_elements/button.rb'
require './gui_elements/game_stats.rb'
require './gui_elements/dialog.rb'
require './game.rb'

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
        @current_dialog = nil
    end

    def button_up(id)
        if @left_click_down
            puts "left button released"
            @left_click_down = false
            if @current_dialog != nil && @current_dialog.is_visible?
                if @current_dialog.handle_result
                    @current_dialog = nil
                end
            end
            if @are_you_sure_dialog.is_visible?
                @are_you_sure_dialog.handle_result do |clicked|
                    if clicked == :yes_clicked
                        puts "I am starting a game then"
                        @game = Game.new(3, @logger, self)
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
                    activePlayer = @game_driver.active_player

                    cardToPlay = activePlayer.remove_card_from_hand(clickedCard)
                    puts "you clicked a card button #{cardToPlay}"

                    @game_driver.post_card_play_clean_up(activePlayer, cardToPlay)

                    @redraw_hand = true

                    if @game_driver.turn_over?
                        @game_driver.end_turn_cleanup
                        @player_changed = true
                    end
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
        if !@game_driver
        # for main menu
            @new_game_button.draw
        else
            @new_game_button.set_visibility(false)
            @are_you_sure_dialog.hide
            @game_stats.draw(@game)

            activePlayer = @game_driver.active_player
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
                    @game_driver.setup_new_turn
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
        @current_dialog = CardDialog.new(self, card_list, &block)
        @current_dialog.show
    end

end