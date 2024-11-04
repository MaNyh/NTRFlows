import argparse
from ntrfc.filehandling.mesh import load_mesh
import pyvista as pv

pv.start_xvfb()

parser = argparse.ArgumentParser(description='Snakemake arguments for ntr')
parser.add_argument('--input', type=str)
parser.add_argument('--output', type=str)
args = parser.parse_args()


res = 2048
fontsize = int(0.05*res)

input = args.input

mesh = load_mesh(input)

# Controlling the text properties
sargs = dict(
    title_font_size=fontsize,
    label_font_size=fontsize,
    shadow=True,
    n_labels=6,
    italic=True,
    fmt="%.1f",
    font_family="arial",
)
pv.set_plot_theme("document")

midspanz = (mesh.bounds[5] - mesh.bounds[4]) / 2
midspanplane = mesh.slice(origin=(0, 0, midspanz), normal=(0, 0, 1))
# Create a single plot with 4 subplots in a 4x1 grid
p = pv.Plotter(shape=(4, 1), off_screen=True, window_size=[res, 4*res])

# Define scalar_bar_args if needed
sargs = dict(title_font_size=40, label_font_size=30)
midspanplane = mesh.slice(origin=(0, 0, midspanz), normal=(0, 0, 1))

# Define the scalar fields you want to visualize
scalar_fields = ["UMean", "TMean", "rhoMean", "pMean"]

# Create the subplots
for i, scalar_field in enumerate(scalar_fields):
    sl = midspanplane.copy()
    sl.clear_data()
    sl[scalar_field] = midspanplane[scalar_field]
    # Add the subplot
    p.subplot(i, 0)
    p.add_mesh(sl, scalars=scalar_field, scalar_bar_args=sargs)
    p.view_xy()



# Show the plot
p.show(screenshot=args.output)

# Close the plot
p.close()


