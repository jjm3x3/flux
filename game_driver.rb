require "concurrent"

class GameDriver
    include Concurrent::Async

    def initialize(game, logger)
        super()
        @game = game
        @logger = logger
        @cardsPlayed = 0
    end

    def sleep_for_10
        sleep 10
    end

    def setup_new_turn
      if(active_player.has_death?)
        @game.resolve_death_rule(active_player)
      end
      drawnCards = @game.drawCards(active_player, :draw_rule)
      @logger.debug "GameDriver::setup_new_turn: cards drawn at beginning of turn"
      active_player.add_cards_to_hand(drawnCards)
      @logger.debug "GameDriver::setup_new_turn: cards added to players hand"
      @cardsPlayed = 0
      @cardsDrawn = drawnCards.length
      @logger.debug "GameDriver::setup_new_turn: New turn has been setup"
    end

    def turn_over?
        @logger.debug "Beginning of turn_over?"
        @logger.debug "Who is the active_player: #{active_player}"
        active_player_has_cards = active_player.hand.length > 0
        @logger.debug "Does the active player have cards #{active_player_has_cards}"
        active_player_has_reached_play_limit = @cardsPlayed < @game.play_limit
        @logger.debug "cards played #{@cardsPlayed}"
        @logger.debug "Play limit is #{@game.play_limit}"
        @logger.info "GameDriver::turn_over? active player has reached play limit #{active_player_has_reached_play_limit}"

        result = !(active_player_has_reached_play_limit && active_player_has_cards)
        @logger.debug "Is the turn over? #{result}"
        return result
    end

    def remove_card_from_active_player(index)
      active_player.remove_card_from_hand(index)
    end

    def play_card(card_to_play)
        @logger.debug "this should get logged sync"
        @game.play_card(card_to_play, active_player)
        @logger.debug "After card was played"
        @cardsPlayed += 1
        @logger.debug "Increment cards played"
    end

    def post_card_play_clean_up
        @game.enforceNonActivePlayerLimits(active_player)
        @logger.info "the discard has #{@game.discardPile.length} card(s) in it"
        # do something if the discard need reshufleing
        @cardsDrawn = @game.replenishHand(@cardsDrawn, active_player)
        @logger.debug "Finished post_card_play_clean_up"
        if turn_over?
            @logger.debug "The turn is over proceed to end_turn_cleanup"
            end_turn_cleanup
            return true
        end
        return false
    end

    def end_turn_cleanup
      @game.discardDownToLimit(active_player)
      @game.removeDownToKeeperLimit(active_player)
      if active_player.take_another_turn
        active_player.set_take_another_turn(false)
      else
        @game.progress_turn
      end
    end

    def active_player
        @logger.debug "GameDriver: Getting active_player from game"
        @game.active_player
    end

    def has_winner
      @logger.debug "GameDriver:has_winner: checking if game has a winner"
      @game.winner
    end

    def get_game_state
      GameState.new(
        @game.deck.count,
        @game.discardPile.size,
        @game.goal.to_s,
        @game.ruleBase,
        active_player)
    end

    private
    def checkForWinner
      if @game.winner
        puts "the game is over!!!!==============\\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/"
        exit 0
      end
    end
end