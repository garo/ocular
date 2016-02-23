class Ocular
    def self.deep_symbolize(obj)
        return obj.inject({}){|memo,(k,v)| memo[k.to_sym] =  deep_symbolize(v); memo} if obj.is_a? Hash
        return obj.inject([]){|memo,v    | memo           << deep_symbolize(v); memo} if obj.is_a? Array
        return obj
    end
end
