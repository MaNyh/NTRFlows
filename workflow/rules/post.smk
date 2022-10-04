
rule create_vtk:
    input:
        rules.execute.output,
    output:
        vtkdir=directory(f"results/simulations/{paramspace.wildcard_pattern}/vtk/"),
        blade=f"results/simulations/{paramspace.wildcard_pattern}/vtk/BLADE.vtp",
        inlet=f"results/simulations/{paramspace.wildcard_pattern}/vtk/INLET.vtp",
        outlet=f"results/simulations/{paramspace.wildcard_pattern}/vtk/OUTLET.vtp",
        volume=f"results/simulations/{paramspace.wildcard_pattern}/vtk/internal.vtu",
    params:
        casedirs = f"results/simulations/{paramspace.wildcard_pattern}",
        casename = paramspace.wildcard_pattern
    threads: 1
    container:
        "docker://openfoamplus/of_v2006_centos73"
    log: f"logs/{paramspace.wildcard_pattern}/create_vtk.log"
    shell:
        """
        (
        set +euo pipefail;. /opt/OpenFOAM/setImage_v2006.sh ;set -euo pipefail; 
        cd {params.casedirs}
        reconstructPar -latestTime
        foamToVTK -latestTime 
        VTKDIR=$(find VTK/* -maxdepth 0 -type d)
        mv $VTKDIR/boundary/BLADE.vtp vtk/.
        mv $VTKDIR/boundary/INLET.vtp vtk/.
        mv $VTKDIR/boundary/OUTLET.vtp vtk/.
        mv $VTKDIR/internal.vtu vtk/.
        rm -r VTK
        ) 2> {log}
        """



rule bladeloading:
    input: f"results/simulations/{paramspace.wildcard_pattern}/vtk/BLADE.vtp"
    output: f"results/simulations/{paramspace.wildcard_pattern}/bladeloading.jpg"
    log: f"logs/{paramspace.wildcard_pattern}/bladeloading.log"
    container: "library://nyhuma/ntrflows/ntr.sif:latest"
    shell:
        """
        python workflow/scripts/ntr_bladeloading.py --input {input} --output {output} > {log}
        """

rule contours:
    input: f"results/simulations/{paramspace.wildcard_pattern}/vtk/internal.vtu"
    output: f"results/simulations/{paramspace.wildcard_pattern}/velocity_contour.jpg"
    log: f"logs/{paramspace.wildcard_pattern}/contours.log"
    container: "library://nyhuma/ntrflows/ntr.sif:latest"
    shell:
        """
        python workflow/scripts/ntr_contours.py --input {input} --output {output} > {log}
        """