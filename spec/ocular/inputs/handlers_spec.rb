require 'ocular'
require 'faraday'
require 'pp'

RSpec.describe Ocular::Inputs::Handlers do

    it "can be created" do
        handlers = ::Ocular::Inputs::Handlers.new
        expect(handlers).not_to eq(nil)
    end

    it "can get handler instance by class" do
        handlers = ::Ocular::Inputs::Handlers.new
        a = handlers.get(::Ocular::Inputs::HTTP::Input)
        expect(a).not_to eq(nil)

        b = handlers.get(::Ocular::Inputs::HTTP::Input)
        expect(a).to eq(b)
    end

    it "can start handlers" do

        class TestInput < ::Ocular::Inputs::Base
            attr_reader :started

            def initialize(settings)
                @started = false
            end

            def start()
                @started = true
            end

            def stop()
                @started = false
            end            
        end

        handlers = ::Ocular::Inputs::Handlers.new
        a = handlers.get(TestInput)
        expect(a).not_to eq(nil)
        expect(a.started).to eq(false)

        handlers.start()
        expect(a.started).to eq(true)

        handlers.stop()
        expect(a.started).to eq(false)

    end

end

