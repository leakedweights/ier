// initialization

!start.

+!start <-
    .print("Drone started.");
    .wait(1000);
    .my_name(Name);
    +route(Name, []).
    
// auction (sealed-bid)

+!bid([X, Y])[source(auctioneer)] : true <-

    .my_name(Name);
    ?pos(Name, PosX, PosY);
    ?route(Name, Route);

    .concat(Route, [[X, Y]], NewRoute);
    functions.SolveGreedyTSP(NewRoute, [PosX, PosY], _, Cost);
    
    .send(auctioneer, tell, bid([X, Y], Cost)).

+!win([X, Y])[source(auctioneer)] : true <-

    .my_name(Name);

    ?route(Name, Queue);
    .concat(Queue, [[X, Y]], NewQueue);

    -route(Name, Queue);
    +route(Name, NewQueue);

    if(not(busy(Name))) {
        +busy(Name);
        !traverse_route;
    }.

// movement

+!traverse_route : true <-
    .my_name(Name);
    ?pos(Name, PosX, PosY);
    ?route(Name, Queue);

 
    if (not(.empty(Queue))) {
        functions.SolveGreedyTSP(Queue, [PosX, PosY], [[X, Y]|NewQueue], _);

        -route(Name, Queue);
        +route(Name, NewQueue);

        !go_to(X, Y);
        !traverse_route;
    } else {
        -busy(Name);
    }.


+plant_status(X, Y, PlantState, PlantHealth) : true <-
    if(PlantState == "HARVESTABLE" | PlantState == "EMPTY") {
        .send(harvester, tell, plant_status(X, Y, PlantState));
    };

    if(not(PlantState == "WATERED") | not(PlantState == "EMPTY")) {
        .send(irrigation_robot, tell, plant_status(X, Y, PlantState, PlantHealth));
    }.
    

+!go_to(X, Y) : true <-
    .my_name(Name);
    if(not(pos(Name, X, Y))) {
        move_towards(X, Y);
        !go_to(X,Y);
    } else {
      survey(X, Y);
      .send(auctioneer, tell, survey_completed([X, Y]));
    }.