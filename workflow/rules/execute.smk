rule execute:
    input:
        polymeshdir = directory(f"results/simulations/{paramspace.wildcard_pattern}/constant/polyMesh")
    output:
        resultfiles = f"results/simulations/{paramspace.wildcard_pattern}/haha.txt"
    params:
        casedirs = f"results/simulations/{paramspace.wildcard_pattern}",
        environment = options["env"],
        run = options["run"]
    shell:
        """
        set +u
        {params.environment}
        cd {params.casedirs}
        {params.run}
        """