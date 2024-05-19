!start.

+!start <-
    .print("Automated Harvester starting...");
    !schedule_tasks.

+!schedule_tasks <-
    .print("Scheduling planting and harvesting tasks...");
    .wait(1000);
    !execute_tasks.

+!execute_tasks <-
    .print("Executing scheduled tasks...");
    .wait(1000);
    .print("Planting and harvesting completed.").

+data(dryness, moderate) <-
    .print("Received data from Drone: Dryness level is moderate.");
    !adjust_schedule.

+!adjust_schedule <-
    .print("Adjusting schedule based on new data...").
