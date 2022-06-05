require "tempfile"
require "./game.rb"

describe "PlayerPromptGenerator" do
    describe "generate_prompts" do

        user_specific_prompts = {
          some_prompt_name: {
              key_template: "Some_key_name_{name}",
              value_template: "Some prompt where a name like: '{name}' belongs"}
        }

        it "should generate a prompt per uesr" do
            players = Player.generate_players(2)
            result = PlayerPromptGenerator.generate_prompts(players, user_specific_prompts)
            expect(result.size).to eq 2 # there should be two prompts one for each player
        end

        it "should add a property to the user in order to recal the prompt" do
            players = Player.generate_players(2)
            result = PlayerPromptGenerator.generate_prompts(players, user_specific_prompts)

            players.each do |player|
                user_specific_prompts.each do |key, value|
                    expect(player.respond_to?(key.to_sym)).to be true
                end
            end
        end
    end
end

describe "player" do

    test_outfile = Tempfile.new 'test_output'

    describe "add_permanenet" do
        it "should add a keeper to the players keeper collection if the card is a keeper" do
            # setup
            keeper1 = Keeper.new(1, "thing1")
            theFirstPlayer = Player.new("The first player")

            # execute
            theFirstPlayer.add_permanent(keeper1)
        end

        it "should add a keeper to the players keeper collection if the card is a keeper extra lite version" do
            # setup
            thePlayer = Player.new("JOE")
            keeper1 = Keeper.new(1, "thing1")

            # execute
            thePlayer.add_permanent(keeper1)
        end
    end

    describe "has_death?" do
        it "should return false if the player does not have the death creeper in front of them" do
            # setup
            thePlayer = Player.new("JOE")
            deathCreepepr1 = Creeper.new(3, "wanna be death", "you cannot win heh heh")

            # execute, test
            expect(thePlayer.has_death?).to be false
        end

        it "should return true if the player has death creeper in front of them" do
            # setup
            thePlayer = Player.new("JOE")
            deathCreepepr1 = Creeper.new(3, "wanna be death", "you cannot win heh heh")
            thePlayer.add_permanent(deathCreepepr1)

            # execute, test
            expect(thePlayer.has_death?).to be true
        end
    end

    test_outfile.unlink
end