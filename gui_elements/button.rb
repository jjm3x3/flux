class Button
    def initialize(window, font, text, x, y, z, options={})
        @window = window
        @text = text
        @x = x
        @y = y
        @z = z
        @font = font
        @visible = true
        puts "options for button: '#{text}' is: '#{options}'"
        @is_pressed = nil
        @pressed_color = nil
        @unpressed_color = nil
        if options
            puts "options being intialized"
            @is_pressed = options[:is_pressed]
            @pressed_color = options[:pressed_color]
            @unpressed_color = options[:unpressed_color]
        end
        puts "in ctor pressed_color is: '#{@pressed_color}' unpressed_color is: '#{@unpressed_color}'"
    end

    def draw
        puts "drawing #{@text}"
        left_click_down = @is_pressed.call

        puts "pressed_color is: '#{@pressed_color}' unpressed_color is: '#{@unpressed_color}'"
        textcolor = left_click_down && intersects ? @pressed_color : @unpressed_color
        puts "textcolor is: '#{textcolor}'"
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