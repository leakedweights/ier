package env.farm;

import jason.asSyntax.*;
import jason.environment.Environment;
import jason.environment.grid.GridWorldModel;
import jason.environment.grid.GridWorldView;
import jason.environment.grid.Location;

import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;

import java.util.*;
import java.util.logging.Logger;

public class FarmEnvironment extends Environment {

    /* constants */

    public static final int GRID_SIZE = 17;

    public static final int FIELD = 32;
    public static final int PLANTED = 64;
    public static final int WATERED = 128;
    public static final int DEAD = 256;
    public static final int HARVESTABLE = 512;

    private static final int MATURITY_AGE = 300;
    private static final int WATERING_INTERVAL = 5;
    private static final double DEATH_PROBABILITY = 0.05;
    private static final double HEALTH_DECREASE = 0.10;

    private static final int NUM_DRONES = 3;
    private static final int HARVESTER_ID = 3;
    private static final int IRRIGATION_ROBOT_ID = 4;
    private static final int AUCTIONEER_ID = 5;

    /* commands */

    static Logger logger = Logger.getLogger(FarmEnvironment.class.getName());

    private FarmModel model;
    private FarmView  view;

    @Override
    public void init(String[] args) {
        model = new FarmModel();
        view  = new FarmView(model);
        model.setView(view);
        updatePercepts();
    }

