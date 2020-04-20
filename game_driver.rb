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
        if(activePlayer.has_death?)
          @game.resolve_death_rule(activePlayer)
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