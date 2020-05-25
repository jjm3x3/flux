require "./cards/cards.rb"

class Action < Card

  def initialize(id, name, rule_text)
    super(4,name)
    @id = id
    @rule_text = rule_text
  end

  def play(player, game)
    case @id
    when 1
      game.ruleBase.resetToBasic
    when 2
      game.await.draw_2_and_use_em(player)
    when 3
      game.await.jackpot(player)
    when 4
      game.ruleBase.removeLimits
    when 5
      game.await.draw_3_play_2_of_them(player)
    when 6
      game.await.discard_and_draw(player)
    when 7
      game.await.use_what_you_take(player)
    when 8
      game.await.taxation(player)
    when 9
      game.await.todaysSpecial(player)
    when 10
      game.await.mix_it_all_up(player)
    when 11
      game.await.letsDoThatAgain(player)
    when 12
      game.await.everybody_gets_1(player)
    when 13
      game.await.tradeHands(player)
    when 14
      game.await.rotateHands(player)
    when 15
      game.await.take_another_turn(player)
    when 16
      game.await.exchange_keepers(player)
    end
    game.discard(self)
  end
end
