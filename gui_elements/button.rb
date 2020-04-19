class Button
    def initialize(window, text)
        @window = window
        @font = Gosu::Font.new(20)
        @text = text
    end

    def draw
        left_click_down = Gosu.button_down? Gosu::MS_LEFT

        textcolor = left_click_down && intersects ? Gosu::Color::BLACK : Gosu::Color::WHITE
        @font.draw_text(@text, 10,10, 1 , 1.0, 1.0, textcolor)
    end

    def is_clicked?
        intersects
    end

    private
    def intersects
        text_height = 10
        @window.mouse_x > 10 && @window.mouse_x < 10 + @font.text_width(@text) && @window.mouse_y > 10 && @window.mouse_y < 10 + @font.height
    end
end