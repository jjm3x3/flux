require 'gosu'

class GameGui < Gosu::Window
    def initialize
        super 640, 480
        self.caption = "Fluxx"

        @bakground_image = Gosu::Image.new("assets/onlinePurpleSquare.jpg", tileable: true)
        @cursor = Gosu::Image.new("assets/onlineCursor2.png")
        @font = Gosu::Font.new(20)

        @left_click_down = false
    end

    def button_up(id)
        if @left_click_down
            puts "left button released"
            @left_click_down = false
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

        textcolor = @left_click_down && intersects ? Gosu::Color::BLACK : Gosu::Color::WHITE
        @font.draw_text("Here is some text", 10,10, 1 , 1.0, 1.0, textcolor)
    end

    private
    def intersects
        text_height = 10
        mouse_x > 10 && mouse_x < 10 + @font.text_width("Here is some text") && mouse_y > 10 && mouse_y < 10 + @font.height
    end
end

GameGui.new.show