#!/usr/local/bin/python3
import sys
from pathlib import Path

import cv2
import numpy as np
import onnxruntime as rt

if len(sys.argv) != 2:
    print(f"Usage: {Path(sys.argv[0]).stem} <image_file>")
    print("       It returns the best square face bbox as <x y w h>.")
    exit(1)

image = cv2.imread(sys.argv[1])
height, width, _ = image.shape
img = cv2.resize(image, (640, 480))
img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
img_mean = np.array([127, 127, 127])
img = (img - img_mean) / 128
img = np.transpose(img, [2, 0, 1])
img = np.expand_dims(img, axis=0)
img = img.astype(np.float32)

rt.set_default_logger_severity(3)
sess = rt.InferenceSession(
    f"{Path(__file__).parent.resolve()}/ultraface.onnx",
    providers=["CUDAExecutionProvider", "CPUExecutionProvider"],
)
conf, boxes = sess.run(["scores", "boxes"], {"input": img})

max_idx = np.argmax([c[0] for c in conf[0]])
bbox = boxes[0][max_idx]
x, y, w, h = (
    bbox[0] * width,
    bbox[1] * height,
    (bbox[2] - bbox[0]) * width,
    (bbox[3] - bbox[1]) * height,
)

wp = int(max(w, h)) * 1.3
xp = int(x + 0.5 * (w - wp))
yp = int(y + 0.5 * (h - wp))
print(f"{xp} {yp} {wp} {wp}")

# cv2.imwrite("crop.png", image[yp : yp + wp, xp : xp + wp, :])
exit(0)
