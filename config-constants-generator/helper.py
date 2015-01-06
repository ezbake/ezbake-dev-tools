from __future__ import print_function

from ezconfiguration_constants_generator import HelperPlugin


class Helper(HelperPlugin):
    def generate(self, group, constants):
        """Example helper"""
        print(group)
        for c in constants:
            print(c)
