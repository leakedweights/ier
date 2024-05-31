!start.

+!start : true <- 
    !waterPlants.
 
+plant_status(X,Y,Health).

+dryPlants(X,Y).

+!waterPlants : true <- 
    for(.member(get_info_from_drone(X,Y,Health), [X,Y,Health])){
        if(Health< 40){
            +dryPlants(X,Y);
        }
    }
    .findall([X, Y], dryPlants(X, Y), PlantsHealthBelow40);
    
    .print(dryPlants);
    .my_name(Name);
    ?pos(Name, PosX, PosY);

    // If there are plants below 40 health, prioratize them
    if(not(PlantsHealthBelow40 == [])){ 
        
        // If not empty, call SolveGreedyTSP with filtered plants
        functions.SolveGreedyTSP(PlantsHealthBelow40, [PosX, PosY], PlannedRouteBelow40, PlannedCost);
        !traverse_route(PlannedRouteBelow40);
        
        

        .findall([Xx, Yx], get_info_from_drone(Xx,Yx,_), X);
        
        .findall([Xy, Yy], get_info_from_drone(Xy,Yy,_), Y);
        
        .print(X);
        -get_info_from_drone(X,Y,_);
    }     
    // Now water plants above 40 health
    .findall([X, Y], get_info_from_drone(X,Y,_), Plants);
    .print(Plants);
    if(not(Plants==[])){
        functions.SolveGreedyTSP(Plants, [PosX, PosY], PlannedRoute, PlannedCost);
        .print("Route: ", PlannedRoute, ", Cost: ", PlannedCost);
        !traverse_route(PlannedRoute);
        -get_info_from_drone(PlannedRoute[0], PlannedRoute[1],_);
    }.
    
+!traverse_route([]) <-
    .print("Completed the entire route.");
    .my_name(Name);
    ?pos(Name, X, Y);
    water(X,Y).
    

+!traverse_route([[X,Y]|Tail]) <-
    .print("Going to next node: (", X, ", ", Y, ")");
    .print("Tail: ", Tail);
    !go_to(X,Y);
    .print("Reached node: (", X, ", ", Y, ")");
    !traverse_route(Tail).

+!go_to(X, Y) : true <-
    .my_name(Name);
    if(not(pos(Name, X, Y))) {
        .print("IRRIGATION: X: ", X , "Y: ",Y);
        move_towards(X, Y);
        !go_to(X,Y);
    } else {
      .print("Arrived at: (", X, ",", Y, ")"); 
    }.