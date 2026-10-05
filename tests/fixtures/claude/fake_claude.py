"""Fake stream-json Claude: fails a turn if the next prompt arrived early."""
import json
import select
import sys
import time

print(json.dumps({"type": "system", "subtype": "init", "cwd": "/w", "skills": []}), flush=True)
for index, line in enumerate(sys.stdin):
    time.sleep(0.2)  # a real turn takes time; queued input would be visible now
    early = bool(select.select([sys.stdin], [], [], 0)[0])
    prompt = json.loads(line)["message"]["content"]
    print(json.dumps({"type": "result", "subtype": "success", "is_error": early,
                      "result": f"{index}:{prompt}", "result_index": index}), flush=True)
