import pyvista as pv
import numpy as np
import argparse


from ntrfc.turbo.gmsh.turbo_cascade import generate_turbocascade , MeshConfig
from ntrfc.turbo.cascade_case.utils.domain_utils import CascadeDomain2DParameters, Blade2D
from ntrfc.turbo.cascade_case.domain import CascadeDomain2D


parser = argparse.ArgumentParser(description='Process some integers.')
parser.add_argument('--input', metavar='input', type=str, help='input file path')
parser.add_argument('--output', metavar='output', type=str, help='output file path')

parser.add_argument('--xoutlet', type=float, help='output file path')
parser.add_argument('--xinlet', type=float, help='output file path')
parser.add_argument('--pitch',type=float, help='output file path')
parser.add_argument('--blade_yshift',type=float, help='output file path')
parser.add_argument('--bl_size', type=float, help='output file path')
parser.add_argument('--di', type=float, help='output file path')
parser.add_argument('--span', type=float, help='output file path')
parser.add_argument('--le_progression', type=float, help='output file path')
parser.add_argument('--te_progression', type=float, help='output file path')
args = parser.parse_args()

pv.start_xvfb()  # Start X virtual framebuffer (Xvfb)


points = np.loadtxt(args.input)*0.001
#move points to origin
points -= points[np.argwhere(points[:,0] == np.min(points[:,0]))[0][0]]

pts = pv.PolyData(points)
blade = Blade2D(pts)
blade.compute_all_frompoints()

domainparams = CascadeDomain2DParameters(xinlet = args.xinlet, xoutlet = args.xoutlet, pitch = args.pitch, blade_yshift = args.blade_yshift)


domain2d = CascadeDomain2D()
domain2d.generate_from_cascade_parameters(domainparams,blade)



meshconfig = MeshConfig()

#characteristic length
di = args.di


meshconfig.max_lc = di
meshconfig.min_lc = di/10


meshconfig.bl_growratio = 1.2
meshconfig.bl_thickness =sum([args.bl_size * (1 - meshconfig.bl_growratio**i) / (1 - meshconfig.bl_growratio) for i in range(14)])
meshconfig.bl_size = args.bl_size
meshconfig.wake_length = blade.camber_length*1.3
meshconfig.wake_width = blade.camber_length*.16
meshconfig.wake_lc =di/3
meshconfig.fake_yShiftCylinder = 0
meshconfig.bladeres =  int((blade.ps_pv.length + blade.ss_pv.length) /(meshconfig.bl_size*50))
meshconfig.progression_le_halfss = 1+ args.le_progression
meshconfig.progression_halfss_te = 1- args.te_progression
meshconfig.progression_te_halfps = 1+ args.te_progression
meshconfig.progression_halfps_le = 1- args.le_progression
meshconfig.spansize= args.span
meshconfig.spanres = 1

generate_turbocascade(domain2d,meshconfig, args.output)