require 'bundler/setup'
require 'ga'

require 'parallel'

MAP_SIZE = 7


# 0 empty 1 dust 2 wall
# [x][y]
def new_map
  MAP_SIZE.times.map { [0] * MAP_SIZE }
end

def rand_map(map, dust_rate = 0.5)
  map.each do |cols|
    cols.length.times {|i| cols[i] = rand() <= dust_rate ? 1 : 0 }
  end
end

def show_map(map, bx = nil, by = nil)
  puts('-' * 20)
  MAP_SIZE.times do |y|
    MAP_SIZE.times do |x|
      if bx == x and by == y then
        print(map[x][y], '* ')
      else
        print(map[x][y], '  ')
      end
    end
    print("\n")
  end
  puts('-' * 20)
end


# 0 random move
# 9 clear
# 1 2 3
# 4   5
# 6 7 8
ACTIONS_DATA = {
  0 => nil,
  9 => nil,

  # 1 => [-1, -1],
  2 => [0, -1],
  # 3 => [1, -1],

  4 => [-1, 0],
  # 5 => [1, 0],

  6 => [-1, 1],
  # 7 => [0, 1],
  8 => [1, 1]
}

ACTIONS = ACTIONS_DATA.keys
MOVE_ACTIONS = [2, 4, 6, 8]

class Robot
  include GA

  # genome
  #
  # {env => action}
  #
  # env: '10122'
  #     1
  #   2 3 4
  #     5
  # action:

  attr_accessor :genome, :fitness
  TOTAL_VALUE_TEST = 150

  def self.random_new
    self.new({})
  end

  def initialize(genome)
    @genome = genome.dup
  end

  def fitness
    tester = RobotTester.new(self)
    @fitness ||= TOTAL_VALUE_TEST.times.map { tester.test }.reduce(&:+) / TOTAL_VALUE_TEST
  end

  def <=>(target)
    fitness <=> target.fitness
  end

  def analyse_env(env)
    @genome[env] ||= if env[2] == '1' then
      9
    elsif env == '00000' then
      0
    else
      MOVE_ACTIONS.sample
    end
  end

  def cross!(target)
    all_genome = (genome.keys + target.genome.keys).uniq
    len = all_genome.length
    min_robot = [self, target].min

    rand(len).times do
      gene = all_genome[rand(len)]

      if genome[gene] == target.genome[gene] and rand() < 0.3 then
        min_robot.genome[gene] = ACTIONS.sample
      else
        genome[gene], target.genome[gene] = target.genome[gene], genome[gene]
      end
    end
  end

  def mutate!
    all_genome = genome.keys
    len = all_genome.length

    (rand(len) + 1).times do
      gene = all_genome[rand(len)]
      genome[gene] = ACTIONS.sample
    end
  end
end

class RobotTester
  attr_reader :map, :robot

  def initialize(robot)
    @map = new_map
    @robot = robot
  end

  def test(step = 70, show = false)
    rand_map(map)
    x = rand(map.length)
    y = rand(map.length)
    @total_value = 0

    step.times do
      env = scan_env(x, y)
      action = robot.analyse_env(env)
      rx, ry = execute_action(x, y, action)

      x += rx
      y += ry

      if x < 0 or y < 0 or x >= MAP_SIZE or y >= MAP_SIZE then
        x -= rx
        y -= ry
        @total_value -= 10
      elsif map[x][y] == 1
        @total_value += 1
      end

      if show then
        show_map(map, x, y)
        sleep 0.2
      end
    end

    @total_value
  end

  def execute_action(x, y, action)
    case action
    when 9 then
      if map[x][y] == 1 then
        map[x][y] = 0
        @total_value += 10
      else
        @total_value -= 10
      end

      [0, 0]
    when 0 then
      @total_value -= 1
      ACTIONS_DATA[MOVE_ACTIONS.sample]
    else
      @total_value -= 1
      ACTIONS_DATA[action]
    end
  end

  SCAN_COORDS = [
    [0, -1], [-1, 0], [0, 0], [1, 0], [0, 1]
  ]
  def scan_env(x, y)
    SCAN_COORDS.map do |sx, sy|
      rx = x + sx
      ry = y + sy

      if rx < 0 || ry < 0 || rx >= MAP_SIZE || ry >= MAP_SIZE then
        2
      else
        map[rx][ry]
      end
    end.join
  end
end


ga_zoo = Robot.new_ga_zoo
ga_zoo.debug!

ga_zoo.before_init_fitness do |units|
  vs = Parallel.map(units, in_processes: 8) do |unit|
    [unit.fitness, unit.genome]
  end
  units.each_with_index do |unit, index|
    unit.fitness, unit.genome = vs[index]
  end
end

robots = ga_zoo.evolve(256, 300)
robot = robots.max

RobotTester.new(robot).test(100, true)

puts "========= result ============="
puts "fitness: #{robot.fitness}"
puts robot.genome


