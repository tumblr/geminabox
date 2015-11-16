RSpec.describe Geminabox::FilenameGenerator do
  include Geminabox::FilenameGenerator

  describe "#gem_filename" do
    context "with platform of ruby" do
      it do
        expect(gem_filename("foo", "1.2.3", "ruby"))
          .to eq("foo-1.2.3.gem")
      end
    end

    context "with platform of not jruby" do
      it do
        expect(gem_filename("foo", "1.2.3", "jruby"))
          .to eq("foo-1.2.3-jruby.gem")
      end
    end

    context "with platform of nil" do
      it do
        expect{ gem_filename("foo", "1.2.3", nil) }
          .to raise_error(ArgumentError)
      end
    end

    context "with full name passed" do
      it do
        expect(gem_filename("foo-1.2.3", nil, "ruby")).to eq("foo-1.2.3.gem")
      end
    end

    context "with name of nil" do
      it do
        expect{ gem_filename(nil, "1.2.3", "ruby") }
          .to raise_error(ArgumentError)
      end
    end
  end
end
