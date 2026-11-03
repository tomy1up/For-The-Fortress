"""Check source preservation, transparent margins, palette and uniform preview sizing."""
from pathlib import Path
from PIL import Image
import hashlib,json
import numpy as np
from hoof_regions import hoof_regions
folder=Path(__file__).resolve().parent
reference=folder.parent/'sanglier_peau_continue/sanglier_proche_source_v001.png'
original=Path('C:/Users/Tomy/.codex/generated_images/01a155cb-cefa-7193-a478-f2a27c0d25b0/exec-3fa0f191-ff38-45fe-a36d-284ce0887c2d.png')
front=folder/'sanglier_face_source_v001.png'
assert hashlib.sha256(front.read_bytes()).hexdigest()=='8b56880c8988aacdb803b6a72d9c557989aed96ae1a6b0eb13d416c4d77334b6'
if original.is_file(): assert front.read_bytes()==original.read_bytes()
quarter=folder/'sanglier_trois_quarts_source_v001.png'
quarter_original=Path('C:/Users/Tomy/.codex/generated_images/01a155cb-cefa-7193-a478-f2a27c0d25b0/exec-7a58f6a3-e950-4bbc-ab30-beadf39e4657.png')
assert hashlib.sha256(quarter.read_bytes()).hexdigest()=='b23cae9009d5fe7bd80386455b787606c519475a070466161e328b9672783a85'
if quarter_original.is_file(): assert quarter.read_bytes()==quarter_original.read_bytes()
rear=folder/'sanglier_arriere_trois_quarts_source_v001.png'
rear_original=Path('C:/Users/Tomy/.codex/generated_images/01a155cb-cefa-7193-a478-f2a27c0d25b0/exec-e3b9dee9-21fd-4826-af91-280bf7e252a2.png')
if rear_original.is_file(): assert rear.read_bytes()==rear_original.read_bytes()
assert hashlib.sha256(rear.read_bytes()).hexdigest()=='ded43dd0ef741cfdc2438c2b51c450c3acf786b811ff311c1f554ef6acbeed3c'
report={'scope':'Static frontal, front-three-quarter and rear-three-quarter drawing preparation, not an animation or artistic approval','passed':True,'artistically_approved':False,'source_pixels_edited':False,'images':{}}
for label,path in [('profile',reference),('front',front),('quarter',quarter),('rear',rear)]:
    im=Image.open(path);assert im.mode=='RGBA';pixels=np.asarray(im);alpha=pixels[:,:,3]
    mask=Image.fromarray((alpha>=16).astype('uint8')*255);box=mask.getbbox();assert box is not None
    left,top,right,bottom=box;width,height=im.size
    assert left>0 and top>0 and right<width and bottom<height and (alpha==0).sum()>width*height*.3
    rgb=pixels[:,:,:3].astype(float)
    fur=(alpha>240)&(rgb[:,:,0]>90)&(rgb[:,:,0]>rgb[:,:,1]*1.5)&(rgb[:,:,1]>rgb[:,:,2]*1.4)&(rgb[:,:,1]>25)
    median=np.median(rgb[fur],axis=0)
    game_scale=34.0*.85/(bottom-top)
    report['images'][label]={'path':path.name,'size':list(im.size),'visible_bounds_alpha16':list(box),'alpha_max':int(alpha.max()),'fully_transparent_pixels':int((alpha==0).sum()),'maximum_edge_alpha':int(max(alpha[0].max(),alpha[-1].max(),alpha[:,0].max(),alpha[:,-1].max())),'fur_median_rgb':median.tolist(),'display_height':34.0*.85,'uniform_scale':game_scale,'display_width':(right-left)*game_scale,'pivot':[(left+right)/2,bottom],'sha256':hashlib.sha256(path.read_bytes()).hexdigest()}
for label,path in [('profile',reference),('front',front),('quarter',quarter),('rear',rear)]:
    groups=hoof_regions(path);assert len(groups)==(2 if label=='profile' else 4),(label,groups)
    report['images'][label]['hoof_highlight_groups']=groups
report['hoof_diagnostic_limit']='Palette-specific lower-half highlight components; supports manual review, does not prove anatomy or count invisible limbs.'
report['palette_note']='Front fur median is darker than the profile median; projected areas differ. No pixel recolouring, stretch or contrast normalization applied. Visual consistency still requires review.'
(folder/'controle_sources.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf8')
print('BOAR_FRONT_PREFLIGHT',json.dumps(report))
