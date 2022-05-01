
print([directory(f"results/simulations/{instance_pattern}/asd.ext") for instance_pattern in paramspace.instance_patterns])
rule execute:
    input:
        polymeshdir = [directory(f"results/simulations/{paramspace.wildcard_pattern}/processor{pid}") for pid in range(config["processors"])]
    output:
        resultfiles = [directory(f"results/simulations/{paramspace.wildcard_pattern}/ja") ]

    #log: f"results/simulations/{paramspace.wildcard_pattern}/logfile",
    params:
        casedirs = f"results/simulations/{paramspace.wildcard_pattern}/",
        environment = config["env"],
        execute = config["execute"],
        preexec=config["prexec"],
    resources:
        attempt=3,
        mem_mb=32000
    threads: 40
    container:
        "docker://openfoamplus/of_v1612plus_centos66"
    shell:
        """
        {params.environment}
        cd {params.casedirs}
        {params.preexec}
        mpirun -oversubscribe -np {threads} {params.execute} #> {log}
        """
