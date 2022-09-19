#!/usr/bin/python3
import argparse
import json
import shlex
import subprocess
from pathlib import Path

import jq

# fmt: off
ASSETS_PATH = "/home/carles/src/vime/vime-renderer/public"
MEDIA_UTILS_PATH = "/home/carles/src/media-utils"
MUSIC = { "1": 1, "2": 2, "2b": 2, "3": 3, "3b": 3, "4": 3, "5": 7, "6": 4, "7": 8, "8": 9, "9": 9, "10": 2, "14":3, "17":1 }
# fmt: on


def video_duration(video_file: str) -> float:
    output = subprocess.check_output(
        shlex.split(f"sh {MEDIA_UTILS_PATH}/vid_duration.sh {ASSETS_PATH}/{video_file}")
    )
    return float(output)


def get_music_file(template_id: str) -> str:
    music_id = MUSIC.get(template_id, 1)
    return f"music/music_0{music_id}.mp3"


def remove_nlpmetadata(d, level: int = 1):
    """Iteratively remove NLP metadata along the hierarchy"""
    if isinstance(d, dict):
        for key in list(d):
            # print(f"[{level}] {key} {type(d[key])}")
            if key == "nlpMetadata":
                del d[key]
            elif isinstance(d[key], dict) or isinstance(d[key], list):
                d[key] = remove_nlpmetadata(d[key], level + 1)
    elif isinstance(d, list):
        for i, key in enumerate(d):
            # print(f"[{level}] {d[i]} {type(d[i])}")
            if isinstance(d[i], dict) or isinstance(d[i], list):
                d[i] = remove_nlpmetadata(d[i], level + 1)
    return d


def main(args):
    if not Path(args.input).exists:
        raise Exception(f"Couldn't find JSON file: {args.input}")
    if args.output == None:
        args.output = args.input

    with open(args.input, "r") as file:
        jsonfile = json.load(file)

    # If global/sequences, take out the global/
    if "config" in jsonfile and "sequences" in jsonfile["config"]:
        jsonfile = jsonfile["config"]

    N = int(jq.compile(".sequences | length").input(jsonfile).text())
    for i in range(N):
        actor_video = f"avatars/{args.product}/{i+1}.webm"
        template_id = jsonfile["id"].split("_")[0].split("#")[1]

        # set actor video for that product and slide
        jsonfile["sequences"][i]["parameters"]["avatar"]["cvUrl"] = actor_video

        # set slide duration. according to video
        jsonfile["sequences"][i]["parameters"]["duration"] = video_duration(actor_video)

        # remove NLP metadata fields
        jsonfile = remove_nlpmetadata(jsonfile)

        # add music structure
        jsonfile["global"]["music"] = {}
        jsonfile["global"]["music"]["url"] = get_music_file(template_id)
        jsonfile["global"]["music"]["loop"] = False

    with open(args.output, "w") as out_file:
        json.dump(jsonfile, out_file, indent=4)

    print(f" :: Successfully patched fields in {Path(args.output).name} :-)\n")


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
