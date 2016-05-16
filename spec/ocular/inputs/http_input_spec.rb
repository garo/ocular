require 'ocular'
require 'faraday'
require 'pp'

RSpec.describe Ocular::Inputs::HTTP::Input do

    it "can start its server" do
        Ocular::Settings.load_from_file("spec/data/settings.yaml")

        port = Ocular::Settings.get(:inputs)[:http][:port]
        input = ::Ocular::Inputs::HTTP::Input.new(Ocular::Settings)
        input.start()

        response = Faraday.get("http://localhost:#{port}/does_not_exists")
        expect(response.status).to eq(404)
        input.stop()
    end
 
    it "can be used to define custom routes" do
        Ocular::Settings.load_from_file("spec/data/settings.yaml")

        proxy = ::Ocular::Event::DefinitionProxy.new("script_name", ::Ocular::Inputs::Handlers.new)
        input = ::Ocular::Inputs::HTTP::Input.new(Ocular::Settings)
        input.add_get('', '/custompath', {}, proxy) do
            "customresponse"
        end
        input.start()

        port = Ocular::Settings.get(:inputs)[:http][:port]
        response = Faraday.get("http://localhost:#{port}/custompath")
        expect(response.status).to eq(200)
        expect(response.body).to eq("customresponse")
        input.stop()

    end

    it "contains built-in /check path" do
        Ocular::Settings.load_from_file("spec/data/settings.yaml")

        proxy = ::Ocular::Event::DefinitionProxy.new("script_name", ::Ocular::Inputs::Handlers.new)
        input = ::Ocular::Inputs::HTTP::Input.new(Ocular::Settings)
        input.start()

        port = Ocular::Settings.get(:inputs)[:http][:port]
        response = Faraday.get("http://localhost:#{port}/check")
        expect(response.status).to eq(200)
        expect(response.body).to eq("OK\n")
        input.stop()

    end    

    it "can be used to define custom routes with arguments" do
        Ocular::Settings.load_from_file("spec/data/settings.yaml")

        proxy = ::Ocular::Event::DefinitionProxy.new("script_name", ::Ocular::Inputs::Handlers.new)
        input = ::Ocular::Inputs::HTTP::Input.new(Ocular::Settings)
        input.add_get('', '/custompath/:foo1/:foo2', {}, proxy) do
            "#{params["foo1"]} is #{params["foo2"]}"
        end
        input.start()

        port = Ocular::Settings.get(:inputs)[:http][:port]
        response = Faraday.get("http://localhost:#{port}/custompath/1/derp")
        expect(response.status).to eq(200)
        expect(response.body).to eq("1 is derp")
        input.stop()

    end

    it "can be used to POST data" do
        Ocular::Settings.load_from_file("spec/data/settings.yaml")

        proxy = ::Ocular::Event::DefinitionProxy.new("script_name", ::Ocular::Inputs::Handlers.new)
        input = ::Ocular::Inputs::HTTP::Input.new(Ocular::Settings)
        input.add_post('', '/custompath', {}, proxy) do
            "foo is #{params["foo"]}"
        end
        input.start()

        port = Ocular::Settings.get(:inputs)[:http][:port]
        response = Faraday.post("http://localhost:#{port}/custompath",
            {"foo" => "bar"})

        expect(response.status).to eq(200)
        expect(response.body).to eq("foo is bar")
        input.stop()

    end

    it "can be used to DELETE data" do
        Ocular::Settings.load_from_file("spec/data/settings.yaml")

        deleted = nil
        proxy = ::Ocular::Event::DefinitionProxy.new("script_name", ::Ocular::Inputs::Handlers.new)        
        input = ::Ocular::Inputs::HTTP::Input.new(Ocular::Settings)
        input.add_delete('', '/custompath/:id', {}, proxy) do
            deleted = params["id"].to_i
            "deleted #{deleted}"
        end
        input.start()

        port = Ocular::Settings.get(:inputs)[:http][:port]
        response = Faraday.delete("http://localhost:#{port}/custompath/20")
        expect(response.status).to eq(200)
        expect(response.body).to eq("deleted 20")
        input.stop()
    end      

    it "can use content_type to set it" do
        Ocular::Settings.load_from_file("spec/data/settings.yaml")

        deleted = nil
        proxy = ::Ocular::Event::DefinitionProxy.new("script_name", ::Ocular::Inputs::Handlers.new)        
        input = ::Ocular::Inputs::HTTP::Input.new(Ocular::Settings)
        input.add_get('', '/custompath', {}, proxy) do
            content_type 'text/plain'
            "Hello"
        end
        input.start()

        port = Ocular::Settings.get(:inputs)[:http][:port]
        response = Faraday.get("http://localhost:#{port}/custompath")
        expect(response.status).to eq(200)
        expect(response.body).to eq("Hello")
        expect(response.env.response_headers["content-type"]).to eq("text/plain")
        input.stop()
    end

    it "can be used to return custom status codes" do
        Ocular::Settings.load_from_file("spec/data/settings.yaml")

        deleted = nil
        proxy = ::Ocular::Event::DefinitionProxy.new("script_name", ::Ocular::Inputs::Handlers.new)        
        input = ::Ocular::Inputs::HTTP::Input.new(Ocular::Settings)
        input.add_delete('', '/custompath/:id', {}, proxy) do
            if params["id"].to_i == 200
                [200, "Everything is fine"]
            elsif params["id"].to_i == 409
                409
            end
        end
        input.start()
        port = Ocular::Settings.get(:inputs)[:http][:port]


        response = Faraday.delete("http://localhost:#{port}/custompath/200")
        expect(response.status).to eq(200)
        expect(response.body).to eq("Everything is fine")

        response = Faraday.delete("http://localhost:#{port}/custompath/409")
        expect(response.status).to eq(409)
        expect(response.body).to eq("")

        input.stop()
    end     
 
    describe "#dsl" do
        it "#onGET can be used to define a route" do
            ef = Ocular::Event::EventFactory.new
            proxy = ef.load_from_block "test_dsl" do
                onGET "/newroute" do
                    "route called"
                end
            end
            
            input = ef.handlers.get(::Ocular::Inputs::HTTP::Input)

            input.start()
            port = ::Ocular::Settings.get(:inputs)[:http][:port]
            response = Faraday.get("http://localhost:#{port}/test_dsl/newroute")
            expect(response.status).to eq(200)
            expect(response.body).to eq("route called")
            input.stop()

            routes = input.routes
            # The routes object maps on how sinatra does its route setup. Read more at
            # https://github.com/sinatra/sinatra/blob/master/lib/sinatra/base.rb#L1585           
            expect(routes["GET"][0][0]).to eq(/\A\/test_dsl\/newroute\z/)
        end

        it "#onGET can be used to define a route which uses return" do
            ef = Ocular::Event::EventFactory.new
            proxy = ef.load_from_block "test_dsl" do
                fork true
                onGET "/" do
                    return "{}"
                end
            end

            input = ef.handlers.get(::Ocular::Inputs::HTTP::Input)

            input.start()
            port = ::Ocular::Settings.get(:inputs)[:http][:port]
            response = Faraday.get("http://localhost:#{port}/test_dsl/")
            expect(response.status).to eq(200)
            expect(response.body).to eq("{}")
            input.stop()

            routes = input.routes
            # The routes object maps on how sinatra does its route setup. Read more at
            # https://github.com/sinatra/sinatra/blob/master/lib/sinatra/base.rb#L1585
            expect(routes["GET"][0][0]).to eq(/\A\/test_dsl\/\z/)
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

        it "#onOPTIONS can be used to define a route" do
            a = nil
            ef = Ocular::Event::EventFactory.new
            proxy = ef.load_from_block "test_dsl" do
                onOPTIONS "/newroute" do
                    @headers["Foo"] = "Bar"
                    ""
                end
            end

            input = ef.handlers.get(::Ocular::Inputs::HTTP::Input)
            routes = input.routes
            expect(routes["OPTIONS"][0][0]).to eq(/\A\/test_dsl\/newroute\z/)
        end        

        it "#onGET will register route into DefinitionProxy for tracking" do
            ef = Ocular::Event::EventFactory.new
            proxy = ef.load_from_block "test_dsl" do
                onPOST "/newroute" do
                    ""
                end
            end

            expect(ef.get("test_dsl").events["POST"]["/test_dsl/newroute"]).not_to eq(nil)
        end

    end
end

