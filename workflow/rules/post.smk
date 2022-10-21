
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
        )  2>&1 > {log}
        """


rule log_residuals:
    input:  f"logs/{paramspace.wildcard_pattern}/execute.log"
    output:
        logfile = temporary(f"results/simulations/{paramspace.wildcard_pattern}/foamexecution.log"),
        ux_residuals =  f"results/simulations/{paramspace.wildcard_pattern}/logs/Ux_0",
        uy_residuals =  f"results/simulations/{paramspace.wildcard_pattern}/logs/Uy_0",
        uz_residuals =  f"results/simulations/{paramspace.wildcard_pattern}/logs/Uz_0",
        time =  f"results/simulations/{paramspace.wildcard_pattern}/logs/Time_0",
    params:
        casedirs = f"results/simulations/{paramspace.wildcard_pattern}",
    container:
        "docker://openfoamplus/of_v2006_centos73"
    log: f"logs/{paramspace.wildcard_pattern}/readlog.log"
    threads: 1
    shell:
        """
        (
        cp {input} {output.logfile}
        set +euo pipefail;. /opt/OpenFOAM/setImage_v2006.sh ;set -euo pipefail; 
        cd {params.casedirs}
        foamLog -n foamexecution.log
        )  2>&1 > {log}
        """

rule plot_residuals:
    input:
        ux_residuals = rules.log_residuals.output.ux_residuals,
        uy_residuals = rules.log_residuals.output.uy_residuals,
        uz_residuals = rules.log_residuals.output.uz_residuals,
        time =  rules.log_residuals.output.time
    output:
        residuals = report(f"results/simulations/{paramspace.wildcard_pattern}/residuals.jpg",category="residual u")
    container: "library://nyhuma/ntrflows/ntr.sif:v0.0.1"

    log: f"logs/{paramspace.wildcard_pattern}/residualplot.log"
    shell:
        """
        python workflow/scripts/ntr_plotresiduals.py --ux {input.ux_residuals} --uy {input.uy_residuals} \
                                                    --uz {input.uz_residuals} --time {input.time} \
                                                   --output {output} > {log}
        """


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

rule contours:
    input: f"results/simulations/{paramspace.wildcard_pattern}/vtk/internal.vtu"
    output: report(f"results/simulations/{paramspace.wildcard_pattern}/velocity_contour.jpg",category="contours")
    log: f"logs/{paramspace.wildcard_pattern}/contours.log"
    container: "library://nyhuma/ntrflows/ntr.sif:v0.0.1"
    threads: 1
    shell:
        """
        python workflow/scripts/ntr_contours.py --input {input} --output {output} > {log}
        """

