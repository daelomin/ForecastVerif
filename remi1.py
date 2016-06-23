#import CompareGrids 

#exec("/home/remi/GIT/ForecastVerif/CompareGrids.py")

from tools import grid_tools


GLOB0500=grid_tools.GridDefinition("GLOB0500",-180.0,-90.0,180.0,90.0)

GLOB1000=grid_tools.GridDefinition("GLOB1000",0.0,-90.0,360.0,90.0)

grid_tools.grid_intersection(GLOB0500, GLOB1000)

