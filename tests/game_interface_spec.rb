require "./game_interface.rb"
require "Tempfile"
require "io/console"

describe "TestInterface" do

    test_outfile = Tempfile.new 'test_output'

    describe "choose_from_list" do
        it "should output the exact string when one is passed" do
            # setup
            input_stream = StringIO.new("0")
            sut = TestInterface.new(input_stream, test_outfile)
            expected_prompt = "Some expected prompt"

            # execute
            sut.choose_from_list([1,2,3], expected_prompt)

            # test
            test_outfile.rewind
            expect(test_outfile.read).to include expected_prompt
        end

        it "should not output the exact symbol text" do
            # setup
            input_stream = StringIO.new("0")
            sut = TestInterface.new(input_stream, test_outfile)
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
    end
end