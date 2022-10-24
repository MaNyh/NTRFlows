rule bladeloading:
    input: f"results/simulations/{paramspace.wildcard_pattern}/vtk/BLADE.vtp"
    output: report(f"results/simulations/{paramspace.wildcard_pattern}/bladeloading.jpg",category="bladeloading")
    log: f"logs/{paramspace.wildcard_pattern}/bladeloading.log"
    container: "library://nyhuma/ntrflows/ntr.sif:v0.0.1"
    threads: 1
    shell:
        """
        python workflow/scripts/ntr_bladeloading.py --input {input} --output {output} > {log}
        """