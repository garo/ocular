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

    describe("locking") do
        it "can lock and unlock" do
            c = Class.new.extend(Ocular::DSL::Etcd)
            locked = c.ttl_lock("foo", ttl:5)

            expect(locked).not_to eq(nil)
            expect(c.locked?("foo")).to eq(locked)
            expect(c.unlock("foo")).to eq(true)
        end

        it "can refresh a lock" do
            c = Class.new.extend(Ocular::DSL::Etcd)
            locked = c.ttl_lock("foo", ttl:5)

            # refresh the lock
            expect(c.ttl_lock("foo")).to eq(locked)
            expect(c.ttl_lock("foo")).to eq(locked)

            expect(c.unlock("foo")).to eq(true)
        end

        it "can't lock if somebody else has a lock" do
            c = Class.new.extend(Ocular::DSL::Etcd)
            c.instance_variable_set(:@run_id, "run_id:c")
            locked = c.ttl_lock("foo", ttl:5)

            expect(locked).not_to eq(nil)
            expect(c.locked?("foo")).to eq(locked)

            # Simulate another process
            d = Class.new.extend(Ocular::DSL::Etcd)
            d.instance_variable_set(:@run_id, "run_id:d")

            # This process can't lock because process 'c' has already the lock
            expect(d.ttl_lock("foo")).to eq(nil)

            # c has still the lock
            expect(c.ttl_lock("foo")).not_to eq(nil)

            expect(c.unlock("foo")).to eq(true)
        end
    end  

end

