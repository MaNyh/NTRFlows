import numpy as np

def np_encoder(object):
    """
    encode an object to a numpy-object
    """
    if isinstance(object,np.generic):
        return object.item()


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

rule create_case:
    input:
        templatefiles=[f"{template.path}/{file}" for file in template.files],
        paramfile=f"results/simulations/{paramspace.wildcard_pattern}/paramdict.json",
        configfile=f"results/simulations/{paramspace.wildcard_pattern}/configdict.json"
    output:
        casefiles=[f"results/simulations/{paramspace.wildcard_pattern}/{file}" for file in template.files]
    log: f"logs/{paramspace.wildcard_pattern}/create_case.log"
    container: "library://nyhuma/ntrflows/ntr.sif:v0.0.1"
    threads: 1
    shell:
        """
        python workflow/scripts/ntr_createcase.py --input {input.templatefiles} --output {output.casefiles} --paramfile {input.paramfile} --configfile {input.configfile} > {log}
        """

def get_indepentend_cases():
    independents = []
    for sim, dep in zip(SIMNAMES,DEPS):
        if dep==0 or dep == "0":
            independents.append(f"results/dependency/{sim}.idep")
    return independents

def get_depentend_cases():
    dependents = []
    for sim, dep in zip(SIMNAMES,DEPS):
        if dep!=0 and dep!="0":
            dependents.append(f"results/dependency/{sim}.dep")
    return dependents

rule touch_independents:
    output: temporary(get_indepentend_cases())
    shell:
        """
        touch {output}
        """

rule touch_dependents:
    output: temporary(get_depentend_cases())
    shell:
        """
        touch {output}
        """