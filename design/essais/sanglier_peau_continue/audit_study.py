"""Verify the actual study renderer plus the independent curve/readback audit."""
import hashlib
import importlib.util
import json
from pathlib import Path
folder=Path(__file__).resolve().parent
native=json.loads((folder/'captures/native_smooth_mesh.json').read_text(encoding='utf8'))
assert native['draw_renderer_sha256']==hashlib.sha256((folder/'render_study.gd').read_bytes()).hexdigest()
path=folder.parent/'loup_peau_continue/check_smooth_motion.py'
spec=importlib.util.spec_from_file_location('shared_curve_audit',path)
module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
assert module.check(with_native=True,folder=folder)
print('BOAR_RENDERER_AND_CURVE_AUDIT passed=True')
