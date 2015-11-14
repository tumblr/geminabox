RSpec.describe Geminabox::GemStore do
  attr_reader :gem_store, :dir

  describe "#get_path" do
    context "when the file exists" do
      before do
        FileUtils.touch "#{dir}/billy.gem"
      end

      it "returns the path to the named gem" do
        expect(gem_store.get_path("billy")).to eq("#{dir}/billy.gem")
      end
    end

    context "when the file does not exists" do
      it "returns the path to the named gem" do
        expect{gem_store.get_path("billy")}
          .to raise_error(Geminabox::GemNotFound)
      end
    end
  end

  around do |example|
    Dir.mktmpdir do |dir|
      @dir = dir
      @gem_store = Geminabox::GemStore.new(dir)
      example.run
    end
  end
end
