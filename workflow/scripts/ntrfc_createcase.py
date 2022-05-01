import argparse
import json
import os
import shutil

from ntrfc.utils.filehandling.datafiles import inplace_change

parser = argparse.ArgumentParser(description='Snakemake arguments for ntrfc')
parser.add_argument('--inputfiles', nargs='+', help='list of input files')
parser.add_argument('--outputfiles', nargs='+', help='list of output files')
parser.add_argument('--paramfile', type=str, help='path to paramfile')
parser.add_argument('--configfile', type=str, help='path to configfile')


args = parser.parse_args()

input = args.inputfiles
output = args.outputfiles
paramfile = args.paramfile
configfile = args.configfile

with open(paramfile,"r") as fobj:
    paramdict = json.loads(fobj.read())

with open(configfile,"r") as fobj:
    configdict = json.loads(fobj.read())

def deploy(deply_sources,deploy_targets, paramsdict, configdict):
    for source, target in zip(deply_sources,deploy_targets):
        os.makedirs(os.path.dirname(target), exist_ok=True)
        shutil.copyfile(source, target)
        for parameter in paramsdict:
            inplace_change(target, f"<PARAM {parameter} PARAM>", str(paramsdict[parameter]))
        for config in configdict:
            inplace_change(target, f"<CONFIG {config} CONFIG>", str(configdict[config]))


deploy(input, output, paramdict, configdict)
