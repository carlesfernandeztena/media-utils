#!/usr/bin/python3
import argparse
import json
import re
import shlex
import subprocess
import sys
from pathlib import Path

import jq

ASSETS_PATH = "/home/carles/src/vime/vime-renderer/public"
MEDIA_UTILS_PATH = "/home/carles/src/media-utils"
TEXTS = [
    "Vime Studio Editor",
    "Match your style",
    "Pitch your product",
    "Customize",
    "Now it's your turn",
]


def video_duration(video_file: str):
    output = subprocess.check_output(
        shlex.split(f"sh {MEDIA_UTILS_PATH}/vid_duration.sh {ASSETS_PATH}/{video_file}")
    )
    return float(output)


def main(args):
    if not Path(args.input).exists:
        raise Exception(f"Couldn't find JSON file: {args.input}")
    if args.output == None:
        args.output = args.input

    with open(args.input, "r") as file:
        jsonfile = json.load(file)
    N = int(jq.compile(".sequences | length").input(jsonfile).text())
    for i in range(N):
        actor_video = f"avatars/tutorial/{i+1}.webm"
        slide_image = f"images/tutorial/{i+1}.png"
        slide_text = TEXTS[i]

        # set actor video for that product and slide
        jsonfile["sequences"][i]["parameters"]["avatar"]["cvUrl"] = actor_video
        # set slide duration. according to video
        jsonfile["sequences"][i]["parameters"]["duration"] = video_duration(actor_video)
        # set image for each slide (if there is)
        if "image1" in jsonfile["sequences"][i]["visualElements"][0]["props"]:
            jsonfile["sequences"][i]["visualElements"][0]["props"]["image1"][
                "value"
            ] = slide_image
        if "text1" in jsonfile["sequences"][i]["visualElements"][0]["props"]:
            jsonfile["sequences"][i]["visualElements"][0]["props"]["text1"][
                "value"
            ] = slide_text

    with open(args.output, "w") as out_file:
        json.dump(jsonfile, out_file, indent=4)

    print(f" :: Successfully created tutorial {Path(args.output).name} :-)\n")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Create tutorial video from an implemented template."
    )
    parser.add_argument(
        "-i", "--input", type=str, help="input JSON file", required=True
    )
    args = parser.parse_args()
    args.output = ASSETS_PATH + "/../" + Path(args.input).name[0:2] + "tutorial.json"
    print(args.output)
    main(args)
