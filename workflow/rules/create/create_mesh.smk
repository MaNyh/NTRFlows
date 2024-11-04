rule create_mesh:
    input: "resources/geometry/profilepoints.txt"
    output:
        mesh = "results/simulations/mesh.msh",
    params:
        xoutlet = config["mesh"]["xoutlet"],
        xinlet = config["mesh"]["xinlet"],
        pitch = config["mesh"]["pitch"],
        blade_yshift = config["mesh"]["blade_yshift"],
        bl_size = config["mesh"]["bl_size"],
        di = config["mesh"]["di"],
        span = config["mesh"]["span"],
        le_progression = config["mesh"]["le_progression"],
        te_progression = config["mesh"]["te_progression"],
    container: "library://nyhuma/ntrflows/ntr.sif:0.2.2"
    log: "logs/create_mesh.log"
    shell: """
        python workflow/scripts/ntr_createmesh.py --input {input} --output {output.mesh} --xoutlet {params.xoutlet} --xinlet {params.xinlet} --pitch {params.pitch} --blade_yshift {params.blade_yshift} --bl_size {params.bl_size} --di {params.di} --span {params.span} --le_progression {params.le_progression} --te_progression {params.te_progression} 2>&1 >  {log} 
    """