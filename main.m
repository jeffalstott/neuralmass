clear all
close all

load macaque47
name = 'M47'
%
%R = size(CIJr,3);
I = 8;  % repeats

Call = zeros(47,47,I);

for i=1:I
    rn = [name,'_',num2str(i)];
    eval(['C = sim_function(rn,CIJ);']);
    Call(:,:,i) = C;
    save Call
end;

