checkpoint prep_dependencies:
    input: rules.create_case.output.casefiles,
    output: directory(f"results/simulations/{paramspace.wildcard_pattern}/dependency")
    shell:
        """
        mkdir {output}
        if (({wildcards.dependency} == -1))
            then
                touch {output}/independent
            else
                touch {output}/dependent
        fi
        """


def check_dependency(wildcards):
    ck_output = checkpoints.prep_dependencies.get(**wildcards).output
    DEP, = glob_wildcards(os.path.join(ck_output,"{dependency}}"))
    print(DEP)
    return expand(os.path.join(ck_output,{DEPENDENCY}), DEPENDENCY=DEP)

rule prep_independent:
    input:
        casefiles=rules.create_case.output.casefiles,
        mesh=config["mesh"],
        independency=check_dependency
    output:
        mesh = temporary(f"results/simulations/{paramspace.wildcard_pattern}/mesh.msh"),
        preped = [directory(f"results/simulations/{paramspace.wildcard_pattern}/processor{pid}/constant") for pid in range(config["processors"])]
    params:
        casedirs = f"results/simulations/{paramspace.wildcard_pattern}",
    log: f"logs/{paramspace.wildcard_pattern}/prep.log"
    threads: 1
    container:
        "docker://openfoamplus/of_v2006_centos73"
    shell:
        """
        (         
        set +euo pipefail;. /opt/OpenFOAM/setImage_v2006.sh ;set -euo pipefail;
        cp {input.mesh} {params.casedirs}/mesh.msh
        cd {params.casedirs}
        fluent3DMeshToFoam mesh.msh
        createPatch -overwrite
        topoSet
        decomposePar -force
        )>> {log}
        """

