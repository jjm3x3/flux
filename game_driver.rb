require 'concurrent'

class GameDriver
    include Concurrent::Async

    attr_reader :game

    def initialize(game, logger)
        super()
        @game = game
        @logger = logger
        @cardsPlayed = 0
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
      active_player_has_cards = active_player.hand.length > 0
      @cardsPlayed >= @game.ruleBase.playRule || !active_player_has_cards
    end

    def post_card_play_clean_up(player, cardToPlay)
        cardToPlay.await.play(player, @game)
        @logger.debug "Should only happen at the end"
        @cardsPlayed += 1
        checkForWinner # should check for a winner before discarding
        @game.enforceNonActivePlayerLimits(player)
        @logger.information "the discard has #{@game.discardPile.length} card(s) in it"
        # do something if the discard need reshufleing
        @cardsDrawn = @game.replenishHand(@cardsDrawn, player)
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
        @game.active_player
    end

    private
    def checkForWinner
      if @game.winner
        puts "the game is over!!!!==============\\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/"
        exit 0
      end
    end
end