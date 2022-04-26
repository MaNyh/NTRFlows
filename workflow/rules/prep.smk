rule prep:
    input:
        casefiles=[f"results/simulations/{paramspace.wildcard_pattern}/{file}" for file in template.files],
        mesh=config["case_params"]["mesh"]
    output:
        # todo: the following line is excluded because of ambigiuty between prep and execute. the paramspace-.wildcard_pattern
        # is reading /output/cgns/TRACE.cgns as a pattern --> ambigious
        # but temporary()
        #mesh = temporary(f"results/simulations/{paramspace.wildcard_pattern}/TRACE.cgns"),
        preped = f"results/simulations/{paramspace.wildcard_pattern}/input/TRACE.cgns"
    params:
        casedirs = f"results/simulations/{paramspace.wildcard_pattern}",
        environment = options["env"],
        prepcommands = options["prep"]
    threads: 1
    shell:
        """
        set +u
        {params.environment}
        cp {input.mesh} {params.casedirs}/.
        cd {params.casedirs}
        {params.prepcommands}
        """