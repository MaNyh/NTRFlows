from snakemake.utils import validate
from snakemake.utils import Paramspace
from snakemake import load_configfile

import pandas as pd
import os

AVAIL_TEMPLATES = ["openfoamCompressorCascadeRas"]

def get_filelist_fromdir(path):
    filelist = []
    for r, d, f in os.walk(path):
        for file in f:
            filelist.append(os.path.join(r, file))
    return filelist

class case_template:

    psign = "PARAM"
    osign = "OPTION"

    def __init__(self, name):
        self.name = name
        self.path = f"resources/{name}"
        self.param_schema = f"../../resources/{name}_param.schema.yaml"
        self.option_schema = f"../../resources/{name}_option.schema.yaml"
        self.files = [os.path.relpath(fpath, self.path) for fpath in get_filelist_fromdir(self.path)]


    """
        self.params = find_vars(self.path, self.psign)
        self.params_set = {}
        self.options = find_vars(self.path,self.osign)
        self.options_set = {}

    def set_params_options(self,params_set,options_set):
        self.params_set = params_set
        self.options_set = options_set

    def sanity_check(self):
        sanity = True
        for p in self.params.keys():
            if p not in self.params_set.keys():
                sanity=False
                warnings.warn(f"{p} not set")
        for o in self.options.keys():
            if o not in self.options_set.keys():
                sanity=False
                warnings.warn(f"{o} not set")
        return sanity
    """


CASE_TEMPLATES = {templatename: case_template(templatename) for templatename in AVAIL_TEMPLATES}

template = CASE_TEMPLATES[config["case_params"]["case_type"]]

params = pd.read_csv("config/case_params.tsv",sep="\t")
validate(params, template.param_schema)
paramspace = Paramspace(params)

option_config = load_configfile("config/case_options.yaml")
validate(option_config,template.option_schema)


def get_casefiles():
    files = [f"results/simulations/{instance_pattern}/{file}" for instance_pattern in paramspace.instance_patterns for file
      in template.files]
    return files


rule create_case:
    input:
        [f"{template.path}/{file}" for file in template.files]
    output:
        # format a wildcard pattern like "alpha~{alpha}/beta~{beta}/gamma~{gamma}"
        # into a file path, with alpha, beta, gamma being the columns of the data frame
        *[f"results/simulations/{paramspace.wildcard_pattern}/{file}" for file in template.files]
    params:
        # automatically translate the wildcard values into an instance of the param space
        # in the form of a dict (here: {"alpha": ..., "beta": ..., "gamma": ...})
        simparams = paramspace.instance
    # container:
    #    "conainer/ntrfc.sif"
    #shell:
    #    "python scripts/ntrfc_createcase.py --input {input} --output {output} --simparams {params.simparams} --options {option_config}"
    run:
        print(params["simparams"])