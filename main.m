clear all
close all

%load macaque47
%name = 'M47'
load DSI_enhanced
CIJ = CIJ_resampled_average;
dataset_name = 'Hagmann'

%
%R = size(CIJr,3);
I = 8;  % repeats

Call = zeros(size(CIJ,1),size(CIJ,2),I);

for i=1:I
    rn = [name,'_',num2str(i)];
    eval(['C = sim_function(rn,CIJ);']);
    Call(:,:,i) = C;
    save Call
end;

