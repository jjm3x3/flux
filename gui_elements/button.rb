class Button
    attr_reader :id
    def initialize(window, font, text, x, y, z, options={}, image=nil, id=0)
        @window = window
        @text = text
        @x = x
        @y = y
        @z = z
        @font = font
        @image = image
        @id = id
        @visible = true
        @is_pressed = options[:is_pressed]
        @pressed_color = options[:pressed_color]
        @unpressed_color = options[:unpressed_color]
    end

    def draw
        left_click_down = @is_pressed.call

        textcolor = left_click_down && intersects ? @pressed_color : @unpressed_color
        if @image
            @image.draw(@x , @y, @z, 1, 1, textcolor)
        else
            @font.draw_text(@text, @x , @y, @z , 1.0, 1.0, textcolor)
        end
    end

    def is_clicked?
        result = intersects && @visible
        return result
    end

    def set_visibility(is_visible)
        @visible = is_visible
    end

    def set_position(x, y)
        @x = x
        @y = y
    end

    def height
        if @image
            @image.height
        else
            @font.height
        end
    end

    private
    def intersects
        x_max = 0
        y_max = 0
        if @image
            x_max = @image.width
            y_max = @image.height
        else
            x_max = @font.text_width(@text)
            y_max = @font.height
        end
        mouse_past_left = @window.mouse_x > @x
        mouse_past_right = @window.mouse_x >= @x + x_max
        mouse_below_top = @window.mouse_y > @y
        mouse_above_bottom = @window.mouse_y < @y + y_max
        mouse_past_left && !mouse_past_right && mouse_below_top && mouse_above_bottom
    end
end
