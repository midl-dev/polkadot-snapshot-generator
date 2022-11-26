import sys,json

data = json.load(sys.stdin)

objects_to_delete = [ s["Key"] for s in data[:-2] ]

if objects_to_delete:
    print("\n".join(objects_to_delete))
