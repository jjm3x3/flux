
class RuleBase
  attr_reader :drawRule, :playRule, :handLimit, :keeperLimit

  def initialize(game, anInterface)
    @game = game
    @interface = anInterface
  end

  def addRule(card)
    @interface.debug "here is the rule text of the card: \n'#{card.rule_text}'\n ->and has a type of: #{card.rule_type}"
    if card.rule_type == 1
      @game.discard(@drawRuleCard) if @drawRuleCard
      @drawRuleCard = card
      # puts "changes the draw rule to #{drawRule}"
    elsif card.rule_type == 2
      @game.discard(@playRuleCard) if @playRuleCard
      @playRuleCard = card
      # puts "this changes play to '#{@playRule}'"
    elsif card.rule_type == 3
      @game.discard(@handLimitCard) if @handLimitCard
      @handLimitCard = card
      # puts "this changes the hand limmit to: '#{card.rule_text[18]}'"
    elsif card.rule_type == 4
      @game.discard(@keeperLimitCard) if @keeperLimitCard
      @keeperLimitCard = card
      # puts "going to change the keeper limit to #{@keeperLimit}"
    else
      puts "this card not implemented yet #{self}"
    end
  end

  def drawRule
    if @drawRuleCard
      @drawRuleCard.rule_text[5].to_i
    else
      1
    end
  end

  def playRule
    if @playRuleCard
      if @playRuleCard.rule_text[5] == 'a'
        Float::INFINITY
      else
        @playRuleCard.rule_text[5].to_i
      end
    else
      1
    end
  end

  def handLimit
    if @handLimitCard
      @handLimitCard.limit
    else
      Float::INFINITY
    end
  end

  def keeperLimit
    if @keeperLimitCard
      @keeperLimitCard.limit
    else
      Float::INFINITY
    end
  end

  def resetToBasic
    @game.discard(@drawRuleCard) if @drawRuleCard
    @drawRuleCard = nil
    @game.discard(@playRuleCard) if @playRuleCard
    @playRuleCard = nil
    removeLimits
  end

  def removeLimits
    @game.discard(@handLimitCard) if @handLimitCard
    @handLimitCard = nil
    @game.discard(@keeperLimitCard) if @keeperLimitCard
    @keeperLimitCard = nil
  end

  def to_s
    return "\tdraw #{drawRule}\n\tplay #{playRule}\n\thandLimit #{handLimit}\n\tkeeperLimit #{keeperLimit}"
  end
end
