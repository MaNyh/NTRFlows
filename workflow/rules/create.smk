rule prep_config_create_case:
    output:
        param_config = f"results/simulations/{paramspace.wildcard_pattern}/simparams.json",
        option_config = f"results/simulations/{paramspace.wildcard_pattern}/options.json"
    params:
        simparams = paramspace.instance,
    threads: 1
    run:
        import numpy as np
        import json
        def np_encoder(object):
            if isinstance(object,np.generic):
                return object.item()

        with open(output.param_config, "w") as fobj:
            fobj.write(json.dumps(params.simparams,indent=4, default=np_encoder))
        with open(output.option_config, "w") as fobj:
            fobj.write(json.dumps(options,indent=4,default=np_encoder))


rule create_case:
    input:
        templatefiles=[f"{template.path}/{file}" for file in template.files],
        param_config=rules.prep_config_create_case.output.param_config,
        option_config=rules.prep_config_create_case.output.option_config,
    output:
        casefiles=[f"results/simulations/{paramspace.wildcard_pattern}/{file}" for file in template.files]
    container:
        "workflow/container/ntrfc.sif"
    threads: 1
    shell:
        """
        python workflow/scripts/ntrfc_createcase.py --input {input.templatefiles} --output {output.casefiles} --simparams {input.param_config} --options {input.option_config}
        """