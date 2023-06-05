/**
* Name: PreyTutorial
* Following The Prey tutorial 
* Author: caranha
* Tags: 
*/

// Changes:
// - Prey prefers to move to cells with a lot of plants
// - Lakes are generated
// - Plant growth depends on lake proximity

// Things to do:
// - Reintroduce Predators near edge if extinct every 100 cycles
// - Make move speed a parameter (calculate cell neighbors inside agent move)
// - More intelligent behaviors 
// - Cave
// - Initialization from Image (step 12 forward)
// - Understand the optimization part better




model PreyTutorial

/* Insert your model definition here */

global {
	
	// Prey
    int nb_preys_init <- 200;
    int nb_preys_migrate <- 20;
    float prey_max_energy <- 1.0;
	float prey_max_transfer <- 0.1;
	float prey_energy_consum <- 0.05;    
	
	// Predators
    int nb_predators_init <- 20;
    int nb_predators_migrate <- 5;
    float predator_max_energy <- 1.0;
    float predator_max_transfer <- 0.5;
    float predator_energy_consum <- 0.02;
    
    // Irrigation
    int irrigation_range <- 4;
    float irrigation_amount <- 0.005;

	// Breeding    
    float prey_proba_reproduce <- 0.01;
    int prey_nb_max_offsprings <- 5; 
    float prey_energy_reproduce <- 0.5; 
    float predator_proba_reproduce <- 0.01;
    int predator_nb_max_offsprings <- 3;
    float predator_energy_reproduce <- 0.5;

	// Things to do for entry points:    
    // - Figure out how to do multiple entry points. This line only adds the last point
    // - Add entry points for prey too
    // - Make entry point a polygon
    geometry predator_entrypoint <- {10, 10} + {90, 90};

    int nb_preys -> {length (prey)}; 							// This defines a monitor variable
    int nb_predators -> {length (predator)}; 
    
    init {
    	// RNG Seed:
    	//seed<-42.0;
    	
    	write "Initialize Simulation";
    	
    	
    	create prey number: nb_preys_init ;
    	create predator number: nb_predators_init ;
    	    	    	
//    	Change: Initialize water cells
//		loop lakes from: 1 to: 3 {
//			vegetation_cell water_origin <- one_of(vegetation_cell);
//			water_origin.water_level <- 1.1;
//			
//			list lake_cells <- water_origin neighbors_at 5;
//			loop _cell over:lake_cells {
//				write _cell distance_to water_origin;
//				_cell.water_level <- 1.1 - (_cell distance_to water_origin)/10;	
//			}			
//		}

		loop x from:1 to: 100 {
			loop y from:1 to: 100 {
				vegetation_cell _cell <- vegetation_cell closest_to({x,y});
				int rx <- 40 + int(y/10);
				
				_cell.water_level <- 1.1 - abs(rx - x)/10;
			}
		}
    	    	
	}
	
	reflex repopulate {
		if (nb_predators = 0) {
			write "Predator Migration";
			
			vegetation_cell _migration_point <- vegetation_cell closest_to(one_of(predator_entrypoint));
			list migration_cells <- _migration_point neighbors_at 5;
			
	    	loop i from:1 to:nb_predators_migrate {
	    	create predator number: 1 {
            		my_cell <- one_of(migration_cells);
            		location <- my_cell.location ;
        		}	    		
	    	}
	    	
	    	//create predator number: nb_predators_migrate;
	    	
	    	
	    	

		}
		if (nb_preys = 0) {
			create prey number: nb_preys_migrate;
			write "Prey Migration";
		} 
	}

}

