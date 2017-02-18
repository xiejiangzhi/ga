require 'ga'

class Unit
  include GA

  attr_accessor :genome, :fitness

  def self.random_new
    self.new(3.times.map { rand(3) })
  end

  def initialize(genome)
    @genome = genome.dup
  end

  def fitness
    @fitness ||= genome.reduce(&:+)
  end

  def cross!(target)
    (rand(3) + 1).times do |i|
      genome[i], target.genome[i] = target.genome[i], genome[i]
    end
  end

  def mutate!
    (rand(3) + 1).times do
      i = rand(3)
      genome[i] = (genome[i] + rand(3)) % 3
    end
  end

  def <=>(target)
    self.fitness <=> target.fitness
  end
end

