require "./gui_elements/dialog.rb"
require "tempfile"
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
            test_logger = TestLogger.new(input_stream, test_outfile)
            sut = CardDialog.new(
                gui_double,
                background_double,
                font_double,
                test_logger,
                {})
            expected_prompt_text = "Some prompt text"

            # setup lite
            sut.set_prompt(expected_prompt_text)
            sut.show

            # set expectations (Assertaions, Test) first
            expect(font_double).to receive(:draw_text).with(expected_prompt_text, any_args)

            # execute
            sut.draw
        end

        it "should not call draw_text on font when prompt symbol is passed" do
            # setup
            gui_double = double("gui")
            background_double = double("background", draw: nil)
            font_double = instance_double("font")
            input_stream = StringIO.new("")
            test_logger = TestLogger.new(input_stream, test_outfile)
            prompt_image_double = double("prompt image", draw: nil)
            expected_prompt_key = :some_expected_prompt
            sut = CardDialog.new(
                gui_double,
                background_double,
                font_double,
                test_logger,
                {expected_prompt_key => prompt_image_double})

            # setup lite
            sut.set_prompt(expected_prompt_key)
            sut.show

            # set expectations (Assertaions, Test) first
            expect(font_double).not_to receive(:draw_text).with(any_args)

            # execute
            sut.draw
        end

        it "should have an add_prompt method which will prevent set_prompt from raising an error" do
            # setup
            gui_double = double("gui")
            background_double = double("background", draw: nil)
            font_double = instance_double("font", draw_text: nil)
            input_stream = StringIO.new("")
            test_logger = TestLogger.new(input_stream, test_outfile)
            sut = CardDialog.new(
                gui_double,
                background_double,
                font_double,
                test_logger,
                {})
            expected_prompt_key = :some_prompt_key

            # setup lite
            # sut.add_prompt(expected_prompt_key, double("SomeGosuImage"))

            # Assert this should not fail
            sut.set_prompt(expected_prompt_key)
        end
    end
end
