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
    
    print("AI actor scripts:")
    for i in range(N):
        avatar_text = (
            jq.compile(f".sequences[{i}].parameters.avatar.value")
            .input(jsonfile)
            .text()
        )
        print(f" ({i+1}) {avatar_text}")

    print("\nSlide texts:")
    for i in range(N):
        for j in range(3):
            if f"text{j}" in jsonfile["sequences"][i]["visualElements"][0]["props"]:
                text_j = (
                    jq.compile(f".sequences[{i}].visualElements[0].props.text{j}.value")
                    .input(jsonfile)
                    .text()
                )
                print(f" ({i+1}.{j}) {text_j}")
    print()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Obtain total duration from a Vime JSON file."
    )
    parser.add_argument("json", type=str, help="input JSON file")
    args = parser.parse_args()
    main(args)
