import json
from pprint import pprint 

with open('config.json') as json_data_file:
    data = json.load(json_data_file)
    
pprint(data)



##  WRITE

with open('config_write.json', 'w') as outfile:
    json.dump(data, outfile) 