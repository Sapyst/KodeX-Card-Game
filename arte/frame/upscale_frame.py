"""Amplia o recorte original com 4x-UltraSharp no ComfyUI. Uso: python upscale_frame.py <original.png> <saida.png>"""
import io, json, sys, time, urllib.parse, urllib.request, uuid
import numpy as np
from PIL import Image
API = "http://127.0.0.1:8188"
orig = Image.open(sys.argv[1]).convert("RGB")
oa = np.asarray(orig).astype(int); fundo = oa[5, 5]
dif = np.abs(oa - fundo).sum(2) > 40; dif[:, int(orig.width * 0.83):] = False
ys, xs = np.where(dif)
crop = orig.crop((xs.min() - 4, ys.min() - 4, xs.max() + 5, ys.max() + 5))
buf = io.BytesIO(); crop.save(buf, "PNG"); b = uuid.uuid4().hex
corpo = (f"--{b}\r\nContent-Disposition: form-data; name=\"image\"; filename=\"gk_up_in.png\"\r\nContent-Type: image/png\r\n\r\n").encode() + buf.getvalue() \
    + f"\r\n--{b}\r\nContent-Disposition: form-data; name=\"overwrite\"\r\n\r\ntrue\r\n--{b}--\r\n".encode()
nome = json.load(urllib.request.urlopen(urllib.request.Request(API + "/upload/image", data=corpo, headers={"Content-Type": f"multipart/form-data; boundary={b}"})))["name"]
wf = {"1": {"class_type": "LoadImage", "inputs": {"image": nome}},
      "2": {"class_type": "UpscaleModelLoader", "inputs": {"model_name": "4x-UltraSharp.pth"}},
      "3": {"class_type": "ImageUpscaleWithModel", "inputs": {"upscale_model": ["2", 0], "image": ["1", 0]}},
      "4": {"class_type": "SaveImage", "inputs": {"filename_prefix": "gk_up", "images": ["3", 0]}}}
pid = json.load(urllib.request.urlopen(urllib.request.Request(API + "/prompt", data=json.dumps({"prompt": wf}).encode(), headers={"Content-Type": "application/json"})))["prompt_id"]
while True:
    time.sleep(2)
    h = json.load(urllib.request.urlopen(API + "/history/" + pid))
    if pid in h:
        st = h[pid].get("status", {})
        if st.get("status_str") == "error": sys.exit(json.dumps(st)[:800])
        for n in h[pid]["outputs"].values():
            for im in n.get("images", []):
                q = urllib.parse.urlencode({"filename": im["filename"], "subfolder": im["subfolder"], "type": im["type"]})
                open(sys.argv[2], "wb").write(urllib.request.urlopen(API + "/view?" + q).read()); print("ok", crop.size); sys.exit(0)
