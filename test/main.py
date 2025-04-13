import sys
sys.path.append('./src/')

from pipeline import *

target = {"ID":33398702,"ra":344.420449437894,"dec":-8.06747255937119,"sector":42,"camera":1,"ccd":1}
# print(process_target(target))
print(lambda_handler(target, None))
