require 'ga'
require 'pry'
require 'parallel'
require 'ffi'

system 'make sharedlib'

# env:
# '12001'
#   1
# 2 3 4
#   5

# actions:
#   1
# 2   3
#   4
# 1 2 3 4 move
# 0 rand move
# 5 clean
ACTIONS = [0, 1, 2, 3, 4, 5]

class Robot
  include GA

  # {env => action}
  attr_accessor :genome, :fitness
  TOTAL_TEST_TIMES = 100

  def self.random_new
    genome = {}
    self.new(genome)
  end

  def initialize(genome)
    @genome = genome.dup
  end

  def fitness
    @fitness ||= RobotTester.test(TOTAL_TEST_TIMES, 200, self)
  end

  def analyse_env(env)
    @genome[env] ||= ACTIONS.sample
  end

  def cross!(target)
    all_genome = (genome.keys + target.genome.keys).uniq
    len = all_genome.length

    (len / 4 + rand(len / 4)).times do
      gene = all_genome[rand(len)]
      genome[gene] ||= ACTIONS.sample
      target.genome[gene] ||= ACTIONS.sample
      genome[gene], target.genome[gene] = target.genome[gene], genome[gene]
    end
  end

  def mutate!
    all_genome = genome.keys
    len = all_genome.length

    (len / 4 + rand(len / 2)).times do
      gene = all_genome[rand(len)]
      genome[gene] = (ACTIONS - [genome[gene]]).sample
    end
  end
end

module RobotTester
  extend FFI::Library

  ffi_lib File.expand_path('../librt.so', __FILE__)
  callback :analyse_cb, [:string], :int
  attach_function :robot_test, [:int, :int, :pointer, :pointer, :int, :analyse_cb], :int

  def self.test(times, step, robot)
    genome = robot.genome
    len = genome.length
    env_pointer = FFI::MemoryPointer.new(:pointer, len)
    action_pointer = FFI::MemoryPointer.new(:int, len)

    eps = genome.keys.map {|k| FFI::MemoryPointer.from_string(k) }
    env_pointer.write_array_of_pointer eps
    action_pointer.write_array_of_int genome.values

    robot_test(
      times, step,
      env_pointer, action_pointer, len,
      robot.method(:analyse_env)
    )
  end
end

ga_zoo = Robot.new_ga_zoo
ga_zoo.debug!
# ga_zoo.cataclysm(10, 1)

ga_zoo.before_init_fitness do |units, generation|
  vs = Parallel.map(units, in_processes: 8) do |unit|
    [unit.fitness, unit.genome]
  end
  units.each_with_index do |unit, index|
    unit.fitness, unit.genome = vs[index]
  end
end

srand(Time.now.to_i)
robots = ga_zoo.evolve(200, 1000, 0.9, 0.2)
robot = robots.max

puts "========= result ============="
puts "fitness: #{robot.fitness}"
puts robot.genome
puts "score: %i" % RobotTester.test(1, 200, robot)
binding.pry
puts 'end'

