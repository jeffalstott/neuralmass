function V2BOLD(channel, filename, directory)
disp(['Calculating BOLD for channel: ',channel]);
file = strcat(directory, filename)
info = h5info(file, '/V');
n = info.Dataspace.Size(2);

i = str2num(channel)+1;
Y = h5read(file, '/V', [i 1], [1 n]);
Ybold = Yall_bold(Y)';

tic;
disp(['Writing channel: ', channel]);
output_filename = strcat('BOLDchan', channel,'_',filename)
output_file = strcat(directory, output_filename)
n = size(Ybold,2);
h5create(output_file, '/BOLD', [1 n])
h5write(output_file, '/BOLD', Ybold, [1 1], [1 n]);
toc;
