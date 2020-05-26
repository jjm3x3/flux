require 'concurrent'

class GuiInputManager
    include Concurrent::Async

    def initialize(gui)
        super()
        @gui = gui
    end

    def select_a_card(card_list, prompt)
        # @input_manager_log = File.open("input_manager.log", "a")
        puts "goint to display a card selection dialog"
        # @input_manager_log.puts "goint to display a card selection dialog"
        @gui.select_a_card(card_list, prompt)
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
            sleep 0.5
            # @input_manager_log.puts "checking dialog_result at #{Time.now}"
            # @input_manager_log.flush
            dialog_result = @gui.get_dialog_result
            # @input_manager_log.puts "What is the value of #{dialog_result}"
            # @input_manager_log.flush
        end
        # @input_manager_log.puts "What is the dialog_result: '#{dialog_result}''"
        # @input_manager_log.flush
        return dialog_result
    end
end