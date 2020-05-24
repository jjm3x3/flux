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

    def post_card_play_clean_up(player, card_to_play)
        @logger.debug "this should get logged sync"
        card_to_play.await.play(player, @game)
        @logger.debug "Should only happen at the end"
        @cardsPlayed += 1
        checkForWinner # should check for a winner before discarding
        @game.await.enforceNonActivePlayerLimits(player)
        @logger.information "the discard has #{@game.discardPile.length} card(s) in it"
        # do something if the discard need reshufleing
        @cardsDrawn = @game.await.replenishHand(@cardsDrawn, player).value
    end
end