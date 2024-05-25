!start.

+!start : true <-
    .print("Drone started.");
    !plan_and_traverse.


+!plan_and_traverse : true <-
    .my_name(MyName);
    for (destination(AgentName, Destination)) {
        if(AgentName == MyName) {
            Destination = [X, Y];
            !go_to(X, Y);
            -destination(MyName, Destination);
        };
    }.

+!go_to(X, Y) : true <-
    .my_name(Name);
    if(not(pos(Name, X, Y))) {
        move_towards(X, Y);
        !go_to(X,Y);
    } else {
      .print("Arrived at: (", X, ",", Y, ")");
      survey(X, Y);  
    }.
