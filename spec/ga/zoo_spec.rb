RSpec.describe GA::Zoo do
  let(:gz) { GA::Zoo.new(Unit) }

  describe '#initialize' do
    it 'should save unit class' do
      expect(gz.unit_cls).to eql(Unit)
    end
  end

  describe '#debug!' do
    it 'should set @debug to true' do
      expect {
        gz.debug!
      }.to change { gz.instance_variable_get(:@debug) }.to(true)
    end
  end

  describe '#before_init_fitness' do
    it 'should save callback' do
      p = Proc.new { 1 }
      expect {
        gz.before_init_fitness(&p)
      }.to change { gz.instance_variable_get(:@before_fitness_callback) }.to(p)

    end
  end

  describe '#evolve' do
    it 'should create units if args[0] is a number' do
      units = gz.evolve(4, 0)
      expect(units.length).to eql(4)

      units = gz.evolve(7, 0)
      expect(units.length).to eql(7)
    end

    it 'should use units if args[0] is units array' do
      units = 3.times.map { Unit.random_new }
      new_units = gz.evolve(units, 0)
      expect(new_units).to eql(units)

      units = 5.times.map { Unit.random_new }
      new_units = gz.evolve(units, 1)
      expect(new_units).to_not eql(units)
      expect(new_units.length).to eql(units.length)
    end

    it 'should call before_fitness_callback if set before_init_fitness' do
      p = Proc.new { 1 }
      units = 3.times.map { Unit.random_new }

      gz.before_init_fitness(&p)

      expect(p).to receive(:call).with(units, 1).ordered
      expect(units[0]).to receive(:fitness).at_least(1).ordered.and_call_original
      expect(p).to receive(:call).with(kind_of(Array), 2).ordered

      gz.evolve(units, 2)
    end

    it 'should output debug info if call #debug!' do
      gz.debug!

      units = 4.times.map { Unit.random_new }
      expect {
        gz.evolve(units, 1)
      }.to output(
        /^\[.+\]GA-1\/1 4-3 fitness: #{units.map(&:fitness).sort.join(', ')}\s$/
      ).to_stdout

      units = 10.times.map { Unit.random_new }
      head = units.sort[0..2].map(&:fitness).join(', ')
      foot = units.sort[-5..-1].map(&:fitness).join(', ')
      midd = units.sort[units.length / 2].fitness
      expect {
        gz.evolve(units, 1)
      }.to output(/^\[.+\]GA-1\/1 10-3 fitness: #{head} ... #{midd} ... #{foot}\s$/).to_stdout
    end

    it 'should generate better next generation' do
      units = 2.times.map { Unit.random_new }
      new_units = gz.evolve(units, 1, 0, 0)
      expect(new_units.map(&:fitness)).to eql([units.max.fitness] * 2)

      10.times do
        units = 6.times.map { Unit.random_new }
        new_units = gz.evolve(units, 5)
        expect(new_units.map(&:fitness).reduce(&:+)).to be >= units.map(&:fitness).reduce(&:+)
      end
    end

    it 'should generate next generation with crossover and mutation' do
      expect(gz).to receive(:cross).exactly(2)
      expect(gz).to receive(:mutate).exactly(2)
      gz.evolve(3, 2)

      expect(gz).to receive(:cross).exactly(5)
      expect(gz).to receive(:mutate).exactly(5)
      gz.evolve(3, 5)
    end
  end
end

