require "./gui_elements/zorder.rb"

class Dialog
    def initialize
        @visible = true
        @baground_image = Gosu::Image.new("assets/onlineGreenSquare2.png", tileable: true)
    end

    def draw
        if @visible
            @baground_image.draw(100, 100, 2, 0.25, 0.25)
        end
    end

end