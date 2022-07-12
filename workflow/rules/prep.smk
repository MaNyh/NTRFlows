rule prep:
    input:
        casefiles=[f"results/simulations/{paramspace.wildcard_pattern}/{file}" for file in template.files],
        mesh=config["mesh"]
    output:
        mesh = temporary(f"results/simulations/{paramspace.wildcard_pattern}/mesh.msh"),
        preped = [directory(f"results/simulations/{paramspace.wildcard_pattern}/processor{pid}/constant") for pid in range(config["processors"])]
    params:
        casedirs = f"results/simulations/{paramspace.wildcard_pattern}",
        environment = config["env"],
    log: f"logs/{paramspace.wildcard_pattern}/prep.log"
    threads: 1
    container:
        "docker://openfoamplus/of_v2006_centos73"
    shell:
        """
        (
        {params.environment}
        cp {input.mesh} {params.casedirs}/mesh.msh
        cd {params.casedirs}
        fluent3DMeshToFoam mesh.msh
        createPatch -overwrite
        topoSet
        decomposePar -force
        )>> {log}
        """