"""Palette-specific diagnostic for hoof highlight regions, supporting visual review."""
from PIL import Image,ImageFilter
import numpy as np

def hoof_regions(path):
    pixels=np.asarray(Image.open(path).convert('RGBA'));rgb=pixels[:,:,:3].astype(float)
    mask=(pixels[:,:,3]>240)&(rgb[:,:,0]>65)&(rgb[:,:,0]<130)&(rgb[:,:,2]>=rgb[:,:,1]-2)&(rgb[:,:,0]-rgb[:,:,1]<25)
    mask[:int(mask.shape[0]*.5),:]=False
    dilated=np.asarray(Image.fromarray((mask*255).astype('uint8')).filter(ImageFilter.MaxFilter(21)))>0
    remaining=set(zip(*np.where(dilated)));groups=[]
    while remaining:
        queue=[remaining.pop()];points=[]
        while queue:
            y,x=queue.pop();points.append((y,x))
            for dy,dx in [(0,1),(0,-1),(1,0),(-1,0)]:
                near=(y+dy,x+dx)
                if near in remaining:remaining.remove(near);queue.append(near)
        if len(points)>=1000:
            values=np.array(points)
            groups.append({'diagnostic_area':len(points),'min_yx':values.min(axis=0).tolist(),'max_yx':values.max(axis=0).tolist()})
    return sorted(groups,key=lambda g:g['min_yx'])
