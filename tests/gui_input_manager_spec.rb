require "./cards/cards.rb"
require "./gui_input_manager.rb"

describe "gui_input_manager" do

    describe "select_a_card" do
        it "works?" do
            testCard = Card.new
            guiDouble = double("gui", :select_a_card => nil, :get_dialog_result => testCard)
            sut = GuiInputManager.new(guiDouble)

            select_result = sut.await.select_a_card([testCard], "prompt for a test")

            expect(select_result).not_to be nil
        end

        it "should remove the selected card from the input card list" do
            testCard = Card.new
            guiDouble = double("gui", :select_a_card => nil, :get_dialog_result => testCard)
            sut = GuiInputManager.new(guiDouble)

            input_card_list = [testCard]
            select_result = sut.await.select_a_card(input_card_list, "prompt for a test")

            expect(input_card_list).not_to include testCard
        end
    end

end