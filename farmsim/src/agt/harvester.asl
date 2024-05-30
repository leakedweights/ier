!start.

+!start <-
    .print("Harvester started.");
    .my_name(Name);
    +survey_count(Name, 0).

+plant_status(X, Y, State)[source(S)] : true <-
    .print("Received msg for field: ", [X, Y], ", State: ", State);
    
    .findall([X, Y, State], plant_status(_,_,_), PlantStatuses);

    .length(PlantStatuses, StatusCount);

    if (StatusCount == 5) {
        !make_decision;
        .abolish(plant_status(_,_,_));
    }.

+!make_decision : true <-

    .my_name(Name);

    ?pos(Name, PosX, PosY);

    .findall([X,Y], plant_status(X, Y, "EMPTY"), EmptyFields);
    .findall([X,Y], plant_status(X, Y, "HARVESTABLE"), HarvestFields);


    functions.SolveGreedyTSP(EmptyFields, [PosX, PosY], OptimizedEmptyFields, _);
    functions.SolveGreedyTSP(HarvestFields, [PosX, PosY], OptimizedHarvestFields, _);
    

    for(.member([HarvestableX, HarvestableY], OptimizedHarvestFields)) {
        !move_and_harvest(HarvestableX, HarvestableY);
    };

    for(.member([EmptyX, EmptyY], OptimizedEmptyFields)) {
        !move_and_plant(EmptyX, EmptyY);
    }.

+!move_and_harvest(X, Y) : true <-
    .my_name(Name);
    .print("Harvesting: ", [X, Y]);
    if(not(pos(Name, X, Y))) {
        move_towards(X, Y);
        !move_and_harvest(X,Y);
    } else {
      .print("Harvesting & planting: (", X, ",", Y, ")");
      harvest(X, Y);
      plant(X, Y);
    }.

+!move_and_plant(X, Y) : true <-
    .my_name(Name);
    .print("Planting: ", [X, Y]);
    if(not(pos(Name, X, Y))) {
        move_towards(X, Y);
        !move_and_plant(X,Y);
    } else {
      .print("Planting: (", X, ",", Y, ")");
      plant(X, Y);
    }.