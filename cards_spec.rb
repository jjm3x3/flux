require "./game.rb"
require "Tempfile"
require "io/console"

describe "cards" do

    test_outfile = Tempfile.new 'test_output'

    describe "Keepers" do
        describe "play" do
            it "should call resolve_war_rule if peace is played" do
                # setup
                fakeGame = Object.new
                calledResolveWarRule = false
                fakeGame.define_singleton_method(:resolve_war_rule) do |player|
                    calledResolveWarRule = true
                end
                fakePlayer = Player.new("fake boi", fakeGame)
                sut = Keeper.new(16, "Wanna be Peace")

                # exectue
                sut.play(fakePlayer, fakeGame)

                # test
                expect(calledResolveWarRule).to be true

            end

            it "should not call resolve_war_rule if not peace is played" do
                # setup
                fakeGame = Object.new
                calledResolveWarRule = false
                fakeGame.define_singleton_method(:resolve_war_rule) do |player|
                    calledResolveWarRule = true
                end
                fakePlayer = Player.new("fake boi", fakeGame)
                sut = Keeper.new(11, "not peace")

                # exectue
                sut.play(fakePlayer, fakeGame)

                # test
                expect(calledResolveWarRule).to be false
            end
        end
    end
end