class GuiUtil
    def self.generate_simple_color_tile(color)
        Gosu::record(1, 1) do
            new_color = Gosu::Color.new(color)
            Gosu::draw_rect(0,0, 1, 1, new_color, ZOrder::BAKGROUND)
        end
    end

    def self.get_text_image(text, font)
        lines = []
        lines_by_newline = text.split("\n")
        current_line = ""
        line_length = 30
        lines_by_newline.each do |line|
            if line.size > line_length
                words = line.split(" ")
                words.each do |word|
                    if current_line.size + 1 + word.size > line_length
                        lines << current_line
                        current_line = word + " "
                    else
                        current_line += word + " "
                    end
                end
            else
                lines << line
            end
        end
        lines << current_line
        width = font.text_width("x"*line_length)
        height = (font.height + 5) * lines.size
        text_image = Gosu::record(width.to_i, height) do
            my_green = Gosu::Color.new(0xFF357035)
            Gosu::draw_rect(0, 0, width + 6, height + 6, my_green, ZOrder::DIALOG)
            line_count = 0
            lines.each do |line|
                font.draw_text(line, 3, line_count * (font.height + 5) + 3, ZOrder::DIALOG_ITEMS, 1.0, 1.0, Gosu::Color::WHITE)
                line_count += 1
            end
        end
        return text_image
    end
end
