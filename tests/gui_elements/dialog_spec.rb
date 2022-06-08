require "./gui_elements/dialog.rb"
require "tempfile"
require "logger"

describe "CardDialog" do

    test_outfile = Tempfile.new 'test_output'

    describe "set_prompt" do
        it "should not call draw_text on font when prompt symbol is passed" do
            # setup
            gui_double = double("gui")
            background_double = double("background", width: 1, height: 1, draw: nil)
            font_double = instance_double("font", height: 1)
            input_stream = StringIO.new("")
            test_logger = Logger.new(test_outfile)
            prompt_image_double = double("prompt image", width: 1, draw: nil)
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
            font_double = instance_double("font", height: 1)
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
            font_double = instance_double("font", height:1, draw_text: nil)
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
            font_double = instance_double("font", height: 1, draw_text: nil)
            input_stream = StringIO.new("")
            test_logger = Logger.new(test_outfile)
            prompt_image_double = double("prompt image", width: 1)
            sut = CardDialog.new(
                gui_double,
                background_double,
                font_double,
                test_logger,
                dialog_prompts={},
                button_options={})
            expected_prompt_key = :some_prompt_key

            # execute the test
            sut.add_prompt(expected_prompt_key, prompt_image_double)

            # Assert this should not fail
            sut.set_prompt(expected_prompt_key)
        end
    end

    describe "draw" do
        it "should call draw with the right intial width" do
            # setup
            gui_double = double("gui")
            background_double = double("background", width: 1, draw: nil)
            font_double = instance_double("font", height:1)
            test_logger = Logger.new(test_outfile)
            expected_width = 300 / background_double.width
            prompt_image_double = double("prompt image", width: 1, draw: nil)
            expected_prompt_key = :some_expected_prompt
            sut = CardDialog.new(
                gui_double,
                background_double,
                font_double,
                test_logger,
                {expected_prompt_key => prompt_image_double})
            sut.show


            # Execute and Assert this should not fail
            expect do
                sut.draw
            end.to raise_error("Cannot draw a dialog without setting the prompt")
        end

        it "should call draw with a width based on the prompt" do
            # setup
            gui_double = double("gui")
            background_double = double("background", width: 1, height: 1, draw: nil)
            font_double = instance_double("font", height: 1)
            test_logger = Logger.new(test_outfile)
            prompt_image_double = double("prompt image", width: 400, draw: nil)
            expected_width = (prompt_image_double.width + 20 * 2) / background_double.width
            expected_prompt_key = :some_expected_prompt
            sut = CardDialog.new(
                gui_double,
                background_double,
                font_double,
                test_logger,
                {expected_prompt_key => prompt_image_double})
            sut.set_prompt(expected_prompt_key)
            sut.show


            # execute
            sut.draw

            # test
            expect(background_double).to have_received(:draw).with(anything, anything, anything, expected_width, anything)
        end

        it "should call draw with the default height when no cards set" do
            # setup
            gui_double = double("gui")
            background_double = double("background", width: 1, height: 1, draw: nil)
            font_double = instance_double("font", height: 1)
            test_logger = Logger.new(test_outfile)
            prompt_image_double = double("prompt image", width: 400, draw: nil)
            # This test is mostly asserting that the following calculation with
            # all assumptions and constants is executed
            expected_height = (font_double.height + 10) * 4 + 20 * 2
            expected_prompt_key = :some_expected_prompt
            sut = CardDialog.new(
                gui_double,
                background_double,
                font_double,
                test_logger,
                {expected_prompt_key => prompt_image_double})
            sut.set_prompt(expected_prompt_key)
            sut.show


            # execute
            sut.draw

            # test
            expect(background_double).to have_received(:draw).with(anything, anything, anything, anything, expected_height)
        end

        it "should call draw with a height that is based on how many cards are set" do
            pending("This test requires that buttons can be created which intern requries that buttons don't depend on Gosu")
            # setup
            gui_double = double("gui")
            background_double = double("background", width: 1, height: 1, draw: nil)
            font_double = instance_double("font", height: 1)
            test_logger = Logger.new(test_outfile)
            prompt_image_double = double("prompt image", width: 400, draw: nil)
            mock_card_list = [1,2,3]
            # This test is mostly asserting that the following calculation with
            # all assumptions and constants is executed
            expected_height = (font_double.height + 10) * (mock_card_list.length + 1) + 20 * 2
            expected_prompt_key = :some_expected_prompt
            sut = CardDialog.new(
                gui_double,
                background_double,
                font_double,
                test_logger,
                {expected_prompt_key => prompt_image_double})
            sut.set_prompt(expected_prompt_key)
            sut.set_cards(mock_card_list)
            sut.show


            # execute
            sut.draw

            # test
            expect(background_double).to have_received(:draw).with(anything, anything, anything, anything, expected_height)
        end
    end
end
