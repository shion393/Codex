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
%   Requires Control System and System Identification Toolboxes.

% time vector
T = (0:N-1)'*Ts;

% reference: pseudo random binary sequence
% Rely on idinput defaults: 0–0.5 normalized Nyquist band, amplitude ±1.
r = idinput(N, 'prbs');

% discrete-time identity (avoid feedback(...,1) mixing times)
I = tf(1,1,Ts);


% disturbance with specified SNR at the plant output
raw_v = randn(N,1);

% simulate nominal output to estimate signal power
Tyr_nom = feedback(G0*C0, I);
y_nom = lsim(Tyr_nom, r, T);

P_signal = var(y_nom);
P_noise = P_signal/10^(SNR/10);
v = raw_v * sqrt(P_noise / max(var(raw_v), eps));


% closed-loop transfer functions (all discrete, same Ts)
Tyr = feedback(G0*C0, I);   % r -> y
Tyv = feedback(I, G0*C0);   % v -> y
Tur = feedback(C0, G0);     % r -> u
Tuv = -C0*Tyv;              % v -> u


% simulate
y = lsim(Tyr, r, T) + lsim(Tyv, v, T);
u = lsim(Tur, r, T) + lsim(Tuv, v, T);

% package data
data.r = r;
data.u = u;
data.y = y;
data.Ts = Ts;
end
