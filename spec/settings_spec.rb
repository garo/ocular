require 'ocular'

RSpec.describe Ocular::Settings do

    it "get receiver settings" do
        ::Ocular::Settings.load_from_file('spec/data/settings.yaml')
        a = ::Ocular::Settings.get(:test_setting)
        expect(a).to eq("Hello, World!")
    end
end

