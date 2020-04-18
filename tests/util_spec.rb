require "Tempfile"
require "io/console"
require "./util.rb"

describe "Util" do
    describe "are_all_nill" do
        it "should be true for all nils" do
            # setup
            testList = [nil,nil,nil]

            expect(Util.are_all_nil(testList)).to be true
        end

        it "should be false if there is even one non nil item" do
            # setup
            testList = [nil,nil,10]

            expect(Util.are_all_nil(testList)).to be false
        end
    end

end

