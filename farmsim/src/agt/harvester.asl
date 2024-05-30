!start.

+!start <-
    .print("Harvester started.");
    .my_name(Name);
    +survey_count(Name, 0).

+plant_status(X, Y, State)[source(S)] : true <-
    
    .findall([X, Y, State], plant_status(_,_,_), PlantStatuses);

    .length(PlantStatuses, StatusCount);

    if (StatusCount == 5) {
        !make_decision;
        .abolish(plant_status(_,_,_));
    }.

+!plant_successful : true <-
    !make_decision.

+!make_decision : true <-

    .my_name(Name);

    ?pos(Name, PosX, PosY);

    .findall([X,Y], plant_status(X, Y, "EMPTY"), EmptyFields);
    .findall([X,Y], plant_status(X, Y, "HARVESTABLE"), HarvestFields);


    functions.SolveGreedyTSP(EmptyFields, [PosX, PosY], OptimizedEmptyFields, _);
    functions.SolveGreedyTSP(HarvestFields, [PosX, PosY], OptimizedHarvestFields, _);
    
    for(.member([EmptyX, EmptyY], OptimizedEmptyFields)) {
        !move_and_plant(EmptyX, EmptyY);
    };

    for(.member([HarvestableX, HarvestableY], OptimizedHarvestFields)) {
        !move_and_harvest(HarvestableX, HarvestableY);
    }.

+!move_and_harvest(X, Y) : true <-
    harvest(X, Y);
    plant(X, Y).

+!move_and_plant(X, Y) : true <-
      plant(X, Y).