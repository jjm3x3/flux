class PlayerState
    attr_reader :name, :permanents, :cards_in_hand
    def initialize(player)
        @name = player.name
        @permanents = []
        player.permanents.each do |card|
            @permanents << card.to_s
        end
        @cards_in_hand = []
        player.hand.each do |card|
            @cards_in_hand << card.to_s
        end
    end
end
