rule execute:
    input:
        decomposed = [f"results/simulations/{paramspace.wildcard_pattern}/processor{pid}/constant" for pid in range(config["processors"])]
    output:
        results_pressurefield = protected([f"results/simulations/{paramspace.wildcard_pattern}/{proc}/{config['endtime']}/p"
                                            for proc in [f"processor{id}"  for id in range(config["processors"])]]),
        results_temperaturefield = protected([f"results/simulations/{paramspace.wildcard_pattern}/{proc}/{config['endtime']}/T"
                                            for proc in [f"processor{id}"  for id in range(config["processors"])]]),
        results_velocityfield = protected([f"results/simulations/{paramspace.wildcard_pattern}/{proc}/{config['endtime']}/U"
                                            for proc in [f"processor{id}"  for id in range(config["processors"])]]),
        results_densityfield = protected([f"results/simulations/{paramspace.wildcard_pattern}/{proc}/{config['endtime']}/rho"
                                            for proc in [f"processor{id}"  for id in range(config["processors"])]]),
    params:
        casedirs = f"results/simulations/{paramspace.wildcard_pattern}/",
    container: "docker://openfoamplus/of_v2006_centos73"
    log: f"logs/{paramspace.wildcard_pattern}/execute.log"
    threads: config["processors"]
    shell:
        """
        (
        cd {params.casedirs}
        set +euo pipefail;. /opt/OpenFOAM/setImage_v2006.sh ;set -euo pipefail;
        mpirun --oversubscribe -n {threads} rhoSimpleFoam -parallel 
        ) 2> {log}
        """