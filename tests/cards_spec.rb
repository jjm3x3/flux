require "./game.rb"
require "Tempfile"
require "io/console"

describe "cards" do

    test_outfile = Tempfile.new 'test_output'

    describe "Cards" do

        describe "==" do
            it "should not crash when compated to nil" do
                sut = Keeper.new(16, "Let there be Peace")

                expect(sut == nil).to be false
            end

            # since we have started using the concurrent-ruby package
            # we need to make sure that this doesn't result in an exception
            # or else every time we retun a card from an async method
            # an exception will be raised due to trying to check equality
            # with the Concurrent::NULL
            it "should handle Concurrent::NULL" do
                sut = Keeper.new(1, "THING")

                expect(sut == Concurrent::NULL).to be false
            end
        end
    end

    describe "Keepers" do
        describe "play" do
            it "should call resolve_war_rule if peace is played" do
                # setup
                fakeGame = Object.new
                asyncGame = double("game", :await => fakeGame)
                calledResolveWarRule = false
                fakeGame.define_singleton_method(:resolve_war_rule) do |player|
                    calledResolveWarRule = true
                end
                fakePlayer = Player.new("fake boi")
                sut = Keeper.new(16, "Wanna be Peace")

                # exectue
                sut.play(fakePlayer, asyncGame)

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
                fakePlayer = Player.new("fake boi")
                sut = Keeper.new(11, "not peace")

                # exectue
                sut.play(fakePlayer, fakeGame)

                # test
                expect(calledResolveWarRule).to be false
            end

            it "should call resolve_taxes_rule if money is played" do
                fakeGame = Object.new
                asyncGame = double("game", :await => fakeGame)
                calledResolveTaxesRule = false
                fakeGame.define_singleton_method(:resolve_taxes_rule) do |player|
                    calledResolveTaxesRule = true
                end
                fakePlayer = Player.new("fake boi")
                sut = Keeper.new(19, "Wanna be moeny")

                # exectue
                sut.play(fakePlayer, asyncGame)

                # test
                expect(calledResolveTaxesRule).to be true
            end

            it "should not call resolve_taxes_rule if not money is played" do
                fakeGame = Object.new
                calledResolveTaxesRule = false
                fakeGame.define_singleton_method(:resolve_taxes_rule) do |player|
                    calledResolveTaxesRule = true
                end
                fakePlayer = Player.new("fake boi")
                sut = Keeper.new(11, "Not money")

                # exectue
                sut.play(fakePlayer, fakeGame)

                # test
                expect(calledResolveTaxesRule).to be false
            end
        end
    end

    describe "Creepers" do
        describe "play" do
            it "should call resolve_taxes_rule if taxes is played" do
                # setup
                fakeGame = Object.new
                asyncGame = double("game", :await => fakeGame)
                calledResolveTaxesRule = false
                fakeGame.define_singleton_method(:resolve_taxes_rule) do |player|
                    calledResolveTaxesRule = true
                end
                fakePlayer = Player.new("fake boi")
                sut = Creeper.new(2, "shut up and take my money (taxes)", "don't go bankrupt")

                # exectue
                sut.play(fakePlayer, asyncGame)

                # test
                expect(calledResolveTaxesRule).to be true

            end
        end
    end
end