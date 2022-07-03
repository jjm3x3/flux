class Button
    attr_reader :id
    def initialize(window, image, x, y, z, options={}, id=0)
        @window = window
        @image = image
        @x = x
        @y = y
        @z = z
        @id = id
        @visible = true
        @is_pressed = options[:is_pressed]
        @text_color = options[:text_color]
        @unpressed_background_image = options[:unpressed_background_image]
        @pressed_background_image = options[:pressed_background_image]
        @tool_tip = options[:tool_tip]
        @height = @image.height + 6
        @width = @image.width + 6
    end

    def draw
        left_click_down = @is_pressed.call

        if @pressed_background_image && @unpressed_background_image
            button_image = left_click_down && intersects ? @pressed_background_image : @unpressed_background_image
            x_scale = @width/button_image.width
            y_scale = @height/button_image.height
            button_image.draw(@x, @y, @z, x_scale, y_scale)
        end
        @image.draw(@x + 3, @y + 3, @z, 1, 1, @text_color)
        if intersects && @tool_tip
            @tool_tip.draw
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
        x_max = @width
        y_max = @height
        mouse_past_left = @window.mouse_x > @x
        mouse_past_right = @window.mouse_x >= @x + x_max
        mouse_below_top = @window.mouse_y > @y
        mouse_above_bottom = @window.mouse_y < @y + y_max
        mouse_past_left && !mouse_past_right && mouse_below_top && mouse_above_bottom
    end
end
