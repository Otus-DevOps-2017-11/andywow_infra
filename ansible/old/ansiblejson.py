#!/usr/bin/env python
import json
test_file = json.loads(open('./inventory20.json', 'r').read())
print json.dumps(test_file)
