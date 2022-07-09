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
      active_player.add_cards_to_hand(drawnCards)
      @cardsPlayed = 0
      @cardsDrawn = drawnCards.length
    end

    def turn_over?
        @logger.debug "Beginning of turn_over?"
        @logger.debug "Who is the active_player: #{active_player}"
        active_player_has_cards = active_player.hand.length > 0
        @logger.debug "Does the active player have cards #{active_player_has_cards}"
        result = @cardsPlayed >= @game.play_limit || !active_player_has_cards
        @logger.debug "Is the turn over? #{result}"
        return result
    end

    def play_card(player, card_to_play)
        @logger.debug "this should get logged sync"
        @game.play_card(card_to_play, player)
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
      if(@take_another_turn)
        @currentPlayerCounter -= 1
        @take_another_turn = false
      end
      @game.progress_turn
    end

    def active_player
        @logger.debug "GameDriver: Getting active_player from game"
        @game.active_player
    end

    def has_winner
      @game.winner
    end

    private
    def checkForWinner
      if @game.winner
        puts "the game is over!!!!==============\\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/"
        exit 0
      end
    end
end