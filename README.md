# Media utils
Collection of utilities for video, image, and audio manipulation and visualization.

Most of the utilities are bash scripts, seeking to provide easy command-line interfacing to typical FFmpeg operations, such as:
- Retrieve individual aspects of a video: dimensions, duration, bitrate, etc
- Cut a video segment between two timepoints
- Crop a video
- Extract frame N from a video
- Concatenate videos one after the other
- Convert video to different formats (including transparency formats, e.g. VP9)
- Extract audio from a video (wav or mp3)
- Add text to a video
- etc.

But also some more advanced utilities, like:
- Detecting a face in an image (retrieve bbox)
- Automatically download images from a Google images search
- Automatically segment video based on cuts

They are residing on a CUDA-based docker container containing FFmpeg compiled against NVIDIA codecs,
for GPU-enabled video encoding and decoding.

---
## Docker

Build CPU docker image:
```bash
DOCKER_BUILDKIT=1 docker build -t media-utils .
```

Build CUDA docker image:
```bash
DOCKER_BUILDKIT=1 docker build -t media-utils-cuda -f Dockerfile.cuda .
```

Run docker container interactively:
```bash
docker run -it --rm -v "$(pwd)":/src media-utils bash
```

---
## Set aliases
```bash
bash 
