
print([directory(f"results/simulations/{instance_pattern}/asd.ext") for instance_pattern in paramspace.instance_patterns])
rule execute:
    input:
        polymeshdir = [directory(f"results/simulations/{paramspace.wildcard_pattern}/processor{pid}") for pid in range(options["processors"])]
    output:
        resultfiles = [directory(f"results/simulations/{paramspace.wildcard_pattern}/ja") ]

    #log: f"results/simulations/{paramspace.wildcard_pattern}/logfile",
    params:
        casedirs = f"results/simulations/{paramspace.wildcard_pattern}/",
        environment = options["env"],
        executable = options["executable"],
        preexec = options["preexec"],
        args = options["args"]
    resources:
        attempt=3,
        mem_mb=32000
    threads: 10
    container:
        "docker://openfoamplus/of_v1612plus_centos66"
    shell:
        """
        {params.environment}
        cd {params.casedirs}
        {params.preexec}
        mpirun -np {threads} {params.executable} {params.args} #> {log}
        """
