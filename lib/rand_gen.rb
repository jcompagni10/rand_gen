def rand_gen
  rand100 = rand(1..100)
  case 
  when (0..50).cover?(rand100)
    puts 1
  when (51..75).cover?(rand100)
    puts 2
  when (76..90).cover?(rand100)
    puts 3
  when (91..95).cover?(rand100)
    puts 4
  when (96..100).cover?(rand100)
    puts 4
  end
end

  100.times do
    rand_gen
  end