from ntrfc.filehandling.mesh import load_mesh
from ntrfc.turbo.cascade_case.utils.domain_utils import Blade2D
from ntrfc.math.vectorcalc import vecAbs
from ntrfc.meshquality.nondimensionals import calc_dimensionless_gridspacing
import argparse
import matplotlib.pyplot as plt
import ntrfc
import numpy as np
import pyvista as pv


parser = argparse.ArgumentParser(description="Process delta values with arguments")


parser.add_argument("--wall_solution", required=True, help="Path to wall solution file")
parser.add_argument("--fluid_solution", required=True, help="Path to fluid solution file")
parser.add_argument("--velocity_arrayname", required=True, help="Name of the velocity array")
parser.add_argument("--density_arrayname", required=True, help="Name of the density array")
parser.add_argument("--reference_viscosity", required=True, help="reference viscosity")
parser.add_argument("--output", required=True, help="output mesh result")

args = parser.parse_args()


solution = load_mesh(args.fluid_solution)
blade_solution = load_mesh(args.wall_solution)
blade_solution_slice = blade_solution.slice(normal="z")

blade = Blade2D(blade_solution_slice)
blade.compute_all_frompoints()

velocity_arrayname =args.velocity_arrayname
density_arrayname = args.density_arrayname
mu_ref = float(args.reference_viscosity)
output = args.output

dimless_gridspacings = calc_dimensionless_gridspacing(solution, [blade_solution], velocity_arrayname, density_arrayname, mu_ref)

##########################################################

delta_cells_one = dimless_gridspacings.slice(normal="z")
delta_cc_one = delta_cells_one.cell_centers()

sortedPoly_one = blade.sortedpointsrolled_pv
psPoly_one = blade.ps_pv
ssPoly_one = blade.ss_pv
ind_vk_one = blade.ile
ind_hk_one = blade.ite
midsPoly_one = blade.skeletonline_pv
beta_leading_one = blade.beta_le
beta_trailing_one = blade.beta_te
camber_angle_one = blade.camber_phi



psPoly_one.clear_data()
ssPoly_one.clear_data()

# find and define delta values on ps and ss
ps_delta_one = psPoly_one.interpolate(delta_cc_one,radius=0.001)
ss_delta_one = ssPoly_one.interpolate(delta_cc_one,radius=0.001)


chotwordlength_one = vecAbs(ps_delta_one.points[0] - ps_delta_one.points[-1])
x0_one = np.min(ps_delta_one.points[:,0])
x1_one = np.max(ps_delta_one.points[:,0])

ps_rc_one = (ps_delta_one.points[::, 0] - x0_one) / (x1_one - x0_one)
ss_rc_one = (ss_delta_one.points[::, 0] - x0_one) / (x1_one - x0_one)
# Create a figure and a 1x3 grid of subplots


##########################################################


##########################################################
fig, axes = plt.subplots(3, 1, figsize=(15, 10))


# Plot histograms in the subplots
constrained_y_ticks_1 = [25,50]
axes[0].set_yticks(constrained_y_ticks_1)
axes[0].grid(axis="y")
axes[0].scatter(ss_rc_one * -1, ss_delta_one["DeltaXPlus"], color='b', label='ps')
axes[0].scatter(ps_rc_one, ps_delta_one["DeltaXPlus"], color='c', linestyle='dashed', label='ss')
axes[0].set_title('DeltaXPlus')
axes[0].set_xlabel(r'$x/c_{ax}$')
axes[0].set_ylabel(r'$\Delta \xi^{+}$', rotation=0,size=15, labelpad=20)
# axes[0].set_ylim(0,60)
axes[0].legend()

constrained_y_ticks_2 = [1,2,3,4]
axes[1].set_yticks(constrained_y_ticks_2)
axes[1].grid(axis="y")
axes[1].scatter(ss_rc_one * -1, ss_delta_one["DeltaYPlus"], color='b', label='ps')
axes[1].scatter(ps_rc_one, ps_delta_one["DeltaYPlus"], color='c', linestyle='dashed', label='ss')
axes[1].set_title('DeltaYPlus')
axes[1].set_xlabel(r'$x/c_{ax}$')
axes[1].set_ylabel(r'$\Delta \eta^{+}$', rotation=0,size=15, labelpad=20)
# axes[1].set_ylim(0,4)

constrained_y_ticks_3 = [25,50]
axes[2].set_yticks(constrained_y_ticks_3)
axes[2].grid(axis="y")
axes[2].scatter(ss_rc_one * -1, ss_delta_one["DeltaZPlus"], color='b', label='ps')
axes[2].scatter(ps_rc_one, ps_delta_one["DeltaZPlus"], color='c', linestyle='dashed', label='ss')
axes[2].set_title('DeltaZPlus')
# axes[2].set_xlabel(r'$x/c_{ax}$')
# axes[2].set_ylim(0,60)
axes[2].set_ylabel(r'$\Delta \zeta^{+}$', rotation=0,size=15, labelpad=20)
fig.text(0.05,0.01,f"ntrfc.meshquality.nondimensionals@{ntrfc.__version__}", fontsize=16,color="grey",alpha=0.5)


plt.tight_layout()

# Show the plot
plt.savefig(output)
plt.close()