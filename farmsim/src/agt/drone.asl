// initialization

!start.

+!start <-
    .print("Drone started.");
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

    .print("Won field: ", [X, Y]);

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
    .print("Status of ", [X, Y], ": ", PlantState, ", Health: ", PlantHealth);

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
