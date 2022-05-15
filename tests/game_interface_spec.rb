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
    end
end