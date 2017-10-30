# GraphHomogenization
GraphHomogenization contains two tools for computing the effective diffusivity matrix of a periodic, directed, and weighted graph: homogenization theory and Monte Carlo simulation. In either case, the user must supply
  - the graph's quotient node set,
  - the graph's quotient edge set,
  - the edge weights.

The development of this project is motivated by the application of a random walk on a subset of the integer lattice. Thus, for certain graphs, there are tools in place to aid in setting up the graph's node set, edge set, and edge weights.

## How to Use
### GraphHomogenization/
A set of drivers.

### GraphHomogenization/HomogTools/
A set of functions for computing the effective diffusivity via homogenization theory.
- **buildEffDiff.m** Constructs the effective diffusivity matrix once the stationary distribution and unit-cell solute have been computed.
- **effDiff.m** Wrapper function that calls effDiff_homog and effDiff_mc.
- **effDiff_homog.m** Computes the effective diffusivity from the rate matrix, graph's nodes, graph's edges, edge weights, and edge jumps. Calls LUFull, statDist, unitCell, and buildDeff.
- **effDiff_mc.m** Approximates the effective diffusivity via Monte Carlo simulation.
- **LUFull.m** Computes the full LU factorization (includes permutation matrices and diagonal scaling matrix.
- **statDist.m** Computes the stationary distribution.
- **unitCell.m** Solves the unit-cell problem.

### GraphHomogenization/LatticeTools/
A set of functions for setting up the graph's node set, edge set, and edge weights assuming the graph satisfies certain geometric conditions.
- **homogInputs_lattice.m** Sets up the node set, edge set, and edge weights.
- **rate_lattice.m** Computes the rate of an edge when the rate function is of a certain form.

### GraphHomogenization/MiscTools/
- **checkDetailedBalance.m** Determines whether a graph satisfies the detailed balance condition.
- **saveResults.m** Saves a results object.

### GraphHomogenization/PlottingTools/
A set of functions for drawing various graph poperties and plotting the effective diffusivities.
- **drawCell.m** Draws a periodic cell of the graph.
- **drawCell_lattice.m** Draws a periodic cell of the graph assuming the graph satisfies certain geometric conditions.
- **drawDriftField.m** Draws a vector field based on the drift function.
- **plotObRadVsEffDiff.m** Plots the effective diffusivities computed by homogenization theory and Monte Carlo simulation against obstruction radius.