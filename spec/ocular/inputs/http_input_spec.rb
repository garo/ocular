require 'ocular'
require 'faraday'
require 'pp'

RSpec.describe Ocular::Inputs::HTTP::Input do

    it "can start its server" do
        Ocular::Settings.load_from_file("spec/data/settings.yaml")
        settings = Ocular::Settings.get(:inputs)

        input = ::Ocular::Inputs::HTTP::Input.new(settings)
        input.start()

        response = Faraday.get("http://localhost:#{settings[:http][:port]}/does_not_exists")
        expect(response.status).to eq(404)
        input.stop()
    end
 
    it "can be used to define custom routes" do
        Ocular::Settings.load_from_file("spec/data/settings.yaml")
        settings = Ocular::Settings.get(:inputs)

        input = ::Ocular::Inputs::HTTP::Input.new(settings)
        input.add_get('', '/custompath', {}) do
            "customresponse"
        end
        input.start()

        response = Faraday.get("http://localhost:#{settings[:http][:port]}/custompath")
        expect(response.status).to eq(200)
        expect(response.body).to eq("customresponse")
        input.stop()

    end

    it "can be used to define custom routes" do
        Ocular::Settings.load_from_file("spec/data/settings.yaml")
        settings = Ocular::Settings.get(:inputs)

        input = ::Ocular::Inputs::HTTP::Input.new(settings)
        input.add_get('', '/custompath/:foo1/:foo2', {}) do
            "#{params["foo1"]} is #{params["foo2"]}"
        end
        input.start()

        response = Faraday.get("http://localhost:#{settings[:http][:port]}/custompath/1/derp")
        expect(response.status).to eq(200)
        expect(response.body).to eq("1 is derp")
        input.stop()

    end

    it "can be used to POST data" do
        Ocular::Settings.load_from_file("spec/data/settings.yaml")
        settings = Ocular::Settings.get(:inputs)

        input = ::Ocular::Inputs::HTTP::Input.new(settings)
        input.add_post('', '/custompath', {}) do
            "foo is #{params["foo"]}"
        end
        input.start()

        response = Faraday.post("http://localhost:#{settings[:http][:port]}/custompath",
            {"foo" => "bar"})

        expect(response.status).to eq(200)
        expect(response.body).to eq("foo is bar")
        input.stop()

    end

    it "can be used to DELETE data" do
        Ocular::Settings.load_from_file("spec/data/settings.yaml")
        settings = Ocular::Settings.get(:inputs)

        deleted = nil
        input = ::Ocular::Inputs::HTTP::Input.new(settings)
        input.add_delete('', '/custompath/:id', {}) do
            deleted = params["id"].to_i
            ""
        end
        input.start()

        response = Faraday.delete("http://localhost:#{settings[:http][:port]}/custompath/20")
        expect(response.status).to eq(200)
        expect(response.body).to eq("")
        expect(deleted).to eq(20)
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

            routes = input.routes
            # The routes object maps on how sinatra does its route setup. Read more at
            # https://github.com/sinatra/sinatra/blob/master/lib/sinatra/base.rb#L1585           
            expect(routes["GET"][0][0]).to eq(/\A\/test_dsl\/newroute\z/)
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
            routes = input.routes
            expect(routes["POST"][0][0]).to eq(/\A\/test_dsl\/newroute\z/)
        end        
    end
end

