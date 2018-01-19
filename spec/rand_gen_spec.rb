require 'rand_gen'
require_relative 'rand_gen_spec_helper'
require 'Time'
describe RandomGenerator do
  subject(:generator) {RandomGenerator.new(1000)}

  before(:each) do 
    File.open('./output.txt', 'w') { |file| file.write("") }
    generator.start
  end

  it "generates the expect number of values" do
    data = readfile
    expect(data.length).to eq(1000)
  end

  it "generates numbers with the expected frequency" do
    data = readfile
    freq = get_freq(data)
    expect(freq[1]).to be_within(0.025).of(0.5)
    expect(freq[2]).to be_within(0.025).of(0.25)
    expect(freq[3]).to be_within(0.025).of(0.15)
    expect(freq[4]).to be_within(0.025).of(0.05)
    expect(freq[5]).to be_within(0.025).of(0.05)
  end

  it "places all values in order" do 
    data = readfile
    data.each_cons(2) do |touple|
      time1 = touple[0][2].split(":").join.to_i
      time2 = touple[1][2].split(":").join.to_i
      expect(time1).to be <= time2
    end
  end
end