function [C] = sim_function(rn,CIJ)

% set random number seed - comment out if desired
%rand('state',666);
%randn('state',666);

% global variables (shared with 'simvec')
global V1 V2 V3 V4 V5 V6 V7 gCa gK gL VK VL VCa I b ani aei aie aee phi V8 V9 gNa VNa ane nse rnmda N CM vs c k_in

% runname
%rn = 'M47_005_2';
init = 'randm';     % set if random initial condition is desired
%init = 'saved';     % set if an earlier saved initial condition is to be used

% CONNECTION MATRIX =================================
% load connections
N = size(CIJ,1);
CM = sparse(CIJ);
% set out-strength (= out-degree for binary matrices)
k_in = sum(CM)';

% MODEL PARAMS =====================================
% set model parameters
V1 = -0.01; V2 = 0.15; V3 = 0; V4 = 0.3; V5 = 0; V7 = 0; V9 = 0.3; V8 = 0.15;
gCa = 1; gK = 2.0; gL = 0.5; gNa = 6.7;
VK = -0.7; VL = -0.5; I = 0.3; b = 0.1; phi = 0.7; VNa = 0.53; VCa = 1;
ani = 0.4; vs = 1; aei = 2; aie = 2; aee = 0.36; ane = 1; rnmda = 0.25;
% more parameters: noise, coupling, modulation
nse = 0;
c = 0.10;            % ********* COUPLING ***********
modn = 0;
if (modn==0)
    V6 = 0.65;
else
    V6 = ones(N,1).*0.65 + modn*(rand(N,1)-0.5);
end;

% TIME PARAMS =====================================
% length of run and initial transient
% (in time segments, 1 tseg = l timesteps
tseg = 2;       % number of segments used in the intial transient
lseg = 20;      % number of segments used in the actual run
llen = 60000;   % length of each segment, in milliseconds
tres = 0.2;     % time resolution of model output, in milliseconds

% ERROR TOLERANCES =================================
% default: 'RelTol' 1e-3, 'AbsTol' 1e-6
options = odeset('RelTol', 1e-6, 'AbsTol', 1e-6);

% INITIAL CONDITION ================================
% initial condition - random
if (strcmp(init,'randm'))
    ics = zeros(N,1);
    for i=1:N
        ics((i-1)*3+1:i*3,1) = [(rand-0.5)*0.8-0.2; (rand-0.5)*0.6+0.3; (rand-0.5)*0.16+0.05];
    end;
end;
% initial condition - start from an earlier run
if (strcmp(init,'saved'))
    load ics_previous    % substitute proper file name
end;

% START SIMULATION ================================
% TRANSIENT =======================================
disp('beginning dynamics (transient)...');
for SEGMENT=1:tseg
    tic;
    [t,y] = ode23('simvec',[0:tres:llen],ics,options);
    yics = y(end,:);
    disp(['finished segment ',num2str(SEGMENT)]);
    ics = yics;
    toc;
end;
disp('finished transient');
% END TRANSIENT ==================================

% save model parameters and intial condition
% eval(['save ',rn,'_params ics V1 V2 V3 V4 V5 V6 V6 V7 gCa gK gL VK VL VCa I b ani aei aie aee phi V8 V9 gNa VNa ane nse rnmda N CM vs c k_in']);

% RUN ============================================
% loop over 'lseg' segments of equal length
for SEGMENT=1:lseg
    tic;
    [t,y] = ode23('simvec',[0:tres:llen],ics,options);
    % keep only excitatory variable and downsample to 1 msec resolution
    V = y(1:5:end,1:3:end);
    W = y(1:5:end,2:3:end);
    Z = y(1:5:end,3:3:end);
    
    % save last time step as initial condition for next time segment
    yics = y(end,:);
    % save downsampled time series of excitatory variable, plus parameters
    eval(['save ',rn,'_part',num2str(SEGMENT),' V W Z yics V1 V2 V3 V4 V5 V6 V6 V7 gCa gK gL VK VL VCa I b ani aei aie aee phi V8 V9 gNa VNa ane nse rnmda N CM vs c k_in'])
    disp(['saved segment ',num2str(SEGMENT)]);
    % swap initial condition
    ics = yics;
    toc;
end;
% END OF RUN =======================================

% CONCATENATE OUTPUT FILES =========================
Vall = [];
Zall = [];
Wall = [];
% concatenate
for s=1:lseg
    eval(['load ',rn,'_part',num2str(s)]);
    Vall = [Vall V(1:end-1,:)'];
    Zall = [Zall Z(1:end-1,:)'];
    Wall = [Wall W(1:end-1,:)'];
end;

% COMPUTE BOLD SIGNAL ==============================
% using the nonlinear balloon-windkessel model...
disp('beginning bold calculation ...');
tic;
Ybold = Yall_bold(Vall);
Ybold = Ybold';
% eval(['save ',rn,'_Ybold Ybold']);
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
%eval(['save ',rn,'_Ybold_proc Ybold_w Ybold_w_mean Ybold_w_reg C R T xsec xgap']);
eval(['save ',rn,'_Ybold_proc Vall Zall Wall Ybold_w Ybold_w_mean Ybold_w_reg C R T xsec xgap']);

% delete the small segements...
for s=1:lseg
    eval(['delete ',rn,'_part',num2str(s),'.mat']);
end;

disp('... all done ...');
