import argparse
import json
from ntrfc.database.case_creation import deploy


parser = argparse.ArgumentParser(description='Snakemake arguments for ntrfc')
parser.add_argument('--inputfiles', nargs='+', help='list of input files')
parser.add_argument('--outputfiles', nargs='+', help='list of output files')

parser.add_argument('--simparams', type=str, help='list of output files')
parser.add_argument('--options', type=str, help='list of output files')



args = parser.parse_args()

input = args.inputfiles
output = args.outputfiles
params = args.simparams
option_config = args.options

with open(params,"r") as fobj:
    paramsdict = json.loads(fobj.readlines())

with open(option_config,"r") as fobj:
    optionconfigdict = json.loads(fobj.readlines())

deploy(input, output, paramsdict, optionconfigdict)
