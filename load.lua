-- LOAD - Loads a model from a collection
--
-- KEYS [ ]
-- ARGV [ collection_key, model_id ]

local key = ARGV[1] .. ':' .. ARGV[2]
local model = redis.call('hgetall', key)

local loadArray
loadArray = function (obj)
    for k, v in pairs(obj) do
        local prefix = string.sub(v, 0, 6)

        if prefix == '__h__:' then
            obj[k] = loadHash(redis.call('hgetall', v))
        elseif prefix == '__l__:' then
            obj[k] = loadArray(redis.call('lrange', v, 0, -1))
        end
    end

    return obj
end

local loadHash
loadHash = function(obj)
    local hash = {}
    for i=1, #obj, 2 do
        hash[obj[i]] = obj[i+1]
    end

    for k, v in pairs(hash) do
        local prefix = string.sub(v, 0, 6)

        if prefix == '__h__:' then
            hash[k] = loadHash(redis.call('hgetall', v))
        elseif prefix == '__l__:' then
            hash[k] = loadArray(redis.call('lrange', v, 0, -1))
        end
    end

    return hash
end

return cjson.encode(loadHash(model))
