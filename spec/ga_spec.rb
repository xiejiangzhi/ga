RSpec.describe GA do
  it "has a version number" do
    expect(GA::VERSION).not_to be nil
  end

  describe '.new_ga_zoo' do
    it "should new GA::Zoo" do
      expect(GA::Zoo).to receive(:new).with(Unit)
      Unit.new_ga_zoo
    end
  end

  describe '.evolve' do
    it 'should call GA::Zoo#evolve' do
      zoo = double('zoo', evolve: [])
      expect(GA::Zoo).to receive(:new).with(Unit).and_return(zoo)
      expect(zoo).to receive(:evolve).with(10, 10, 0.7, 0.1)
      Unit.evolve(10, 10, 0.7, 0.1)
    end
  end
end
