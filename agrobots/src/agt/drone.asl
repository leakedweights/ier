!start.

+!start <-
    .print("Terrain Analysis Drone starting...");
    !monitor_area.

+!monitor_area <-
    .print("Monitoring area...");
    .wait(1000);
    +data(dryness, moderate);
    +data(nutrient_deficiency, low);
    !share_data.

+!share_data <-
    !send(agent_harvester, tell, data(dryness, moderate));
    !send(agent_irrigation, tell, data(nutrient_deficiency, low)).
