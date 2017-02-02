## Load Libraries
import pycurl
from StringIO import StringIO

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
