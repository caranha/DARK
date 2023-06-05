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
	// Parameters
		
	// Behavior parameters
	float thirst_per_step <- 1.0 / 48; //(full thirst after a day)
	// FIXME: The parameter should be "time to full thirst" and expressed in day unit
		
	// World parameters
	int worldsize <- 50;		
	int number_of_nest <- 2;
	int hominids_per_nest <- 10; 
	int watersources_per_nest <- 3;
	int watersource_distance <- 20;

	// daycycle related helper parameters
	float step <- 30 #minute;
	
	
	int start_time <- 6 * 60 * 60; // simulation starts at 6:00 AM
	int day_start <- 5 * 60 * 60; // day starts at 5:00 AM
	int day_end <- 19 * 60 * 60; // day ends at 19:00 (7:00 PM)
	
	// helper
	list<terrain_cell> water_sources;
	
	init {
		create nest number: number_of_nest;
	
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

species nest {
	float draw_size <- 1.0;
	rgb draw_color <- #green;
	
	init {
		location <- one_of(terrain_cell).location;
		create hominid number: world.hominids_per_nest with: (mynest: self);
		
		loop times: world.watersources_per_nest {
			terrain_cell water_loc <- one_of(terrain_cell(self.location) neighbors_at world.watersource_distance);
			ask water_loc { do make_source; }		
		}
	}
	
	aspect base {
		draw square(draw_size) color: draw_color;
	}
	
}

species hominid {
	float draw_size <- 0.6;
	float thirst <- 0.0;
	rgb draw_color <- #black;
	nest mynest;
	
	// hominid brain;
	int intent <- 0; // 0- anything, 1- drink water
	terrain_cell goal;
	list<terrain_cell> known_water;
	
	// Function called when hominids are created
	init {
		location <- mynest.location;		
	}
	
	reflex act {
		thirst <- thirst + world.thirst_per_step;
		if (thirst > rnd(0.5)+0.5) {
			intent <- 1; // want to drink water
			draw_color <- #red;
		}
		
		if (world.is_day()) {
			if (intent = 1) {
				do go_drink;	
			} else {
				do wander;				
			}

		} else {
			do goto_nest;
			
		}
	}

	action go_drink {
		if (terrain_cell(self.location).water_source) {
			thirst <- 0.0;
			intent <- 0;
			goal <- nil;
			draw_color <- #black;
			return;
		} 
		
		if (length(known_water) = 0) {
			do wander;
			return;
		}
		
		if (goal = nil) {
			goal <- one_of(known_water);
		}
		
		location <- one_of(closest_to(terrain_cell(self.location).neighbors, goal.location)).location;
	}

	action wander {
		// walk randomly
		terrain_cell _goal <- one_of(terrain_cell(self.location).neighbors);
		if (_goal.water_source and not(known_water contains _goal)) {
			add _goal to: known_water;			
		}
		location <- _goal.location;	
	}
	
	action goto_nest {
		// go back to nest
		if (location != mynest.location) {
				location <- one_of(closest_to(terrain_cell(self.location).neighbors,self.mynest.location)).location;				
			} 
	}
	
	
	aspect base {
    	draw square(draw_size) color: draw_color ;
    }
}

grid terrain_cell width: worldsize height: worldsize neighbors: 4 {

	bool water_source <- false;	
	list<hominid> hominids_inside -> {hominid inside self};
	
	// Function called when the terrain is created
	init {

	}
	
	action make_source {
		water_source <- true;
		add self to: world.water_sources;
		color <- #blue;
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