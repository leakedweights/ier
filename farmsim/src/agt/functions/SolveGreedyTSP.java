package functions;

import jason.asSemantics.*;
import jason.asSyntax.*;

import java.util.*;

public class SolveGreedyTSP extends DefaultInternalAction {

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

        // Apply the greedy TSP algorithm
        List<int[]> route = solveGreedyTSP(points, startPoint);
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

    private List<int[]> solveGreedyTSP(List<int[]> points, int[] startPoint) {
        List<int[]> route = new ArrayList<>();
        Set<int[]> visited = new HashSet<>();
        int[] currentPoint = startPoint;

        route.add(currentPoint);
        visited.add(currentPoint);

        while (visited.size() < points.size()) {
            int[] nextPoint = null;
            double minDistance = Double.MAX_VALUE;

            for (int[] point : points) {
                if (!visited.contains(point)) {
                    double distance = calculateDistance(currentPoint, point);
                    if (distance < minDistance) {
                        minDistance = distance;
                        nextPoint = point;
                    }
                }
            }

            route.add(nextPoint);
            visited.add(nextPoint);
            currentPoint = nextPoint;
        }

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
        return cost;
    }
}
