function H5_V2BOLD(channel, filename)
i = str2num(channel)
i = i+1
info = h5info(filename, '/V')
n = info.Dataspace.Size(2)

Y = h5read(filename, '/V', [i 1], [1 n]);
Ybold = Yall_bold(Y)';
n = size(Ybold,2)
h5write(filename, '/BOLD', Ybold, [i 1], [1 n])
