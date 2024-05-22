!start_auction.

+!start_auction : true <-
    .print("Starting auction for fields.");
    !announce_auction.

+!announce_auction : true <-
    .print("Announcing auction.");
    .broadcast(announce_auction(Field)).

+bid(Drone, Bid) : true <-
    .print("Received bid from ", Drone, " with amount ", Bid);
    .insert(bid(Drone, Bid));
    !evaluate_bids.

+!evaluate_bids : not(is_auction_over) <-
    .wait(500); 
    !evaluate_bids.

+!evaluate_bids : is_auction_over <-
    .print("Evaluating bids.");
    bids(Bids);
    .findall(X, bid(_, X), Bids),
    .max_list(Bids, MaxBid),
    .member(bid(WinningDrone, MaxBid), Bids),
    .print("Winning drone is ", WinningDrone, " with bid ", MaxBid);
    .broadcast(announce_winner(WinningDrone)).

+announce_winner(WinningDrone) : true <-
    .print("Announcing winner: ", WinningDrone);
    .send(WinningDrone, task(Field)).
