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

end

