#!/usr/bin/env python

## this version uses configparser 3.5  & parses the config file
#  as a string (hence no need for the io.BytesIO method)
 

#import configparser
import configparser
#import io

# Load the configuration file
#with open("configxcw.yml") as f:
with open("config_read.ini") as f:
    sample_config = f.read()
config = configparser.RawConfigParser(allow_no_value=True)
#config = configparser.rawconfigparser(allow_no_value=True)

## readfp deprecated since configparser 3.2 (using 3.5)
#config.readfp(io.BytesIO(sample_config))
#print(sample_config)
#config.read_file(io.BytesIO(sample_config))

config.read_string(sample_config)

# List all contents
print("List all contents")
for section in config.sections():
    print("Section: %s" % section)
    for options in config.options(section):
        print("x %s:::%s:::%s" % (options,
                                  config.get(section, options),
                                  str(type(options))))

# Print some contents
print("\nPrint some contents")
print(config.get('other', 'use_anonymous'))  # Just get the value
print(config.getboolean('other', 'use_anonymous'))  # You know the datatype?
