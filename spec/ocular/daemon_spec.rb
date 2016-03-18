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

    it "can do get_name_from_file" do
        daemon = ::Ocular::Daemon.new('')
        expect(daemon.get_name_from_file("script2.rb")).to eq("script2")

        daemon = ::Ocular::Daemon.new('root')
        expect(daemon.get_name_from_file("root/script2.rb")).to eq("script2")
        expect(daemon.get_name_from_file("root/foo/script2.rb")).to eq("foo/script2")

    end

    it "will load script files in" do
        Ocular::Settings.load_from_file("spec/data/settings.yaml")

        daemon = ::Ocular::Daemon.new('spec/data/daemon_test_scripts')
        daemon.load_script_files()
        expect(daemon.eventfactory.get("script1")).not_to eq(nil) 
        expect(daemon.eventfactory.get("subdir/script2")).not_to eq(nil) 
        expect(daemon.eventfactory.get("subdir/script2").script_name).to eq("subdir/script2") 

        daemon.start_input_handlers()

        response = Faraday.get("http://localhost:#{::Ocular::Settings.get(:inputs)[:http][:port]}/subdir/script2/handler")
        expect(response.status).to eq(200)
        expect(response.body).to eq("route called")

        daemon.stop_input_handlers()
    end

    it "can handle syntax errors in script files" do
        Ocular::Settings.load_from_file("spec/data/settings.yaml")

        daemon = ::Ocular::Daemon.new('spec/data/daemon_invalid_test_scripts')
        begin
            daemon.load_script_files()
            expect(false).to eq(true)
        rescue NameError => e

        end
    end

end

