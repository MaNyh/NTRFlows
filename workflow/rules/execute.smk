rule execute:
    input:
         [f"results/simulations/{paramspace.wildcard_pattern}/processor{pid}/constant" for pid in range(config["processors"])]
    output:
        pressure = protected([f"results/simulations/{paramspace.wildcard_pattern}/{proc}/{options['endtime']}/p"
                                            for proc in [f"processor{id}"  for id in range(config["processors"])]]),
        temperature = protected([f"results/simulations/{paramspace.wildcard_pattern}/{proc}/{options['endtime']}/T"
                                            for proc in [f"processor{id}"  for id in range(config["processors"])]]),
        velocity = protected([f"results/simulations/{paramspace.wildcard_pattern}/{proc}/{options['endtime']}/U"
                                            for proc in [f"processor{id}"  for id in range(config["processors"])]]),
        density = protected([f"results/simulations/{paramspace.wildcard_pattern}/{proc}/{options['endtime']}/rho"
                                            for proc in [f"processor{id}"  for id in range(config["processors"])]]),
        log= protected(f"results/simulations/{paramspace.wildcard_pattern}/log")
    params:
        casedirs = f"results/simulations/{paramspace.wildcard_pattern}/",
        environment = options["env"],
        processors = config["processors"]
    resources:
        attempt=3,
        mem_mb=32000
    container:
        "docker://openfoamplus/of_v2006_centos73"

    log: f"logs/{paramspace.wildcard_pattern}/execute.log"
    threads: config["processors"]
    shell:
        """
        (
        cd {params.casedirs}
        {params.environment}
        mpirun --oversubscribe -np {threads} rhoPimpleFoam -parallel
        ) >> {log}
        """






# execut_output = ["p","T","U","rho"]
#
# def execute():
#     return [f"results/simulations/{instance_pattern}/{proc}/{options['endtime']}/{f}"
#                                             for instance_pattern in paramspace.instance_patterns
#                                             for proc in [f"processor{id}"  for id in range(config["processors"])] for f in execut_output]

# rule execute:
#     input:
#         polymeshdir = f"results/simulations/{paramspace.wildcard_pattern}/input/TRACE.cgns"
#     output:
#         resultfiles = f"results/simulations/{paramspace.wildcard_pattern}/output/cgns/TRACE.cgns"
#     params:
#         casedirs = f"results/simulations/{paramspace.wildcard_pattern}/",
#         environment = options["env"],
#         run = options["run"]
#     resources:
#         attempt=3,
#         nodes=5,
#         mem_mb=32000
#     threads: options["processors"]
#
#     shell:
#         """
#         set +u
#         {params.environment}
#         cd {params.casedirs}
#         mpirun -np {threads} {params.run}
#         """
