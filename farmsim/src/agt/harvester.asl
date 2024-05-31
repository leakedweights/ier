!start.

+!start <-
    .print("Harvester started.");

    .wait(1000);

    +d_last_update(0);

    .queue.create(HarvestableQ);
    .queue.create(DeadFieldQ);
    .queue.create(EmptyFieldQ);

    +harvestables(HarvestableQ);
    +dead_fields(DeadFieldQ);
    +empty_fields(EmptyFieldQ).

+blocked(X, Y, Agent) : true <-
    .my_name(Name);
    .print("Blocked by ", Agent);
    ?pos(Name, PosX, PosY);
    .send(Agent, achieve, conflict([X,Y], [PosX, PosY])).

+!conflict([X,Y], [PosX, PosY]) : true <-
    !move_towards(PosX - X, PosY + Y).


+plant_status(X, Y, State)[source(S)] : true <-

    ?harvestables(HarvestableQ);
    ?empty_fields(EmptyFieldQ);
    ?dead_fields(DeadFieldQ);

    .findall([X, Y, State], plant_status(X, Y, State), PlantStatuses);
    .length(PlantStatuses, StatusCount);

    ?d_last_update(UpdateDiff);

    if(.length(HarvestableQ, 0) & .length(EmptyFieldQ, 0) & .length(DeadFieldQ, 0)) {
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
    .findall([X,Y], plant_status(X, Y, "DEAD"), DeadFields);

    functions.SolveGreedyTSP(EmptyFields, [PosX, PosY], OptimizedEmptyFields, _);
    functions.SolveGreedyTSP(HarvestFields, [PosX, PosY], OptimizedHarvestFields, _);
    functions.SolveGreedyTSP(DeadFields, [PosX, PosY], OptimizedDeadFields, _);

    ?harvestables(HarvestableQ);
    ?empty_fields(EmptyFieldQ);
    ?empty_fields(DeadFieldQ);
    -harvestables(HarvestableQ);
    -empty_fields(EmptyFieldQ);
    -empty_fields(DeadFieldQ);

    .queue.create(NewHarvestableQ);
    .queue.create(NewEmptyFieldQ);
    .queue.create(NewDeadFieldQ);
    .queue.add_all(NewHarvestableQ, OptimizedHarvestFields);
    .queue.add_all(NewEmptyFieldQ, OptimizedEmptyFields);
    .queue.add_all(NewDeadFieldQ, OptimizedDeadFields);

    +harvestables(NewHarvestableQ);
    +empty_fields(NewEmptyFieldQ).
    +dead_fields(NewDeadFieldQ).

+!iterate : true <-
    .my_name(Name);
    ?harvestables(HarvestableQ);
    ?empty_fields(EmptyFieldQ);
    ?dead_fields(DeadFieldQ);

    .length(HarvestableQ, HarvestableQSize);
    .length(EmptyFieldQ, EmptyFieldQSize);
    .length(DeadFieldQ, DeadFieldQSize);

    if (not(busy(Name))) {
        if(not(HarvestableQSize == 0)) {
            +busy(Name);
            .queue.remove(HarvestableQ, [X, Y]);
            !move_and_harvest(X, Y);
            !iterate;
        } elif (not(DeadFieldQSize == 0)) {
            +busy(Name);
            .queue.remove(DeadFieldQ, [X, Y]);
            !move_and_remove(X, Y);
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
      plant(X, Y);
      .abolish(plant_status(X, Y, _));
      +plant_status(X, Y, "PLANTED");
      -busy(Name);
    }.

+!move_and_remove(X, Y) : true <-
    .my_name(Name);
    if(not(pos(Name, X, Y))) {
        move_towards(X, Y);
        !move_and_remove(X,Y);
    } else {
      water(X, Y);
      .abolish(plant_status(X, Y, _));
      +plant_status(X, Y, "DEAD");
      -busy(Name);
    }.

