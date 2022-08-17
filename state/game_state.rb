require './state/player_state.rb'

class GameState
    attr_reader :deck_count,
        :discard_pile_count,
        :gaol_text,
        :draw_rule,
        :play_rule,
        :hand_limit,
        :keeper_limit,
        :active_player,
        :card_to_play,
        :players

    def initialize(
        deck_count,
        discard_pile_count=0,
        gaol_text="",
        rule_base=nil,
        active_player=nil,
        card_to_play=1,
        players=[]
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
        @players = []
        players.each do |player|
            player_state = PlayerState.new(player)
            if player == active_player
                @active_player = player_state
            end
            @players << player_state
        end
        @card_to_play = card_to_play
    end

    def current_player_index
        current_player_index = 0
        current_index = 0
        @players.each do |player|
            if @active_player == player
                current_player_index = current_index
            else
                current_index += 1
            end
        end

        return current_player_index
    end
end
