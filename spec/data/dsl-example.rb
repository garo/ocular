puts "dsl-example loaded #{@klass_name}"
onEvent EventFactoryTestClass do
    puts "puts call from dsl-example.rb, run_id: #{@run_id}"
end

debug("test debug from outside eventbase")