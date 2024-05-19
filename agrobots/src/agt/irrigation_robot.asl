!start.

+!start <-
    .print("Irrigation and Nutrient Supply Robot starting...");
    !optimize_resources.

+!optimize_resources <-
    .print("Optimizing water and nutrient use...");
    // Simulate optimization
    .wait(1000);
    !irrigate.

+!irrigate <-
    .print("Irrigating specific areas...");
    // Simulate irrigation
    .wait(1000);
    !apply_nutrients.

+!apply_nutrients <-
    .print("Applying nutrients to specific areas...");
    // Simulate nutrient application
    .wait(1000);
    .print("Irrigation and nutrient application completed.").

+data(nutrient_deficiency, low) <-
    .print("Received data from Drone: Nutrient deficiency level is low.");
    !adjust_nutrient_application.

+!adjust_nutrient_application <-
    .print("Adjusting nutrient application based on new data...").
