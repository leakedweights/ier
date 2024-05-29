!start.

+!start : true <- .print("Harvester started.").

+fieldState([X, Y, State, Health])[source(S)] : true <-
    .print("Received msg for field: ", [X, Y], ", State: ", State, ", Health: ", Health).