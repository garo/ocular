#require_relative "../lib/game.rb"
require 'ocular'

class EventFactoryTestClass
  attr_accessor :name
end

$globalTestFuncTestStr = ""
def globalTestFunc(msg)
    $globalTestFuncTestStr << msg
end

RSpec.describe Ocular::EventFactory do

    describe "EventBase" do
        it "can call exec" do
            a = false
            eb = Ocular::DSL::EventBase.new do
                a = true
            end
            eb.exec
            expect(a).to eq(true)
        end
    end

    describe "#load_from_file" do
        it "can load sample dsl" do
            ef = Ocular::EventFactory.new
            scaffold = ef.load_from_file('spec/data/dsl-example.rb')
            i = scaffold.events[0]
            i.exec()
        end
    end

    describe "#load_from_block" do
        it "can load sample dsl from block" do
            ef = Ocular::EventFactory.new
            a = false

            scaffold = ef.load_from_block "test_dsl" do
                onEvent EventFactoryTestClass do
                    a = true
                    globalTestFunc("Hello")
                end                             
            end
            i = scaffold.events[0]
            i.exec()
            expect(a).to eq(true)
            expect($globalTestFuncTestStr).to eq("Hello")
        end
    end
end

