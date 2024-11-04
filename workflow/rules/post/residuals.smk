rule log_residuals:
    input:  f"logs/{paramspace.wildcard_pattern}/execute.log"
    output:
        logfile = temporary(f"results/simulations/{paramspace.wildcard_pattern}/foamexecution.log"),
        ux_residuals =  f"results/simulations/{paramspace.wildcard_pattern}/logs/Ux_0",
        uy_residuals =  f"results/simulations/{paramspace.wildcard_pattern}/logs/Uy_0",
        uz_residuals =  f"results/simulations/{paramspace.wildcard_pattern}/logs/Uz_0",
        time =  f"results/simulations/{paramspace.wildcard_pattern}/logs/Time_0",
    params:
        casedirs = f"results/simulations/{paramspace.wildcard_pattern}",
    container:
        "docker://openfoamplus/of_v2006_centos73"
    log: f"logs/{paramspace.wildcard_pattern}/readlog.log"
    threads: 1
    shell:
        """
        (
        cp {input} {output.logfile}
        set +euo pipefail;. /opt/OpenFOAM/setImage_v2006.sh ;set -euo pipefail; 
        cd {params.casedirs}
        foamLog -n foamexecution.log
        )  2>&1 > {log}
        """

rule plot_residuals:
    input:
        ux_residuals = rules.log_residuals.output.ux_residuals,
        uy_residuals = rules.log_residuals.output.uy_residuals,
        uz_residuals = rules.log_residuals.output.uz_residuals,
        time =  rules.log_residuals.output.time
    output:
        residuals = report(f"results/simulations/{paramspace.wildcard_pattern}/residuals.jpg",category="residual u")
    container: "library://nyhuma/ntrflows/ntr.sif:0.2.2"
    log: f"logs/{paramspace.wildcard_pattern}/residualplot.log"
    shell:
        """
        python workflow/scripts/ntr_plotresiduals.py --ux {input.ux_residuals} --uy {input.uy_residuals} \
                                                    --uz {input.uz_residuals} --time {input.time} \
                                                   --output {output} > {log}
        """