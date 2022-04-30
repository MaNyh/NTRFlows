

rule execute:
    input:
        polymeshdir = f"results/simulations/{paramspace.wildcard_pattern}/input/TRACE.cgns"
    output:
        resultfiles = [directory(f"results/simulations/{paramspace.wildcard_pattern}/{proc}" for proc in [f"processor{id}"  for id in range(options["processors"])])]#protected(f"results/simulations/{paramspace.wildcard_pattern}/output/cgns/TRACE.cgns"),

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
    threads: 55
    container:
        "docker://openfoamplus/of_v2006_centos73"
    shell:
        """
        set +u
        {params.environment}
        cd {params.casedirs}
        {params.preexec}
        mpirn -np $({params.executable}) {params.args} #> {log}
        """
