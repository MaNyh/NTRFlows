# def get_simdir(path):
#     simdir = []
#     for r, d, f in os.walk(path):
#         for dir in d:
#             if dir == "pitch~0.0765":
#                 simdir.append(os.path.join(r, dir))
#
#     return simdir

def get_filelist_fromdir(path):
    filelist = []
    for r, d, f in os.walk(path):
        for file in f:
            filelist.append(os.path.join(r, file))

    return filelist

rule prep:
    input:
        casefiles= get_filelist_fromdir("results/simulations"),
        mesh=config["case_params"]["mesh"]
    output:
        mesh = temporary(f"results/simulations/{paramspace.wildcard_pattern}/mesh.msh"),
        preped = [directory(f"results/simulations/{paramspace.wildcard_pattern}/processor{num}/constant" for num in range(config["processors"]))]
    params:
        casedirs = f"results/simulations/{paramspace.wildcard_pattern}",
        environment = options["env"],
        prepcommands = options["prep"]
    container:
            "docker://openfoamplus/of_v2006_centos73"
    log: f"logs/{paramspace.wildcard_pattern}/prep.log"
    threads: 1
    shell:
        """
        (
        {params.environment}
        cp {input.mesh} {params.casedirs}/mesh.msh
        cd {params.casedirs}
        {params.prepcommands}) >> {log};
        """

def get_prep():
    return [directory(f"results/simulations/{instance_pattern}/{proc}/constant" for instance_pattern in paramspace.instance_patterns for proc in [f"processor{num}"  for num in range(config["processors"])])]