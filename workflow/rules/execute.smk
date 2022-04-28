

rule execute:
    input:
        polymeshdir = f"results/simulations/{paramspace.wildcard_pattern}/input/TRACE.cgns"
    output:
        resultfiles = protected(f"results/simulations/{paramspace.wildcard_pattern}/output/cgns/TRACE.cgns"),
        nodefile = temp(f"results/simulations/{paramspace.wildcard_pattern}/nodefile"),

    #log: f"results/simulations/{paramspace.wildcard_pattern}/logfile",
    params:
        casedirs = f"results/simulations/{paramspace.wildcard_pattern}/",
        environment = options["env"],
        preexec = options["preexecution"],
        executable = options["executable"],
        args = options["args"]
    resources:
        attempt=3,
        mem_mb=32000
    threads: 55

    shell:
        """
        set +u
        {params.environment}
        cd {params.casedirs}
        {params.preexec}
        srun --cpu_bin=cores --distribution=block:cyclic $({params.executable}) {params.args} #> {log}
        """
