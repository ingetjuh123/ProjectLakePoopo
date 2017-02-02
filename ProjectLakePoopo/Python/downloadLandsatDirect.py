## Load Libraries
import pycurl
from StringIO import StringIO

## Give URLS
urls=['http://storage.googleapis.com/earthengine-public/landsat/L8/233/073/LC82330732013310LGN00.tar.bz','http://storage.googleapis.com/earthengine-public/landsat/L8/233/073/LC82330732015284LGN00.tar.bz']

## Create Download Function with pycurl
## Create Filepath from Filename Landsat Archive
def download(url):
    print("Download Started ...")
    filename = url[-28:]
    filepath = "./data/" + filename
    fp = open(filepath, "wb")
    c = pycurl.Curl()
    c.setopt(c.URL, url)
    c.setopt(c.WRITEDATA, fp)
    c.perform()
    c.close()
    fp.close()
    print("Download Finished ...")

## Run Download Multiple Time For Each Url
for url in urls:
    download(url)