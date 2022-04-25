rule execute:
    input:
        polymeshdir = f"results/simulations/{paramspace.wildcard_pattern}/constant/polyMesh"
    output:
        resultfiles = [directory(f"results/simulations/{paramspace.wildcard_pattern}/{proc}/{options['endtime']}")
                                 for proc in [f"processor{id}" for id in range(1,options["processors"]+1)]]
    params:
        casedirs = f"results/simulations/{paramspace.wildcard_pattern}/",
        environment = options["env"],
        run = options["run"]
    threads:
        options["processors"]
    resources:
        attempt=3
    shell:
        """
        set +u
        {params.environment}
        cd {params.casedirs}
        mpirun -np {threads} {params.run}
        """
