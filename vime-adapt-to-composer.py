#!/usr/bin/python3
import argparse
import json
from pathlib import Path

import jq


def main(args):
    if not Path(args.input).exists:
        raise Exception(f"Couldn't find JSON file: {args.input}")
    if args.output == None:
        args.output = args.input

    with open(args.input, "r") as file:
        jsonfile = json.load(file)
    N = int(jq.compile(".sequences | length").input(jsonfile).text())
    for i in range(N):
        jsonfile["sequences"][i]["parameters"]["avatar"][
            "cvUrl"
        ] = f"avatars/{args.product}/{i+1}.webm"
    with open("myfile.json", "w") as out_file:
        json.dump(jsonfile, out_file, indent=4)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Obtain total duration from a Vime JSON file."
    )
    parser.add_argument(
        "-i", "--input", type=str, help="input JSON file", required=True
    )
    parser.add_argument(
        "-o", "--output", type=str, help="output JSON file", required=False
    )
    parser.add_argument(
        "-p",
        "--product",
        type=str,
        help="Product folder name (e.g. 'ovente')",
        required=True,
    )
    args = parser.parse_args()
    main(args)
