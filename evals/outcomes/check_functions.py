"""Trusted evaluator: run outside the agent-editable workspace, under a sandbox."""

import importlib.util
import json
from pathlib import Path
import sys


workspace = Path(sys.argv[1])
checks = json.loads(sys.argv[2])
for check in checks:
    path = workspace / check["file"]
    if path.is_symlink() or not path.resolve().is_relative_to(workspace.resolve()):
        raise ValueError("candidate module escapes workspace")
    spec = importlib.util.spec_from_file_location("candidate", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    function = getattr(module, check["function"])
    for vector in check["vectors"]:
        try:
            result = function(*vector["args"])
        except Exception as error:
            if type(error).__name__ != vector.get("raises"):
                raise
        else:
            assert "raises" not in vector, "expected exception was not raised"
            assert result == vector["equals"], (vector["args"], result, vector["equals"])
print("All evaluator vectors passed")
