#!/usr/bin/python3
import argparse
import json
from pathlib import Path

import jq


def main(args):
    if not Path(args.json).exists:
        raise Exception(f"Couldn't find JSON file: {args.json}")
    with open(args.json, "r") as file:
        jsonfile = json.load(file)
    N = int(jq.compile(".sequences | length").input(jsonfile).text())
    total = 0
    for i in range(N):
        dur = float(
            jq.compile(f".sequences[{i}].parameters.duration").input(jsonfile).text()
        )
        print(f" #{i} - {dur}")
        total = total + dur
    print(f"Total duration = {total}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Obtain total duration from a Vime JSON file."
    )
    parser.add_argument("json", type=str, help="input JSON file")
    args = parser.parse_args()
    main(args)
