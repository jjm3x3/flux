class GameCli
  def initialize(game, logger, new_game_driver)
      @logger = logger
      @game_driver = game
      @new_game_driver = new_game_driver
      @interface = TrueCliInterface.new
  end

  def run
      loop do
        activePlayer = @new_game_driver.await.active_player.value
        @interface.display_game_state(@game_driver.game)
        @logger.information "\n#{activePlayer}'s turn"

        @new_game_driver.await.setup_new_turn
        hand = activePlayer.hand
        cardsPlayed = 0
        while !@new_game_driver.await.turn_over?.value
          @logger.printPermanents(activePlayer)

          cardToPlay = @interface.await.select_a_card(hand, "Select a card from your hand to play").value

          @new_game_driver.await.post_card_play_clean_up(activePlayer, cardToPlay)
          cardsPlayed += 1

          hand = activePlayer.hand # really a sad sideeffect of much statefull programming
          @logger.information "played: #{cardsPlayed} of play: #{@game_driver.game.ruleBase.playRule}"
        end
      end
  end

end