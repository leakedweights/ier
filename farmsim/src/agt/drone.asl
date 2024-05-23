!start.

+!start : true <-
    .print("Drone started.");
    !traverse_route([[10,10], [5, 5], [20, 25]]).

+!traverse_route([]).
+!traverse_route([[X,Y]|Tail]) <-
    !go_to(X,Y);
    !traverse_route(Tail).

+!go_to(X, Y) : true <-
    if(not(pos(Name, X, Y))) {
        move_towards(X, Y);
        !go_to(X,Y);
    } else {
        .print("Arrived at (", X, ",", Y, ")");
    }.