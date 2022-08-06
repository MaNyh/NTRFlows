rule write_caseconfig:
    output:
        paramfile = f"results/simulations/{paramspace.wildcard_pattern}/paramdict.json",
        configfile = f"results/simulations/{paramspace.wildcard_pattern}/configdict.json",
        dependency = f"results/simulations/{paramspace.wildcard_pattern}/dependency_{paramspace.instance['dependency']}',
    params:
        simparams = paramspace.instance,
        simconfig = config,
    threads: 1
    log: f"logs/{paramspace.wildcard_pattern}/write_caseconfig.log"
    run:
        """
        this rule must use "run" as python-dictionaries have to be converted to json.
        it is not straight forward to call a python script with dicts as arguments.
        therefor the conversion into json usin "run"
        """
        import json

        logger.info(f"writing params to {log}")
        with open(output.paramfile, "w") as fobj:
            fobj.write(json.dumps(params.simparams,indent=4, default=np_encoder))

        logger.info(f"writing config to {log}")
        with open(output.configfile, "w") as fobj:
            fobj.write(json.dumps(params.simconfig,indent=4, default=np_encoder))

        with open(output.dependency,"w") as fobj:
            fobj.write(" ")


rule create_case:
    input:
        templatefiles=[f"{template.path}/{file}" for file in template.files],
        paramfile=f"results/simulations/{paramspace.wildcard_pattern}/paramdict.json",
        configfile=f"results/simulations/{paramspace.wildcard_pattern}/configdict.json"
    output:
        casefiles=[f"results/simulations/{paramspace.wildcard_pattern}/{file}" for file in template.files]
    log: f"logs/{paramspace.wildcard_pattern}/create_case.log"
    container: "library://nyhuma/ntrflows/ntr.sif:latest"
    threads: 1
    shell:
        """
        python workflow/scripts/ntr_createcase.py --input {input.templatefiles} --output {output.casefiles} --paramfile {input.paramfile} --configfile {input.configfile} > {log}
        """