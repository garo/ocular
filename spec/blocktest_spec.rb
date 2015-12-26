#require_relative "../lib/game.rb"
require 'blocktest'

def globalMethodForTesting(val)
    $globalMethodVariable = val
end

RSpec.describe BlockTest do
    describe "#call" do
        it "can call a block" do
            test = BlockTest.new
            a = false
            test.call do
                a = true
            end
            expect(a).to eq(true)
        end
    end

    describe "#ieval" do
        it "can instance_eval a block" do
            test = BlockTest.new
            a = false
            test.ieval do
                a = true
            end
            expect(a).to eq(true)
        end

        it "can call a BlockTest method" do
            test = BlockTest.new
            test.ieval do
                testMethod(2)
            end
            expect(test.testValue).to eq(2)
        end

        it "can call a BlockTest method while calling global methods" do
            test = BlockTest.new
            test.ieval do
                globalMethodForTesting(3)
            end
            expect($globalMethodVariable).to eq(3)
        end

        it "can call a mixin function" do
            test = BlockTest.new
            test.ieval do
                setMixingTestValue(6)
            end
            expect(test.getMixingTestValue).to eq(6)
        end        
    end

    describe "#ievaldef" do
        it "can execute callback from initialise" do
            a = false
            test = BlockTest.new do
                a = true
            end
            test.ievaldef
            expect(a).to eq(true)


        end

    end

end

