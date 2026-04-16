import matplotlib.pyplot as plt
from matplotlib import colormaps
import tikzplotlib

list(colormaps)

x = []
x += (4*["Montgomery"])
x += (5*["Barrett"])
x += (2*["Bitwise"])
x += (3*["K-reduction"])

y = [890, 654, 564, 552, 1157, 657, 494, 334, 303, 322, 308, 307, 296, 269]
c= y
plt.scatter(x,y, c=c, s=72, marker=(4, 1, 45))
cmap = plt.get_cmap('nipy_spectral')
plt.set_cmap(cmap)
plt.xlabel("Butterfly Architecture", fontweight=800)
plt.ylabel("Arithmetic Cost", fontweight=800)
#plt.show()
tikzplotlib.save("../ArithmeticCostOfModularMult.tex")
#data = {'apple': 10, 'orange': 15, 'lemon': 5, 'lime': 20}
#names = list(data.keys())
#values = list(data.values())

#fig, axs = plt.subplots(1, 3, figsize=(9, 3), sharey=True)
#axs[0].bar(names, values)
#axs[1].scatter(names, values)
#axs[2].plot(names, values)
#fig.suptitle('Categorical Plotting')