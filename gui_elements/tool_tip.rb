class ToolTip
    def initialize(window, image)
        @window = window
        @image = image
    end

    def draw
        my_green = Gosu::Color.new(255, 53, 112, 53)
        Gosu::draw_rect(@window.mouse_x, @window.mouse_y - (@image.height + 6), @image.width + 6, @image.height + 6, my_green, ZOrder::DIALOG)
        @image.draw(@window.mouse_x + 6, (@window.mouse_y - @image.height) - 3, ZOrder::DIALOG_ITEMS)
    end

end
