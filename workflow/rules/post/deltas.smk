rule deltas:
    input:  f"results/simulations/{paramspace.wildcard_pattern}/vtk/" ,
    output: report(f"results/simulations/{paramspace.wildcard_pattern}/delta_profile.jpg",category="profile")
    log: f"logs/{paramspace.wildcard_pattern}/deltas.log"
    container: "library://nyhuma/ntrflows/ntr.sif:0.2.2"
    params:
        velocity_arrayname = "UMean",
        density_arrayname = "rhoMean",
        reference_viscosity= "0.0000182",
    threads: 1
    shell:
        """
        python workflow/scripts/ntr_deltavalueprofile.py --wall_solution {input}/boundary/blade_wall.vtp --fluid_solution {input}/internal.vtu --velocity_arrayname {params.velocity_arrayname} --density_arrayname {params.density_arrayname} --reference_viscosity {params.reference_viscosity} --output {output} > {log}
        """

