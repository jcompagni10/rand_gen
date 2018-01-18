require 'rand_gen'
require_relative 'rand_gen_spec_helper'
require 'Time'
describe RandomGenerator do
  subject(:generator) {RandomGenerator.new(2000)}

  before(:each) do 
    File.open('./output.txt', 'w') { |file| file.write("") }
    generator.start
  end

  it "generates the expect number of values" do
    data = readfile
    expect(data.length).to eq(5000)
  end

  it "generates numbers with the expected frequency" do
    data = readfile
    freq = get_freq(data)
    expect(freq[1]).to be_within(0.01).of(0.5)
    expect(freq[2]).to be_within(0.01).of(0.25)
    expect(freq[3]).to be_within(0.01).of(0.15)
    expect(freq[4]).to be_within(0.01).of(0.05)
    expect(freq[5]).to be_within(0.01).of(0.05)
  end

  it "places all values in order" do 
    data = readfile
    sorted = data.sort_by do |line|
      p line[2]
      Time.strptime(line[2], "%H:%M:%N")
    end
    expect(sorted).to eq(data)
  end
end