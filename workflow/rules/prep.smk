rule prep_envmodules:
    input:
        casefiles=*get_casefiles(),
        mesh="resources/mesh.msh"
    output:
        "results/stuff.txt"
    envmodules:
        "GCC/4.9.3-2.25",
        "OpenMPI/1.10.2",
        "OpenFOAM/v1612+",
    shell:
        """
        fluent3dMeshToFoam {input.mesh}
        createPatch -overwrite
        topoSet
        decposePar
        """