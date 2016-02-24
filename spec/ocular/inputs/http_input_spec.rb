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
        input.add_get('/custompath', {}) do
            return "customresponse"
        end
        input.start()

        response = Faraday.get("http://localhost:#{settings[:http][:port]}/custompath")
        expect(response.status).to eq(200)
        expect(response.body).to eq("customresponse")
        input.stop()

    end

    describe "#dsl" do
        it "#onGET can be used to define a route" do
            a = nil
            ef = Ocular::Event::EventFactory.new
            proxy = ef.load_from_block "test_dsl" do
                onGET "/newroute" do
                    a = "test"
                    "route called"
                end                             
            end
            
            input = ef.handlers.get(::Ocular::Inputs::HTTP::Input)

            input.start()
            port = ::Ocular::Settings.get(:inputs)[:http][:port]
            response = Faraday.get("http://localhost:#{port}/test_dsl/newroute")
            expect(response.status).to eq(200)
            expect(response.body).to eq("route called")
            expect(a).to eq("test")
            input.stop()

            routes = input.instance_variable_get(:@app_class).instance_variable_get(:@routes)
            # The routes object maps on how sinatra does its route setup. Read more at
            # https://github.com/sinatra/sinatra/blob/master/lib/sinatra/base.rb#L1585           
            expect(routes["GET"][0][0]).to eq(/\A\/test_dsl\/newroute\z/)
            expect(routes["HEAD"][0][0]).to eq(/\A\/test_dsl\/newroute\z/)
        end

        it "#onPOST can be used to define a route" do
            a = nil
            ef = Ocular::Event::EventFactory.new
            proxy = ef.load_from_block "test_dsl" do
                onPOST "/newroute" do
                    ""
                end                             
            end

            input = ef.handlers.get(::Ocular::Inputs::HTTP::Input)
            routes = input.instance_variable_get(:@app_class).instance_variable_get(:@routes)
            expect(routes["POST"][0][0]).to eq(/\Atest_dsl\/newroute\z/)
        end        
    end

end

