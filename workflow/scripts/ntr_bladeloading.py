import argparse
from ntrfc.turbo.cascade_case.solution import GenericCascadeCase
from ntrfc.turbo.cascade_case.post import blade_loading_cp
import pyvista as pv

pv.start_xvfb()

parser = argparse.ArgumentParser(description='Snakemake arguments for ntr')
parser.add_argument('--blade', type=str)
parser.add_argument('--inlet', type=str)
parser.add_argument('--outlet', type=str)
parser.add_argument('--output', type=str)
args = parser.parse_args()

case = GenericCascadeCase()

case.read_meshes(args.inlet,"inlet")
case.read_meshes(args.outlet,"outlet")
case.read_meshes(args.blade,"blade")

case.set_bladeslice_midz()
case.blade.compute_all_frompoints()

blade_loading_cp(case, pressurevar="pMean", densityvar="rhoMean", velvar="UMean", figpath=args.output)
