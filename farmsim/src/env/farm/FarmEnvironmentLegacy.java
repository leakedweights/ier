package env.farm;

import jason.asSyntax.*;
import jason.environment.*;
import jason.environment.grid.*;

import java.util.logging.*;

public class FarmEnvironmentLegacy extends Environment {

    public static final int GRID_SIZE = 25;
    private FarmModel model;
    private Logger logger = Logger.getLogger("farmsim." + FarmEnvironment.class.getName());

    @Override
    public void init(String[] args) {
        super.init(args);
        model = new FarmModel(GRID_SIZE);
        model.initGrid();
        updatePercepts();
        logger.info("Free: " + model.isFree(0, 0));
    }

    private void updatePercepts() {
        clearPercepts();
        for (int i = 0; i < model.getNbOfAgs(); i++) {
            Location loc = model.getAgPos(i);
            if (loc != null) {
                Literal pos = Literal.parseLiteral("at(" + loc.x + "," + loc.y + ")");
                addPercept("agent" + (i + 1), pos);
            }
        }
    }

    @Override
    public boolean executeAction(String agName, Structure action) {
        try {
            if (action.getFunctor().equals("move")) {
                int agentId = getAgentId(agName);
                int x = (int) ((NumberTerm) action.getTerm(0)).solve();
                int y = (int) ((NumberTerm) action.getTerm(1)).solve();
                return moveAgent(agentId, x, y);
            } else if (action.getFunctor().equals("survey")) {
                int agentId = getAgentId(agName);
                return survey(agentId);
            } else if (action.getFunctor().equals("move_to_nearest_target")) {
                int agentId = getAgentId(agName);
                boolean success = moveToNearestTarget(agentId);
                if (success) {
                    addPercept(agName, Literal.parseLiteral("move_to_nearest_target_result(success)"));
                } else {
                    addPercept(agName, Literal.parseLiteral("move_to_nearest_target_result(failure)"));
                }
                return success;
            } else if (action.getFunctor().equals("plant")) {
                int x = (int) ((NumberTerm) action.getTerm(0)).solve();
                int y = (int) ((NumberTerm) action.getTerm(1)).solve();
                model.plant(x, y);
                return true;
            } else if (action.getFunctor().equals("water")) {
                int x = (int) ((NumberTerm) action.getTerm(0)).solve();
                int y = (int) ((NumberTerm) action.getTerm(1)).solve();
                model.water(x, y);
                return true;
            } else if (action.getFunctor().equals("next_iteration")) {
                model.nextIteration();
                updatePercepts();
                informAgsEnvironmentChanged();
                return true;
            }
        } catch (Exception e) {
            logger.warning("Failed to execute action: " + action + " due to " + e.getMessage());
        }

        logger.info("executing: " + action + ", but not implemented!");
        if (true) {
            informAgsEnvironmentChanged();
        }
        return true;
    }

    private int getAgentId(String agName) {
        return Integer.parseInt(agName.replace("agent", "")) - 1;
    }

    private boolean moveAgent(int agentId, int x, int y) {
        Location next = new Location(x, y);
        if (model.moveDrone(agentId, next)) {
            updatePercepts();
            informAgsEnvironmentChanged();
            logger.info("Agent " + (agentId + 1) + " moved to " + x + ", " + y);
            return true;
        }
        return false;
    }

    private boolean survey(int agentId) {
        Location loc = model.getAgPos(agentId);
        boolean found = false;
        for (int dx = -1; dx <= 1; dx++) {
            for (int dy = -1; dy <= 1; dy++) {
                if (dx == 0 && dy == 0)
                    continue;
                int x = loc.x + dx;
                int y = loc.y + dy;
                if (x >= 0 && x < GRID_SIZE && y >= 0 && y < GRID_SIZE) {
                    if (model.survey(new Location(x, y))) {
                        found = true;
                        Literal percept = Literal.parseLiteral("survey(" + x + "," + y + ")");
                        addPercept("agent" + (agentId + 1), percept);
                    }
                }
            }
        }
        informAgsEnvironmentChanged();
        return found;
    }

    private boolean moveToNearestTarget(int agentId) {
        Location current = model.getAgPos(agentId);
        Location nearest = model.findNearestTarget(current);
        if (nearest != null) {
            return moveAgent(agentId, nearest.x, nearest.y);
        }
        return false;
    }

    @Override
    public void stop() {
        super.stop();
    }
}
