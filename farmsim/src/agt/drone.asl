!start.

+!start : true <- .print("Drone started."); !move_to_nearest_target.

+!move_to_nearest_target : true <- 
    .print("Moving to nearest target field.").

+move_to_nearest_target_result(success) : true <- .print("Move to nearest target successful."); !survey_area.
+move_to_nearest_target_result(failure) : true <- .print("Move to nearest target failed.").

+survey_area : true <- .print("Surveying area."); .send(env, survey); !process_survey_results.

+survey(X, Y) : true <- .print("Found target at ", X, ", ", Y); !handle_target(X, Y).

+handle_target(X, Y) : true <- .print("Handling target at ", X, ", ", Y).

+!process_survey_results : true <- .print("Processing survey results").
