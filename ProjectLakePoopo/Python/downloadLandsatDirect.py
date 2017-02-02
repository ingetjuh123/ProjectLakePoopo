## Load Libraries
import pycurl
from StringIO import StringIO

## Create Download Function with pycurl
def download(url, filename):
    print("Download Started ...")
    fp = open(filename, "wb")
    c = pycurl.Curl()
    c.setopt(c.URL, url)
    c.setopt(c.WRITEDATA, fp)
    c.perform()
    c.close()
    fp.close()
    print("Download Finished ...")

