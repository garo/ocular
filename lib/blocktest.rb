# game.rb

module MixinTest

    def setMixingTestValue(val)
        @mixingTestValue = val
    end

    def getMixingTestValue
        return @mixingTestValue
    end

end

class BlockTest

    attr_accessor :testValue

    include MixinTest

    def initialize(&block)
        @callback = block
    end

    def testMethod(val)
        @testValue = val
    end

    def call(&block)
        block.call
    end

    def ieval(&block)
        self.instance_eval(&block)
    end

    def ievaldef
        self.instance_eval(&@callback)
    end
end