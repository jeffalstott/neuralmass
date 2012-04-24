rn = 1
% COMPUTE BOLD SIGNAL ==============================
% using the nonlinear balloon-windkessel model...
disp('beginning bold calculation ...');
tic;
Ybold = Yall_bold(Y);
Ybold = Ybold';
toc;

% COMPUTE SOME BASIC BOLD SIGNAL ANALYSES ==========
% settings for bold averages
T = size(Ybold,2);
xsec = 2000; xgap = 500;        % in msec, window size and spacing
t0 = [1:xgap:T-xsec+1];
te = [xsec:xgap:T];
% initialize...
Ybold_w = zeros(N,length(t0));
% compute bold averages
for w=1:length(t0)
    Ybold_w(:,w) = mean(Ybold(:,t0(w):te(w)),2);
end;

% remove NaNs, get average bold signal over whole brain, and regress out
Ybold_w(isnan(Ybold_w)) = 0;
Ybold_w_mean = mean(Ybold_w);
Ybold_w_reg = zeros(N,length(t0));
for i=1:N
    [B,BINT,Ybold_w_reg(i,:)] = regress(Ybold_w(i,:)',Ybold_w_mean');
end;

% get BOLD cross-correlations
[C,R] = corr(Ybold_w_reg');

% save processed BOLD data
eval(['save ',rn,'_Ybold_proc Ybold_w Ybold_w_mean Ybold_w_reg C R T xsec xgap']);
disp('... all done ...');
