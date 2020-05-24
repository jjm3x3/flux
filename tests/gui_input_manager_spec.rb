require "./cards/cards.rb"
require "./gui_input_manager.rb"

require "pry-byebug"

describe "gui_input_manager" do

    describe "select_a_card" do
        it "works?" do
            # debugger
            guiDouble = double("gui")
            sut = GuiInputManager.new(guiDouble)

            aSingleCard = Card.new
            puts "What is this: '#{aSingleCard}'"
            select_result = sut.await.select_a_card([aSingleCard], "prompt for a test")
            # select_result = sut.select_a_card([Card.new], "prompt for a test")

            # binding.pry
            puts "Here is the raw result: '#{select_result}''"
            puts "Here is the state  '#{select_result.state}'"
            if select_result.state == :rejected
                puts "For reason '#{select_result.reason}'"
            end
            puts "Here is the result '#{select_result.value}'"
            expect(select_result).not_to be nil
        end
    end

end