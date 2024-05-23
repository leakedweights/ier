package env.farm;

import jason.asSyntax.*;
import jason.environment.Environment;
import jason.environment.grid.GridWorldModel;
import jason.environment.grid.GridWorldView;
import jason.environment.grid.Location;

import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;
import java.util.Random;
import java.util.logging.Logger;

public class FarmEnvironment extends Environment {

    /* constants */

    public static final int GRID_SIZE = 25;
    public static final int GARB  = 16;

    public static final int FIELD = 32;
    public static final int PLANTED = 64;
    public static final int WATERED = 128;
    public static final int DEAD = 256;

    private static final int MATURITY_AGE = 30;
    private static final int WATERING_INTERVAL = 5;
    private static final double DEATH_PROBABILITY = 0.05;
    private static final double HEALTH_DECREASE = 0.10;

    /* commands */

    public static final Term    ns = Literal.parseLiteral("next(slot)");
    public static final Term    pg = Literal.parseLiteral("pick(garb)");
    public static final Term    dg = Literal.parseLiteral("drop(garb)");
    public static final Term    bg = Literal.parseLiteral("burn(garb)");
    public static final Literal g1 = Literal.parseLiteral("garbage(r1)");
    public static final Literal g2 = Literal.parseLiteral("garbage(r2)");

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
        logger.info(ag + " doing: " + action);

