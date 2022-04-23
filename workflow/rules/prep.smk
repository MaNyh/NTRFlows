

def get_meshdirs():
    return [f"{casedir}/constant/polyMesh" for casedir in get_casedirs()]

rule prep:
    input:
        casefiles=[f"results/simulations/{paramspace.wildcard_pattern}/{file}" for file in template.files]
    output:
        mesh = temporary(f"results/simulations/{paramspace.wildcard_pattern}/fluent.msh"),
        polymeshdirs = directory(f"results/simulations/{paramspace.wildcard_pattern}/constant/polyMesh"),
    params:
        casedirs = get_casedirs(),
        mesh=f"resources/fluent.msh"
    shell:
        """
        set +u
        
        module load GCC/4.9.3-2.25
        module load OpenMPI/1.10.2
        module load OpenFOAM/v1612+
        source $FOAM_BASH
        
        cp {params.mesh} {params.casedirs[0]}/.
        cd {params.casedirs[0]}

        fluent3DMeshToFoam fluent.msh
        #createPatch -overwrite
        #topoSet
        #decposePar
        """