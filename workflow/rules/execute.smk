
rule execute:
    input:
        pfile=f"results/{paramspace.wildcard_pattern}.preped",
        prepedcase = [f"results/simulations/{paramspace.wildcard_pattern}/processor{pid}/constant" for pid in range(config["processors"])]
    output:
        resfile=f"results/{paramspace.wildcard_pattern}.res",
        results_pressurefield= protected([f"results/simulations/{paramspace.wildcard_pattern}/{proc}/{config['endtime']}/p"
        for proc in[f"processor{id}" for id in range(config["processors"])]]),
        results_temperaturefield= protected([f"results/simulations/{paramspace.wildcard_pattern}/{proc}/{config['endtime']}/T"
        for proc in[f"processor{id}" for id in range(config["processors"])]]),
        results_velocityfield= protected([f"results/simulations/{paramspace.wildcard_pattern}/{proc}/{config['endtime']}/U"
        for proc in[f"processor{id}" for id in range(config["processors"])]]),
        results_densityfield= protected([f"results/simulations/{paramspace.wildcard_pattern}/{proc}/{config['endtime']}/rho"
        for proc in[f"processor{id}" for id in range(config["processors"])]]),
    params:
        casedirs = f"results/simulations/{paramspace.wildcard_pattern}/",
    log: f"logs/{paramspace.wildcard_pattern}/execute.log"
    container:
        "docker://openfoamplus/of_v2006_centos73"
    threads: config["processors"]
    shell:
        """
        (
        touch {output.resfile}
        cd {params.casedirs}
        set +euo pipefail;. /opt/OpenFOAM/setImage_v2006.sh ;set -euo pipefail;
        mpirun --oversubscribe -n {threads} rhoPimpleFoam -parallel 
        ) 2> {log}
        """

