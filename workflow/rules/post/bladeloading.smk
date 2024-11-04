rule bladeloading:
    input:   f"results/simulations/{paramspace.wildcard_pattern}/vtk/"
    output: report(f"results/simulations/{paramspace.wildcard_pattern}/bladeloading.jpg",category="bladeloading")
    log: f"logs/{paramspace.wildcard_pattern}/bladeloading.log"
    container: "library://nyhuma/ntrflows/ntr.sif:0.2.2"
    threads: 1
    shell:
        """
        python workflow/scripts/ntr_bladeloading.py --blade {input}/boundary/blade_wall.vtp --inlet {input}/boundary/inlet.vtp  --outlet {input}/boundary/outlet.vtp --output {output} > {log}
        """