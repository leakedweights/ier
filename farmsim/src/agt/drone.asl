// initialization

!start.

+!start : true <-
    .print("Drone started.");
    .my_name(MyName);
    +route(MyName, []);
    +queued_destinations(MyName, []);
    +busy(MyName, false).

// auction (sealed-bid)

+bid([X, Y])[source(S)] : true <-
    .my_name(MyName);
    ?pos(MyName, PosX, PosY);
    ?route(MyName, Route);
    .concat(Route, [[X, Y]], NewRoute);
    functions.SolveGreedyTSP(NewRoute, [PosX, PosY], _, Cost);
    .send(auctioneer, tell, bid([X, Y], Cost)).

+win([X, Y])[source(auctioneer)] : true <-

    .print("Won field: ", [X, Y]);

    .my_name(MyName);
    ?busy(MyName, Busy);
    if (Busy) {
        ?queued_destinations(MyName, QDests);
        .concat(QDests, [[X, Y]], NewQDests);
        -queued_destinations(MyName, QDests);
        +queued_destinations(MyName, NewQDests);
        .print("Added ", [X, Y], " to queue.");
    } else {
        +busy(MyName, true);
        ?pos(MyName, PosX, PosY);
        ?route(MyName, Route);
        .concat(Route, [[X, Y]], NewRoute);
        functions.SolveGreedyTSP(NewRoute, [PosX, PosY], OptimizedRoute, _);
        .print("Optimized route: ", OptimizedRoute);
        -route(MyName, Route);
        +route(MyName, OptimizedRoute);
        !traverse_route(OptimizedRoute);
    }.

// movement

+!traverse_route([]) <-
    .my_name(MyName);
    ?pos(MyName, X, Y);
    -busy(MyName, true);
    ?queued_destinations(MyName, QDests);
    if (not(.empty(QDests))) {
        +busy(MyName, true);

        // clear queue
        -queued_destinations(MyName, QDests);
        +queued_destinations(MyName, []);

        // optimize and traverse new route
        ?route(MyName, Route);
        .concat(Route, QDests, NewRoute);
        functions.SolveGreedyTSP(NewRoute, [X, Y], OptimizedRoute, _);

        -route(MyName, Route);
        +route(MyName, OptimizedRoute);

        !traverse_route(OptimizedRoute);
    }.

+!traverse_route([[X,Y]|Tail]) <-
    !go_to(X,Y);
    !traverse_route(Tail).

+!go_to(X, Y) : true <-
    .my_name(Name);
    if(not(pos(Name, X, Y))) {
        move_towards(X, Y);
        !go_to(X,Y);
    } else {
      .print("Surveying: (", X, ",", Y, ")");
<<<<<<< HEAD
      !survey_completed([X, Y]);
    }.

//sending data to harvester
+!survey_completed([X, Y]) : true <-
    .print("Survey completed at: (", X, ",", Y, ")");
    State = getState(X, Y);
    Health = getHealth(X, Y);
    .send(harvester, tell, fieldState([X, Y, State, Health])).
=======
      survey(X, Y);
      .broadcast(tell, survey_completed([X, Y]));
    }.
>>>>>>> bd54d6d7809c0ea6326daa7417f13b3f1301f837
