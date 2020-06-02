require 'concurrent'

class GuiInputManager
    include Concurrent::Async

    def initialize(gui)
        super()
        @gui = gui
        @sleep_amount = 0.125
    end

    def choose_from_list(list, prompt)
        @gui.display_list_dialog(list, prompt)

        dialog_result = nil
        while !dialog_result
            sleep @sleep_amount
            dialog_result = @gui.get_dialog_result
        end
        list.delete(dialog_result)
        return dialog_result
    end

    def ask_yes_no(prompt)
        yes_string = "Yes"
        @gui.display_list_dialog([yes_string, "No"], prompt)
        dialog_result = nil
        while !dialog_result
            sleep @sleep_amount
            dialog_result = @gui.get_dialog_result
        end
        return dialog_result == yes_string
    end

    def ask_rotation(prompt)
        clockwise_string = "Clockwise"
        @gui.display_list_dialog([clockwise_string, "Counter Clockwise"], prompt)

        dialog_result = nil
        while !dialog_result
            sleep @sleep_amount
            dialog_result = @gui.get_dialog_result
        end

        return dialog_result == clockwise_string ? Direction::Clockwise : Direction::CounterClockwise
    end
end