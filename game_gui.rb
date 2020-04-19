require 'gosu'
require './gui_elements/button.rb'
require './game.rb'

class GameGui < Gosu::Window
    def initialize
        super 640, 480
        self.caption = "Fluxx"

        @bakground_image = Gosu::Image.new("assets/onlinePurpleSquare.jpg", tileable: true)
        @cursor = Gosu::Image.new("assets/onlineCursor2.png")
        @font = Gosu::Font.new(20)

        @left_click_down = false
        @new_game_button = Button.new(self, "New Game?")
        @game = nil
    end

    def button_up(id)
        if @left_click_down
            puts "left button released"
            @left_click_down = false
            if @new_game_button.is_clicked?
                puts "I am starting a game then"
                @game = Game.new(3, CliInterface.new(true))
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

        if !@game
        # for main menu
            @new_game_button.draw
        else
            @font.draw_text("The deck has #{@game.deck.count} cards in it", 10, 10, 1, 1.0, 1.0, Gosu::Color::WHITE)
            @font.draw_text("The discard pile has #{@game.discardPile.size} cards in it", 10, 10*2 + 20, 1, 1.0, 1.0, Gosu::Color::WHITE)
            @font.draw_text("The Current rules are: #{@game.ruleBase}", 10, 10*3 + 20 *2, 1, 1.0, 1.0, Gosu::Color::WHITE)

            activePlayer = @game.players[@game.currentPlayer]
            @font.draw_text("It is player #{activePlayer}'s turn'", 10, 10*4 + 20 *7, 1, 1.0, 1.0, Gosu::Color::WHITE)

            cardsDisplayed = 0
            displayedCards = []
            activePlayer.hand.each do |card|
                newCardButton = Button.new(self, "#{card}")
                newCardButton.draw
                displayedCards <<
                cardsDisplayed += 1
            end
        end
    end

end

GameGui.new.show