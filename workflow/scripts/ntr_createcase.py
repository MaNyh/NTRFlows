import argparse
import json
import os
import pdb
import re
import shutil

from ntrfc.utils.filehandling.datafiles import inplace_change

parser = argparse.ArgumentParser(description='Snakemake arguments for ntrfc')
parser.add_argument('--inputfiles', nargs='+', help='list of input files')
parser.add_argument('--outputfiles', nargs='+', help='list of output files')
parser.add_argument('--paramfile', type=str, help='templatepath to paramfile')
parser.add_argument('--configfile', type=str, help='templatepath to configfile')


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
    params={"PARAM":[],
            "CONFIG":[]}

    for sign in params.keys():
        varsignature = r"<PLACEHOLDER [a-z]{3,}(_{1,1}[a-z]{1,}){0,} PLACEHOLDER>".replace(r'PLACEHOLDER', sign)
        siglim = (len(sign)+2, -len(sign)-2)

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
                            match = line[span[0]:span[1]]
                            line = line.replace(match, "")
                            if parameter not in params[sign]:
                                params[sign].append(parameter)
    return params


def check_sanity(deply_sources, paramsdict, configdict):
    param=find_paramconfig(deply_sources)
    template_params = param["PARAM"]
    template_configs = param["CONFIG"]
    defined_params = list(paramsdict.keys())
    defined_config = list(configdict.keys())

    for par in template_params:
        assert par in defined_params, f"error finding {par} in the template. {template_params}"
        if par in defined_params:
            defined_params.remove(par)

    for con in template_configs:
        assert con in template_configs, f"error finding {con} in the template"
        if con in defined_config:
            defined_config.remove(con)
    return 0

def deploy(deply_sources,deploy_targets, paramsdict, configdict):
    check_sanity(deply_sources, paramsdict, configdict)
    for source, target in zip(deply_sources,deploy_targets):
        os.makedirs(os.path.dirname(target), exist_ok=True)
        shutil.copyfile(source, target)
        for parameter in paramsdict:
            inplace_change(target, f"<PARAM {parameter} PARAM>", str(paramsdict[parameter]))
        for config in configdict:
            inplace_change(target, f"<CONFIG {config} CONFIG>", str(configdict[config]))


deploy(input, output, paramdict, configdict)
