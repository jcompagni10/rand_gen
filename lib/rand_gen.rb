require "byebug"

class RandomGenerator
  attr_reader :store
  def initialize
    @store = []
  end

  def add_to_store(val)
    @store << val
    @store.shift if @store.length > 100
  end

  def handle_output(val)
    p val
    add_to_store(val)
    output_to_disk(val)
  end

  def get_freq
    freq = Hash.new(0)
    @store.each do |val|
      freq[val] += 1
    end
    freq.each do |key, val|
      freq[key] = val / @store.length.to_f
    end
    freq
  end

  def output_to_disk(val)
    time_stamp = Time.now
    path = "./output.txt"
    output = val.to_s + ", " + time_stamp.to_s + "\n"
    File.open(path, 'a') { |file| file.write(output) }
  end

  def rand_gen
    rand100 = rand(1..100)
    if (0..50).cover?(rand100)
      output_val =  1
    elsif (51..75).cover?(rand100)
      output_val =  2
    elsif (76..90).cover?(rand100)
      output_val = 3
    elsif (91..95).cover?(rand100)
      output_val =  4
    elsif (96..100).cover?(rand100)
      output_val =  5
    end
    handle_output(output_val)
  end
end


#test 
rg = RandomGenerator.new
100 .times do
  rg.rand_gen
end
puts rg.get_freq