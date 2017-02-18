module GA
  class Zoo
    attr_reader :unit_cls

    def initialize(unit_cls)
      @unit_cls = unit_cls
      @debug = false
      @before_fitness_callback = nil
    end

    def evolve(units = 32, generations = 100, crossover_rate = 0.8, mutation_rate = 0.15)
      units = units.times.map { unit_cls.random_new } if units.is_a?(Fixnum)

      generations.times do |i|
        @before_fitness_callback.call(units, i + 1) if @before_fitness_callback
        output_debug_info(units, generations, i + 1) if @debug

        units = select_units(units)
        cross(units, crossover_rate)
        mutate(units, mutation_rate)
      end

      return units
    end

    def debug!
      @debug = true
    end

    def before_init_fitness(&block)
      @before_fitness_callback = block
    end


    private

    def select_units(units)
      new_units = units.map do
        ou = units.sample(3).max
        unit_cls.new(ou.genome).tap {|u| u.fitness = ou.fitness }
      end

      # Elite policy
      min_index = new_units.index(new_units.min)
      if min_index != 0 then
        new_units[min_index], new_units[0] = new_units[0], new_units[min_index]
      end
      new_units[0] = unit_cls.new(units.max.genome)
      new_units
    end

    def cross(units, rate)
      last_index = nil

      units.each_with_index do |unit, index|
        next if index == 0
        next if rand() >= rate

        if last_index
          units[last_index].cross!(unit)
          # recalculate fitness
          units[last_index].fitness = unit.fitness = nil
          last_index = nil
        else
          last_index = index
        end
      end
    end

    def mutate(units, rate)
      units.each_with_index do |unit, index|
        next if index == 0
        next if rand() >= rate
        unit.mutate!
        # recalculate fitness
        unit.fitness = nil
      end
    end

    def output_debug_info(units, generations, generation)
      units.sort!
      info = [
        "GA-#{generation}/#{generations} #{units.count}-#{units[-1].genome.length}",
        ' fitness: '
      ]

      if units.length <= 7 then
        info << units.map(&:fitness).join(', ')
      else
        info << "#{units[0..2].map(&:fitness).join(', ')}"
        info << " ... #{units[-5..-1].map(&:fitness).join(', ')}"
      end

      puts info.join
    end
  end
end

