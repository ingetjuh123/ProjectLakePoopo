import pycurl
from StringIO import StringIO

def download(url, filename):
    fp = open(filename, "wb")
    c = pycurl.Curl()
    c.setopt(c.URL, url)
    c.setopt(c.WRITEDATA, fp)
    c.perform()
    c.close()
    fp.close()
    
download('http://storage.googleapis.com/earthengine-public/landsat/L8/233/073/LC82330732013310LGN00.tar.bz', './data/LC82330732013310LGN00.tar.bz')
download('http://storage.googleapis.com/earthengine-public/landsat/L8/233/073/LC82330732015284LGN00.tar.bz', './data/LC82330732015284LGN00.tar.bz')