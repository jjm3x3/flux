require 'gosu'

class GameGui < Gosu::Window
    def initialize
        super 640, 480
        self.caption = "Fluxx"

        @bakground_image = Gosu::Image.new("assets/onlinePurpleSquare.jpg", tileable: true)
        @font = Gosu::Font.new(20)
    end

    def update

    end

    def draw
        @bakground_image.draw(0,0,0)
        @font.draw_text("Here is some text", 10,10, 1 , 1.0, 1.0, Gosu::Color::WHITE)
    end
end

GameGui.new.show