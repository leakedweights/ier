!start.

+!start <-
    .print("Harvester started.");

    .wait(1000);

    .queue.create(HarvestableQ);
    .queue.create(EmptyFieldQ);

    +harvestables(HarvestableQ);
    +empty_fields(EmptyFieldQ).

+plant_status(X, Y, State)[source(S)] : true <-

    ?harvestables(HarvestableQ);
    ?empty_fields(EmptyFieldQ);

    .length(HarvestableQ, HarvestableQSize);
    .length(EmptyFieldQ, EmptyFieldQSize);

    .findall([X, Y, State], plant_status(X, Y, State), PlantStatuses);
    .length(PlantStatuses, StatusCount);

    if(EmptyFieldQSize == 0 & HarvestableQSize == 0) {
        !update_queue;
        !iterate;
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
    ?harvestables(HarvestableQ);
    ?empty_fields(EmptyFieldQ);

    .length(HarvestableQ, HarvestableQSize);
    .length(EmptyFieldQ, EmptyFieldQSize);

    if(not(HarvestableQSize == 0)) {
        .queue.remove(HarvestableQ, [X, Y]);
        !move_and_harvest(X, Y);
        !iterate;
    } elif (not(EmptyFieldQSize == 0)) {
        .queue.remove(EmptyFieldQ, [X, Y]);
        .print("Calling move to: (", X, ",", Y, ")");
        !move_and_plant(X, Y);
        .print("Move and plant finished.");

        !iterate;
    }.

+!move_and_harvest(X, Y) : true <-
    .my_name(Name);
    if(not(pos(Name, X, Y))) {
        move_towards(X, Y);
        !move_and_harvest(X,Y);
    } else {
      harvest(X, Y);
    }.

+!move_and_plant(X, Y) : true <-
    .my_name(Name);
    if(not(pos(Name, X, Y))) {
        .print("Moving to: (", X, ",", Y, ")");
        move_towards(X, Y);
        !move_and_plant(X,Y);
    } else {
      ?harvestables(HarvestableQ);
      .print("Planting: (", X, ",", Y, ")");

      plant(X, Y);
      .abolish(plant_status(X, Y, _));
      +plant_status(X, Y, "PLANTED");
    }.