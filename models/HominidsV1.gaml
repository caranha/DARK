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
	// Constants
	int EXPLORING <- 0;
	int DIRECTED <- 1;
	
	
	
	// Parameters
		
	// Agent parameters
	float exploring_pace <- 3.5 / 60;  // 3.5 m/minute; See AgentPace.md
	float directed_pace <- 4.0;        // 4   m/second; See AgentPace.md 
	float time_to_thirst <- 1 #day; //(full thirst after a day)
	// FIXME: The parameter should be "time to full thirst" and expressed in day unit
		
	// Grid parameters
	int grid_size <- 50;
	float cell_size <- 100 #meter;       // Meters
	
	
	// Environment paramters
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
	
	bool debug <- false;
	reflex day_ping when: debug{
		write (time + start_time);
		write is_day();
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
	
	// hominid attributes
	float directed_speed;
	float exploring_speed;
	
	// hominid brain;
	int intent <- 0; // 0- anything, 1- drink water
	int pace <- EXPLORING;
	terrain_cell goal;
	list<terrain_cell> known_water;
	
	// Function called when hominids are created
	init {
		location <- mynest.location;
		directed_speed <- world.directed_pace * world.step / world.cell_size;
		exploring_speed <- world.exploring_pace * world.step / world.cell_size;
	}
	
	reflex update {
		terrain_cell _here <- terrain_cell(self.location);
		
		// Update Agent status
		thirst <- thirst + world.step;

		// Update Movement
		do move;

		// Update Actions at current location
		if (_here.water_source) { 
			thirst <- 0.0;    // ASSUMPTION: drinking always happen if water is available, and fully satiates thirst
			if not(known_water contains _here) {
				add _here to: known_water;			
			}
		}						
		
		// Update Intents
		if (thirst > world.time_to_thirst) {
			intent <- 1; // want to drink water
		} else {
			intent <- 0;
		}
				
		
		
		if (goal = nil) {
			do choose_action;
		}
	}
	
	action move {
		if (goal = nil) { return; }
		
		float _speed;
		if (pace = EXPLORING) {
			_speed <- exploring_speed;
		} else {
			_speed <- directed_speed;
		}
				
		if (distance_to(location, goal.location) < _speed) {
			location <- goal.location;
			goal <- nil;			
		} else {
			location <- location + (goal.location - location) * (_speed / distance_to(location, goal.location));
		}
	}
	
	action choose_action {		
		// decide the next action FIXME: drinking water at night?
		if (intent = 1 and length(known_water) > 0) {
			goal <- one_of(known_water); // Go drink water if thirsty
		} else if (world.is_day()) {
			goal <- one_of(terrain_cell(self.location).neighbors); // Wander FIXME: Memory
		} else {
			goal <- terrain_cell(mynest.location); // Go to nest at night
		}
	}
	
	aspect base {
		rgb _color <- draw_color;
		if (intent = 1) { _color <- #red; }
		
		draw square(draw_size) color: _color ;
    }
}

grid terrain_cell width: grid_size height: grid_size neighbors: 4 {

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