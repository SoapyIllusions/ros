-- ADD - Adds a model to a collection
--
-- KEYS [ collection_key, collection_ids ]
-- ARGV [ model_json ]

local model = cjson.decode(ARGV[1])
local id = redis.call('incr', KEYS[2])
local key = KEYS[1] .. ':' .. id

local setArray
setArray = function (key, val)
    for k, v in ipairs(val) do
        if type(v) == 'table' then
            if v[1] == nil then
                local pointer = '__h__:' .. key .. ':' .. k
                redis.call('rpush', key, pointer)
                setHash(pointer, v)
            else
                local pointer = '__l__:' .. key .. ':' .. k
                redis.call('rpush', key, pointer)
                setArray(pointer, v)
            end
        else
            redis.call('rpush', key, v)
        end
    end
end

local setHash
setHash = function (key, val)
    for k, v in pairs(val) do
        if type(v) == 'table' then
            if v[1] == nil then
                local pointer = '__h__:' .. key .. ':' .. k
                redis.call('hset', key, k, pointer)
                setHash(pointer, v)
            else
                local pointer = '__l__:' .. key .. ':' .. k
                redis.call('hset', key, k, pointer)
                setArray(pointer, v)
            end
        else
            redis.call('hset', key, k, v)
        end
    end
end

redis.call('sadd', KEYS[1], key)
setHash(key, model)

return id
