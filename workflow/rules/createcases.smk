
from snakemake.utils import Paramspace
from snakemake import load_configfile

import pandas as pd
import os

def get_template_files(path):

    files = []
    # r=root, d=directories, f = files
    for r, d, f in os.walk(path):
        for file in f:
            files.append(os.path.join(r,file))
    return files


TEMPLATENAME = config["case_type"]
TEMPLATEPATH =f"../resources/{TEMPLATENAME}"
PARAMS = pd.read_csv("config/case_params.tsv",sep="\t")
validate(PARAMS, config["param_schema"])
PARAMSPACE = Paramspace(PARAMS)
option_config = load_configfile("config/case_options.yaml")
validate(option_config,config["option_schema"])
TEMPLATEFILES = get_template_files(f"resources/{TEMPLATENAME}")

rule create_case:
    input:
        TEMPLATEFILES
    output:
        # format a wildcard pattern like "alpha~{alpha}/beta~{beta}/gamma~{gamma}"
        # into a file path, with alpha, beta, gamma being the columns of the data frame
        *[f"results/simulations/{PARAMSPACE.wildcard_pattern}/{file}" for file in TEMPLATEFILES]
    params:
        # automatically translate the wildcard values into an instance of the param space
        # in the form of a dict (here: {"alpha": ..., "beta": ..., "gamma": ...})
        simparams = PARAMSPACE.instance
    conda: "../envs/ntrfc.yaml"
    script: "../scripts/ntrfc_createcase.py"
