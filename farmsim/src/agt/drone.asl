!start.

+!start : true <-
    .print("Drone started.");
    .my_name(MyName);
    ?pos(MyName, X, Y);
    functions.SolveGreedyTSP([[10,10], [20,20]], [X, Y], PlannedRoute, PlannedCost);
    .print("Route: ", PlannedRoute, ", Cost: ", PlannedCost).


+!go_to(X, Y) : true <-
    .my_name(Name);
    if(not(pos(Name, X, Y))) {
        move_towards(X, Y);
        !go_to(X,Y);
    } else {
      .print("Arrived at: (", X, ",", Y, ")");
      survey(X, Y);  
    }.
