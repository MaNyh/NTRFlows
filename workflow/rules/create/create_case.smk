rule create_case:
    input:
        templatefiles=ntrflow.templatefiles,
        paramfile=f"results/simulations/{paramspace.wildcard_pattern}/paramdict.json",
        configfile=f"results/simulations/{paramspace.wildcard_pattern}/configdict.json"
    output:
        casefiles=[f"results/simulations/{paramspace.wildcard_pattern}/{file}" for file in ntrflow.casefiles]
    log: f"logs/{paramspace.wildcard_pattern}/create_case.log"
    container: "library://nyhuma/ntrflows/ntr.sif:v0.0.1"
    threads: 1
    shell:
        """
        python workflow/scripts/ntr_createcase.py --input {input.templatefiles} --output {output.casefiles} \
                                                --paramfile {input.paramfile} --configfile {input.configfile} > {log}
        """
