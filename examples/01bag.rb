require 'bundler/setup'
require 'ga'

ITEMS = [
  { weight: 3, value: 200},
  { weight: 10, value: 500},
  { weight: 100, value: 30},
  { weight: 200, value: 2000},
  { weight: 300, value: 500},
  { weight: 50, value: 50},
  { weight: 190, value: 1000},
  { weight: 200, value: 1500},
]

MAX_WEIGHT = 400

class Unit
  include GA

  attr_accessor :genome, :fitness

  def self.random_new
    self.new(ITEMS.map do rand(2) == 1 end)
  end

  def initialize(genome)
    @genome = genome.dup
  end

  def fitness
    return @fitness if @fitness
    total_value = 0
    total_weight = 0
    genome.each_with_index do |item, index|
      next unless item
      total_value += ITEMS[index][:value]
      total_weight += ITEMS[index][:weight]
    end
    (total_weight > MAX_WEIGHT or total_value == 0) ? 1 : total_value
  end

  def weight
    total_weight = 0

    genome.each_with_index do |item, index|
      next unless item
      total_weight += ITEMS[index][:weight]
    end

    return total_weight
  end

  def length
    genome.length
  end

  def mutate!
    rand(length).times { genome[rand(length)] ^= true }
  end

  def cross!(unit)
    (rand(length) + 1).times do
      i = rand(length)
      genome[i], unit.genome[i] = unit.genome[i], genome[i]
    end
  end

  def <=>(target)
    self.fitness <=> target.fitness
  end

  def inspect
    "#{object_id} #{self.fitness}|#{self.weight} = #{genome.map {|i| i ? 1 : 0 }.join(', ')}"
  end
end


require 'benchmark'

r = {}
Benchmark.bm do |x|
  x.report('a') do
    puts 'start'
    100.times do
      units = Unit.evolve(32, 100, 0.8, 0.15)
      unit = units.max
      print unit.inspect + "\r"
      r[unit.fitness] ||= 0
      r[unit.fitness] += 1
    end
    puts 'end'
  end
end

puts "100 times result: "
r.each do |val, times|
  puts "#{val}: #{times} times"
end

