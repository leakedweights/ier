!start.

+!start : true <- 
    +get_info_from_drone(10,10,20);
    +get_info_from_drone(3,1,20);
    +get_info_from_drone(4,2,20);
    +get_info_from_drone(2,2,20);
    +get_info_from_drone(2,3,20);
    +get_info_from_drone(2,4,20);
 
+!get_info_from_drone(X,Y,Health) <- 
    +plant(X,Y,Health).

// Plan to find plants with health below 40 and call the appropriate function
+!waterPlants : true <- 
    // Find all plants with health below 40
    .findall((X, Y, Health), (plant(X, Y, Health) & Health < 40), PlantsHealthBelow40);
    
    // Check if the list is empty
    ( PlantsHealthBelow40 == [] -> 
        // If empty, call SolveGreedyTSP with all plants
        .findall((X, Y, Health), plant(X, Y, Health), Plants);
        functions.SolveGreedyTSP(Plants, PlannedRoute, PlannedCost)
    ;
        // If not empty, call SolveGreedyTSP with filtered plants
        functions.SolveGreedyTSP(PlantsHealthBelow40, PlannedRoute, PlannedCost)
    )
    .print("Route: ", PlannedRoute, ", Cost: ", PlannedCost);
    !traverse_route(PlannedRoute).

+!traverse_route([]) <-
    .print("Completed the entire route.")
    waterPlant(location).

+!traverse_route([[X,Y]|Tail]) <-
    .print("Going to next node: (", X, ", ", Y, ")");
    !go_to(X,Y);
    .print("Reached node: (", X, ", ", Y, ")");
    !traverse_route(Tail).

+!go_to(X, Y) : true <-
    .my_name(Name);
    if(not(pos(Name, X, Y))) {
        move_towards(X, Y);
        !go_to(X,Y);
    } else {
      .print("Arrived at: (", X, ",", Y, ")");
      survey(X, Y);  
    }.