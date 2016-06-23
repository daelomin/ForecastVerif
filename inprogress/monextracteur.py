import sys,os


#           Args        1       2       3           4       5       6
##      le script       MODEL   GRID    START       END   somevar  extract_dir
#python monextracteur.py PGFSUS GLOB0500 20150123 20150322 dummy /tmp/extract_model 
if __name__ == "__main__":
    MODEL = sys.argv[1]
    GRID = sys.argv[2]
    START = sys.argv[3]
    END = sys.argv[4]
    DUMMYVAR = sys.argv[5]
    EXTRACT_DIR = sys.argv[6]
    
    print("Processing model %s on grid %s" % (MODEL, GRID) )
    
     
    
