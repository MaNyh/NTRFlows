import argparse
import json
import os
import shutil

from ntrfc.utils.filehandling.datafiles import inplace_change

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
    paramsdict = json.loads(fobj.read())

with open(option_config,"r") as fobj:
    optionconfigdict = json.loads(fobj.read())

def deploy(deply_sources,deploy_targets, deploy_params, deploy_options):
    for source, target in zip(deply_sources,deploy_targets):
        os.makedirs(os.path.dirname(target), exist_ok=True)
        shutil.copyfile(source, target)
        for parameter in deploy_params:
            inplace_change(target, f"<PARAM {parameter} PARAM>", str(deploy_params[parameter]))
        for option in deploy_options:
            inplace_change(target, f"<OPTION {option} OPTION>", str(deploy_options[option]))

deploy(input, output, paramsdict, optionconfigdict)
