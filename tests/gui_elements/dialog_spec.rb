require "./gui_elements/dialog.rb"
require "tempfile"
require "logger"

describe "CardDialog" do

    test_outfile = Tempfile.new 'test_output'

    describe "set_prompt" do
        it "should not call draw_text on font when prompt symbol is passed" do
            # setup
            gui_double = double("gui")
            background_double = double("background", width: 1, draw: nil)
            font_double = instance_double("font")
            input_stream = StringIO.new("")
            test_logger = Logger.new(test_outfile)
            prompt_image_double = double("prompt image", draw: nil)
            expected_prompt_key = :some_expected_prompt
            sut = CardDialog.new(
                gui_double,
                background_double,
                font_double,
                test_logger,
                {expected_prompt_key => prompt_image_double},
                button_options={})

            # setup lite
            sut.set_prompt(expected_prompt_key)
            sut.show

            # set expectations (Assertaions, Test) first
            expect(font_double).not_to receive(:draw_text).with(any_args)

            # execute
            sut.draw
        end

        it "should raise an error if the prompt_key is nil" do
            # setup
            gui_double = double("gui")
            background_double = double("background", draw: nil)
            font_double = instance_double("font", draw_text: nil)
            input_stream = StringIO.new("")
            test_logger = Logger.new(test_outfile)
            sut = CardDialog.new(
                gui_double,
                background_double,
                font_double,
                test_logger,
                dialog_prompts={},
                button_options={})

            # Execute and Assert this should not fail
            expect do
                sut.set_prompt(nil)
            end.to raise_error("prompt_key is nil")
        end

        it "should raise an error if the prompt is a symbol which doesn't exist in the dialog_prompts" do
            # setup
            gui_double = double("gui")
            background_double = double("background", draw: nil)
            font_double = instance_double("font", draw_text: nil)
            input_stream = StringIO.new("")
            test_logger = Logger.new(test_outfile)
            sut = CardDialog.new(
                gui_double,
                background_double,
                font_double,
                test_logger,
                dialog_prompts={},
                button_options={})
            expected_prompt_key = :some_prompt_key

            # Execute and Assert this should not fail
            expect do
                sut.set_prompt(expected_prompt_key)
            end.to raise_error("prompt_key missing from prompts collection")
        end

    end

    describe "add_prompt" do
        it "should exist to prevent set_prompt from raising an error" do
            # setup
            gui_double = double("gui")
            background_double = double("background", draw: nil)
            font_double = instance_double("font", draw_text: nil)
            input_stream = StringIO.new("")
            test_logger = Logger.new(test_outfile)
            sut = CardDialog.new(
                gui_double,
                background_double,
                font_double,
                test_logger,
                dialog_prompts={},
                button_options={})
            expected_prompt_key = :some_prompt_key

            # execute the test
            sut.add_prompt(expected_prompt_key, double("SomeGosuImage"))

            # Assert this should not fail
            sut.set_prompt(expected_prompt_key)
        end
    end
end
