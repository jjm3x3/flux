class PlayerPromptGenerator
  def self.generate_prompts(players, prompt_templates)
    result = {}
    players.each do |player|

      prompt_templates.each do |prompt_name, prompt_hash|
        key = prompt_hash[:key_template].gsub(/{name}/, player.name).to_sym
        prompt = prompt_hash[:value_template].gsub(/{name}/, player.name)
        result[key] = prompt
        player.define_singleton_method(prompt_name.to_sym) do
          return key
        end
      end
    end
    return result
  end
end

class Player
  attr_reader :creepers, :name, :keepers, :hand

  def self.generate_players(number)
      result = []
      (1..number).select do |playerId|
        result << Player.new("player" + playerId.to_s)
      end
      result
  end

  def initialize(name)
    @name = name
    @keepers = []
    @creepers = []
    @hand = []
  end

  def remove_card_from_hand(index)
    @hand.delete_at(index)
  end

  def add_cards_to_hand(cards)
    @hand += cards
  end

  def add_permanent(permanent1)
    if permanent1.card_type == "Keeper"
      @keepers << permanent1
    elsif permanent1.card_type == "Creeper"
      add_creeper(permanent1)
    else
      puts "attempting to play a permanent1 with an unknown type '#{permanent1.card_type}'"
    end
  end

  def add_creeper(creeper)
    @creepers << creeper
  end

  def has_peace?
    @keepers.select do |keeper|
      keeper.is_peace?
    end.size > 0
  end

  def has_war?
    @creepers.select do |creeper|
      creeper.is_war?
    end.size > 0
  end

  def has_money?
    @keepers.select do |keeper|
      keeper.is_money?
    end.size > 0
  end

  def has_taxes?
    @creepers.select do |creeper|
      creeper.is_taxes?
    end.size > 0
  end

  def has_death?
    @creepers.select do |creeper|
      creeper.is_death?
    end.size > 0
  end

  def take_money
    moenyKeeper = @keepers.select do |keeper|
      keeper.is_money?
    end[0]
    @keepers = @keepers.select do |keeper|
      !keeper.is_money?
    end
    moenyKeeper
  end

  def take_taxes
    taxesCreeper = @creepers.select do |creeper|
      creeper.is_taxes?
    end[0]
    @creepers = @creepers.select do |creeper|
      !creeper.is_taxes?
    end
    taxesCreeper
  end

  def take_war
    warCreeper = @creepers.select do |creeper|
      creeper.is_war?
    end[0]
    @creepers = @creepers.select do |creeper|
      !creeper.is_war?
    end
    warCreeper
  end

  def take_death
    deathCreeper = @creepers.select do |creeper|
      creeper.is_death?
    end[0]
    @creepers = @creepers.select do |creeper|
      !creeper.is_death?
    end
    deathCreeper
  end

  def discard_permanent(card)
    @keepers = @keepers.select do |keeper|
      keeper != card
    end
    @creepers = @creepers.select do |creeper|
      creeper != card
    end
  end

  def clear_permanents
    @keepers = []
    @creepers = []
  end

  def permanents
    @keepers + @creepers
  end

  def set_hand(hand)
    oldHand = @hand
    @hand = hand
    oldHand
  end

  def to_s
    @name
  end
end
