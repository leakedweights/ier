!start_auction.

+!start_auction : true <-
    .print("Starting auction for fields.");
    .all_names(Agents);

    for(.member(Agent, Agents)) {
        if(.substring("drone", Agent)) {
            .send(Agent, tell, bid([5, 5]));
            +pending_bid(Agent);
        };
    }.

+bid([X, Y], Cost)[source(Agent)] : true <-
    .print("Received bid from ", Agent, ": Cost=", Cost);

    +agent_bid(Agent, Cost);
    -pending_bid(Agent);

    .findall(PendingAgent, pending_bid(PendingAgent), PendingBids);

    if(.length(PendingBids) == 0) {
        !evaluate_bids;
    }.

+!evaluate_bids : true <-
    .findall([Agent, Cost], agent_bid(Agent, Cost), Bids);
    !find_lowest_bid(Bids, none, 9999).

+!find_lowest_bid([], Winner, LowestCost) : true <-
    .print("Lowest bid from ", Winner, ": Cost=", LowestCost);
    .send(Winner, tell, win([5, 5])).

+!find_lowest_bid([[Agent, Bid] | Rest], CurrentWinner, CurrentLowestCost) : true <-
    if (Bid < CurrentLowestCost) {
        NewWinner = Agent;
        NewLowestCost = Bid;
    } else {
        NewWinner = CurrentWinner;
        NewLowestCost = CurrentLowestCost;
    };
    !find_lowest_bid(Rest, NewWinner, NewLowestCost).