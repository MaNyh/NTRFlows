# Snakemake workflow: `NTRFlows`

[![Snakemake](https://img.shields.io/badge/snakemake-≥6.3.0-brightgreen.svg)](https://snakemake.github.io)
[![GitHub actions status](https://github.com/MaNyh/NTRFlows/workflows/Tests/badge.svg?branch=main)](https://github.com/MaNyh/NTRFlows/actions?query=branch%3Amain+workflow%3ATests)

NumericalTestRigFlows (NTRFlows)

A Snakemake workflow for `parameterstudies in cfd-simulations`

## Deployment and Usage

Be aware, that this repository is still in early development. There are tons of issues left and the workflow will change quite a bit until it is productive.

Currently, the workflow is deployed via git. Simply clone the repo and start the workflow using snakemake.

The only dependencies needed are "snakemake, pandas, singularity/conda and slurm"

BE AWARE!

There are two configuration files where the number of processors have to be defined equally. 

- config/workflowsettings.yaml
- profiles/slurm/config.yaml

This issue is documented in https://github.com/MaNyh/NTRFlows/issues/1 
It is crucial to solve this issue as soon as possible

```console
foo@bar:/path/to/somedirectory$ git clone -b master https://github.com/MaNyh/NTRFlows.git 
foo@bar:/path/to/somedirectory$ cd NTRFlows
foo@bar:/path/to/somedirectory/NTRFlows$ snakemake -j 1 -c16 --use-singularity --profile profiles/slurm
```

There will be another deployment-option that is described in the Snakemake Workflow Catalog (see Documentation below)


## Documentation

The usage of this workflow is described in the [Snakemake Workflow Catalog](https://snakemake.github.io/snakemake-workflow-catalog/?usage=MaNyh%2FNTRFlows).

If you use this workflow in a paper, don't forget to give credits to the authors by citing the URL of this (original) NTRFlowssitory and its DOI (see above).
