class Button
    def initialize(window, font, text, x, y, z, options={})
        @window = window
        @text = text
        @x = x
        @y = y
        @z = z
        @font = font
        @visible = true
        @is_pressed = options[:is_pressed]
        @pressed_color = options[:pressed_color]
        @unpressed_color = options[:unpressed_color]
    end

    def draw
        left_click_down = @is_pressed.call

        textcolor = left_click_down && intersects ? @pressed_color : @unpressed_color
        @font.draw_text(@text, @x , @y, @z , 1.0, 1.0, textcolor)
    end

    def is_clicked?
        intersects && @visible
    end

    def set_visibility(is_visible)
        @visible = is_visible
    end

    private
    def intersects
        @window.mouse_x > @x && @window.mouse_x < @x + @font.text_width(@text) && @window.mouse_y > @y && @window.mouse_y < @y + @font.height
    end
end