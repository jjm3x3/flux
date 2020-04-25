class GameCli
  def initialize(game, logger)
      @logger = logger
      @game_driver = game
      @interface = TrueCliInterface.new
  end

  def run
      loop do
        activePlayer = @game_driver.active_player
        @interface.display_game_state(@game_driver.game)
        @logger.information "\n#{activePlayer}'s turn"

        @game_driver.setup_new_turn
        hand = activePlayer.hand
        cardsPlayed = 0
        while !@game_driver.turn_over?
          @logger.printPermanents(activePlayer)

          cardToPlay = @logger.select_a_card(hand, "Select a card from your hand to play")

          @game_driver.post_card_play_clean_up(activePlayer, cardToPlay)
          cardsPlayed += 1

          hand = activePlayer.hand # really a sad sideeffect of much statefull programming
          @logger.information "played: #{cardsPlayed} of play: #{@game_driver.game.ruleBase.playRule}"
        end
        @game_driver.end_turn_cleanup
      end
  end

end