%% MAIN_CLOSEDLOOP_JOINTIO
% Demonstration script for closed-loop identification using joint input
% output approach.  The script generates data, performs identification and
% validates the result.
%
% Requires Control System and System Identification Toolboxes.

clear; close all; clc;

%% User settings
Ts  = 0.01;       % Sampling period [s]
N   = 5000;       % Number of samples
SNR = 20;         % Signal-to-noise ratio of disturbance [dB]
nb  = 2; nf = 2;  % Transfer function model orders

% True plant and controller
G0 = tf([0.5],[1 -1.5 0.7],Ts);
C0 = pid(0.5,0.1,0,Ts);

%% Closed-loop simulation
data = simulate_cl(G0, C0, Ts, N, SNR);

% Split into estimation and validation sets
Ne = floor(0.7*N);
est = struct('r',data.r(1:Ne), 'u',data.u(1:Ne), 'y',data.y(1:Ne), 'Ts',Ts);
val = struct('r',data.r(Ne+1:end), 'u',data.u(Ne+1:end), 'y',data.y(Ne+1:end), 'Ts',Ts);

% Save data as iddata objects for reproducibility
id_est = iddata(est.y, [est.r est.u], Ts, 'InputName',{'r','u'}, 'OutputName',{'y'});
id_val = iddata(val.y, [val.r val.u], Ts, 'InputName',{'r','u'}, 'OutputName',{'y'});
save('cl_data.mat','id_est','id_val');

%% Identification
[G_hat, Tyr_hat, Tur_hat] = identify_Tyr_Tur(est, nb, nf);

%% Post analysis
metrics = post_analysis(G_hat, G0, C0, val);

%% Save models
save('identified_models.mat','G_hat','Tyr_hat','Tur_hat','metrics');
