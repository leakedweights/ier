!start.

+!start <-
    .print("Harvester started.");

    .wait(1000);

    +d_last_update(0);

    .queue.create(HarvestableQ);
    .queue.create(EmptyFieldQ);

    +harvestables(HarvestableQ);
    +empty_fields(EmptyFieldQ).

+plant_status(X, Y, State)[source(S)] : true <-

    ?harvestables(HarvestableQ);
    ?empty_fields(EmptyFieldQ);

    .findall([X, Y, State], plant_status(X, Y, State), PlantStatuses);
    .length(PlantStatuses, StatusCount);

    ?d_last_update(UpdateDiff);

    if(.length(HarvestableQ, 0) & .length(EmptyFieldQ, 0)) {
        !update_queue;
        -d_last_update(UpdateDiff);
        +d_last_update(0);
        !iterate;
    } elif (UpdateDiff > 5) {
        !update_queue;
        -d_last_update(UpdateDiff);
        +d_last_update(0);
    } else {
        -d_last_update(UpdateDiff);
        +d_last_update(UpdateDiff + 1);
    }.

+!update_queue : true <-
    .my_name(Name);

    ?pos(Name, PosX, PosY);

    .findall([X,Y], plant_status(X, Y, "EMPTY"), EmptyFields);
    .findall([X,Y], plant_status(X, Y, "HARVESTABLE"), HarvestFields);

    functions.SolveGreedyTSP(EmptyFields, [PosX, PosY], OptimizedEmptyFields, _);
    functions.SolveGreedyTSP(HarvestFields, [PosX, PosY], OptimizedHarvestFields, _);

    ?harvestables(HarvestableQ);
    ?empty_fields(EmptyFieldQ);
    -harvestables(HarvestableQ);
    -empty_fields(EmptyFieldQ);

    .queue.create(NewHarvestableQ);
    .queue.create(NewEmptyFieldQ);
    .queue.add_all(NewHarvestableQ, OptimizedHarvestFields);
    .queue.add_all(NewEmptyFieldQ, OptimizedEmptyFields);

    +harvestables(NewHarvestableQ);
    +empty_fields(NewEmptyFieldQ).

+!iterate : true <-
    .my_name(Name);
    ?harvestables(HarvestableQ);
    ?empty_fields(EmptyFieldQ);

    .length(HarvestableQ, HarvestableQSize);
    .length(EmptyFieldQ, EmptyFieldQSize);

    if (not(busy(Name))) {
        if(not(HarvestableQSize == 0)) {
            +busy(Name);
            .queue.remove(HarvestableQ, [X, Y]);
            !move_and_harvest(X, Y);
            !iterate;
        } elif (not(EmptyFieldQSize == 0)) {
            +busy(Name);
            .queue.remove(EmptyFieldQ, [X, Y]);
            !move_and_plant(X, Y);
            !iterate;
        };
    }.

    

+!move_and_harvest(X, Y) : true <-
    .my_name(Name);
    if(not(pos(Name, X, Y))) {
        move_towards(X, Y);
        !move_and_harvest(X,Y);
    } else {
      .print("Harvesting: (", X, ",", Y, ")");
      harvest(X, Y);
      .abolish(plant_status(X, Y, _));
      +plant_status(X, Y, "EMPTY");
      -busy(Name);
    }.

+!move_and_plant(X, Y) : true <-
    .my_name(Name);
    if(not(pos(Name, X, Y))) {
        move_towards(X, Y);
        !move_and_plant(X,Y);
    } else {
      .print("Planting: (", X, ",", Y, ")");
      plant(X, Y);
      .abolish(plant_status(X, Y, _));
      +plant_status(X, Y, "PLANTED");
      -busy(Name);
    }.