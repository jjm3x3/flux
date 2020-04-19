class GameDriver
  def initialize(players, logger)
      @logger = logger
      @game = Game.new(players, logger)
      @interface = TrueCliInterface.new
  end

  def run
      loop do
        activePlayer = @game.players[@game.currentPlayer]
        @interface.display_game_state(@game)
      #   @interface.information "here is the current goal: #{@goal }"
        @logger.information "\n#{activePlayer}'s turn"
        takeTurn(activePlayer)
        @game.progress_turn
      end
  end

  def takeTurn(activePlayer)
    if(activePlayer.has_death?)
      @game.resolve_death_rule(activePlayer)
    end
    @game.drwaCards(activePlayer, :draw_rule)
    # activePlayer.drawCards
    @game.playCards(activePlayer)
    @game.discardDownToLimit(activePlayer)
    @game.removeDownToKeeperLimit(activePlayer)
    if(@take_another_turn)
      @game.currentPlayerCounter -= 1
      @take_another_turn = false
    end
  end

end