    @Override
    public boolean executeAction(String ag, Structure action) {
        int agentId = getAgentId(ag);
        try {
            if (action.getFunctor().equals("move_towards")) {
                int x = (int) ((NumberTerm) action.getTerm(0)).solve();
                int y = (int) ((NumberTerm) action.getTerm(1)).solve();
                model.moveTowards(agentId, x, y);
            } else if (action.getFunctor().equals("plant")) {
                int x = (int) ((NumberTerm) action.getTerm(0)).solve();
                int y = (int) ((NumberTerm) action.getTerm(1)).solve();
                model.plant(x, y);
            } else if (action.getFunctor().equals("harvest")) {
                int x = (int) ((NumberTerm) action.getTerm(0)).solve();
                int y = (int) ((NumberTerm) action.getTerm(1)).solve();
                model.harvest(x, y);
            } else if (action.getFunctor().equals("water")) {
                int x = (int) ((NumberTerm) action.getTerm(0)).solve();
                int y = (int) ((NumberTerm) action.getTerm(1)).solve();
                model.water(x, y);
            } else if (action.getFunctor().equals("survey")) {
                int x = (int) ((NumberTerm) action.getTerm(0)).solve();
                int y = (int) ((NumberTerm) action.getTerm(1)).solve();
                model.survey(ag, x, y);
            } else {
                return super.executeAction(ag, action);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        updatePercepts();
        //SIMULATE GROWTH
        model.simulatePlanGrow();

        try {
            Thread.sleep(200);
        } catch (Exception e) {
        }
        informAgsEnvironmentChanged();
        model.simulatePlantGrowth();
        return true;
    }

    void updatePercepts() {
        clearPercepts();
    
        Location harvesterLocation = model.getAgPos(HARVESTER_ID);
        addPercept(Literal.parseLiteral("pos(harvester" + "," + harvesterLocation.x + "," + harvesterLocation.y + ")"));

       
        Location irrigationRobotLocation = model.getAgPos(IRRIGATION_ROBOT_ID);
        addPercept(Literal.parseLiteral("pos(irrigation_robot" + "," + irrigationRobotLocation.x + "," + irrigationRobotLocation.y + ")"));
    

        for (int i = 0; i < NUM_DRONES; i++) {       
            Location droneLocation = model.getAgPos(i);
            addPercept(Literal.parseLiteral("pos(drone" + (i + 1) + "," + droneLocation.x + "," + droneLocation.y + ")"));
        }

        for (int x = 0; x < GRID_SIZE; x++) {
            for (int y = 0; y < GRID_SIZE; y++) {
                if (model.hasObject(FIELD, x, y)) {
                    addPercept("auctioneer", Literal.parseLiteral("field(" + x + "," + y + ")"));
                }
            }
        }
    }

    private int getAgentId(String agName) {
        try {
            if (agName.startsWith("drone")) {
                String idStr = agName.replace("drone", "");
                int id = Integer.parseInt(idStr);
                return id - 1;
            } else if (agName.equals("harvester")) {
                return 3;
            } else if (agName.equals("irrigation_robot")) {
                return 4;
            } else if (agName.equals("auctioneer")) {
                return 5;
            } else {
                throw new IllegalArgumentException("Unknown agent name: " + agName);
            }
        } catch (NumberFormatException e) {
            System.err.println("Failed to parse agent ID from name: " + agName);
            e.printStackTrace();
            throw e;
        }
    }

    class FarmModel extends GridWorldModel {

        private double[][] plantHealth;
        private int[][] plantAge;
        private int[][] lastWatered;
        private Map<Integer, Location> lastLocations;

        Random random = new Random(System.currentTimeMillis());

        private FarmModel() {
            super(GRID_SIZE, GRID_SIZE, 6);

            plantHealth = new double[GRID_SIZE][GRID_SIZE];
            plantAge = new int[GRID_SIZE][GRID_SIZE];
            lastWatered = new int[GRID_SIZE][GRID_SIZE];
            lastLocations = new HashMap<>();

            try {
                setAgPos(0, 0, 0); // Drone 1 at (0, 0)
                setAgPos(1, GRID_SIZE - 1, 0); // Drone 2 at (25, 0)
                setAgPos(2, 0, GRID_SIZE - 1); // Drone 3 at (0, 25)
                
                setAgPos(IRRIGATION_ROBOT_ID, GRID_SIZE / 2, GRID_SIZE / 2); // Irrigation robot at the center
                setAgPos(HARVESTER_ID, GRID_SIZE - 1, GRID_SIZE - 1); // Harvester at the bottom right corner
    
            } catch (Exception e) {
                e.printStackTrace();
            }
    
            for (int x = 0; x < GRID_SIZE; x++) {
                for (int y = 0; y < GRID_SIZE; y++) {
                    if (x % 2 != 0 && y % 2 != 0) {
                        add(FIELD, x, y);
                    } 
                }
            }
        }

        @Override
        public Location getAgPos(int agentId) {
            Location agPos = super.getAgPos(agentId);
            if(agPos == null) {
                logger.info("Agpos null for agent " + agentId);
                agPos = lastLocations.get(agentId);
            }
            return agPos;
        }

        @Override
        public void setAgPos(int agentId, Location loc) {
            lastLocations.remove(agentId);
            lastLocations.put(agentId, loc);
            super.setAgPos(agentId, loc);
        }

        @Override
        public void setAgPos(int agentId, int x, int y) {
           setAgPos(agentId, new Location(x, y));
        }

        void plant(int x, int y) {
            if (hasObject(FIELD, x, y)) {
                plantHealth[x][y] = 100;
                plantAge[x][y] = 0;
                add(PLANTED, x, y);
                plantAge[x][y] = 0;
                logger.info("Planted: (" + x + "," + y + ")");
                updatePercepts(); // Update percepts after planting
            }
        }
        
        void harvest(int x, int y) {
            plantHealth[x][y] = 100;
            plantAge[x][y] = 0;
            plantAge[x][y] = 0;
            remove(HARVESTABLE, x, y);
            remove(PLANTED, x, y);
            if (hasObject(WATERED, x, y)) {
                remove(WATERED, x, y);
            }
        }

    
        void water(int x, int y) {
            if (hasObject(PLANTED, x, y)) {
                add(WATERED, x, y);
            }
        }

        void survey(String agentName, int x, int y) {
            String fieldState;
            double fieldHealth = plantHealth[x][y];

            if (model.hasObject(PLANTED, x, y)) {
                fieldState = "PLANTED";
            } else if (model.hasObject(WATERED, x, y)) {
                fieldState = "WATERED";
            } else if (model.hasObject(HARVESTABLE, x, y)) {
                fieldState = "HARVESTABLE";
            } else {
                fieldState = "EMPTY";
                fieldHealth = 0;
            }
        
            Literal plantStatusPercept = Literal.parseLiteral("plant_status(" + x + "," + y + "," + "\"" + fieldState + "\"" + "," + fieldHealth + ")");
            addPercept(agentName, plantStatusPercept);
        }
    
        void simulatePlantDeath_Random() {
            for (int x = 0; x < GRID_SIZE; x++) {
                for (int y = 0; y < GRID_SIZE; y++) {
                    if (hasObject(WATERED, x, y) && random.nextDouble() < DEATH_PROBABILITY) {
                        remove(WATERED, x, y);
                        add(DEAD, x, y);
                    }
                }
            }
        }

        void simulatePlantGrowth() {
            for (int x = 0; x < GRID_SIZE; x++) {
                for (int y = 0; y < GRID_SIZE; y++) {
                    if (hasObject(PLANTED, x, y)) {
                        plantAge[x][y]++;
                        if (plantAge[x][y] >= MATURITY_AGE) {
                            remove(PLANTED, x, y);
                            add(HARVESTABLE, x, y);
                        }
                    }
                }
            }
        }

        void moveTowards(int agentId, int x, int y) throws Exception {
            Location loc = getAgPos(agentId);
            if (loc.x < x)
                loc.x++;
            else if (loc.x > x)
                loc.x--;
            if (loc.y < y)
                loc.y++;
            else if (loc.y > y)
                loc.y--;
            setAgPos(agentId, loc);
        }
    }

    class FarmView extends GridWorldView {

        public FarmView(FarmModel model) {
            super(model, "Farm World", 600);
            defaultFont = new Font("Arial", Font.BOLD, 14);
            setVisible(true);
            repaint();
        }
    
        @Override
        public void draw(Graphics g, int x, int y, int object) {
            switch (object) {
                case FarmEnvironment.FIELD:
                    drawField(g, x, y);
                    break;
                case FarmEnvironment.PLANTED:
                    drawPlanted(g, x, y);
                    break;
                case FarmEnvironment.WATERED:
                    drawWatered(g, x, y);
                    break;
                case FarmEnvironment.DEAD:
                    drawDead(g, x, y);
                    break;
                case FarmEnvironment.HARVESTABLE:
                    drawHarvestable(g, x, y);
                    break;
            }
        }
    
        @Override
        public void drawAgent(Graphics g, int x, int y, Color c, int id) {
            String label;
            if (id < 3) {
                label = "D" + (id + 1);
                c = Color.orange;
            } else if (id == IRRIGATION_ROBOT_ID) {
                label = "I";
                c = Color.blue;
            } else if (id == HARVESTER_ID) {
                label = "H";
                c = Color.magenta;
            } else {
                label = "A" + (id + 1);
                c = Color.gray;
            }
    
            super.drawAgent(g, x, y, c, -1);
            g.setColor(Color.black);
            super.drawString(g, x, y, defaultFont, label);
        }
    
        private void drawField(Graphics g, int x, int y) {
            Color brown = new Color(188, 143, 143);
            g.setColor(brown);
            g.fillRect(x * cellSizeW, y * cellSizeH, cellSizeW, cellSizeH);
        }
    
        private void drawPlanted(Graphics g, int x, int y) {
            Color green = new Color(60, 179, 113);
            g.setColor(green);
            g.fillRect(x * cellSizeW, y * cellSizeH, cellSizeW, cellSizeH);
        }
    
        private void drawWatered(Graphics g, int x, int y) {
            g.setColor(Color.blue);
            g.fillRect(x * cellSizeW, y * cellSizeH, cellSizeW, cellSizeH);
        }
    
        private void drawDead(Graphics g, int x, int y) {
            g.setColor(Color.red);
            g.fillRect(x * cellSizeW, y * cellSizeH, cellSizeW, cellSizeH);
        }

        private void drawHarvestable(Graphics g, int x, int y) {
            g.setColor(Color.orange);
            g.fillRect(x * cellSizeW, y * cellSizeH, cellSizeW, cellSizeH);
        }
    }
}