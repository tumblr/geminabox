RSpec.describe Geminabox::IndexedGem do
  IndexedGem = Geminabox::IndexedGem

  describe ".new" do
    it "takes the name, version and platform of a gem" do
      expect{ IndexedGem.new("foo", "1.2.3", "ruby") }.not_to raise_error
    end

    it "rejects gems with a blank name" do
      expect{ IndexedGem.new(nil, "1.2.3", "ruby") }.to raise_error(ArgumentError)
      expect{ IndexedGem.new("", "1.2.3", "ruby") }.to raise_error(ArgumentError)
    end

    it "rejects gems with a blank version" do
      expect{ IndexedGem.new("foo", nil, "ruby") }.to raise_error(ArgumentError)
      expect{ IndexedGem.new("foo", "", "ruby") }.to raise_error(ArgumentError)
    end

    it "rejects gems with a blank platform" do
      expect{ IndexedGem.new("foo", "1.2.3", nil) }.to raise_error(ArgumentError)
      expect{ IndexedGem.new("foo", "1.2.3", "") }.to raise_error(ArgumentError)
    end
  end

  describe "#to_s" do
    it "returns the full gem name for a ruby gem" do
      indexed_gem = IndexedGem.new("foo", "1.2.3", "ruby")
      expect(indexed_gem.to_s).to eq("foo-1.2.3.gem")
    end

    it "returns the full gem name for a jruby gem" do
      indexed_gem = IndexedGem.new("foo", "1.2.3", "jruby")
      expect(indexed_gem.to_s).to eq("foo-1.2.3-jruby.gem")
    end
  end

  describe "#==" do
    it "raises an ArgumentError for anything other than an IndexedGem" do
      indexed_gem = IndexedGem.new("foo", "1.2.3", "jruby")
      expect{ indexed_gem == 3 }.to raise_error(ArgumentError)
    end

    it "returns true when passed self" do
      indexed_gem = IndexedGem.new("foo", "1.2.3", "jruby")
      expect(indexed_gem == indexed_gem).to be_truthy
    end

    it "returns true when passed an IndexedGem with the same values" do
      indexed_gem_a = IndexedGem.new("foo", "1.2.3", "jruby")
      indexed_gem_b = IndexedGem.new("foo", "1.2.3", "jruby")
      expect(indexed_gem_a == indexed_gem_b).to be_truthy
    end

    it "returns false when passed an IndexedGem with a different name" do
      indexed_gem_a = IndexedGem.new("foo", "1.2.3", "jruby")
      indexed_gem_b = IndexedGem.new("bar", "1.2.3", "jruby")
      expect(indexed_gem_a == indexed_gem_b).to be_falsy
    end

    it "returns false when passed an IndexedGem with a different name" do
      indexed_gem_a = IndexedGem.new("foo", "1.2.3", "jruby")
      indexed_gem_b = IndexedGem.new("foo", "2.2.3", "jruby")
      expect(indexed_gem_a == indexed_gem_b).to be_falsy
    end

    it "returns false when passed an IndexedGem with a different platform" do
      indexed_gem_a = IndexedGem.new("foo", "1.2.3", "jruby")
      indexed_gem_b = IndexedGem.new("foo", "1.2.3", "ruby")
      expect(indexed_gem_a == indexed_gem_b).to be_falsy
    end
  end

  describe "#hash" do
    it "returns the same value if called twice" do
      indexed_gem = IndexedGem.new("foo", "1.2.3", "jruby")
      expect(indexed_gem.hash).to eq(indexed_gem.hash)
    end

    it "returns the same value if called on two objects of the same value" do
      indexed_gem_a = IndexedGem.new("foo", "1.2.3", "jruby")
      indexed_gem_b = IndexedGem.new("foo", "1.2.3", "jruby")
      expect(indexed_gem_a.hash).to eq(indexed_gem_b.hash)
    end

    it "returns a different value if called on two objects of different values" do
      indexed_gem_a = IndexedGem.new("foo", "1.2.3", "ruby")
      indexed_gem_b = IndexedGem.new("foo", "1.2.3", "jruby")
      expect(indexed_gem_a.hash).not_to eq(indexed_gem_b.hash)
    end
  end
end
