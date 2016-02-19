puts "dsl-example loaded"
onEvent EventFactoryTestClass do
    puts "puts call from dsl-example.rb, run_id: #{@run_id}"
end

debug("test debug from outside eventbase")