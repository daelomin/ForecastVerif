from BeautifulSoup import BeautifulSoup

with open("config.xml") as f:
    content = f.read()

y = BeautifulSoup(content)
print(y.mysql.host.contents[0])
for tag in y.other.preprocessing_queue:
    print(tag)