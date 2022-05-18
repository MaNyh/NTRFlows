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
        log= protected(f"results/simulations/{paramspace.wildcard_pattern}/log")
    params:
        casedirs = f"results/simulations/{paramspace.wildcard_pattern}/",
        environment = config["env"],
    container:
        "docker://openfoamplus/of_v2006_centos73"
    log: f"logs/{paramspace.wildcard_pattern}/execute.log"
    threads: config["processors"]
    shell:
        """
        (
        cd {params.casedirs}
        {params.environment}
        mpirun -n 10 rhoPimpleFoam -parallel
        ) 2> {log}
        """