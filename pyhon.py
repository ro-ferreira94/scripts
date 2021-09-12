#! /usr/bin/python
import random
import time
list = ['João','Rodrigo','Mark','Kaue','Sandro','Gustavo']
list2 = ['João','Rodrigo','Mark','Kaue','Sandro','Gustavo']
item = random.choice(list)
item2 = random.choice(list2)
print("Sorteando...")
time.sleep(1)
print("Quem irá buscar : ", item)
print("Sorteando...")
time.sleep(1)
print("Quem irá pagar : " , item2)