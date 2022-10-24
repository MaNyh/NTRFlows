
rule write_caseconfig:
    output:
        paramfile = f"results/simulations/{paramspace.wildcard_pattern}/paramdict.json",
        configfile = f"results/simulations/{paramspace.wildcard_pattern}/configdict.json"
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
        import logging

        logger = logging.getLogger(f"{log}")
        fh = logging.FileHandler(str(log))
        fh.setLevel(logging.INFO)
        formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
        fh.setFormatter(formatter)
        logger.addHandler(fh)

        logger.info(f"writing params to {log}")
        with open(output.paramfile, "w") as fobj:
            fobj.write(json.dumps(params.simparams,indent=4, default=np_encoder))

        logger.info(f"writing config to {log}")
        with open(output.configfile, "w") as fobj:
            fobj.write(json.dumps(params.simconfig,indent=4, default=np_encoder))