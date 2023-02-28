#!/usr/bin/python3
import argparse
import json
import shlex
import subprocess
from pathlib import Path

import jq

RENDERER_PATH = "/home/carles/src/vime-composer-service/renderer"
ASSETS_PATH = RENDERER_PATH + "public"
TUTORIAL_DIR = RENDERER_PATH + "test/tutorial/"
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
        args.output = (
            f"{TUTORIAL_DIR}/{Path(args.input).stem.split('_')[0]}_tutorial.json"
        )

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
        if "image2" in jsonfile["sequences"][i]["visualElements"][0]["props"]:
            jsonfile["sequences"][i]["visualElements"][0]["props"]["image2"][
                "value"
            ] = slide_image
        if "text1" in jsonfile["sequences"][i]["visualElements"][0]["props"]:
            jsonfile["sequences"][i]["visualElements"][0]["props"]["text1"][
                "value"
            ] = slide_text
        if "text2" in jsonfile["sequences"][i]["visualElements"][0]["props"]:
            jsonfile["sequences"][i]["visualElements"][0]["props"]["text1"][
                "value"
            ] = ""

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
    parser.add_argument(
        "-o", "--output", type=str, help="output JSON file", required=False
    )
    args = parser.parse_args()
    print(args.output)
    main(args)
