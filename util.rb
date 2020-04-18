
class Util
  def self.are_all_nil(list)
    list.inject(true) do |sum,x| 
      sum = (x == nil && sum)
    end
  end
end

