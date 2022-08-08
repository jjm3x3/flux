require "./game_interface.rb"
require "tempfile"
require "io/console"

describe "TestInterface" do

    test_outfile = Tempfile.new 'test_output'

    describe "choose_from_list" do
        it "should not output the exact symbol text" do
            # setup
            input_stream = StringIO.new("0")
            sut = TestInterface.new(input_stream, test_outfile, {some_expected_prompt: "Some expected prompt"})
            expected_prompt = :some_expected_prompt


            # execute
            sut.choose_from_list([1,2,3], expected_prompt)

            # test
            test_outfile.rewind
            expect(test_outfile.read).not_to include expected_prompt.to_s
        end

        it "should work when :default is passed as prompt_key" do
            # setup
            input_stream = StringIO.new("0")
            sut = TestInterface.new(input_stream, test_outfile)

            # execute & test (should not raise error)
            sut.choose_from_list([1,2,3], :default)
        end

        it "should raise an error when prompt_key is missing from prompts collection" do
            # setup
            input_stream = StringIO.new("0")
            sut = TestInterface.new(input_stream, test_outfile)

            # execute & test
            expect do
                sut.choose_from_list([1,2,3], :missing_key)
            end.to raise_error("prompt_key missing from prompts collection")
        end

        it "should raise an error when nil is passed as prompt_key" do
            # setup
            input_stream = StringIO.new("0")
            sut = TestInterface.new(input_stream, $stdout)

            # execute & test
            expect do
                sut.choose_from_list([1,2,3], nil)
            end.to raise_error("prompt_key missing")
        end
    end

    describe "ask_yes_no" do
        it "should not output the exact symbol text" do
            # setup
            input_stream = StringIO.new("0")
            sut = TestInterface.new(input_stream, test_outfile, {some_expected_prompt: "Some expected prompt"})
            expected_prompt = :some_expected_prompt


            # execute
            sut.ask_yes_no(expected_prompt)

            # test
            test_outfile.rewind
            expect(test_outfile.read).not_to include expected_prompt.to_s
        end

        it "should work when :default is passed as prompt_key" do
            # setup
            input_stream = StringIO.new("0")
            sut = TestInterface.new(input_stream, test_outfile)

            # execute & test (should not raise error)
            sut.ask_yes_no(:default)
        end

        it "should raise an error when prompt_key is missing from prompts collection" do
            # setup
            input_stream = StringIO.new("0")
            sut = TestInterface.new(input_stream, test_outfile)

            # execute & test
            expect do
                sut.ask_yes_no(:missing_key)
            end.to raise_error("prompt_key missing from prompts collection")
        end

        it "should raise an error when nil is passed as prompt_key" do
            # setup
            input_stream = StringIO.new("0")
            sut = TestInterface.new(input_stream, $stdout)

            # execute & test
            expect do
                sut.ask_yes_no(nil)
            end.to raise_error("prompt_key missing")
        end
    end

    describe "ask_rotation" do
        it "should not output the exact symbol text" do
            # setup
            input_stream = StringIO.new("0")
            sut = TestInterface.new(input_stream, test_outfile, {some_expected_prompt: "Some expected prompt"})
            expected_prompt = :some_expected_prompt


            # execute
            sut.ask_rotation(expected_prompt)

            # test
            test_outfile.rewind
            expect(test_outfile.read).not_to include expected_prompt.to_s
        end

        it "should work when :default is passed as prompt_key" do
            # setup
            input_stream = StringIO.new("0")
            sut = TestInterface.new(input_stream, test_outfile)

            # execute & test (should not raise error)
            sut.ask_rotation(:default)
        end

        it "should raise an error when prompt_key is missing from prompts collection" do
            # setup
            input_stream = StringIO.new("0")
            sut = TestInterface.new(input_stream, test_outfile)

            # execute & test
            expect do
                sut.ask_rotation(:missing_key)
            end.to raise_error("prompt_key missing from prompts collection")
        end

        it "should raise an error when nil is passed as prompt_key" do
            # setup
            input_stream = StringIO.new("0")
            sut = TestInterface.new(input_stream, $stdout)

            # execute & test
            expect do
                sut.ask_rotation(nil)
            end.to raise_error("prompt_key missing")
        end
    end
end
