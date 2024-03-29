# deep_struct.rb
require 'ostruct'

class DeepStruct < OpenStruct
  def initialize(hash=nil)
    @table = {}
    @hash_table = {}

    if hash
      hash.each do |k,v|
        @table[k.to_sym] = (v.is_a?(Hash) ? self.class.new(v) : v)
        if v.is_a?(Array)
          v.map! { |i|
            if i.is_a?(Hash)
              self.class.new(i)
            else
              i
            end
          }
        end
        @hash_table[k.to_sym] = v

        new_ostruct_member(k)
      end
    end
  end

  def to_h
    @hash_table
  end

end