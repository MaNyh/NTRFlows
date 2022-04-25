rule prep:
    input:
        casefiles=[f"results/simulations/{paramspace.wildcard_pattern}/{file}" for file in template.files],
        mesh=config["case_params"]["mesh"]
    output:
        mesh = temporary(f"results/simulations/{paramspace.wildcard_pattern}/mesh.msh"),
        polymeshdir = directory(f"results/simulations/{paramspace.wildcard_pattern}/constant/polyMesh")
    params:
        casedirs = f"results/simulations/{paramspace.wildcard_pattern}",
        environment = options["env"],
        prepcommands = options["prep"]
    shell:
        """
        set +u
        {params.environment}
        cp {input.mesh} {params.casedirs}/mesh.msh
        cd {params.casedirs}
        {params.prepcommands}
        """