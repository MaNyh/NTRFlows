import numpy as np

def np_encoder(object):
    """
    encode an object to a numpy-object
    """
    if isinstance(object,np.generic):
        return object.item()


def get_indepentend_cases():
    independents = []
    for sim, dep in zip(SIMNAMES,DEPS):
        if dep==0 or dep == "0":
            independents.append(f"results/touchfiles/{sim}.idep")
    return independents

def get_depentend_cases():
    dependents = []
    for sim, dep in zip(SIMNAMES,DEPS):
        if dep!=0 and dep!="0":
            dependents.append(f"results/touchfiles/{sim}.dep")
    return dependents

def get_dependency_case(wildcards):
    depid = wildcards.dependency
    simid = SIMS.index(depid)
    dependency = SIMNAMES[simid]
    return dependency

def get_dependency_solution(wildcards):
    dependency = get_dependency_case(wildcards)
    resultfile =f"results/touchfiles/{dependency}.res"
    return resultfile

def get_dependency_touchfile(wildcards):
    simid = wildcards.id
    idx = SIMS.index(simid)
    simname = SIMNAMES[idx]
    touchfile = f"results/touchfiles/{simname}.dep"
    return touchfile

def get_independency_touchfile(wildcards):
    simid = wildcards.id
    idx = SIMS.index(simid)
    simname = SIMNAMES[idx]
    touchfile = f"results/touchfiles/{simname}.idep"
    return touchfile

def get_filelist_fromdir(path):
    """
    a simple method creating a list of templatepath's using os.walk

    """
    filelist = []
    for r, d, f in os.walk(path):
        for file in f:
            filelist.append(os.path.join(r, file))
    return filelist

def get_post():
    """
    get a list of files that have to be created by the rule post
    """
    res = [f"results/simulations/{instance_pattern}/bladeloading.jpg"
                                            for instance_pattern in paramspace.instance_patterns]
    res += [f"results/simulations/{instance_pattern}/velocity_contour.jpg"
                                            for instance_pattern in paramspace.instance_patterns]
    res += [f"results/simulations/{instance_pattern}/residuals.jpg"
                                            for instance_pattern in paramspace.instance_patterns]
    return res


class case:
    """
    the original goal of this object was a flexible workflow that can handle multiple templates.
    this currently does not make sense as we have to write a simple and clean workflow that can easily adapted
    templatepath and param-schema can be defined outside of this object
    when files is the only attribute of this object, we can redefine it to a function
    """
    def __init__(self):
        self.templatepath = "resources/casefiles"
        self.casefiles = [os.path.relpath(fpath,self.templatepath) for fpath in get_filelist_fromdir(self.templatepath)]
        self.templatefiles = [ os.path.join(self.templatepath,file) for file in self.casefiles]

        self.resultfiles = {
            "pressurefield" :[f"{proc}/{config['endtime']}/p" for proc in [f"processor{id}" for id in range(config["processors"])]],
            "temperaturefield" :[f"{proc}/{config['endtime']}/T" for proc in[f"processor{id}" for id in range(config["processors"])]],
            "velocityfield" :[f"{proc}/{config['endtime']}/U" for proc in [f"processor{id}" for id in range(config["processors"])]],
            "densityfield" :[f"{proc}/{config['endtime']}/rho" for proc in[f"processor{id}" for id in range(config["processors"])]],
                }

ntrflow = case()

