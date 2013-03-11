#!/usr/bin/env python

import os
import redis
import json

os.environ['PYTHONINSPECT'] = 'True'
r = redis.StrictRedis()

add = r.register_script(open('add.lua').read())
load = r.register_script(open('load.lua').read())

obj = {'name': 'Test', 'count': 5, 'hash': {'a': 'b'}, 'list': [1, 2, 3]}
obj_str = json.dumps(obj)


def run():
    model_id = add(keys=['users', 'users_id'], args=[obj_str])
    model_json = load(keys=[], args=['users', model_id])
    print 'JSON: %s' % model_json
