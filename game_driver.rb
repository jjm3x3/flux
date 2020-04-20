class GameDriver
  def initialize(game, logger)
      @logger = logger
      @game = game
      @interface = TrueCliInterface.new
  end

  def run
      loop do
        activePlayer = @game.players[@game.currentPlayer]
        @interface.display_game_state(@game)
        @logger.information "\n#{activePlayer}'s turn"

        @game.setup_new_turn
        hand = activePlayer.hand
        while !@game.ready_to_progress
          @logger.printPermanents(activePlayer)

          cardToPlay = @logger.select_a_card(hand, "Select a card from your hand to play")

          @game.post_card_play_clean_up(activePlayer, cardToPlay)

          hand = activePlayer.hand # really a sad sideeffect of much statefull programming
          # @logger.information "played: #{@cardsPlayed} of play: #{@game.ruleBase.playRule}"
        end

        @game.discardDownToLimit(activePlayer)
        @game.removeDownToKeeperLimit(activePlayer)
        if(@take_another_turn)
          @game.currentPlayerCounter -= 1
          @take_another_turn = false
        end
        @game.progress_turn
      end
  end

end