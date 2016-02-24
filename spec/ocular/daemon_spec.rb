require 'ocular'
require 'faraday'
require 'pp'

RSpec.describe Ocular::Daemon do

    it "can be created" do
        daemon = ::Ocular::Daemon.new('')
        expect(daemon).not_to eq(nil)
    end

    it "can find script files" do
        daemon = ::Ocular::Daemon.new('')
        files = daemon.get_script_files("spec/data")
        expect(daemon).not_to eq(nil)
    end

    it "can has an EventFactory" do
        daemon = ::Ocular::Daemon.new('')
        expect(daemon.eventfactory).not_to eq(nil)
    end

    it "will load script files in" do
        Ocular::Settings.load_from_file("spec/data/settings.yaml")

        daemon = ::Ocular::Daemon.new('spec/data/daemon_test_scripts')
        daemon.load_script_files()
        expect(daemon.eventfactory.get("script1.rb")).not_to eq(nil) 
        expect(daemon.eventfactory.get("script2.rb")).not_to eq(nil) 

        daemon.start_input_handlers()

        response = Faraday.get("http://localhost:#{::Ocular::Settings.get(:inputs)[:http][:port]}/script2")
        expect(response.status).to eq(200)
        expect(response.body).to eq("route called")

        daemon.stop_input_handlers()

    end


end

