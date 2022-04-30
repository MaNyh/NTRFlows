
print([directory(f"results/simulations/{instance_pattern}/asd.ext") for instance_pattern in paramspace.instance_patterns])
rule execute:
    input:
        polymeshdir = [directory(f"results/simulations/{paramspace.wildcard_pattern}/processor{pid}") for pid in range(options["processors"])]
    output:
        resultfiles = "results/yay"#[directory(f"results/simulations/{instance_pattern}/asd.ext") for instance_pattern in paramspace.instance_patterns]

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
        "docker://openfoamplus/of_v1612plus_centos66"
    shell:
        """
        set +u
        {params.environment}
        cd {params.casedirs}
        {params.preexec}
        mpirn -np $({params.executable}) {params.args} #> {log}
        """
