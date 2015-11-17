RSpec.describe Geminabox::GemStore do
  describe '#get_path' do
    context 'when the file exists' do
      before do
        FileUtils.touch "#{dir}/billy-1.0.1.gem"
      end

      it 'returns the path to the named gem' do
        expect(gem_store.get_path('billy-1.0.1')).to eq("#{dir}/billy-1.0.1.gem")
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

    it 'saves gems with dependencies' do
      gem_store.add(GemFactory.gem('depgem', '1.0.0', deps: {foo: '>0.0.0'}))
      expect(gem_store).to have_gem('depgem', '1.0.0')
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
    it 'deletes the gem' do
      gem_store.add(GemFactory.gem("hello", "1.0.0"))
      gem_store.delete("hello", "1.0.0")
      expect(gem_store).not_to have_gem("hello", "1.0.0")
    end

    it 'handles double deletes with grace' do
      gem_store.add(GemFactory.gem("hello", "1.0.0"))
      gem_store.delete("hello", "1.0.0")
      expect{ gem_store.delete("hello", "1.0.0") }.not_to raise_error
      expect(gem_store).not_to have_gem("hello", "1.0.0")
      gem_store.delete("hello", "1.0.0")
    end
  end

  describe '#find_gem_versions' do
    it 'returns IndexedGem objects' do
      gem_store.add(GemFactory.gem("a-gem"))
      actual = gem_store.find_gem_versions("a-gem")
      expect(actual).to be_a(Array)
      expect(actual.first).to be_a(Geminabox::IndexedGem)
    end

    it 'lists the versions previously added for the specific gem' do
      gem_store.add(GemFactory.gem("hello", "1.0.0"))
      gem_store.add(GemFactory.gem("hello", "1.0.1"))
      expect(gem_store.find_gem_versions("hello").length).to eq 2
    end

    it 'returns an empty set when no versions exist' do
      expect(gem_store.find_gem_versions("not-a-gem")).to be_empty
    end

    it 'does not return gems that have a different name' do
      gem_store.add(GemFactory.gem("hello", "1.0.0"))
      gem_store.add(GemFactory.gem("world", "1.0.0"))
      expect(gem_store.find_gem_versions("world")).to eq([
        Geminabox::IndexedGem.new("world", "1.0.0", "ruby")
      ])
    end

    it 'does not return gems that have been deleted' do
      gem_store.add(GemFactory.gem("hello", "1.0.0"))
      gem_store.delete("hello", "1.0.0")
      expect(gem_store.find_gem_versions("hello")).to be_empty
    end

    it 'deletes only the version specified' do
      gem_store.add(GemFactory.gem("hello", "1.0.0"))
      gem_store.add(GemFactory.gem("hello", "1.0.1"))
      gem_store.delete("hello", "1.0.0")
      expect(gem_store.find_gem_versions("hello").length).to eq 1
    end

    it 'returns indexed gems with dependency information' do
      gem_store.add(GemFactory.gem('depgem', '1.1.0', deps: {foo: '> 0.0.0', bar: '~> 1.2'}))
      indexed_gems = gem_store.find_gem_versions("depgem")
      expect(indexed_gems).to eq([
        Geminabox::IndexedGem.new('depgem', '1.1.0', 'ruby'),
      ])

      expect(indexed_gems.first.dependencies).to eq [
        ['foo', '> 0.0.0'],
        ['bar', '~> 1.2'],
      ]
    end

    it 'handles multiple gems at once' do
      gem_store.add(GemFactory.gem("hello", "1.0.0"))
      gem_store.add(GemFactory.gem("foo", "1.0.1"))
      expect(gem_store.find_gem_versions(["hello", "foo"]).length).to eq 2
    end
  end

  it "persists between restarts" do
    gem_store.add(GemFactory.gem("world", "1.0.0"))
    @gem_store = Geminabox::GemStore.new(@dir)
    expect(gem_store.get_path('world-1.0.0')).to eq("#{dir}/world-1.0.0.gem")
    expect(gem_store.find_gem_versions("world")).to eq([
      Geminabox::IndexedGem.new("world", "1.0.0", "ruby")
    ])
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
