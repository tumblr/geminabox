RSpec.describe Geminabox::GemStore do
  describe '#get_path' do
    context 'when the file exists' do
      before do
        FileUtils.touch "#{dir}/billy.gem"
      end

      it 'returns the path to the named gem' do
        expect(gem_store.get_path('billy')).to eq("#{dir}/billy.gem")
      end
    end

    context 'when the file does not exists' do
      it 'returns the path to the named gem' do
        expect{gem_store.get_path('billy')}
          .to raise_error(Geminabox::GemNotFound)
      end
    end
  end

  describe '#add' do
    it 'saves the gem to the store' do
      gem_store.add(GemFactory.gem('hello', '1.0.0'))
      expect(gem_store).to have_gem('hello', '1.0.0')
    end

    it 'rejects gems with no content' do
      expect{gem_store.add(StringIO.new(""))}
        .to raise_error(Geminabox::BadGemfile)
    end

    it 'rejects gems where the input object is not an IO' do
      expect{gem_store.add(:fish)}.to raise_error(ArgumentError)
    end

    it 'rejects gems that are not in gem format' do
      expect{gem_store.add(StringIO.new("I am a bad lobser"))}
        .to raise_error(Geminabox::BadGemfile)
    end
  end

  describe '#delete' do
    it 'deletes the gem'
    it 'handles double deletes with grace'
  end

  describe '#find_gem_versions' do
    it 'returns IndexedGem objects'
    it 'lists the versions previously added for the specific gem'
    it 'returns an empty set when no versions exist'
    it 'does not return gems that have been deleted'
  end

  attr_reader :gem_store, :dir

  around do |example|
    Dir.mktmpdir do |dir|
      @dir = dir
      @gem_store = Geminabox::GemStore.new(dir)
      example.run
    end
  end
end
