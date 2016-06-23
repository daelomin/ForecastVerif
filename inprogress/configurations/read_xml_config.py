## pip install BeautifulSoup4 (needed for python3)
#  https://www.crummy.com/software/BeautifulSoup/bs4/doc
#
# Also required a "pip install lxml"
from bs4 import BeautifulSoup

with open("config_read.xml") as f:
    content = f.read()

#y = BeautifulSoup(content, "xml.parser")
#y = BeautifulSoup(content, "lxml")

## the only currently supported XML parser
y = BeautifulSoup(content, "lxml-xml")
#y = BeautifulSoup(content, "html.parser")


## Access different elements of the xml 
print(y.mysql.host.contents[0])
#for tag in y.other.preprocessing_queue:
for tag in y.other:

    print(tag)