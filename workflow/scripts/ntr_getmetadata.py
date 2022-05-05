
import re

import argparse
from ntrfc.utils.filehandling.datafiles import write_yaml_dict

parser = argparse.ArgumentParser(description='Snakemake arguments for ntr')
parser.add_argument('--inputfile', nargs=1, help='input file')
parser.add_argument('--outputfile', nargs=1, help='output file')
args = parser.parse_args()

input = args.inputfile[0]
output = args.outputfile[0]
with open(input,"r") as fobj:
    log = fobj.read()


timestepcompleted_pattern = r'Courant Number mean:(.*){1,}max:(.*){1,}deltaT = Time ='
timestep = len(re.findall(timestepcompleted_pattern, log))
meta = {"timesteps":timesteps}
write_yaml_dict(output,meta)