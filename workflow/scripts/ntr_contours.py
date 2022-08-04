import argparse
from ntrfc.utils.filehandling.mesh import load_mesh
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
pv.set_plot_theme("document")
p = pv.Plotter(off_screen=True, window_size=[10240, 10240])
p.add_mesh(midspanplane.rotate_z(90, inplace=True), scalars="U")
p.show(screenshot=output, cpos=(0, 0, 1))
