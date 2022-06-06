class GameCli
  def initialize(game, logger, new_game_driver, interface)
      @logger = logger
      @game = game
      @new_game_driver = new_game_driver
      @interface = interface
  end

  def run
      loop do
        activePlayer = @new_game_driver.await.active_player.value
        @interface.await.display_game_state(@game, @new_game_driver)

        @new_game_driver.await.setup_new_turn
        hand = activePlayer.hand
        cardsPlayed = 0
        while !@new_game_driver.await.turn_over?.value
          @interface.await.print_permanents(activePlayer, prompt="here are the permanents you have:")

          cardToPlay = @interface.await.choose_from_list(hand, :select_a_card_to_play_prompt).value
          @logger.debug "Card selected is: '#{cardToPlay}'"

          play_result = @new_game_driver.await.play_card(activePlayer, cardToPlay)
          @logger.debug "What was the play result? '#{play_result.state}'"
          if play_result.state != :fulfilled
            @logger.warn "play_result may not have been fulfilled because: '#{play_result.reason}'"
          end
          cardsPlayed += 1

          hand = activePlayer.hand # really a sad sideeffect of much statefull programming
          @logger.info "played: #{cardsPlayed} of play: #{@game.ruleBase.playRule}"
          @logger.debug "Check if winner"
          break if @new_game_driver.await.has_winner.value
          @logger.debug "no winner coninute"
          @new_game_driver.await.post_card_play_clean_up
        end
        break if @new_game_driver.await.has_winner.value
      end
  end

  private

end
