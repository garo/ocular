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
        i = handlers.get(::Ocular::Inputs::HTTP::Input)
        expect(handlers).not_to eq(nil)
    end

end