species generic_species {
    float size <- 1.0;
    rgb color;

    float max_energy;
    float max_transfer;
    float energy_consum;
    
    float proba_reproduce ;
    int nb_max_offsprings;
    float energy_reproduce;

    vegetation_cell my_cell <- one_of (vegetation_cell) ;
    
    float energy <- rnd(max_energy) update: energy - energy_consum max: max_energy ;
    
    init {
	    location <- my_cell.location;

    }
                
    reflex eat {
    energy <- energy + energy_from_eat();
    }

    reflex die when: energy <= 0 {
    do die;
    }

    float energy_from_eat {
    return 0.0;
    } 
    
    reflex move {
    	vegetation_cell _target <- choose_cell();
    	my_cell <- (_target = nil) ? my_cell : _target;
    	location <- my_cell.location; 
    } 
    
    vegetation_cell choose_cell {
    	return nil;
    }
    
    reflex reproduce when: (energy >= energy_reproduce) and (flip(proba_reproduce)) {
        int nb_offsprings <- rnd(1, nb_max_offsprings);
        create species(self) number: nb_offsprings {
            my_cell <- myself.my_cell ;
            location <- my_cell.location ;
            energy <- myself.energy / nb_offsprings ;
        }
        energy <- energy / nb_offsprings ;
    }
    
    aspect base {
    draw square(size) color: color ;
    }
}

species predator parent: generic_species {
	
   	init {
   		color <- #red;
   		max_energy <- predator_max_energy;
   		max_transfer <- predator_max_transfer;
   		energy_consum <- predator_energy_consum;
	    energy <- rnd(max_energy);
	    
   	    proba_reproduce <- predator_proba_reproduce ;
      	nb_max_offsprings <- predator_nb_max_offsprings ;
      	energy_reproduce <- predator_energy_reproduce ;
   	}

    vegetation_cell choose_cell {
    	
        vegetation_cell _cell_with_prey <- shuffle(my_cell neighbors_at 3) first_with (!(empty (prey inside (each))));
	    
	    if _cell_with_prey != nil {
    	    return _cell_with_prey;
    	} else {
        	return one_of (my_cell.neighbors2 where (each.iswater() = false));
    	} 
    }

   			
	vegetation_cell choose_cell { 
				
		vegetation_cell _nonwater_cell <- shuffle(my_cell neighbors_at 3) first_with (each.iswater() = false);
        return _nonwater_cell; 
        
    }
    
    float energy_from_eat {
    	float energy_transfer <- 0.0;

	    list<prey> reachable_preys <- prey inside (my_cell);    

    	if(! empty(reachable_preys)) {
    		prey _prey <- one_of(reachable_preys);    		
    		energy_transfer <- min(predator_max_transfer, _prey.energy);
    		ask _prey { do die; }

	    }

	    return energy_transfer;
    }
    		
}

species prey parent: generic_species {
   	
   	init {
   		color <- #black;
   		max_energy <- prey_max_energy;
   		max_transfer <- prey_max_transfer;
   		energy_consum <- prey_energy_consum;
	    energy <- rnd(max_energy);
	    
 	    proba_reproduce <- prey_proba_reproduce ;
      	nb_max_offsprings <- prey_nb_max_offsprings ;
      	energy_reproduce <- prey_energy_reproduce ;
   	}

	   			
	vegetation_cell choose_cell { 
		
		list _nonwater <- my_cell.neighbors2 where (each.iswater() = false);
		vegetation_cell _target <- shuffle(_nonwater) first_with (each.food > 0.4);		// Selecting any place with enough food
		// vegetation_cell _target <- _nonwater with_max_of (each.food); 				// Selecting place with most food
		
		_target <- (_target = nil) ? one_of(_nonwater) : _target;
		               
       	return _target;
    }
    
    float energy_from_eat { 
        float energy_transfer <- min([max_transfer, my_cell.food]) ;
        my_cell.food <- my_cell.food - energy_transfer ;
        return energy_transfer;
    }
    
} 

