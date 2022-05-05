
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
    resources:
        attempt=3,
        mem_mb=32000
    threads: config["processors"]
    container:
        "docker://openfoamplus/of_v2006_centos73"
    shell:
        """
        {params.environment}
        cd {params.casedirs}
        #write hostfile
        echo "" > myhostfile; for var in $SLURM_JOB_NODELIST; do echo $var max_slots={threads} >> myhostfile; done
        echo $SLURM_JOB_NODELIST max_slots=10 > myhostfile
        mpirun -hostfile myhostfile --oversubscribe -np {threads} rhoPimpleFoam -parallel > log
        """
