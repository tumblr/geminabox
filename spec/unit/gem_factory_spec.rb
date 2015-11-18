RSpec.describe GemFactory do
  context 'when there is no cached gem' do
    it 'makes a new gem' do
      expect(GemFactory.gem('foo', "1.0.#{Time.now.to_i}", deps: {other: '>1.2.3', foo: nil})).to be_a(IO)
    end
  end
end
