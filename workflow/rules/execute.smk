

rule execute:
    input:
        polymeshdir = get_defined_sim()
    output:
        resultfiles = get_results()
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
