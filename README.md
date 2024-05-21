# Agricultural Agents

## Setup

### Installation
1. Download & extract Jason: https://sourceforge.net/projects/jason/
2. Add `jason/bin` to PATH

### Start project
```bash
cd agrobots
jason agrobots.mas2j -v
```

## Project outline

Agrobots simulates an autonomous agricultural system that is capable of sustaining a farm, involving planting and harvesting specific types of crops, watering fields, and surveying for dead plants.

**Types of agents:** survey drones, irrigation robots, and harvesters.

The Farm consists of a `25x25` rectangular grid, **every second row and column is part of a patio** for the irrigation robots and harvesters. All other cells are fields where crops can be planted.

Assuming everything goes well, a crop should become mature in **30 iterations**. Crops should be **watered at least every 5 iterations**. If the plants in a specific field are left unwatered for more than 5 iterations, its **health decreases by 10%** each iteration until the next irrigation. In a single iteration, **each plant dies with `p=0.05`**.

### Survey Drones

### Planter-Harvesters

### Irrigation Robots

