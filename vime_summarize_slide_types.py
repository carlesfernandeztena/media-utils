#!/usr/bin/python3
import argparse
import json
from pathlib import Path

import jq
import numpy as np

TEMPLATES_PATH = Path(
    "/home/carles/src/vime-nlp-pipeline/vime_nlp_pipeline/video_composer/templates"
)


def main():
    tpl_types = {}
    tpl_content = {}

    for f in TEMPLATES_PATH.iterdir():
        if f.is_file():
            with open(f, "r") as file:
                jsonfile = json.load(file)

        N = int(jq.compile(".sequences | length").input(jsonfile).text())
        slide_types = []
        slide_content = []
        for i in range(N):
            slide_types.append(
                jq.compile(f".sequences[{i}].visualElements[0].type")
                .input(jsonfile)
                .text()
            )
            props = jsonfile["sequences"][i]["visualElements"][0]["props"]
            slide_content.append(
                "".join(sorted([props[k]["type"][0] for k in props.keys()]))
            )

        key = jq.compile(".id").input(jsonfile).text()[1:-1]
        tpl_types[key] = slide_types
        tpl_content[key] = slide_content

    i = 0
    print(
        f"{'Template name':20s} {'Slide types':12s} {'Slide content':15s} {'Slide composition'}"
    )
    for key, val in sorted(tpl_types.items()):
        str_types = " ".join([v[-2:-1] for v in val])
        unique_types = " ".join([v[-2:-1] for v in np.unique(val)])
        slide_content = " ".join(tpl_content[key])
        print(f"{key:20s} {unique_types:15s} {slide_content:20s} {str_types} ")
        if (i + 1) % 5 == 0:
            print()
        i = i + 1


if __name__ == "__main__":
    main()
