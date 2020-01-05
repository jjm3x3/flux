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
      game.draw_2_and_use_em(player)
    when 3
      game.jackpot(player)
    when 4
      game.ruleBase.removeLimits
    when 5
      game.draw_3_play_2_of_them(player)
    when 6
      game.discard_and_draw(player)
    when 7
      game.use_what_you_take(player)
    when 8
      game.taxation(player)
    when 9
      game.todaysSpecial(player)
    when 10
      game.mix_it_all_up(player)
    when 11
      game.letsDoThatAgain(player)
    when 12
      game.everybody_gets_1(player)
    when 13
      game.tradeHands(player)
    when 14
      game.rotateHands(player)
    when 15
      game.take_another_turn(player)
    when 16
      game.exchange_keepers(player)
    end
    game.discard(self)
  end
end
