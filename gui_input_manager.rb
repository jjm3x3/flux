require 'concurrent'

class GuiInputManager
    include Concurrent::Async

    def initialize(gui)
        super()
        @gui = gui
    end

    def select_a_card(card_list, prompt)
        puts "goint to display a card selection dialog"
        @gui.select_a_card(card_list, prompt)
        puts "after dialog displayed"
        dialog_result = nil
        puts "going into wait loop"
        while !dialog_result
            sleep 0.5
            dialog_result = @gui.get_dialog_result
        end
        return dialog_result
    end
end