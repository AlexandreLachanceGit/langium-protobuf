#!/bin/python

import sys
import json

with open(sys.argv[1]) as file:
    lines = file.readlines()

diags = []
for i in range(len(lines)):
    if "message" in lines[i]:
        diags.append({
            "message": "This line contains 'message'.",
            "startLine": i,
            "endLine": i,
            "startCol": 0,
            "endCol": len(lines[i]),
        })

result = {
    "diagnostics": diags
}

print(json.dumps(result))