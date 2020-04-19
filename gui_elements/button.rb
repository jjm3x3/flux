class Button
    def initialize(window, text, x, y)
        @window = window
        @text = text
        @x = x
        @y = y
        @font = Gosu::Font.new(20)
    end

    def draw
        left_click_down = Gosu.button_down? Gosu::MS_LEFT

        textcolor = left_click_down && intersects ? Gosu::Color::BLACK : Gosu::Color::WHITE
        @font.draw_text(@text, @x , @y, 1 , 1.0, 1.0, textcolor)
    end

    def is_clicked?
        intersects
    end

    private
    def intersects
        @window.mouse_x > @x && @window.mouse_x < @x + @font.text_width(@text) && @window.mouse_y > @y && @window.mouse_y < @y + @font.height
    end
end