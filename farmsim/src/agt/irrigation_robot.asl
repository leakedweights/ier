!start.

+!start <-
    .print("Irrigation Robot started.");

    .wait(1000);

    .queue.create(LowHealthQ);
    .queue.create(RegularQ);

    +low_health_queue(LowHealthQ);
    +water_queue(RegularQ).

+blocked(X, Y, Agent) : true <-
    .my_name(Name);
    ?pos(Name, PosX, PosY);
    .send(Agent, achieve, conflict([X,Y], [PosX, PosY])).

+!conflict([X,Y], [PosX, PosY]) : true <-
    move_towards(math.abs(PosX - X), math.abs(PosY + Y)).

+plant_status(X, Y, Health)[source(S)] : true <-
    ?low_health_queue(LowHealthQ);
    ?water_queue(RegularQ);
    
    if(.length(LowHealthQ, 0) & .length(RegularQ, 0)) {
        !update_queue;
        !iterate;
    } else {
        !update_queue;
    }.

+!update_queue : true <-
    .my_name(Name);
    ?pos(Name, PosX, PosY);

    .findall([X,Y, Health], plant_status(X, Y, Health) & Health >= 40, PlantedFields);
    .findall([X,Y, Health], plant_status(X, Y, Health) & Health < 40, LowHealthFields);

    functions.SolveGreedyTSP(PlantedFields, [PosX, PosY], OptimizedPlantedFields, _);
    functions.SolveGreedyTSP(LowHealthFields, [PosX, PosY], OptimizedLowHealthFields, _);

    ?low_health_queue(LowHealthQ);
    ?water_queue(RegularQ);
    -low_health_queue(LowHealthQ);
    -water_queue(RegularQ);

    .queue.create(NewLowHealthQ);
    .queue.create(NewRegularQ);
    .queue.add_all(NewLowHealthQ, OptimizedLowHealthFields);
    .queue.add_all(NewRegularQ, OptimizedPlantedFields);

    +low_health_queue(NewLowHealthQ);
    +water_queue(NewRegularQ).

+!iterate : true <-

    .my_name(Name);
    ?low_health_queue(LowHealthQ);
    ?water_queue(RegularQ);

    .length(LowHealthQ, LowHealthQSize);
    .length(RegularQ, RegularQSize);

    if (not(busy(Name))) {
        if(not(LowHealthQSize == 0)) {
            +busy(Name);
            .queue.remove(LowHealthQ, [X, Y]);
            !move_and_water(X, Y);
            !iterate;
        } elif (not(RegularQSize == 0)) {
            +busy(Name);
            .queue.remove(RegularQ, [X, Y]);
            !move_and_water(X, Y);
            !iterate;
        };
    }.

+!move_and_water(X, Y) : true <-
    .my_name(Name);
    if(not(pos(Name, X, Y))) {
        move_towards(X, Y);
        !move_and_water(X,Y);
    } else {
      water(X, Y);
      .abolish(plant_status(X, Y, _));
      -busy(Name);
    }.
