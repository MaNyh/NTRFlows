rule prep_independent:
    input:
        case=rules.create_case.output,
        idepfile=get_independency_touchfile,
        mesh=config["mesh"]

    output:
        pfile=temporary(f"results/{paramspace.wildcard_pattern}.preped"),
        mesh= temporary(f"results/simulations/{paramspace.wildcard_pattern}/mesh.msh"),
        preped=[directory(f"results/simulations/{paramspace.wildcard_pattern}/processor{pid}/constant") for pid in range(config["processors"])]
    params:
        casedirs = f"results/simulations/{paramspace.wildcard_pattern}",
    log: f"logs/{paramspace.wildcard_pattern}/prep.log"
    threads: 1
    container:
        "docker://openfoamplus/of_v2006_centos73"
    shell:
        """
        (         
        touch {output.pfile}         
        set +euo pipefail;. /opt/OpenFOAM/setImage_v2006.sh ;set -euo pipefail;
        cp {input.mesh} {params.casedirs}/mesh.msh
        cd {params.casedirs}
        fluent3DMeshToFoam mesh.msh
        createPatch -overwrite
        topoSet
        decomposePar -force
        ) 2>&1 > {log}
        """


rule prep_dependent:
    input:
        case=rules.create_case.output,
        depfile=get_dependency_touchfile,
        dependency=get_dependency_solution,
        mesh=config["mesh"]
    output:
        pfile=temporary(f"results/{paramspace.wildcard_pattern}.preped"),
        mesh= temporary(f"results/simulations/{paramspace.wildcard_pattern}/mesh.msh"),
        preped=[directory(f"results/simulations/{paramspace.wildcard_pattern}/processor{pid}/constant") for pid in range(config["processors"])]
    params:
        casedirs = f"results/simulations/{paramspace.wildcard_pattern}",
        depdir= get_dependency_case
    log: f"logs/{paramspace.wildcard_pattern}/prep.log"
    threads: 1
    container:
        "docker://openfoamplus/of_v2006_centos73"
    shell:
        """
        (         
        touch {output.pfile}
        set +euo pipefail;. /opt/OpenFOAM/setImage_v2006.sh ;set -euo pipefail;
        cp {input.mesh} {params.casedirs}/mesh.msh
        cd {params.casedirs}
        fluent3DMeshToFoam mesh.msh
        createPatch -overwrite
        mapFields ../{params.depdir} -consistent -sourceTime 'latestTime' -parallelSource
        topoSet
        decomposePar -force
        ) 2>&1 > {log}
        """

