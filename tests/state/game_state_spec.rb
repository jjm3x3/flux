require "./state/game_state.rb"

describe "game_state" do
    describe "initialize" do
        it "should construct" do
            # setup
            #   nothign to do

            # execute
            sut = GameState.new(10)

            # test 
            #   should not throw ex
        end

        it "require that the active_player exists in the players list" do
            # setup
            current_player_double = double("current_player", name:"Hi" , permanents:[], hand:[])

            # execute && test
            expect do
                sut = GameState.new(
                    deck_count=10,
                    discard_pile_count=10,
                    gaol_text="Doesn't matter",
                    rule_base=nil,
                    active_player=current_player_double,
                    card_to_play=1,
                    players=[
                        double("player2", name: "2", permanents:[], hand:[]),
                        double("player3", name: "3", permanents:[], hand:[]),
                        double("player4", name: "4", permanents:[], hand:[]),
                    ])
            end.to raise_error("Object passed as active_player does not exist in the list of current game players")
        end
    end
end