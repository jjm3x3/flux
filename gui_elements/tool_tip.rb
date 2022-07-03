class ToolTip
    def initialize(window, image)
        @window = window
        @image = image
    end

    def draw

        if @prevous_x == @window.mouse_x && @prevous_y == @window.mouse_y 
            if !@timer_start
                @timer_start = Time.now
            else
                diff = Time.now - @timer_start
                if diff > 1
                    my_green = Gosu::Color.new(255,0, 128, 0)
                    Gosu::draw_rect(@window.mouse_x, @window.mouse_y - (@image.height + 6), @image.width + 6, @image.height + 6, my_green, ZOrder::DIALOG)
                    @image.draw(@window.mouse_x + 3, (@window.mouse_y - @image.height) - 3, ZOrder::DIALOG_ITEMS)
                end
            end
        else
            @timer_start = nil
        end
        @prevous_x = @window.mouse_x
        @prevous_y = @window.mouse_y
    end

end
