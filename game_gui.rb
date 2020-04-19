require 'gosu'
require './gui_elements/button.rb'

class GameGui < Gosu::Window
    def initialize
        super 640, 480
        self.caption = "Fluxx"

        @bakground_image = Gosu::Image.new("assets/onlinePurpleSquare.jpg", tileable: true)
        @cursor = Gosu::Image.new("assets/onlineCursor2.png")
        @font = Gosu::Font.new(20)

        @left_click_down = false
        @new_game_button = Button.new(self, "New Game?")
    end

    def button_up(id)
        if @left_click_down
            puts "left button released"
            @left_click_down = false
            if @new_game_button.is_clicked?
                puts "I am starting a game then"
                # Start a game
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

        @new_game_button.draw
    end

end

GameGui.new.show