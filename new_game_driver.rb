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

    def turn_over?
        puts "Beginning of turn_over?"
        @logger.debug "Beginning of turn_over?"
        active_player_has_cards = active_player.hand.length > 0
        @logger.debug "Does the active player have card #{active_player_has_cards}"
        @cardsPlayed >= @game.await.play_rule.value || !active_player_has_cards
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

    def active_player
        @game.await.active_player.value
    end
end