def readfile
  output = []
  File.open('./output.txt') do |file|
    file.each_line do |line|
      data = line.chomp.split(", ")
      output << data
    end
  end
  output 
end

def get_freq(output)
  freq = { 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0 }
  output.each do |item|
    freq[item[0].to_i] += 1
  end
  freq.each do |key, val|
    freq[key] = val / output.length.to_f
  end
  freq
end  