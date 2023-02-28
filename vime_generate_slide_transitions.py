#!/usr/bin/python3
import argparse
import json
from pathlib import Path

import jq
import numpy as np
from numpy.typing import NDArray

TARGET_DIR = (
    "/home/carles/src/vime-monorepo/packages/renderer/test/templates/variations/"
)


def getPositionCode(N: int) -> str:
    if N == 1:
        return ["000"]
    elif N == 2:
        return ["001", "110"]
    elif N == 3:
        return ["012", "1021", "20"]
    elif N == 4:
        return ["0123", "1032", "2021", "3130"]
    elif N == 5:
        return ["01234", "10243", "203042", "31401", "413210"]


def modifyAndWriteSequence(
    jsonfile: dict, code: str, slide_types: NDArray, out_file: str
):

    unique_types = np.unique(slide_types)
    positions = [slide_types.index(u) for u in unique_types]
    min_json_seq = [jsonfile["sequences"][p] for p in positions]
    newjsonfile = jsonfile.copy()
    newjsonfile["sequences"] = [min_json_seq[int(c)] for c in code]
    print(
        f"Sequence: {code} -> {'-'.join([newjsonfile['sequences'][c]['id'] for c in range(len(newjsonfile['sequences']))])}"
    )

    with open(out_file, "w") as ofile:
        json.dump(newjsonfile, ofile, indent=4)


def main(args):
    if not Path(args.input).exists:
        raise Exception(f"Couldn't find JSON file: {args.json}")
    with open(args.input, "r") as file:
        jsonfile = json.load(file)

    N = int(jq.compile(".sequences | length").input(jsonfile).text())
    slide_types = []
    for i in range(N):
        slide_types.append(
            jq.compile(f".sequences[{i}].visualElements[0].type").input(jsonfile).text()
        )
    M = len(np.unique(slide_types))

    codes = getPositionCode(M)
    for i, code in enumerate(codes):
        out_file = Path(TARGET_DIR) / f"{i}.json"
        modifyAndWriteSequence(jsonfile, code, slide_types, out_file)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Generate all possible slide transitions, startings and endings to test slide roles."
    )
    parser.add_argument("-i", "--input", type=str, help="input JSON file")
    args = parser.parse_args()
    main(args)
