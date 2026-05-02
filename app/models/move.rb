class Move < ApplicationRecord
    belongs_to :type
    has_many :pokemon_moves
    has_many :learned_by, through: :pokemon_moves, source: :pokemon # define m:m relationship
    has_one :damage, through: :type, source: :damage_relation # define m:m relationship

    
    def self.get_learned_by(move_datum: nil)
      moves = @self.all
      pkmn = Pokemon.all
      return nil if moves.empty? || pkmn.empty?

      #####################################
      moves.each do |move|
        learned_by = HTTParty.get(move.url)['learned_by_pokemon']
        break if learned_by.blank?

        learned_by.each do |lb| 
          name = lb["name"]
          curr = pkmn.find_by(name: name)
          next if curr.blank?

          curr.moves << move  
        end

      end

    end



end
