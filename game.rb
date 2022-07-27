require "./cards/cards.rb"
require "./deck.rb"
require "./player.rb"
require "./ruleBase.rb"
require "./game_interface.rb"


class Game

  attr_accessor :ruleBase
  attr_accessor :players
  attr_accessor :discardPile
  attr_accessor :currentPlayerCounter
  attr_reader :deck, :goal

  def initialize(aLogger, aTrueInterface = CliInterface.new, players=[], aDeck = Deck.new(aLogger), aRandom = Random.new)

    @logger = aLogger
    @interface = aTrueInterface

    @random = aRandom

    @logger.debug "Initialize some game stuff"
    @ruleBase = RuleBase.new(self, aLogger)
    @deck = aDeck
    @discardPile = []

    @players = players

    @currentPlayerCounter = 0
  end

  def setup
    # deal openings hands
    @players.each do |player|
      firstHand = drawCards(player, 3) # basic rules draw three cards to start
      @logger.debug "draw your opening hand #{firstHand}"
      player.set_hand(firstHand)
    end
  end

  def drawCards(player, count)
    expectedNumberOfCards = (count == :draw_rule ? @ruleBase.drawRule : count)
    @logger.debug "expecting to draw #{expectedNumberOfCards} cards"
    drawnCards = @deck.drawCards(expectedNumberOfCards)
    loop do
      @logger.debug "How many cards where actually drawn #{drawnCards.size}"
      drawnCards = drawnCards.select do |card|
        @logger.debug "What is this card? #{card.card_type}"
        if card.card_type == "Creeper"
          @logger.debug "Found a creeper: #{card}"
          card.play(player, self)
        end
        card.card_type != "Creeper"
      end
      if drawnCards.length == expectedNumberOfCards
        break
      else
      # TODO: should shuffle the discard back in the draw at this point
      if @deck.count == 0
        @logger.debug "No cards left to draw"
        break
      end
      drawnCards += @deck.drawCards(expectedNumberOfCards - drawnCards.length)
      end
    end
    drawnCards
  end

  def progress_turn
    @currentPlayerCounter += 1
  end

  def enforceNonActivePlayerLimits(the_active_player)
    @players.each do |player|
      if player != the_active_player
        discardDownToLimit(player)
        removeDownToKeeperLimit(player)
      end
    end
  end

  def removeDownToKeeperLimit(player)
    while player.keepers.length > @ruleBase.keeperLimit
      @logger.info "Since the keeper limit is #{@ruleBase.keeperLimit} you must discard a keeper"
      choose_result = @interface.await.choose_from_list(player.keepers, :discard_down_to_keeper_limit)
      if choose_result.state != :fulfilled
        @logger.debug "choose_result may not have been fulfilled because #{choose_result.reason}"
      end
      @discardPile << choose_result.value
      @logger.debug "discarding #{choose_result.value}"
    end
  end

  def discardDownToLimit(player)
    @logger.debug "The hand limit is #{@ruleBase.handLimit}"
    while player.hand.count > @ruleBase.handLimit
      removed_card_result = @interface.await.choose_from_list(player.hand, player.discard_prompt_name)
      @logger.debug "Game::discardDownToLimit: What state is the removed_card_result: #{removed_card_result.state}"
      if removed_card_result.state != :fulfilled
        @logger.info "choose_result may not have been fulfilled because #{removed_card_result.reason}"
      end
      card_to_remove = removed_card_result.value
      @discardPile << card_to_remove
      @logger.debug "removing '#{card_to_remove}'"
    end
  end

  def discard(card)
    @logger.debug "discarding #{card}"
    @discardPile << card
  end

  def play_limit
    @ruleBase.playRule
  end

  def hasGoal?
    !@goal.nil?
  end

  def goalMet?(player)
    @goal.met?(player, self)
  end

  def setGoal(newGoal)
    @logger.info "changeing goal to #{newGoal}"
    if @goal
      @discardPile << @goal
    end
    @goal = newGoal
    @logger.debug "here is the new value of goal #{@goal}"
  end

  def replenishHand(numberOfCardsDrawn, currentPlayer)
    # puts "here is #{numberOfCardsDrawn} < #{@ruleBase.drawRule}"
    if numberOfCardsDrawn < @ruleBase.drawRule
      lackingCards = @ruleBase.drawRule - numberOfCardsDrawn
      currentPlayer.add_cards_to_hand(drawCards(currentPlayer, lackingCards))
      numberOfCardsDrawn += lackingCards
    end
    numberOfCardsDrawn
  end

  def currentPlayer
    @currentPlayerCounter % @players.length
  end

  def active_player
    @logger.debug "Game: Fetching active player out of list of players"
    players[currentPlayer]
  end

  def winner
    checkingPlayer = @firstPlayer
    winner = false
    @players.each do |player|
      winner ||= has_player_won?(player)
    end
    @logger.debug "is there a winner? #{winner.to_s}\n"
    winner
  end

  def has_player_won?(player)
    if hasGoal?
      goalMet?(player) && !player.creepers.any?
    else
      false
    end
  end

  def opponents(of_player)
    @players.select do |player|
      player != of_player
    end
  end

  def play_card(card, player)
    card.play(player, self)
  end

  def draw_2_and_use_em(player)
    @logger.debug "happens sync at the beginning of draw_2_and_use_em"
    cardsDrawn = drawCards(player, 2)
    select_result = @interface.await.choose_from_list(cardsDrawn, :play_first_prompt)
    @logger.debug "Here is the selected card in draw_2_and_use_em: '#{select_result.value}'"
    selected_card = select_result.value
    selected_card.play(player, self)
    cardsDrawn[0].play(player, self)
  end

  def jackpot(player)
    player.add_cards_to_hand(drawCards(player, 3))
  end

  def draw_3_play_2_of_them(player)
    cardsDrawn = drawCards(player, 3)
    firstOne = @interface.await.choose_from_list(cardsDrawn, :play_first_prompt)
    @logger.debug "Here is the first card that was selected #{firstOne.value}"
    firstOne.value.play(player, self)
    @logger.debug "Going to select a second one"
    second_choice_result = @interface.await.choose_from_list(cardsDrawn, :play_next_prompt)
    if second_choice_result.state != :fulfilled
      @logger.warn "second_choice_result may not have been fulfilled because: '#{second_choice_result.reason}'"
    end
    second_choice_result.value.play(player, self)
    discard(cardsDrawn[0])
  end

  def discard_and_draw(player)
    numberOfCardsToDraw = player.hand.length
    player.hand.each do |card|
      discard(card)
    end
    player.set_hand(drawCards(player, numberOfCardsToDraw))
  end

  def use_what_you_take(player)
    validOpponents = opponents(player).select do |opp|
      opp.hand.size > 0
    end
    if(validOpponents.size == 0)
      @logger.info "Too bad no body has any cards for you"
      return
    end
    choice_result = @interface.await.choose_from_list(validOpponents, :which_player_to_pick_from_prompt)
    if choice_result.state != :fulfilled
      @logger.warn "Game::use_what_you_take: Was not able to choose an opponent because: #{choice_result.reason}"
    end
    selectedPlayer = choice_result.value
    randomPosition = Random.new.rand(selectedPlayer.hand.length)
    selectedCard = selectedPlayer.hand.delete_at(randomPosition)
    @logger.debug "playing #{selectedCard}"
    selectedCard.play(player, self)
  end

  def taxation(player)
    @logger.debug "playing taxation!"
    newCardsForPlayer = opponents(player).select do |player|
      player.hand.size > 0
    end.map do |aPlayer|
      @logger.debug "prompting #{aPlayer} to give a card to #{player}"
      choose_result = @interface.await.choose_from_list(aPlayer.hand, player.give_card_to_player_prompt_name)
      if choose_result.state != :fulfilled
        @logger.warn "choose_result may not have been fulfilled because #{choose_result.reason}"
      end
      choose_result.value
    end
    player.add_cards_to_hand(newCardsForPlayer)
  end

  def todaysSpecial(player)
    @logger.debug "Executing todays_special"
    drawnCards = drawCards(player, 3)
    cardToPlay = @interface.await.choose_from_list(drawnCards, :choose_card_to_play_prompt).value
    cardToPlay.play(player, self)

    @logger.debug "First card played now figure out if any more should be played"
    if @interface.await.ask_yes_no(:birthday_prompt).value
      @logger.debug "It is the current players birthday"
      cardToPlay = @interface.await.choose_from_list(drawnCards, :choose_card_to_play_prompt).value
      cardToPlay.play(player, self)

      cardToPlay = @interface.await.choose_from_list(drawnCards, :choose_card_to_play_prompt).value
      cardToPlay.play(player, self)
    else
      @logger.debug "It is the not current players birthday is it at least a holiday or anniversary"
      if @interface.await.ask_yes_no(:holiday_anniversary_prompt).value
        cardToPlay = @interface.await.choose_from_list(drawnCards, :choose_card_to_play_prompt).value
        cardToPlay.play(player, self)
      end
    end

    drawnCards.each do |card|
      discard(card)
    end
  end

  def mix_it_all_up(player)
    allPermanents = @players.flat_map do |aPlayer|
      aPlayer.keepers
    end

    allPermanents += @players.flat_map do |aPlayer|
      aPlayer.creepers
    end

    @players.each do |aPlayer|
      aPlayer.clear_permanents
    end

    @logger.debug "how many keepers do I have: #{allPermanents.count} but the length is #{allPermanents.length}"
    @logger.debug "and here they are: \n#{allPermanents}"
    playerCur = @currentPlayerCounter
    random = @random
    while allPermanents.length > 0
      @logger.debug "here are the keepers now: \n#{allPermanents}"
      playerCur = playerCur % @players.length
      randomPosition = random.rand(allPermanents.length)
      aPermanent = allPermanents.delete_at(randomPosition)
      @logger.debug "Trying to add the permanent #{aPermanent}"
      @players[playerCur].add_permanent(aPermanent)
      playerCur += 1
    end

    # might regret this decission but I am going to resolve the war rule for
    # every player since it will check for both permanents anyway it will be a
    # no-op for most players
    @players.each do |aPlayer|
      resolve_war_rule(aPlayer)
      resolve_taxes_rule(aPlayer)
    end

    # TODO:: may need to redraw permanants in both CLI/GUI
  end

  def letsDoThatAgain(player)
    eligibleCards = @discardPile.select do |card|
      @logger.debug "this card is of type: #{card.card_type}"
      card.card_type == "Rule" || card.card_type == "Action"
    end
    pickedCard = @interface.await.choose_from_list(eligibleCards, :replay_prompt).value
    @discardPile = @discardPile.select do |card|
      card != pickedCard
    end
    @logger.info "replaying #{pickedCard}"
    pickedCard.play(player, self)
  end

  def everybody_gets_1(player)
    cardsDrawn = drawCards(player, @players.length)
    playerCur = currentPlayer
    while cardsDrawn.length > 0
      @logger.debug "Game::everbody_gets_1: Number of cards left to deal out: #{cardsDrawn.length}"
      player_to_select_card_for = @players[playerCur]
      if playerCur == currentPlayer
        choose_result = @interface.await.choose_from_list(cardsDrawn, :give_card_to_yourself_prompt)
        if choose_result.state != :fulfilled
          @logger.warn  "choose_result may not have been fulfilled because #{choose_result.reason}"
        end
        selectedCard = choose_result.value
      else
        selectedCard = @interface.await.choose_from_list(cardsDrawn, player_to_select_card_for.give_card_to_player_prompt_name).value
      end
      @logger.debug "Game::everbody_gets_1: Player #{player_to_select_card_for.to_s} has a hand of length: #{player_to_select_card_for.hand.length}}"
      player_to_select_card_for.hand << selectedCard
      playerCur += 1
      playerCur %= @players.length
    end
  end

  def tradeHands(player)
    opponentsText = opponents(player).map do |player|
      player.to_s
    end
    selectedPlayer = @interface.await.choose_from_list(opponents(player), :trade_hands_prompt).value
    otherHand = selectedPlayer.set_hand(player.hand)
    player.set_hand(otherHand)
  end

  def rotateHands(player)
    direction_result = @interface.await.ask_rotation(:rotation_prompt)
    if direction_result != :fulfilled
      @logger.warn("Choose direction may not have been fulfilled because #{direction_result.reason}")
    end
    direction = direction_result.value

    #candidate for debug
    @players.each do |player|
      @logger.debug "What is my hand now #{player}:\n#{StringFormattingUtilities.indexed_display(player.hand)}"
    end

    playerCur = currentPlayer
    tempHand = @players[playerCur].hand
    nextPlayer = -1
    while nextPlayer != currentPlayer
      @logger.debug "the Direction is '#{direction}'"
      if direction == Direction::Clockwise
        @logger.debug "move clockwise"
        nextPlayer  = (playerCur + 1) % @players.length
      else
        @logger.debug "move counterclockwise playerCur: #{playerCur} nextPlayer: #{nextPlayer} "
        nextPlayer  = (playerCur - 1) % @players.length
      end

      @logger.info "player #{playerCur+1} gets =  #{nextPlayer+1}'s hand "
      @logger.debug "giving plyer #{playerCur+1} the hand\n\t#{@players[nextPlayer].hand}"
      @players[playerCur].set_hand(@players[nextPlayer].hand)

      playerCur = nextPlayer
      @logger.debug "here is the value of nextPlayer: #{nextPlayer}"
    end
    @logger.debug "giving plyer #{playerCur+1} the hand\n\t#{tempHand}"
    if direction == Direction::Clockwise
      newNextPlayer = (playerCur - 1) % @players.length
    else
      newNextPlayer = (playerCur + 1) % @players.length
    end
    @players[newNextPlayer].set_hand(tempHand)

    # candidate for debug
    @players.each do |player|
      @logger.debug "What is my hand now #{player}:\n#{StringFormattingUtilities.indexed_display(player.hand)}"
    end
  end

  def take_another_turn(player)
    player.take_another_turn = true
  end

  def exchange_keepers(player)
    if player.keepers.length == 0
      @logger.info "Too bad you have no keepers"
      return
    end
    otherKeepers = false
    opponents(player).select do |player|
      otherKeepers ||= player.keepers.length != 0
    end
    if !otherKeepers
      @logger.info "Too bad you have no keepers"
      return
    end

    eligibleOpponents = opponents(player).select do |aPlayer|
      aPlayer.keepers.length > 0
    end



    eligibleOpponents.select do |aPlayer|
      # TODO:: should consider that any player should be able to see this at any time
      @logger.debug "Here are the keepers: #{aPlayer.to_s} has:\n#{StringFormattingUtilities.indexed_display(aPlayer.keepers)}"
    end

    eligibleOpponents.unshift(:no_one)
    selectedPlayer = :no_one
    loop do
      selected_player_result = @interface.await.choose_from_list(eligibleOpponents, :pick_a_keeper_from_prompt)
      if selected_player_result.state != :fulfilled
        @logger.warn "selected_player may not have been fulfilled because: '#{selected_player_result.reason}'"
      end
      selectedPlayer = selected_player_result.value
      areYouSure = selectedPlayer != :no_one
      if selectedPlayer == :no_one
        areYouSure = @interface.await.ask_yes_no(:are_you_sure_no_trade_prompt).value
      end
      if areYouSure
        break
      end
    end
    if selectedPlayer == :no_one
      return
    end

    if selectedPlayer.keepers.length > 1
      myNewKeeper = @interface.await.choose_from_list(selectedPlayer.keepers, :select_a_keeper_prompt).value
    else
      myNewKeeper = selectedPlayer.keepers.delete_at(0)
    end
    if player.keepers.length > 1
      myOldKeeper = @interface.await.choose_from_list(player.keepers, :keeper_to_give_prompt).value
    else
      myOldKeeper = player.keepers.delete_at(0)
    end
    player.keepers << myNewKeeper
    selectedPlayer.keepers << myOldKeeper

    resolve_war_rule(player)
    resolve_war_rule(selectedPlayer)
    resolve_taxes_rule(player)
    resolve_taxes_rule(selectedPlayer)

    @logger.debug "Here are your Keepers after the exchange\n#{StringFormattingUtilities.indexed_display(player.keepers)}"

  end

  def resolve_war_rule(player)
    playerHasPeace = player.has_peace?
    playerHasWar = player.has_war?
    if (playerHasPeace && playerHasWar)
      selectedPlayer = @interface.await.choose_from_list(opponents(player), player.move_war_prompt_name).value
      @logger.debug "Who is the selected playar #{selectedPlayer}\n who is the original #{player}"

      selectedPlayer.add_creeper(player.take_war)
    end
  end

  def resolve_taxes_rule(player)
    if(player.has_money? && player.has_taxes?)
      discard(player.take_taxes)
      discard(player.take_money)
    end
  end

  def resolve_death_rule(player)
    if(player.has_death?)
      @logger.debug "Player has death, determining eleigible permananets"
      eligiablePermanents = player.permanents.select do |perm|
        perm.card_type != "Creeper" || !perm.is_death?
      end
      @logger.debug "Determined elegible permanents"
      if(eligiablePermanents.size == 0)
        discard(player.take_death)
      else
        selectedCard = @interface.await.choose_from_list(eligiablePermanents, :death_discard_prompt).value
        player.discard_permanent(selectedCard)
      end
    end
  end

end
