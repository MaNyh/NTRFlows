rule touch_independents:
    output: temporary(get_indepentend_cases())
    log: f"logs/touch_independents.log"
    container: "library://nyhuma/ntrflows/ntr.sif:v0.0.1"
    shell:
        """
        touch {output} > {log}
        """

rule touch_dependents:
    output: temporary(get_depentend_cases())
    log: f"logs/touch_dependents.log"
    container: "library://nyhuma/ntrflows/ntr.sif:v0.0.1"
    shell:
        """
        touch {output} > {log}
        """