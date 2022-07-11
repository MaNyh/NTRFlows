def get_casefiles():
    """
    this method probably (!) can't be used with create_case.smk, as there the wildcards have to be defined from the
    template-files
    :return:
    """
    files = [f"results/simulations/{instance_pattern}/{file}" for instance_pattern in paramspace.instance_patterns for file
      in template.files]
    return files

def get_defined_sim():
    res = [directory(f"results/simulations/{instance_pattern}/{proc}/constant" for instance_pattern in paramspace.instance_patterns for proc in [f"processor{id}"  for id in range(config["processors"])])]
    return res


def get_results():
    """
    get list of results dependend on case_params.tsv and the workflowsettings.yaml
    this list will be used to determine wildcards. wildcards are passed down the rules
    """
    res = [f"results/simulations/{instance_pattern}/{proc}/{config['endtime']}/p"
                                            for instance_pattern in paramspace.instance_patterns
                                            for proc in [f"processor{id}"  for id in range(config["processors"])]]
    return res

def get_post():
    res = [f"results/simulations/{instance_pattern}/bladeloading.jpg"
                                            for instance_pattern in paramspace.instance_patterns]
    return res