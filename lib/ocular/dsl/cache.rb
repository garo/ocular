require 'logger'
require 'net/http'
require 'cgi'

class Ocular
    module DSL
        module Cache

            def cache_set(key, value, ttl=nil)
            	m = mysql()
            		if ttl
            			ttl = Time.now.to_i + ttl.to_i
            		end
            	begin
	            	m.query("REPLACE INTO ocular_cache VALUES('#{m.escape(key)}', '#{m.escape(value)}', #{ttl == nil ? "NULL" : ttl});")
	            rescue Mysql2::Error => e
	            	puts "Got #{e}, #{e.to_s}"
	            	if e.to_s.include?("doesn't exist")
            			m.query("CREATE TABLE IF NOT EXISTS ocular_cache (keyname varchar(100) PRIMARY KEY, value text, expires int(11) null)")
		            	m.query("REPLACE INTO ocular_cache VALUES('#{m.escape(key)}', '#{m.escape(value)}', #{ttl == nil ? "NULL" : ttl});")
	            	end
	            end
            end

            def cache_get(key)
            	m = mysql()
            	begin
	            	ret = m.query("SELECT value FROM ocular_cache WHERE keyname = '#{m.escape(key)}' AND (expires IS NULL OR expires > UNIX_TIMESTAMP(NOW()))").first
	            	return ret["value"]
	            rescue
	            	return nil
	            end
            end

        end

    end
end
