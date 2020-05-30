require 'concurrent'

class GuiInputManager
    include Concurrent::Async

    def initialize(gui)
        super()
        @gui = gui
        @sleep_amount = 0.125
    end

    def choose_from_list(list, prompt)
        # @input_manager_log = File.open("input_manager.log", "a")
        puts "goint to display a card selection dialog"
        # @input_manager_log.puts "goint to display a card selection dialog"
        @gui.display_list_dialog(list, prompt)
        puts "after dialog displayed"
        # @input_manager_log.puts "after dialog displayed"
        # @input_manager_log.flush
        dialog_result = nil
        puts "going into wait loop"
        # @input_manager_log.puts "going into wait loop"
        # @input_manager_log.puts "what is the dialog results '#{dialog_result}'"
        # @input_manager_log.puts "what is the condition used for the loop '#{!dialog_result}'"
        # @input_manager_log.flush
        while !dialog_result
            # @input_manager_log.puts "Going to sleep since nothing is selected at #{Time.now}"
            # @input_manager_log.flush
            sleep @sleep_amount
            # @input_manager_log.puts "checking dialog_result at #{Time.now}"
            # @input_manager_log.flush
            dialog_result = @gui.get_dialog_result
            # @input_manager_log.puts "What is the value of #{dialog_result}"
            # @input_manager_log.flush
        end
        # @input_manager_log.puts "What is the dialog_result: '#{dialog_result}''"
        # @input_manager_log.flush
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