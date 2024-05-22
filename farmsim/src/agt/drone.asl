!start.

+!start : true <-
    .print("Drone started.");
    my_position(0, 0);
    planned_visits([]);
    !move_to_nearest_target.

+!move_to_nearest_target : true <-
    .print("Moving to nearest target field.").

+move_to_nearest_target_result(success) : true <-
    .print("Move to nearest target successful.");
    !survey_area.

+move_to_nearest_target_result(failure) : true <-
    .print("Move to nearest target failed.").

+survey_area : true <-
    .print("Surveying area.");
    !process_survey_results.

+survey(X, Y) : true <-
    .print("Found target at ", X, ", ", Y);
    !handle_target(X, Y).

+handle_target(X, Y) : true <-
    .print("Handling target at ", X, ", ", Y);
    planned_visits(Visits);
    .concat(Visits, [target(X, Y)], NewVisits);
    planned_visits(NewVisits).

+!process_survey_results : true <-
    .print("Processing survey results").

+announce_auction(Field) : true <-
    .print("Auction announced for field ", Field);
    !evaluate_field(Field).

+!evaluate_field(Field) : true <-
    .print("Evaluating field ", Field);
    planned_visits(Visits);
    my_position(CX, CY);
    !calculate_bid(Field, Visits, (CX, CY)).

+!calculate_bid((X, Y), Visits, (CX, CY)) : true <-
    .print("Calculating bid for field ", X, ", ", Y);
    !calculate_total_cost(Visits, (CX, CY), TotalCost);
    !calculate_nearest_distance((X, Y), Visits, (CX, CY), NearestDist);
    Bid = TotalCost + NearestDist;
    .print("Calculated bid: ", Bid);
    !submit_bid(Bid).

+!submit_bid(Bid) : true <-
    .send(auctioneer, bid(self, Bid));
    .print("Bid sent with amount ", Bid).

// Calculate the total cost of planned visits
+!calculate_total_cost([], (CX, CY), 0) : true.

+!calculate_total_cost([target(X, Y) | Rest], (CX, CY), TotalCost) : true <-
    Cost = abs(CX - X) + abs(CY - Y);  // Cost from current position to the first target
    !calculate_total_cost(Rest, (X, Y), RestTotalCost);
    TotalCost = Cost + RestTotalCost.

// Calculate the Manhattan distance between the nearest point in the planned visits and the location under auction
+!calculate_nearest_distance((X, Y), [], (CX, CY), NearestDist) : true <-
    NearestDist = abs(CX - X) + abs(CY - Y).

+!calculate_nearest_distance((X, Y), [target(X1, Y1) | Rest], (CX, CY), NearestDist) : true <-
    Dist = abs(X - X1) + abs(Y - Y1);
    !calculate_nearest_distance((X, Y), Rest, (CX, CY), RestNearestDist);
    NearestDist = min(Dist, RestNearestDist).
