require "./gui_elements/zorder.rb"

class Dialog
    def initialize(window)
        @visible = false
        @baground_image = Gosu::Image.new("assets/onlineGreenSquare2.png", tileable: true)
        @font = Gosu::Font.new(20)
        @yes_button = Button.new(window, "Yes", 120, 120, ZOrder::DIALOG_ITEMS)
        widthOfYesButtonGuess = 30
        spaceBetweenButtonts = 40
        @no_button = Button.new(window, "No", 120 + widthOfYesButtonGuess + spaceBetweenButtonts, 120, ZOrder::DIALOG_ITEMS  )
    end

    def draw
        if @visible
            @baground_image.draw(100, 100, ZOrder::DIALOG, 0.25, 0.25)
            @yes_button.set_visibility true
            @no_button.set_visibility true
            @yes_button.draw
            @no_button.draw
        end
    end

    def show
        @visible = true
        @yes_button.set_visibility true
        @no_button.set_visibility true
    end

    def hide
        @visible = false
        @yes_button.set_visibility false
        @no_button.set_visibility false
    end

    def is_visible?
        @visible
    end

    def handle_result
        if @yes_button.is_clicked?
            yield(:yes_clicked)
        elsif @no_button.is_clicked?
            yield(:no_clicked)
        else
            yield(:nothing_clicked)
        end
    end

end