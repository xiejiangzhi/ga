require "ga/version"
require "ga/zoo"

module GA
  def self.included(cls)
    cls.extend(ClassMethods)
  end

  def <=>(target)
    fitness <=> target.fitness
  end

  module ClassMethods
    def new_ga_zoo
      GA::Zoo.new(self)
    end

    def evolve(total_units = 32, generations = 100, crossover_rate = 0.8, muration_rate = 0.1)
      new_ga_zoo.evolve(total_units, generations, crossover_rate, muration_rate)
    end
  end
end

