package functions;

import jason.asSemantics.*;
import jason.asSyntax.*;

import java.util.*;
import java.util.logging.Logger;

public class SolveGreedyTSP extends DefaultInternalAction {

    static Logger logger = Logger.getLogger(SolveGreedyTSP.class.getName());

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
        // Extract the list of points
        ListTerm pointsList = (ListTerm) args[0];
        List<int[]> points = new ArrayList<>();

        // Extract starting point
        ListTerm startPointList = (ListTerm) args[1];
        int[] startPoint = new int[2];
        startPoint[0] = (int) ((NumberTerm) startPointList.get(0)).solve();
        startPoint[1] = (int) ((NumberTerm) startPointList.get(1)).solve();

        // Extract all points from the list term
        for (Term t : pointsList) {
            ListTerm point = (ListTerm) t;
            int[] coordinates = new int[2];
            coordinates[0] = (int) ((NumberTerm) point.get(0)).solve();
            coordinates[1] = (int) ((NumberTerm) point.get(1)).solve();
            points.add(coordinates);
        }

        // Ensure the startPoint is in the list and find its index
        int startIndex = -1;
        for (int i = 0; i < points.size(); i++) {
            if (Arrays.equals(points.get(i), startPoint)) {
                startIndex = i;
                break;
            }
        }
        if (startIndex == -1) {
            points.add(startPoint);
            startIndex = points.size() - 1;
        }

        // Apply the greedy TSP algorithm
        List<int[]> route = solveGreedyTSP(points, startIndex);
        double cost = calculateRouteCost(route);

        // Convert the route and cost to Jason terms
        ListTerm plannedRoute = new ListTermImpl();
        for (int[] point : route) {
            ListTerm pointTerm = new ListTermImpl();
            pointTerm.add(new NumberTermImpl(point[0]));
            pointTerm.add(new NumberTermImpl(point[1]));
            plannedRoute.add(pointTerm);
        }

        NumberTerm plannedCost = new NumberTermImpl(cost);

        // Unify the results with the output variables
        return un.unifies(plannedRoute, args[2]) && un.unifies(plannedCost, args[3]);
    }

    private List<int[]> solveGreedyTSP(List<int[]> points, int startIndex) {
        List<int[]> route = new ArrayList<>();
        boolean[] visited = new boolean[points.size()];
        int currentIndex = startIndex;

        route.add(points.get(currentIndex));
        visited[currentIndex] = true;

        while (route.size() < points.size()) {
            int[] currentPoint = route.get(route.size() - 1);
            double minDistance = Double.MAX_VALUE;
            int nextIndex = -1;

            for (int i = 0; i < points.size(); i++) {
                if (!visited[i]) {
                    double distance = calculateDistance(currentPoint, points.get(i));
                    if (distance < minDistance) {
                        minDistance = distance;
                        nextIndex = i;
                    }
                }
            }

            if (nextIndex != -1) {
                route.add(points.get(nextIndex));
                visited[nextIndex] = true;
            }
        }

        // Optionally, return to the starting point to complete the circuit
        // route.add(points.get(startIndex));

        return route;
    }

    private double calculateDistance(int[] point1, int[] point2) {
        int dx = point1[0] - point2[0];
        int dy = point1[1] - point2[1];
        return Math.sqrt(dx * dx + dy * dy);
    }

    private double calculateRouteCost(List<int[]> route) {
        double cost = 0.0;
        for (int i = 0; i < route.size() - 1; i++) {
            cost += calculateDistance(route.get(i), route.get(i + 1));
        }
        // Optionally, add the cost of returning to the start point to complete the circuit
        // cost += calculateDistance(route.get(route.size() - 1), route.get(0));
        return cost;
    }
}
