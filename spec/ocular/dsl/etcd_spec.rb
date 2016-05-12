require 'ocular'


RSpec.describe Ocular::DSL::Etcd do

    it "#etcd returns object" do
        ::Ocular::Settings.load_from_file('spec/data/settings.yaml')

        ef = Ocular::Event::EventFactory.new
        a = "nan"
        proxy = ef.load_from_block "test_dsl" do
            fork false
            onEvent "name" do
                a = etcd()
            end                             
        end
        eventbase = proxy.events["onEvent"]["name"]

        context = Ocular::DSL::RunContext.new(Ocular::Logging::ConsoleLogger.new)
        eventbase.exec(context)
        expect(a).not_to eq(nil)
    end

    it "can do locking" do
        c = Class.new.extend(Ocular::DSL::Etcd)
        locked = c.ttl_lock("foo", ttl:5)

        expect(locked).not_to eq(nil)
        expect(c.locked?("foo")).to eq(true)

        expect(c.ttl_lock("foo")).to eq(nil)

        expect(c.unlock("foo")).to eq(true)
        expect(c.locked?("foo")).to eq(false)
    end

end

