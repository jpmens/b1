
import os

CONFIG=os.getenv('M2SCONFIG', 'settings.py')

class Config(object):
    def __init__(self, filename=CONFIG):
        self.config = {}
        execfile(filename, self.config)
        
    def get(self, key, default=None):
        return self.config.get(key, default)

if __name__ == '__main__':
    cf = Config()
    print cf.get('mqtt_broker', 'xx')
