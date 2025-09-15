function data = simulate_cl(G0, C0, Ts, N, SNR)
%SIMULATE_CL  Generate closed-loop data for joint IO identification.
%   DATA = SIMULATE_CL(G0, C0, TS, N, SNR) returns simulated reference,
%   control input and output signals for the plant G0 under the controller
%   C0.  TS is the sampling period, N is the number of samples and SNR is
%   the desired signal-to-noise ratio (in dB) for an additive output
%   disturbance.
%
%   The reference signal is a PRBS generated with IDINPUT and the
%   disturbance is white noise scaled to achieve the specified SNR.  The
%   closed-loop signals are computed using linear dynamic models and LSIM.
%
%   The output DATA is a structure with fields:
%       r  - reference signal
%       u  - control input
%       y  - measured output
%       Ts - sampling period
%
%   Example:
%       G0 = tf([0.5],[1 -1.5 0.7],0.01);
%       C0 = pid(0.5,0.1,0,0.01);
%       data = simulate_cl(G0,C0,0.01,5000,20);
%
%   Requires Control System and System Identification Toolboxes.
%
%   See also: IDENTIFY_TYR_TUR, POST_ANALYSIS

% time vector
T = (0:N-1)'*Ts;

% reference: pseudo random binary sequence
% Rely on the IDINPUT default settings (0 to 0.5 Nyquist band and
% amplitude levels of [-1 1]) to produce a valid sequence. IDINPUT may
% warn when N is not an exact PRBS period (2^k-1); this is expected.
r = idinput(N, 'prbs');


% disturbance with specified SNR at the plant output
raw_v = randn(N,1);
% simulate nominal output to estimate signal power
I = tf(1,1,Ts);
Tyr_nom = feedback(G0*C0,I);
y_nom = lsim(Tyr_nom,r,T);
P_signal = var(y_nom);
P_noise = P_signal/10^(SNR/10);
v = raw_v*sqrt(P_noise/var(raw_v));

% closed-loop transfer functions
Tyr = feedback(G0*C0,I);        % r -> y
Tyv = feedback(I,G0*C0);        % v -> y
Tur = feedback(C0,G0);          % r -> u
Tuv = -C0*Tyv;                  % v -> u

% simulate
y = lsim(Tyr,r,T) + lsim(Tyv,v,T);
u = lsim(Tur,r,T) + lsim(Tuv,v,T);

% package data
data.r = r;
data.u = u;
data.y = y;
data.Ts = Ts;
end