        int agentId = getAgentId(ag);
        try {
            if (action.equals(ns)) {
                model.nextSlot();
            } else if (action.getFunctor().equals("move_towards")) {
                int x = (int) ((NumberTerm) action.getTerm(0)).solve();
                int y = (int) ((NumberTerm) action.getTerm(1)).solve();
                model.moveTowards(agentId, x, y);
            } else if (action.getFunctor().equals("plant")) {
                int x = (int) ((NumberTerm) action.getTerm(0)).solve();
                int y = (int) ((NumberTerm) action.getTerm(1)).solve();
                model.plant(x, y);
            } else if (action.getFunctor().equals("water")) {
                int x = (int) ((NumberTerm) action.getTerm(0)).solve();
                int y = (int) ((NumberTerm) action.getTerm(1)).solve();
                model.water(x, y);
            } else if (action.getFunctor().equals("survey")) {
                int x = (int) ((NumberTerm) action.getTerm(0)).solve();
                int y = (int) ((NumberTerm) action.getTerm(1)).solve();
                model.survey(agentId, x, y);
            } else {
                return false;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        updatePercepts();

        try {
            Thread.sleep(200);
        } catch (Exception e) {
        }
        informAgsEnvironmentChanged();
        return true;
    }


    void updatePercepts() {
        clearPercepts();
    
        Location r1Loc = model.getAgPos(0);
        Location r2Loc = model.getAgPos(1);
    
        Literal pos1 = Literal.parseLiteral("pos(r1," + r1Loc.x + "," + r1Loc.y + ")");
        Literal pos2 = Literal.parseLiteral("pos(r2," + r2Loc.x + "," + r2Loc.y + ")");
    
        addPercept(pos1);
        addPercept(pos2);
    
        for (int x = 0; x < GRID_SIZE; x++) {
            for (int y = 0; y < GRID_SIZE; y++) {
                if (model.hasObject(FIELD, x, y)) {
                    if (model.hasObject(PLANTED, x, y)) {
                        addPercept(Literal.parseLiteral("planted(" + x + "," + y + ")"));
                    }
                    if (model.hasObject(WATERED, x, y)) {
                        addPercept(Literal.parseLiteral("watered(" + x + "," + y + ")"));
                    }
                    if (model.hasObject(DEAD, x, y)) {
                        addPercept(Literal.parseLiteral("dead(" + x + "," + y + ")"));
                    }
                }
            }
        }
    }

    private int getAgentId(String agName) {
        return Integer.parseInt(agName.replace("agent", "")) - 1;
    }

    class FarmModel extends GridWorldModel {

        private double[][] plantHealth;
        private int[][] plantAge;
        private boolean[][] plantWatered;
        private int[][] lastWatered;

        boolean r1HasGarb = false; // whether r1 is carrying garbage or not

        Random random = new Random(System.currentTimeMillis());

        private FarmModel() {
            super(GRID_SIZE, GRID_SIZE, 2);

            plantHealth = new double[GRID_SIZE][GRID_SIZE];
            plantAge = new int[GRID_SIZE][GRID_SIZE];
            plantWatered = new boolean[GRID_SIZE][GRID_SIZE];
            lastWatered = new int[GRID_SIZE][GRID_SIZE];

            try {
                setAgPos(0, 0, 0);

                Location r2Loc = new Location(GRID_SIZE/2, GRID_SIZE/2);
                setAgPos(1, r2Loc);
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

        void plant(int x, int y) {
            if (hasObject(FIELD, x, y)) {
                add(PLANTED, x, y);
            }
        }
    
        void water(int x, int y) {
            if (hasObject(PLANTED, x, y)) {
                add(WATERED, x, y);
            }
        }

        void survey(int agentId, int x, int y) {

        }
    
        void simulatePlantDeath() {
            for (int x = 0; x < GRID_SIZE; x++) {
                for (int y = 0; y < GRID_SIZE; y++) {
                    if (hasObject(WATERED, x, y) && random.nextDouble() < DEATH_PROBABILITY) {
                        remove(WATERED, x, y);
                        add(DEAD, x, y);
                    }
                }
            }
        }

        void nextSlot() throws Exception {
            Location r1 = getAgPos(0);
            r1.x++;
            if (r1.x == getWidth()) {
                r1.x = 0;
                r1.y++;
            }
            // finished searching the whole grid
            if (r1.y == getHeight()) {
                return;
            }
            setAgPos(0, r1);
            setAgPos(1, getAgPos(1)); // just to draw it in the view
        }

        void moveTowards(int agentId, int x, int y) throws Exception {
            Location loc = getAgPos(0);
            if (loc.x < x)
                loc.x++;
            else if (loc.x > x)
                loc.x--;
            if (loc.y < y)
                loc.y++;
            else if (loc.y > y)
                loc.y--;
            setAgPos(agentId, loc);
            // for each other agent: set their own agPos
        }

        void pickGarb() {
            if (model.hasObject(GARB, getAgPos(0))) {
                remove(GARB, getAgPos(0));
                r1HasGarb = true;
            }
        }
        void dropGarb() {
            if (r1HasGarb) {
                r1HasGarb = false;
                add(GARB, getAgPos(0));
            }
        }
        void burnGarb() {
            // r2 location has garbage
            if (model.hasObject(GARB, getAgPos(1))) {
                remove(GARB, getAgPos(1));
            }
        }
    }

    class FarmView extends GridWorldView {

        public FarmView(FarmModel model) {
            super(model, "Farm World", 600);
            defaultFont = new Font("Arial", Font.BOLD, 18);
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
            }
        }
    
        @Override
        public void drawAgent(Graphics g, int x, int y, Color c, int id) {
            String label = "R" + (id + 1);
            c = Color.blue;
            if (id == 0) {
                c = Color.yellow;
                if (((FarmModel) model).r1HasGarb) {
                    label += " - G";
                    c = Color.orange;
                }
            }
            super.drawAgent(g, x, y, c, -1);
            if (id == 0) {
                g.setColor(Color.black);
            } else {
                g.setColor(Color.white);
            }
            super.drawString(g, x, y, defaultFont, label);
            // repaint();
        }
    
        private void drawField(Graphics g, int x, int y) {
            g.setColor(Color.green);
            g.fillRect(x * cellSizeW, y * cellSizeH, cellSizeW, cellSizeH);
        }
    
        private void drawPlanted(Graphics g, int x, int y) {
            g.setColor(Color.orange);
            g.fillRect(x * cellSizeW, y * cellSizeH, cellSizeW, cellSizeH);
            drawString(g, x, y, defaultFont, "P");
        }
    
        private void drawWatered(Graphics g, int x, int y) {
            g.setColor(Color.blue);
            g.fillRect(x * cellSizeW, y * cellSizeH, cellSizeW, cellSizeH);
            drawString(g, x, y, defaultFont, "W");
        }
    
        private void drawDead(Graphics g, int x, int y) {
            g.setColor(Color.red);
            g.fillRect(x * cellSizeW, y * cellSizeH, cellSizeW, cellSizeH);
            drawString(g, x, y, defaultFont, "D");
        }
    
    }
}
