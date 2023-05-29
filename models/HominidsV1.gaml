/**
* Name: HominidsV1
* Hominid Model Based on "Clay's Stories" -- version 1 
* Author: caranha
* Tags: 
*/

/**
 * Outline:
 * This models implements ancient hominids living their day to day life in the savanna, 
 * following ideas/data from FIRE paper and other archeological evidence.
 * 
 * Goals:
 * - Represent daily life of tribes of hominids.
 * - Simulation step of 1 hour (maybe 3 hours?)
 * - Simulation area of ??? km
 * - Simulation scope of ??? agents
 * 
 * Google doc:
 * https://docs.google.com/document/d/1bDrZw0PO8csw-aNTdCsMfwNYzh9Ts-8E/edit
 */


model HominidsV1

global {
	float step <- 30 #minute;

	// daycycle related
	int start_time <- 6 * 60 * 60; // simulation starts at 6:00 AM
	int day_start <- 5 * 60 * 60; // day starts at 5:00 AM
	int day_end <- 19 * 60 * 60; // day ends at 19:00 (7:00 PM)
	
	init {
		create nest number: 5;
		create hominid number: 50;
	
	}
	
	bool is_day {
		int time_of_day <- (int(time) + start_time) mod (24 * 60 * 60);
		
		if (time_of_day > day_start and time_of_day < day_end) {
			return true;
		} else {
			return false;
		}		
	}
}

species hominid {
	float draw_size <- 0.6;
	rgb draw_color <- #black;
	nest mynest;
	
	// Function called when hominids are created
	init {
		mynest <- one_of(nest);
		location <- mynest.location;
		
	}
	
	reflex act {
		if (world.is_day()) {
			// move randomly
			location <- one_of(terrain_cell(self.location).neighbors).location;
		} else {
			// move back to nest
			location <- one_of(closest_to(terrain_cell(self.location).neighbors,self.mynest.location)).location;
		}
	}
	
	aspect base {
    	draw square(draw_size) color: draw_color ;
    }
}

species nest {
	float draw_size <- 1.0;
	rgb draw_color <- #green;
	
	init {
		location <- one_of(terrain_cell).location;
	}
	
	aspect base {
		draw square(draw_size) color: draw_color;
	}
	
}

grid terrain_cell width: 100 height: 100 neighbors: 4 {
	
	list<hominid> hominids_inside -> {hominid inside self};
	
	// Function called when the terrain is created
	init {

	}
	
	
}

experiment SingleRun type: gui {
	float minimum_cycle_duration <- 0.1#second;
	
	
	output {
		display map {
			grid terrain_cell border: #black;
			species nest aspect: base ;
			species hominid aspect: base ;		
		}
	}
	
}