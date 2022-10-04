from snakemake.utils import Paramspace

paramspace = Paramspace(params)
paramspace.param_sep="~"
# the wildcardpattern is dependend on the keys defined in case_params.tv
# the pattern needs to contain all params and therefore the length has to be adapted
NUMPARAMS = len(paramspace.dataframe.keys())
if NUMPARAMS==1:
    paramspace.pattern="{}"
elif NUMPARAMS>1:
    paramspace.pattern="{}_" + (NUMPARAMS - 2) * "{}_" + "{}"

SIMS = list(paramspace["id"])
DEPS = list(paramspace["dependency"])
SIMNAMES = list(paramspace.instance_patterns)

def get_dependency_case(wildcards):
    depid = wildcards.dependency
    simid = SIMS.index(depid)
    dependency = SIMNAMES[simid]
    return dependency

def get_dependency_solution(wildcards):
    dependency = get_dependency_case(wildcards)
    resultfile =f"results/{dependency}.res"
    return resultfile

def get_dependency_touchfile(wildcards):
    simid = wildcards.id
    idx = SIMS.index(simid)
    simname = SIMNAMES[idx]
    touchfile = f"results/dependency/{simname}.dep"
    return touchfile

def get_independency_touchfile(wildcards):
    simid = wildcards.id
    idx = SIMS.index(simid)
    simname = SIMNAMES[idx]
    touchfile = f"results/dependency/{simname}.idep"
    return touchfile

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
        self.path = "resources/casefiles"
        self.files = [os.path.relpath(fpath, self.path) for fpath in get_filelist_fromdir(self.path)]

template = case_template()
