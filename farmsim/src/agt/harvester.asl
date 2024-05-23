!start.

+!start : true <- .print("Harvester started.").

+field(X,Y) <- 
    .print("Harvester moving");
    !go_to(X,Y).

+!go_to(X, Y) : true <-
    if(not(pos(Name, X, Y))) {
        move_towards(X, Y);
        !go_to(X,Y);
    } else {
        .print("Arrived at (", X, ",", Y, ")");
    }.
