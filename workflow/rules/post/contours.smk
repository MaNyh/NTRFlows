rule contours:
    input: f"results/simulations/{paramspace.wildcard_pattern}/vtk/internal.vtu"
    output: report(f"results/simulations/{paramspace.wildcard_pattern}/velocity_contour.jpg",category="contours")
    log: f"logs/{paramspace.wildcard_pattern}/contours.log"
    container: "library://nyhuma/ntrflows/ntr.sif:v0.1.0"
    threads: 1
    shell:
        """
        python workflow/scripts/ntr_contours.py --input {input} --output {output} > {log}
        """

