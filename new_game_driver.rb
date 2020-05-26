require "concurrent"

class NewGameDriver
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
        @game.await.resolve_death_rule(active_player)
      end
      drawnCards = @game.await.drawCards(active_player, :draw_rule).value
      active_player.add_cards_to_hand(drawnCards)
      @cardsPlayed = 0
      @cardsDrawn = drawnCards.length
    end

    def turn_over?
        @logger.debug "Beginning of turn_over?"
        active_player_has_cards = active_player.hand.length > 0
        @logger.debug "Does the active player have cards #{active_player_has_cards}"
        result = @cardsPlayed >= @game.await.play_limit.value || !active_player_has_cards
        @logger.debug "Is the turn over? #{result}"
        return result
    end

    def post_card_play_clean_up(player, card_to_play)
        @logger.debug "this should get logged sync"
        @game.await.play_card(card_to_play, player)
        # card_to_play.await.play(player, @game)
        @logger.debug "After card was played"
        @cardsPlayed += 1
        @logger.debug "Increment cards played"
        checkForWinner # should check for a winner before discarding
        @logger.debug "Checked for winner"
        @game.await.enforceNonActivePlayerLimits(player)
        @logger.information "the discard has #{@game.discardPile.length} card(s) in it"
        # do something if the discard need reshufleing
        @cardsDrawn = @game.await.replenishHand(@cardsDrawn, player).value
        @logger.debug "Finished post_card_play_clean_up"
        if turn_over?
            @logger.debug "The turn is over proceed to end_turn_cleanup"
            end_turn_cleanup
            return true
        end
        return false
    end

    def end_turn_cleanup
      @game.await.discardDownToLimit(active_player)
      @game.await.removeDownToKeeperLimit(active_player)
      if(@take_another_turn)
        @currentPlayerCounter -= 1
        @take_another_turn = false
      end
      @game.await.progress_turn
    end

    def active_player
        @game.await.active_player.value
    end

    private
    def checkForWinner
      if @game.await.winner.value
        puts "the game is over!!!!==============\\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/"
        exit 0
      end
    end
end