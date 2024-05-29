// initialization

!start.

+!start : true <-
    .print("Drone started.");
    .my_name(MyName);
    +route(MyName, []).

// auction (sealed-bid)

+bid([X, Y])[source(S)] : true <-
    .my_name(MyName);
    ?pos(MyName, PosX, PosY);
    ?route(MyName, Route);
    .concat(Route, [[X, Y]], NewRoute);
    functions.SolveGreedyTSP(NewRoute, [PosX, PosY], _, Cost);
    .send(auctioneer, tell, bid([X, Y], Cost)).

+win([X, Y])[source(auctioneer)] : true <-
    .my_name(MyName);
    ?pos(MyName, PosX, PosY);
    ?route(MyName, Route);
    .concat(Route, [[X, Y]], NewRoute);
    functions.SolveGreedyTSP(NewRoute, [PosX, PosY], OptimizedRoute, _);
    -route(MyName, Route);
    +route(MyName, OptimizedRoute);
    !traverse_route(OptimizedRoute).

// movement

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
      .print("Surveying: (", X, ",", Y, ")");
      !survey_completed([X, Y]);
    }.

//sending data to harvester
+!survey_completed([X, Y]) : true <-
    .print("Survey completed at: (", X, ",", Y, ")");
    State = getState(X, Y);
    Health = getHealth(X, Y);
    .send(harvester, tell, fieldState([X, Y, State, Health])).