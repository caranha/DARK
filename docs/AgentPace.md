# Agent movement ideas

- Directed pace. The speed of an agent moving with purpose. 
  (hunting, being hunted, going to a place they are familiar with)
  
- Undirected pace. The speed of an agent exploring the environment.
  (scavenging, stalking, exploring, wandering around)
  
## How to define pace:

- Home range: "a circumscribed area in which an individual spends much 
  of its life, and contain the necessary resources (food, shelter, social)" 
  (O'Regan, Wilkinson, Marston 2016; Barnard 1999; Manning, Dawkings 2012)
  
- Home range estimates (radius):
  - 350m; Australopithecus africanus on an ape-like diet; Anton et al. 2002
  - 1200m; Homo herectus on low quality human forager-like; Anton et al. 2002
  - 2500m; 'Average' hominin relevant range estimate; O'Regan, WIlkinson, Marson 2016

- Assumption: Undirected pace is related to the home range. Home range is defined 
  by the area that the hominid explores and gets to know during its life time. 
  Therefore, we define undirected pace as a function of the home range.

- Hypothesis: Undirected pace is calculated as the speed necessary to reach the limit
  of the home range, walking in a more or less constant direction for the duration of 
  an activity day.

- Calculation of undirected pace:
  - Assume largest home range: 2500
  - Assume active day of 12 hours:
  - Undirected pace of 2500 / (12*60) = **3.5 meters / minute**
  - This pace is used by agents wandering around the environment withou a clear objective. 
  - Maybe underestimated

- Calculation of directed pace:
  - Olympic Athlete: 10.5 m/s sprint (100m dash in 9.6 seconds)
  - 1 hour run world record: 5.2~5.9 m/s run (21330m in one hour)
  - Regular healthy human (agent): **4 meters / second**
  - Maybe overestimated
 
## Other pace factors
- Agent age and size (Clutton-Brock & Harvey 1984)
- Agent being wounded
- Agent carrying stuff
- Apply as speed multipliers in the simulation

## Simulation structure: (TODO)
- Agent Directed Speed (m/s)
- Agent Undirected Speed (m/s)
- Gama deals in a reasonable way regarding grids and agents with fractional position
  (grids use CoM collision to assign agents to cells)
- Define a "move" function that updates the position of the agent based on the 
  "goal", "speed" and "time available" of the agent (busy flag if move is not finished)