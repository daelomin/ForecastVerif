#!/home/remi/py3env/bin/python

## Force Python3 
from planar import BoundingBox,Affine
from shapely.geometry import Polygon

from pprint import pprint as pp
import q



class GridDefinition(object):
    def __init__(self,name,bottom_lat,bottom_lon,top_lat,top_lon):
        self.name = name
        self.bottom_lat = bottom_lat
        self.top_lat = top_lat
        self.bottom_lon = bottom_lon
        self.top_lon = top_lon

    #@staticmethod
    def grid(self):
        #"Define a grid"
        grid_list = [ self.bottom_lat, self.bottom_lon, self.top_lat, self.top_lon ]
        print("Defining grid %s and returning bbox as a list" % self.name )
        return grid_list

    def grid_tuple(self):
        #"Define a grid"
        grid_list_of_tuple = [ (self.bottom_lat, self.bottom_lon), (self.top_lat, self.top_lon) ]
        #print("Defining grid %s and returning bbox as a list of tuples" % self.name )
        return grid_list_of_tuple


def bbox_overlaps(bbox1,bbox2):
    blat1 = bbox1.min_point[1]
    blon1 = bbox1.min_point[0] 
    tlat1 = bbox1.max_point[1]   
    tlon1 = bbox1.max_point[0]  

    blat2 = bbox2.min_point[1]
    blon2 = bbox2.min_point[0] 
    tlat2 = bbox2.max_point[1] 
    tlon2 = bbox2.max_point[0] 

    width1 = bbox1.width
    height1 = bbox1.height
    width2 = bbox2.width
    height2 = bbox2.height

    blon_diff = blon1-blon2
    widthsum = width1+width2
    blat_diff = blat1-blat2
    heightsum = height1+height2

    #print(blon1,blon2,blon_diff," ",width1,width2,widthsum)
    #print(blat1,blat2,blat_diff," ",height1,height2,heightsum)


    return ( (abs(blon1-blon2) * 2 < ( width1+width2)) and
        (abs(blat1-blat2) * 2 < (height1+height2))  )


def bbox_to_poly(bbox):
    xmin = bbox.min_point[0]
    ymin = bbox.min_point[1]
    xmax = bbox.max_point[0]
    ymax = bbox.max_point[1]

    poly = Polygon([ (xmin,ymin), (xmin,ymax), (xmax,ymax), (xmax,ymin) ])
    return poly


def grid_intersection(grid1,grid2):

    bboxA_coordinates=grid1.grid_tuple()
    bboxB_coordinates=grid2.grid_tuple()

    bboxA = BoundingBox(bboxA_coordinates)
    bboxB = BoundingBox(bboxB_coordinates)

    polyA = bbox_to_poly(bboxA)
    polyB = bbox_to_poly(bboxB)

    #print("Two bbox intersect?", polyA.intersects(polyB) )
    inter = polyA.intersection(polyB)


    ## Inter contains the 5 vertex polygon. To convert it to a bbox
    #  use bounds() method to get only the coordinates
    #print(inter.bounds)
    #q.d()


    print(bboxA)
    print(bboxB)

    if bbox_overlaps(bboxA,bboxB): 
        print("Bboxes overlap")
        print(inter.bounds)
        return inter.bounds

    else:
        print("Bboxes do NOT overlap")
        return None



######################################################"
#   LAT-LON Definitions
######################################################"

aGG=GridDefinition("testGrid",-10.0,35.0,12.0,53.0)

## this one does not overlap with previous aGG
#bGG=GridDefinition("testGrid",10,42.0,19.0,95.0)

## this one does  overlap with previous aGG
bGG=GridDefinition("testGrid",-4.0,22.0,19.0,75.0)

#bGG=GridDefinition("testGrid",-15,62.0,19.0,95.0)



######################################################"
#   LON-LAT Definitions
######################################################"
aGG=GridDefinition("testGrid",-35.0,-10.0,53.0,22.0)

## this one does not overlap with previous aGG
#bGG=GridDefinition("testGrid",10,42.0,19.0,95.0)

## this one does  overlap with previous aGG
bGG=GridDefinition("testGrid",22.0,-4.0,75.0,19.0)


grid_intersection(aGG,bGG)
        
