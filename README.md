# What is this project?

Our idea: Develop an ecological model that uses biosignal data to
reproduce possible scenarios in ancient earth. Use simulations of the
model to test / experiment / validate hypothesis about the ecological
conditions of ancient earth.

This project is a collaboration between Claus Aranha, Clayton McGill,
and Romain Chassagne. 

The project comes from Claus' interest in simulation, Romain's
interest in data assimilation, and Clayton's interest in biosignals.

Our dream is to use simulations to visualize and understand our
Earth's past. Alien worlds from our history that don't exist anymore.

Also put procedural generation for good use.

# What is this repository

This repository contains the simulated model, as well as text
documents with ideas and logs of the project, references, etc.

It is still in alpha stage. I hope it gets better in the future. This
could be a very cool project.

# Simulator

The simulation currently uses the GAMA Platform. After cloning this
project, you should be able to `import` it directly into GAMA as a
user project.

At the moment, the model is not very different from the
`predator-prey` model, but that shall soon change.

# TODO (move to github issues)
- [ ] Predators / Prey should migrate from the borders if either goes extinct.
- [ ] Make Irrigation dynamic based on closest water
- [ ] Read data from files 
  - PNG with topology, vegetation coverage
  - CSV with cell characteristics, overall characteristics
- [ ] Make a heatmap of predator/prey paths (maybe a moving average animation)

# Weird stuff
- [ ] Understand whether the grid size is 50x50 or 100x100.
- [ ] Learn more GAMA and make the code more GAMA-ey and prettier.

# References (move to another file)

Original Inspiration for the project: Paper about using a simulation
model to make/validate hypothesis about the behavior of pre-historic
hominids:
- "HOMINIDS: An agent-based spatial simulation model to evaluate
behavioral patterns of early Pleistocene hominids"
https://doi.org/10.1016/j.ecolmodel.2009.11.009

## TO READ: Other two probably related papers:
- ["Extreme Environments Perpetuate
  Cooperation"](https://pubs.cs.uct.ac.za/id/eprint/1540/1/2022-Extreme%20Environments%20Perpetuate%20Cooperation.pdf),
  Brandon Gower-WInter and Geoff Nitschke, SSCI 2022.

- ["Simulating the Evolution of Ancient Fortified Cities"](https://doi.org/10.1111/cgf.13897), Almert Mas, Ignacio Martin, Gustavo Patow

## TO ADD: Papers from Clayton with likely data.
