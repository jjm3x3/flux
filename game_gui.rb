require 'gosu'
require './gui_elements/button.rb'
require './gui_elements/game_stats.rb'
require './game.rb'

class GameGui < Gosu::Window
    def initialize(logger)
        super 640, 960
        self.caption = "Fluxx"

        @bakground_image = Gosu::Image.new("assets/onlinePurpleSquare.jpg", tileable: true)
        @cursor = Gosu::Image.new("assets/onlineCursor2.png")
        @font = Gosu::Font.new(20)

        @left_click_down = false
        @new_game_button = Button.new(self, "New Game?", 10, 10)
        @game_stats = GameStats.new(10, 10)
        @game = nil
        @current_displayed_cards = []

        @player_changed = true
        @redraw_hand = true

        @logger = logger
    end

    def button_up(id)
        if @left_click_down
            puts "left button released"
            @left_click_down = false
            if @new_game_button.is_clicked?
                puts "I am starting a game then"
                @game = Game.new(3, @logger)
                @game_driver = GameDriver.new(@game, @logger)
            end
            clickedCard = 0
            @current_displayed_cards.each do |cardButton|
                if cardButton.is_clicked?
                    activePlayer = @game_driver.active_player

                    cardToPlay = activePlayer.remove_card_from_hand(clickedCard)
                    puts "you clicked a card button #{cardToPlay}"

                    @game_driver.post_card_play_clean_up(activePlayer, cardToPlay)

                    @redraw_hand = true

                    if @game_driver.ready_to_progress
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

    def draw
        @bakground_image.draw(0,0,0)
        @cursor.draw(mouse_x, mouse_y, 2, 0.0078125, 0.0078125)

        if !@game_driver
        # for main menu
            @new_game_button.draw
        else
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
                    newCardButton = Button.new(self, "#{card}", 20, (permanents_start_y + permanents_height + 10 + @font.height) + 10 * cardsDisplayed + @font.height * cardsDisplayed)
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

end