!start.

+!start : true <- .print("Harvester started.").

+!traverse_route([]) <-
    .print("Completed the entire route.").
+!traverse_route([[X,Y]|Tail]) <-
    !go_to(X,Y);
    !traverse_route(Tail).

+!go_to(X, Y) : true <-
    .my_name(Name);
    if(not(pos(Name, X, Y))) {
        move_towards(X, Y);
        !go_to(X,Y);
    } else {
      .print("HELO");
    }.


+fieldState([X, Y, State, Health])[source(S)] : true <-
    .print("Received msg for field: ", [X, Y], ", State: ", State, ", Health: ", Health);
    !go_to(X,Y);
    !traverse_route(Tail).