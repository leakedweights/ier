!start.

+!start : true <-
    .print("Drone started.");
    .my_name(MyName);
    ?pos(MyName, X, Y);
    functions.SolveGreedyTSP([[10,10], [20,20], [20, 0], [0, 0], [15, 15]], [X, Y], PlannedRoute, PlannedCost);
    .print("Route: ", PlannedRoute, ", Cost: ", PlannedCost);
    !traverse_route(PlannedRoute).

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
      survey(X, Y);  
    }.
