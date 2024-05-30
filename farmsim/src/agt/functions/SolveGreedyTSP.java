package functions;

import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.ListTerm;
import jason.asSyntax.ListTermImpl;
import jason.asSyntax.NumberTerm;
import jason.asSyntax.NumberTermImpl;
import jason.asSyntax.Term;

public class SolveGreedyTSP extends DefaultInternalAction {

    static Logger logger = Logger.getLogger(SolveGreedyTSP.class.getName());

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
        ListTerm pointsList = (ListTerm) args[0];
        List<int[]> points = new ArrayList<>();

        ListTerm startPointList = (ListTerm) args[1];
        int[] startPoint = new int[2];
        startPoint[0] = (int) ((NumberTerm) startPointList.get(0)).solve();
        startPoint[1] = (int) ((NumberTerm) startPointList.get(1)).solve();

        points.add(startPoint);

        for (Term t : pointsList) {
            ListTerm point = (ListTerm) t;
            int[] coordinates = new int[2];
            coordinates[0] = (int) ((NumberTerm) point.get(0)).solve();
            coordinates[1] = (int) ((NumberTerm) point.get(1)).solve();
            points.add(coordinates);
        }

        List<int[]> route = solveGreedyTSP(points, 0);
        double cost = calculateRouteCost(route, startPoint);

        route.remove(0); // remove current position

        ListTerm plannedRoute = new ListTermImpl();
        for (int[] point : route) {
            ListTerm pointTerm = new ListTermImpl();
            pointTerm.add(new NumberTermImpl(point[0]));
            pointTerm.add(new NumberTermImpl(point[1]));
            plannedRoute.add(pointTerm);
        }
    
        NumberTerm plannedCost = new NumberTermImpl(cost);

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

        return route;
    }

    private double calculateDistance(int[] point1, int[] point2) {
        int dx = Math.abs(point1[0] - point2[0]);
        int dy = Math.abs(point1[1] - point2[1]);
        return dx + dy;
    }

    private double calculateRouteCost(List<int[]> route, int[] startPoint) {
        double cost = 0.0;
        int[] previousPoint = startPoint;
        for (int[] point : route) {
            cost += calculateDistance(previousPoint, point);
            previousPoint = point;
        }
        return cost;
    }
}
