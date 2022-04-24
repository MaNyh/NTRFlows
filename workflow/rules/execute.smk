rule execute:
    input:
        polymeshdir = directory(f"results/simulations/{paramspace.wildcard_pattern}/constant/polyMesh")
    output:
        resultfiles = "haha.txt"
    shell:
        """
        echo haha
        """