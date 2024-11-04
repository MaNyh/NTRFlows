rule contours:
    input:  f"results/simulations/{paramspace.wildcard_pattern}/vtk/" ,
    output:
       report(f"results/simulations/{paramspace.wildcard_pattern}/contours.jpg",category="contours"),
    log: f"logs/{paramspace.wildcard_pattern}/contours.log"
    container: "library://nyhuma/ntrflows/ntr.sif:0.2.2"
    threads: 1
    shell:
        """
        python workflow/scripts/ntr_contours.py --input {input}/internal.vtu --output {output} > {log}
        """

