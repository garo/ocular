require 'logger'
require 'net/http'
require 'cgi'

class Ocular
    module DSL
        module Graphite

            #add_help "graphite", "what?"

            def graphite(target, options = {})
                datasources = ::Ocular::Settings::get(:datasources)
                if !datasources or !datasources[:graphite]
                    raise "No graphite client settings"
                end
                settings = datasources[:graphite]

                uri = URI.parse(settings[:url])
                http = Net::HTTP.new(uri.host, uri.port)
                http.use_ssl = uri.instance_of?(URI::HTTPS)

                if !options[:from]
                    options[:from] = "-1min"
                end

                if options[:format]
                    options.delete(:format)
                end

                query = "/render?target=#{CGI.escape(target)}&format=json"
                options.each do |k, v|
                    query += "&#{k}=#{CGI.escape(v)}"
                end

                request = Net::HTTP::Get.new(query)
                response = http.request(request)
                if !response
                    raise "error, no response from post request"
                end
                if response.code.to_i != 200
                    raise "Invalid response from graphite for query #{query}. Response code: #{response.code}, response body: #{response.body}"
                end

                begin
                    return JSON.parse(response.body)
                rescue
                    return nil
                end
            end

            def graphite_get_latests(target, options = {})
                values = {}
                response = graphite(target, options)
                response.each do |reply|
                    if reply and reply["datapoints"] and reply["datapoints"].length > 0
                        # Discard null replies
                        not_null = reply["datapoints"].select {|x| x and x[0] }

                        # sort in descending order
                        not_null.sort! {|a,b| b[1] <=> a[1]}
                        if not_null.length > 0
                            # pick latests datapoint
                            # from that pick the value                            
                            values[reply["target"]] = not_null.first[0]
                        end
                    end
                end

                return values
            end

        end

    end
end
