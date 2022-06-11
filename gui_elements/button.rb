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
        @pressed_color = options[:pressed_color]
        @unpressed_color = options[:unpressed_color]
        @height = @image.height + 6
        @width = @image.width + 6
    end

    def draw
        left_click_down = @is_pressed.call

        textcolor = left_click_down && intersects ? @pressed_color : @unpressed_color
        @image.draw(@x + 3, @y + 3, @z, 1, 1, textcolor)
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
