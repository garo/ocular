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
            scaffold = ef.load_from_file('spec/data/dsl-example.rb')
            i = scaffold.events[0]
            i.exec(i)
        end
    end

    describe "#load_from_block" do
        it "can load sample dsl from block" do
            ef = Ocular::Event::EventFactory.new
            a = false

            scaffold = ef.load_from_block "test_dsl" do
                onEvent EventFactoryTestClass do
                    a = true
                    globalTestFunc("Hello")
                end                             
            end
            i = scaffold.events[0]
            i.exec(i)
            expect(a).to eq(true)
            expect($globalTestFuncTestStr).to eq("Hello")
        end
    end
end

