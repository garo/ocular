require 'ocular'
require 'faraday'
require 'pp'

RSpec.describe Ocular::Inputs::HTTP::Input do

    it "can start its server" do
        settings = {:http => {:port => 8082}}

        input = ::Ocular::Inputs::HTTP::Input.new(settings)
        input.start()

        response = Faraday.get("http://localhost:#{settings[:http][:port]}/noop")
        expect(response.status).to eq(200)
        input.stop()
    end

    it "can be used to define custom routes" do
        settings = {:http => {:port => 8082}}
        input = ::Ocular::Inputs::HTTP::Input.new(settings)
        input.add_route('GET', '/custompath', {}) do
            return "customresponse"
        end
        input.start()

        response = Faraday.get("http://localhost:#{settings[:http][:port]}/custompath")
        expect(response.status).to eq(200)
        expect(response.body).to eq("customresponse")
        input.stop()

    end
=begin
    describe "#dsl" do
        it "#http get can be used to define a route" do
            a = nil
            ef = Ocular::Event::EventFactory.new
            proxy = ef.load_from_block "test_dsl" do
                onGET "/newroute" do
                    a = "route called"
                end                             
            end
            eventbase = proxy.events[0]

            context = Ocular::DSL::RunContext.new
            eventbase.exec(context)
            expect(a).to eq("route called")
        end
    end
=end
end

