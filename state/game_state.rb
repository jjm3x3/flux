require './state/player_state.rb'

class GameState
    attr_reader :deck_count,
        :discard_pile_count,
        :gaol_text,
        :draw_rule,
        :play_rule,
        :hand_limit,
        :keeper_limit,
        :active_player

    def initialize(
        deck_count,
        discard_pile_count=0,
        gaol_text="",
        rule_base=nil,
        active_player=nil
    )
        @deck_count = deck_count
        @discard_pile_count = discard_pile_count
        @gaol_text = gaol_text
        if rule_base
            @draw_rule = rule_base.drawRule
            @play_rule = rule_base.playRule
            @hand_limit = rule_base.handLimit
            @keeper_limit = rule_base.keeperLimit
        else
            @draw_rule = 1
            @play_rule = 1
            @hand_limit = Float::INFINITY
            @keeper_limit = Float::INFINITY
        end
        if active_player
            @active_player = PlayerState.new(active_player)
        end
    end
end