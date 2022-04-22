import json

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
options = load_configfile("config/case_options.yaml")
validate(options,template.option_schema)

def get_casefiles():
    files = [f"results/simulations/{instance_pattern}/{file}" for instance_pattern in paramspace.instance_patterns for file
      in template.files]
    return files

rule prep_config_create_case:
    output:
        param_config = f"results/simulations/{paramspace.wildcard_pattern}/simparams.json",
        option_config = f"results/simulations/{paramspace.wildcard_pattern}/options.json"
    params:
        simparams = paramspace.instance,
    run:
        # import pdb
        # pdb.set_trace()
        import numpy as np
        def np_encoder(object):
            if isinstance(object,np.generic):
                return object.item()
        with open(output.param_config, "w") as fobj:
            fobj.write(json.dumps(params.simparams,indent=4, default=np_encoder))
        with open(output.option_config, "w") as fobj:
            fobj.write(json.dumps(options,indent=4,default=np_encoder))


rule create_case:
    input:
        templatefiles=[f"{template.path}/{file}" for file in template.files],
        param_config=rules.prep_config_create_case.output.param_config,
        option_config=rules.prep_config_create_case.output.option_config,
    output:
        casefiles=[f"results/simulations/{paramspace.wildcard_pattern}/{file}" for file in template.files]
    container:
        "workflow/container/ntrfc.sif"
    shell:
        """
        python workflow/scripts/ntrfc_createcase.py --input {input.templatefiles} --output {output.casefiles} --simparams {input.param_config} --options {input.option_config}
        """