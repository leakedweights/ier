package env.farm;

import jason.environment.grid.GridWorldModel;
import jason.environment.grid.Location;

import java.util.Random;

public class FarmModel extends GridWorldModel {

    public static final int GRID_SIZE = 25;
    public static final int PATHWAY = 0;
    public static final int FIELD = 1;
    public static final int PLANT = 2;
    public static final int DRONE = 3;
    public static final int UNPLANTED = 4;

    private static final int MATURITY_AGE = 30;
    private static final int WATERING_INTERVAL = 5;
    private static final double DEATH_PROBABILITY = 0.05;
    private static final double HEALTH_DECREASE = 0.10;

    private double[][] plantHealth;
    private int[][] plantAge;
    private boolean[][] plantWatered;
    private int[][] lastWatered;

    private Random random;

    public FarmModel(int size) {
        super(size, size, 3);
        plantHealth = new double[size][size];
        plantAge = new int[size][size];
        plantWatered = new boolean[size][size];
        lastWatered = new int[size][size];
        random = new Random();
    }

    public void initGrid() {
        for (int x = 0; x < width; x++) {
            for (int y = 0; y < height; y++) {
                if (x % 2 == 0 || y % 2 == 0) {
                    add(PATHWAY, x, y);
                } else {
                    add(FIELD, x, y);
                    add(UNPLANTED, x, y);
                }
            }
        }

        setAgPos(0, new Location(0, 0));
        setAgPos(1, new Location(0, 24));
        setAgPos(2, new Location(24, 0));
    }

    @Override
    public boolean isFree(int x, int y) {
        return !hasObject(DRONE, x, y);
    }

    public boolean moveDrone(int agentId, Location dest) {
        Location current = getAgPos(agentId);
        if (isFree(dest.x, dest.y)) {
            setAgPos(agentId, dest);
            return true;
        }
        return false;
    }

    public boolean survey(Location loc) {
        int x = loc.x;
        int y = loc.y;
        if (hasObject(UNPLANTED, x, y)) {
            return true;
        }
        if (hasObject(PLANT, x, y)) {
            if (plantHealth[x][y] < 1.0 || !plantWatered[x][y]) {
                return true;
            }
        }
        return false;
    }

    public Location findNearestTarget(Location current) {
        int minDist = Integer.MAX_VALUE;
        Location nearest = null;
        for (int x = 0; x < width; x++) {
            for (int y = 0; y < height; y++) {
                if (survey(new Location(x, y))) {
                    int dist = Math.abs(current.x - x) + Math.abs(current.y - y);
                    if (dist < minDist) {
                        minDist = dist;
                        nearest = new Location(x, y);
                    }
                }
            }
        }
        return nearest;
    }

    public void plant(int x, int y) {
        remove(UNPLANTED, x, y);
        add(PLANT, x, y);
        plantHealth[x][y] = 1.0;
        plantAge[x][y] = 0;
        plantWatered[x][y] = true;
        lastWatered[x][y] = 0;
    }

    public void water(int x, int y) {
        plantWatered[x][y] = true;
        lastWatered[x][y] = 0;
    }

    public void updatePlantHealth(int x, int y, double health) {
        plantHealth[x][y] = health;
    }

    public void incrementPlantAge(int x, int y) {
        plantAge[x][y]++;
        lastWatered[x][y]++;
        if (lastWatered[x][y] > WATERING_INTERVAL) {
            plantHealth[x][y] -= HEALTH_DECREASE;
            if (plantHealth[x][y] < 0)
                plantHealth[x][y] = 0;
        }
        if (random.nextDouble() < DEATH_PROBABILITY) {
            plantHealth[x][y] = 0; // Plant dies
        }
    }

    public boolean isPlantSickOrDied(int x, int y) {
        return plantHealth[x][y] < 0.5;
    }

    public boolean isMature(int x, int y) {
        return plantAge[x][y] >= MATURITY_AGE;
    }

    public void nextIteration() {
        for (int x = 0; x < width; x++) {
            for (int y = 0; y < height; y++) {
                if (hasObject(PLANT, x, y)) {
                    incrementPlantAge(x, y);
                }
            }
        }
    }
}
