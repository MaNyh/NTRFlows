# Snakemake workflow: `NTRFlows`

[![Snakemake](https://img.shields.io/badge/snakemake-≥6.3.0-brightgreen.svg)](https://snakemake.github.io)
[![GitHub actions status](https://github.com/MaNyh/NTRFlows/workflows/Tests/badge.svg?branch=main)](https://github.com/MaNyh/NTRFlows/actions?query=branch%3Amain+workflow%3ATests)

NumericalTestRigFlows (NTRFlows)

A Snakemake workflow for `parameterstudies in cfd-simulations`

## Deployment and Usage

1) create a conda environment (Miniconda3) ("conda create -n ntrflows python=3.10")
2) activate the environmnent ("conda activate ntrflows")
3) install mamba using "conda install -c conda-forge mamba"
4) install snakemake and snakedeploy using mamba "mamba create -c bioconda -c conda-forge --name snakemake snakemake snakedeploy"
5) deploy workflow "cd path/to/project-workdir && snakedeploy deploy-workflow https://github.com/MaNyh/NTRFlows . --tag null"
6) tbd: provide resources in "resources/"
7) tbd: configure workflow using any unix-editor "nano config/config.yaml"
8) run workflow using "snakemake -c1"
9) view results in "results/"

## Documentation

The usage of this workflow is described in the [Snakemake Workflow Catalog](https://snakemake.github.io/snakemake-workflow-catalog/?usage=MaNyh%2FNTRFlows).

If you use this workflow in a paper, don't forget to give credits to the authors by citing the URL of this (original) NTRFlowssitory and its DOI (see above).
