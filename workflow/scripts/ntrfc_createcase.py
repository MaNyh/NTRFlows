import argparse
from ntrfc.database.case_creation import deploy

parser = argparse.ArgumentParser(description='Snakemake arguments for ntrfc')
parser.add_argument('--inputfiles',type=string, nargs='+',
                    help='list of input files')
parser.add_argument('--outputfiles',type=string, nargs='+',
                    help='list of output files')
parser.add_argument('--params',type=dict, nargs='+',
                    help='list of output files')
parser.add_argument('--options',type=dict, nargs='+',
                    help='list of output files')

args = parser.parse_args()
print(args)

input = args.inputfiles
output = args.outputfiles

deploy(input,output,params["simparams"],option_config)