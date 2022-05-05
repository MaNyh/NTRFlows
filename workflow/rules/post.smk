rule prepost:
    input:
        rules.execute.output
    output:
        directory(f"results/simulations/{paramspace.wildcard_pattern}/VTK")
    params:
        environment = config["env"],
        casedirs = f"results/simulations/{paramspace.wildcard_pattern}",

    threads: 1
    container:
        "docker://openfoamplus/of_v2006_centos73"

    shell:
        """
        {params.environment}
        cd {params.casedirs}
        reconstructPar -latestTime
        foamToVTK -latestTime
        """

rule find_results:
    input:
        f"results/simulations/{paramspace.wildcard_pattern}/VTK"
    output:
        blade=f"results/simulations/{paramspace.wildcard_pattern}/res/BLADE.vtp",
        inlet=f"results/simulations/{paramspace.wildcard_pattern}/res/INLET.vtp",
        outlet=f"results/simulations/{paramspace.wildcard_pattern}/res/OUTLET.vtp",
        volume=f"results/simulations/{paramspace.wildcard_pattern}/res/internal.vtu",
    shell:
        """
        cp {input}/*/boundary/BLADE.vtp {output.blade}
        cp {input}/*/boundary/INLET.vtp {output.inlet}
        cp {input}/*/boundary/OUTLET.vtp {output.outlet}
        cp {input}/*/internal.vtu {output.volume}
        """

rule bladeloading:
    input: f"results/simulations/{paramspace.wildcard_pattern}/res/BLADE.vtp"
    output: f"results/simulations/{paramspace.wildcard_pattern}/bladeloading.csv"

    container: "library://nyhuma/ntrflows/ntr.sif:latest"
    shell:
        """
        python workflow/scripts/ntr_bladeloading.py --input {input} --output {output}
        """