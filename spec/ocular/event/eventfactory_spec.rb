#require_relative "../lib/game.rb"
require 'ocular'

class EventFactoryTestClass
    attr_accessor :name
end

$globalTestFuncTestStr = ""
def globalTestFunc(msg)
    $globalTestFuncTestStr << msg
end

RSpec.describe Ocular::Event::EventFactory do


    describe "#load_from_file" do
        it "can load sample dsl" do
            ef = Ocular::Event::EventFactory.new
            proxy = ef.load_from_file('spec/data/dsl-example.rb')
            eventbase = proxy.events[0]

            context = Ocular::DSL::RunContext.new
            eventbase.exec(context)
        end
    end

    describe "#load_from_block" do
        it "can load sample dsl from block and run global function" do
            ef = Ocular::Event::EventFactory.new
            a = false

            proxy = ef.load_from_block "test_dsl" do
                onEvent EventFactoryTestClass do
                    a = true
                    globalTestFunc("Hello")
                end
            end
            eventbase = proxy.events[0]

            context = Ocular::DSL::RunContext.new
            eventbase.exec(context)
            expect(a).to eq(true)
            expect($globalTestFuncTestStr).to eq("Hello")
        end
    end
end

