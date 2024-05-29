// initialization

!start_auction.

+!start_auction : true <-
    .print("Starting auction for fields.");
    .findall([X,Y], field(X, Y), Fields);
    +auction_queue(Fields);
    !next_auction.

// auction schedule

+!next_auction : true <-
    .wait(2000);
    .all_names(Agents);
    ?auction_queue(Queue);
    [[X, Y] | Rest] = Queue;
    -auction_queue(Queue);
    +auction_queue(Rest);

    .print("On auction: ", [X, Y]);

    +auction([X, Y]);

    for(.member(Agent, Agents)) {
        if(.substring("drone", Agent)) {
            .send(Agent, tell, bid([X, Y]));
            +pending_bid(Agent);
        };
    }.

+survey_completed([X, Y])[source(Agent)] : true <-
    ?auction_queue(Queue);
    .concat(Queue, [[X,Y]], NewQueue);
    -auction_queue(Queue);
    +auction_queue(NewQueue).

// bidding

+bid([X, Y], Cost)[source(Agent)] : true <-
    +agent_bid(Agent, Cost);
    -pending_bid(Agent);

    .findall(PendingAgent, pending_bid(PendingAgent), PendingBids);

    if(.length(PendingBids) == 0) {
        !evaluate_bids;
        -auction([X,Y]);
        !next_auction;
    }.

// bid evaluation

+!evaluate_bids : true <-
    .findall([Agent, Cost], agent_bid(Agent, Cost), Bids);
    !find_lowest_bid(Bids, none, 9999).

+!find_lowest_bid([], Winner, LowestCost) : true <-
    .print("Lowest bid from ", Winner, ": Cost=", LowestCost);
    ?auction(Field);
    .send(Winner, tell, win(Field)).

+!find_lowest_bid([[Agent, Bid] | Rest], CurrentWinner, CurrentLowestCost) : true <-
    if (Bid < CurrentLowestCost) {
        NewWinner = Agent;
        NewLowestCost = Bid;
    } else {
        NewWinner = CurrentWinner;
        NewLowestCost = CurrentLowestCost;
    };
    !find_lowest_bid(Rest, NewWinner, NewLowestCost).