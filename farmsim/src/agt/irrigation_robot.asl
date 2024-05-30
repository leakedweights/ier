!start.

+!start : true <- 
    +get_info_from_drone(10,10,20);
    +get_info_from_drone(3,1,20);
    +get_info_from_drone(4,2,20);
    +get_info_from_drone(2,2,20);
    +get_info_from_drone(2,3,20);
    +get_info_from_drone(2,4,20);
    !waterPlants;
    +get_info_from_drone(4,1,20);
    +get_info_from_drone(3,9,20);
    !waterPlants.
 
+get_info_from_drone(X,Y,Health).

// Plan to find plants with health below 40 and call the appropriate function
+!waterPlants : true <- 
    // Find all plants with health below 40
    .findall([X, Y], get_info_from_drone(X, Y, Health) & Health < 40, PlantsHealthBelow40);
    
    .my_name(Name);
    ?pos(Name, PosX, PosY);

    // Check if the list is empty
    if(PlantsHealthBelow40 == []){ 
        // If empty, call SolveGreedyTSP with all plants
      //  .findall([X, Y, Health], plant(X, Y, Health), Plants);
        .findall([X, Y], get_info_from_drone(X,Y,_), Plants);
        functions.SolveGreedyTSP(Plants, [PosX, PosY], PlannedRoute, PlannedCost)
    } else{
        // If not empty, call SolveGreedyTSP with filtered plants
        functions.SolveGreedyTSP(PlantsHealthBelow40, [PosX, PosY], PlannedRoute, PlannedCost)
    }
    .print("Route: ", PlannedRoute, ", Cost: ", PlannedCost);
    !traverse_route(PlannedRoute);

    -get_info_from_drone(PlannedRoute[0], PlannedRoute[1],_).

+!traverse_route([]) <-
    .print("Completed the entire route.").
    

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
      waterPlant(location);  
    }.