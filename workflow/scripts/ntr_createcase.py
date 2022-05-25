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

def find_paramconfig(files):
    params={"param":[],
            "config":[]}

    for sign in params.keys():
        varsignature = r"<PLACEHOLDER [A-Z]{3,}(_{1,1}[A-Z]{3,}){,} PLACEHOLDER>".replace(r'PLACEHOLDER', sign)
        siglim = (5, -5)

        for fpath in files:
            with open(fpath, "r") as fhandle:
                for line in fhandle.readlines():
                    lookforvar = True
                    while (lookforvar):
                        lookup_var = re.search(varsignature, line)
                        if not lookup_var:
                            lookforvar = False
                        else:
                            span = lookup_var.span()
                            parameter = line[span[0] + siglim[0]:span[1] + siglim[1]]
                            setInDict(case_structure, list(pair[:-1]) + [parameter], varsign)
                            match = line[span[0]:span[1]]
                            line = line.replace(match, "")
                            params[sign].append(match)
    return params




def check_sanity(deply_sources, paramsdict, configdict):
    parm=find_paramconfig(deply_sources)
    return parm

def deploy(deply_sources,deploy_targets, paramsdict, configdict):
    print(check_sanity)
    for source, target in zip(deply_sources,deploy_targets):
        os.makedirs(os.path.dirname(target), exist_ok=True)
        shutil.copyfile(source, target)
        for parameter in paramsdict:
            inplace_change(target, f"<PARAM {parameter} PARAM>", str(paramsdict[parameter]))
        for config in configdict:
            inplace_change(target, f"<CONFIG {config} CONFIG>", str(configdict[config]))


deploy(input, output, paramdict, configdict)
