#!/usr/bin/python3
import argparse
import json
import shlex
import subprocess
from pathlib import Path

import jq

from vime_adapt_to_composer import remove_nlpmetadata

# fmt: off
PUBLIC_PATH = "/home/carles/src/vime-composer-service/renderer/public"
ASSETS_DIR = ""
MEDIA_UTILS_PATH = "/home/carles/src/media-utils"
DOWNLOADABLE_EXTS = [".mp3", ".mov", ".wav", ".webm", ".mp4", ".png", ".jpg", ".bmp", ".gif", ".jpeg", ".svg"]
# fmt: on


def download_asset(s3_asset: str, target_local_file: str) -> None:
    print(f"    ...Downloading {Path(target_local_file).name}")
    output = subprocess.check_output(
        shlex.split(f"aws s3 cp {s3_asset} {target_local_file}")
    )


def video_duration(video_file: str) -> float:
    output = subprocess.check_output(
        shlex.split(f"sh {MEDIA_UTILS_PATH}/vid_duration.sh {PUBLIC_PATH}/{video_file}")
    )
    return float(output)


def is_downloadable(s3_asset: str) -> bool:
    for ext in DOWNLOADABLE_EXTS:
        if s3_asset.endswith(ext):
            return True
    return False


def replace_assets(d, level: int = 1):
    """Iteratively replace S3 assets along the hierarchy"""
    # Path(f"{PUBLIC_PATH}/{ASSETS_DIR}").mkdir(parents=True, exist_ok=True)

    if isinstance(d, dict):
        for key in list(d):
            if (
                isinstance(d[key], str)
                and d[key].startswith("s3://")
                and is_downloadable(d[key])
            ):
                ##############################
                # Download and replace asset
                # out_filename = f"{PUBLIC_PATH}/{ASSETS_DIR}/{Path(d[key]).name}"
                out_filename = f"{PUBLIC_PATH}/{Path(d[key]).name}"
                download_asset(d[key], out_filename)
                # in json, only include path after "public/"
                d[key] = f"{Path(d[key]).name}"
                ##############################
            elif isinstance(d[key], dict) or isinstance(d[key], list):
                d[key] = replace_assets(d[key], level + 1)
    elif isinstance(d, list):
        for i, key in enumerate(d):
            if isinstance(d[i], dict) or isinstance(d[i], list):
                d[i] = replace_assets(d[i], level + 1)
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
    if "job_status" in jsonfile and "sequences" in jsonfile["job_status"]["config"]:
        jsonfile = jsonfile["job_status"]["config"]

    # remove NLP metadata fields
    jsonfile = remove_nlpmetadata(jsonfile)

    # remove NLP metadata fields
    jsonfile = replace_assets(jsonfile)

    # update sequence durations
    N = int(jq.compile(".sequences | length").input(jsonfile).text())
    for i in range(N):
        if "cvUrl" in jsonfile["sequences"][i]["parameters"]["avatar"]:
            cvurl = jsonfile["sequences"][i]["parameters"]["avatar"]["cvUrl"]
            if len(cvurl) > 0:
                jsonfile["sequences"][i]["parameters"]["duration"] = video_duration(
                    cvurl
                )
        if "ttsUrl" in jsonfile["sequences"][i]["parameters"]["avatar"]:
            ttsurl = jsonfile["sequences"][i]["parameters"]["avatar"]["ttsUrl"]
            if len(ttsurl) > 0:
                jsonfile["sequences"][i]["parameters"]["duration"] = video_duration(
                    ttsurl
                )

    with open(args.output, "w") as out_file:
        json.dump(jsonfile, out_file, indent=4)

    print(f" :: Successfully patched fields in {Path(args.output).name} :-)\n")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Download s3 assets associated to a JSON file, patching it to point to './assets/'."
    )
    parser.add_argument(
        "-i", "--input", type=str, help="input JSON file", required=True
    )
    parser.add_argument(
        "-o", "--output", type=str, help="output JSON file", required=False
    )
    args = parser.parse_args()
    main(args)
