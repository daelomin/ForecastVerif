import sys


## for python 2 code
if sys.version_info >= (3,0):
    sys.stdout.write("Sorry, requires Python 2.x, not Python 3.x\n")
    print("Found Python "+str(sys.version_info.major)+'.'+str(sys.version_info.minor) +'.'+str(sys.version_info.micro))
    sys.exit(1)

## for python 3 code
if sys.version_info < (3,0):
    sys.stdout.write("Sorry, requires Python 3.x, not Python 2.x\n")
    print("Found Python "+str(sys.version_info.major)+'.'+str(sys.version_info.minor) +'.'+str(sys.version_info.micro))

    sys.exit(1)



