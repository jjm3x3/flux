class GuiUtil
    def self.generate_simple_color_tile(color)
        Gosu::record(1, 1) do
            new_color = Gosu::Color.new(color)
            Gosu::draw_rect(0,0, 1, 1, new_color, ZOrder::BAKGROUND)
        end
    end
end