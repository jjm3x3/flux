require "tempfile"
require './game_cli.rb'

describe "GameCli" do

    test_outfile = Tempfile.new 'test_output'

    describe "run" do
        it "should run" do
            # setup
            rule_base_double = double("rule_base", :playRule => Float::INFINITY)
            game_double = double("game", :ruleBase => rule_base_double)
            logger = Logger.new(test_outfile)
            player_double = double("player", :hand => [])
            game_driver_active_player_result_double = double("game_driver_active_player_result",
                :value => player_double)
            game_driver_turn_over_result_double = double("game_driver_turn_over_result",
                :value => false)
            game_driver_play_card_result_double =
                double(
                    "game_driver_play_card_result",
                    :state => :fulfilled
                )
            game_driver_post_card_play_clean_up_result_double =
                double(
                    "game_driver_post_card_play_clean_up_result",
                    :state => :fulfilled)
            allow(game_driver_post_card_play_clean_up_result_double).to receive(:value).and_return(false, false, true)
            game_driver_has_winner_result_double = double("game_driver_has_result")
            has_winner_call_count = 0
            allow(game_driver_has_winner_result_double).to receive(:value) do 
               has_winner_call_count += 1
               has_winner_call_count < 2000 ? false : true
            end
            game_driver_async_double = double("game_driver_async",
                :active_player => game_driver_active_player_result_double,
                :setup_new_turn => nil,
                :turn_over? => game_driver_turn_over_result_double,
                :play_card => game_driver_play_card_result_double,
                :post_card_play_clean_up => game_driver_post_card_play_clean_up_result_double,
                :has_winner => game_driver_has_winner_result_double)
            game_driver_double = double("game_driver", :await => game_driver_async_double)
            interface_choose_from_list_result_double = double("interface_choose_from_list_result",
                :value => FakeCard.new("I am a fake"))
            interface_async_double = double("interface_async",
                :display_game_state => nil,
                :print_permanents => nil,
                :choose_from_list => interface_choose_from_list_result_double,
                :display_message => nil)
            interface_double = double("interface", :await => interface_async_double)
            sut = GameCli.new(game_double, logger, game_driver_double, interface_double)

            # execute
            sut.run

            # test
            # ...something here
        end
    end
end
