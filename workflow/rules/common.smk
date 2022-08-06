import pdb

from snakemake.utils import Paramspace
import pandas as pd
import os
import numpy as np


def get_casefiles():
    """
    this method probably (!) can't be used with create_case.smk, as there the wildcards have to be defined from the
    template-files
    :return:
    """
    files = [f"results/simulations/{instance_pattern}/{file}" for instance_pattern in paramspace.instance_patterns for file
      in template.files]
    return files

def get_defined_sim():
    """
    get a list of files that have to be created when the case is ready for execution
    """
    res = [directory(f"results/simulations/{instance_pattern}/{proc}/constant" for instance_pattern in paramspace.instance_patterns for proc in [f"processor{id}"  for id in range(config["processors"])])]
    return res


def get_results():
    """
    get list of results dependend on case_params.tsv and the workflowsettings.yaml
    this list will be used to determine wildcards. wildcards are passed down the rules
    """
    res = [f"results/simulations/{instance_pattern}/{proc}/{config['endtime']}/p"
                                            for instance_pattern in paramspace.instance_patterns
                                            for proc in [f"processor{id}"  for id in range(config["processors"])]]
    return res

def get_post():
    """
    get a list of files that have to be created by the rule post
    """
    res = [f"results/simulations/{instance_pattern}/bladeloading.jpg"
                                            for instance_pattern in paramspace.instance_patterns]
    res += [f"results/simulations/{instance_pattern}/velocity_contour.jpg"
                                            for instance_pattern in paramspace.instance_patterns]
    return res


def get_filelist_fromdir(path):
    """
    a simple method creating a list of path's using os.walk

    """
    filelist = []
    for r, d, f in os.walk(path):
        for file in f:
            filelist.append(os.path.join(r, file))
    return filelist

class case_template:
    """
    the original goal of this object was a flexible workflow that can handle multiple templates.
    this currently does not make sense as we have to write a simple and clean workflow that can easily adapted
    path and param-schema can be defined outside of this object
    when files is the only attribute of this object, we can redefine it to a function
    """
    def __init__(self, ):
        self.path = "resources/templates/openfoamCompressorCascadeRas"
        self.files = [os.path.relpath(fpath, self.path) for fpath in get_filelist_fromdir(self.path)]

def np_encoder(object):
    """
    encode an object to a numpy-object
    """
    if isinstance(object,np.generic):
        return object.item()

template = case_template()
params = pd.read_csv("config/case_params.tsv",sep="\t")
validate(params, "../schemas/param.schema.yaml")
numparams = len(params.keys())
paramspace = Paramspace(params)
paramspace.param_sep="~"

# the wildcardpattern is dependend on the keys defined in case_params.tv
# the pattern needs to contain all params and therefore the length has to be adapted
if numparams==1:
    paramspace.pattern="{}"
elif numparams>1:
    paramspace.pattern="{}_"+(numparams-2)*"{}_"+"{}"
