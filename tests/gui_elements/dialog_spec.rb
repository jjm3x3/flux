require "./gui_elements/dialog.rb"
require "Tempfile"
require "./logger.rb"

describe "CardDialog" do

    test_outfile = Tempfile.new 'test_output'

    describe "set_prompt" do
        it "should draw_text with the prompt value given its set and then draw is called" do
            # setup
            gui_double = double("gui")
            background_double = double("background", draw: nil)
            font_double = instance_double("font", draw_text: nil)
            input_stream = StringIO.new("")
            test_logger = TestLogger.new(input_stream, $stdout)
            sut = CardDialog.new(
                gui_double,
                background_double,
                font_double,
                test_logger)
            expected_prompt_text = "Some prompt text"

            # setup lite
            sut.set_prompt(expected_prompt_text)
            sut.show

            # set expectations (Assertaions, Test) first
            expect(font_double).to receive(:draw_text).with(expected_prompt_text, any_args)

            # execute
            sut.draw
        end
    end
end
