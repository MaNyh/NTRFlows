import argparse
from ntrfc.utils.filehandling.mesh import load_mesh
from ntrfc.utils.geometry.pointcloud_methods import extract_geo_paras
from ntrfc.utils.math.vectorcalc import vecAbs
import matplotlib.pyplot as plt
import pyvista as pv

pv.start_xvfb()

parser = argparse.ArgumentParser(description='Snakemake arguments for ntr')
parser.add_argument('--input', type=str)
parser.add_argument('--output', type=str)
args = parser.parse_args()

input = args.input
output = args.output

mesh = load_mesh(input)

midspanz = (mesh.bounds[5] - mesh.bounds[4]) / 2
midspanplane = mesh.slice(origin=(0, 0, midspanz), normal=(0, 0, 1))

sortedPoly, ps_poly, ss_poly, ind_vk, ind_hk, mids_poly, beta_leading, beta_trailing, camber_angle = extract_geo_paras(
    midspanplane, 0.13)

chordlength = vecAbs(sortedPoly.points[ind_hk] - sortedPoly.points[ind_vk])
ps_xx = ps_poly.points[::, 0]
ps_yy = ps_poly.points[::, 1]
ps_pp = ps_poly["p"]
ss_xx = ss_poly.points[::, 0]
ss_yy = ss_poly.points[::, 1]
ss_pp = ss_poly["p"]
plt.ioff()
plt.figure()
plt.plot(ps_xx, ps_pp, label="ps")
plt.plot(ss_xx, ss_pp, label="ss")

plt.savefig(output, bbox_inches='tight')