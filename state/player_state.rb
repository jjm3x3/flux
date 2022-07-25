class PlayerState
    attr_reader :name, :permanents
    def initialize(player)
        @name = player.name
        @permanents = []
        player.permanents.each do |card|
            @permanents << card.to_s
        end
    end
end