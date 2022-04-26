

rule execute:
    input:
        polymeshdir = f"results/simulations/{paramspace.wildcard_pattern}/input/TRACE.cgns"
    output:
        resultfiles = f"results/simulations/{paramspace.wildcard_pattern}/output/cgns/TRACE.cgns"
    params:
        casedirs = f"results/simulations/{paramspace.wildcard_pattern}/",
        environment = options["env"],
        run = options["run"]
    resources:
        attempt=3,
        nodes=5,
        mem_mb=32000
    threads: options["processors"]

    shell:
        """
        set +u
        {params.environment}
        cd {params.casedirs}
        mpirun -np {threads} {params.run}
        """
