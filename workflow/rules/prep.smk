rule prep:
    input:
        casefiles=[f"results/simulations/{paramspace.wildcard_pattern}/{file}" for file in template.files],
        mesh=f"resources/fluent.msh"
    output:
        mesh = temporary(f"results/simulations/{paramspace.wildcard_pattern}/mesh.msh"),
        polymeshdir = directory(f"results/simulations/{paramspace.wildcard_pattern}/constant/polyMesh")
    params:
        casedirs = f"results/simulations/{paramspace.wildcard_pattern}"
    shell:
        options["prep"]