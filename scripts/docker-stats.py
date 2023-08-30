import json
import shlex
import subprocess

import numpy as np

if __name__ == "__main__":
    while True:
        result = subprocess.run(
            'docker stats "$(docker ps -n 1 -q)" --no-stream --format json',
            check=True,
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
        )
        obj = json.loads(result.stdout)
        cpu = float(obj['CPUPerc'].split('%')[0])
        mem = obj['MemUsage'].split('/')[0].strip()
        print()