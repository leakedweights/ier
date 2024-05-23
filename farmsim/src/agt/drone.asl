!start.

at(P) :- pos(P,X,Y) & pos(Name, X, Y).

+!start : true <-
    .print("Drone started.");
    !model_loop.

+!model_loop : true <-
    if(not(empty(Routes))) {
        Position = [next(X, Y), Rest];
        !go_to(X, Y);
    }.

+!go_to(X, Y): true <-
    if(not(at(X,Y)) {
        move_towards(X,Y);
    }.