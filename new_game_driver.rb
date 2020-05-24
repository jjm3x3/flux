require "concurrent"

class NewGameDriver
    include Concurrent::Async

    def initialize(game, logger)
        super()
        @game = game
        @logger = logger
    end

    def sleep_for_10
        sleep 10
    end

    def post_card_play_clean_up(player, card_to_play)
        puts "this should get logged sync"
        card_to_play.await.play(player, @game)
        # sleep 100
        puts "here is a player #{player}"
        puts "here is the card #{card_to_play}"
    end
end