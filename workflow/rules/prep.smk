rule prep:
    input:
        casefiles=[f"results/simulations/{paramspace.wildcard_pattern}/{file}" for file in template.files],
        mesh=config["mesh"]
    output:
        # but temporary()
        mesh = temporary(f"results/simulations/{paramspace.wildcard_pattern}/mesh.msh"),
        preped = [directory(f"results/simulations/{paramspace.wildcard_pattern}/processor{pid}") for pid in range(config["processors"])]
    params:
        casedirs = f"results/simulations/{paramspace.wildcard_pattern}",
        environment = config["env"],
        prepcommands = config["prep"]
    threads: 1
    container:
        "docker://openfoamplus/of_v1612plus_centos66"

    shell:
        """
        {params.environment}
        cp {input.mesh} {params.casedirs}/mesh.msh
        cd {params.casedirs}
        {params.prepcommands}
        """