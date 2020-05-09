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
    end
end