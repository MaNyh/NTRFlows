import argparse
import matplotlib.pyplot as plt
import pyvista as pv
import numpy as np


pv.start_xvfb()

parser = argparse.ArgumentParser(description='Snakemake arguments for ntr')
parser.add_argument('--ux', type=str)
parser.add_argument('--uy', type=str)
parser.add_argument('--uz', type=str)
parser.add_argument('--time', type=str)
parser.add_argument('--output', type=str)
args = parser.parse_args()

ux = args.ux
uy = args.uy
uz = args.uz
time = args.time
output = args.output


ux_array = np.loadtxt(ux)
uyarray = np.loadtxt(uy)
uz_array = np.loadtxt(uz)
time_array = np.loadtxt(time)



plt.ioff()
plt.figure()
plt.plot(time_array, ux_array, label="ux")
plt.plot(time_array, uyarray, label="uy")
plt.plot(time_array, uz_array, label="uz")
plt.yscale("log")
plt.grid()
plt.legend()
plt.savefig(output, bbox_inches='tight')
plt.close()