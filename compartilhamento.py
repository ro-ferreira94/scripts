import os

path = '../Roro' # Variavel da pasta de rede
folders = []
f = []

for r, d, f in os.walk(path):
    for folder in d:
        folders.append(os.path.join(r, folder))
for f in folders:
    print(f)
if f in folders:
    print("funcionando")
else:
    print("nao ta funcionando")
