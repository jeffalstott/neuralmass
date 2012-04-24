function BOLD_biowulf(i)
i = str2num(i)
i = i+1
Y = h5read('/data/alstottj/Lausanne/Hagmann_1.h5', '/V', [i 1], [1 1200000]);
Ybold = Yall_bold(Y)';
n = size(Ybold,2)
h5write('/data/alstottj/Lausanne/Hagmann_1.h5', '/BOLD', Ybold, [i 1], [1 n])
