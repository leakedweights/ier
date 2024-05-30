!start.

+!start : true <- .print("Irrigation robot started.").

+plant_status(X, Y, State, Health)[source(S)] : true <-
    .print("Received msg for field: ", [X, Y], ", State: ", State, ", Health: ", Health).