# GA

Simple Framework for Genetic Algorithm


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ga'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ga

## Usage

### Define your unit

require methods:

* `Unit.random_new`
* `Unit#initialize(genome)` need copy genome
* `Unit#fitness` return fitness
* `Unit#fitness=` #set fitness
* `Unit#cross!(target_unit)`
* `Unit#mutate!`

```
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
end
```

### Evolve

`Unit#evolve(total_units, generations, crossover_rate, muration_rate)` return latest units

```
units = Unit.evolve(32, 100, 0.8, 0.15) 
best = units.max
```

### Print evolve info

```
gz = Unit.new_ga_zoo
ga.debug!
units = ga.evolve(32, 100, 0.8, 0.15)
```

### Use `before_init_fitness` callback

```
gz = Unit.new_ga_zoo
gz.before_init_fitness do |units, generation|
  # parallel calculate fitness
  data = Parallel.map(units, in_processes: 8) {|unit| unit.fitness }
  units.each_with_index {|unit, index| unit.fitness = data[index] }
end
```

### More

see `examples/` folder



## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/xjz19901211/ga.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