grid vegetation_cell width: 50 height: 50 neighbors: 4 {
	float max_food <- 1.0;
	float food_prod <- rnd(0.01) - 0.005;
	float food <- rnd(0.5) max: max_food;
	
	float water_level <- -0.1;

	float get_season {
		return (1+sin(cycle))/2;
	} 
	
	bool iswater {
		if (water_level > get_season()) {
			return true;			
		} else {
			return false;
		}
	}
		
	rgb get_color {
		if (iswater() = true) {
			return rgb(0,0,255);
		} else {
			float red <- 255 * (1 - food);
			float green <- 255.0;
			float blue <- 255 * (1 - food); 
			
			return rgb(red, green, blue);
		}
	}
	
	
	reflex update {
		color <- get_color();	
		food <- (iswater() = true) ? 0 : max(food + food_prod, 0); 
	}
		
	list<vegetation_cell> neighbors2 <- self neighbors_at 2;
}

experiment prey_predator type: gui {
	parameter "Irrigation Range: " var: irrigation_range min: 1 max: 10 category: "Irrigation" ;
	parameter "Irrigation Amount: " var: irrigation_amount category: "Irrigation" ;
	
	parameter "Initial number of preys: " var: nb_preys_init min: 1 max: 1000 category: "Prey" ;
	parameter "Prey max energy: " var: prey_max_energy category: "Prey" ;
	parameter "Prey max transfer: " var: prey_max_transfer  category: "Prey" ;
	parameter "Prey energy consumption: " var: prey_energy_consum  category: "Prey" ;
	
	parameter "Initial number of predators: " var: nb_predators_init min: 0 max: 200 category: "Predator" ;
	parameter "Predator max energy: " var: predator_max_energy category: "Predator" ;
	parameter "Predator max transfer: " var: predator_max_transfer  category: "Predator" ;
	parameter "Predator energy consumption: " var: predator_energy_consum  category: "Predator" ;
	
	parameter "Prey probability reproduce: " var: prey_proba_reproduce category: "Prey" ;
	parameter "Prey nb max offsprings: " var: prey_nb_max_offsprings category: "Prey" ;
	parameter "Prey energy reproduce: " var: prey_energy_reproduce category: "Prey" ;
	parameter "Predator probability reproduce: " var: predator_proba_reproduce category: "Predator" ;
	parameter "Predator nb max offsprings: " var: predator_nb_max_offsprings category: "Predator" ;
	parameter "Predator energy reproduce: " var: predator_energy_reproduce category: "Predator" ;

	output {
    	display main_display {
    		grid vegetation_cell border: #black;
    	    species prey aspect: base ;	
    	    species predator aspect: base ;	
    	}
    	
    	display Population_information refresh:every(5#cycles) {
	    chart "Species evolution" type: series size: {1,0.5} position: {0, 0} {
		    data "number_of_preys" value: nb_preys color: #blue ;
		    data "number_of_predator" value: nb_predators color: #red ;
		    }
	    chart "Prey Energy Distribution" type: histogram background: #lightgray size: {0.5,0.5} position: {0, 0.5} {
		    data "]0;0.25]" value: prey count (each.energy <= 0.25) color:#blue;
		    data "]0.25;0.5]" value: prey count ((each.energy > 0.25) and (each.energy <= 0.5)) color:#blue;
		    data "]0.5;0.75]" value: prey count ((each.energy > 0.5) and (each.energy <= 0.75)) color:#blue;
		    data "]0.75;1]" value: prey count (each.energy > 0.75) color:#blue;
	    	}
	    chart "Predator Energy Distribution" type: histogram background: #lightgray size: {0.5,0.5} position: {0.5, 0.5} {
		    data "]0;0.25]" value: predator count (each.energy <= 0.25) color: #red ;
		    data "]0.25;0.5]" value: predator count ((each.energy > 0.25) and (each.energy <= 0.5)) color: #red ;
		    data "]0.5;0.75]" value: predator count ((each.energy > 0.5) and (each.energy <= 0.75)) color: #red ;
		    data "]0.75;1]" value: predator count (each.energy > 0.75) color: #red;
	    	}
		}
    	
    	monitor "number of preys" value: nb_preys;
		monitor "number of predators" value: nb_predators;	
	}
}