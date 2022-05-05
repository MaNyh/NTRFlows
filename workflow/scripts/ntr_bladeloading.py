import argparse
from ntrfc.utils.filehandling.mesh import load_mesh
parser = argparse.ArgumentParser(description='Snakemake arguments for ntr')
parser.add_argument('--input', type=str)
parser.add_argument('--output', type=str)
args = parser.parse_args()

input = args.input
output = args.output

mesh = load_mesh(input)

print(mesh)