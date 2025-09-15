function [G_hat, Tyr_hat, Tur_hat] = identify_Tyr_Tur(data, nb, nf)
%IDENTIFY_TYR_TUR  Estimate Tyr and Tur from closed-loop data.
%   [G,Tyr,Tur] = IDENTIFY_TYR_TUR(DATA, NB, NF) estimates the closed-loop
%   transfer functions from reference to output (Tyr) and from reference to
%   control input (Tur) using TFEST.  DATA is a structure produced by
%   SIMULATE_CL containing fields r, u, y and Ts.  NB and NF specify the
%   numerator and denominator orders for the TF models.
%
%   The plant model is returned as G = Tyr/Tur.
%
%   Example:
%       est = struct('r',r_est,'u',u_est,'y',y_est,'Ts',0.01);
%       [G,Tyr,Tur] = identify_Tyr_Tur(est,2,2);
%
%   Requires the System Identification Toolbox.
%
%   See also: SIMULATE_CL, POST_ANALYSIS

if nargin < 3
    error('Model orders NB and NF must be provided.');
end

% build iddata objects
data_ry = iddata(data.y, data.r, data.Ts);
data_ru = iddata(data.u, data.r, data.Ts);

% estimate transfer functions
Tyr_hat = tfest(data_ry, nb, nf);
Tur_hat = tfest(data_ru, nb, nf);

% plant estimate
g_try = minreal(Tyr_hat/Tur_hat);
G_hat = idtf(g_try);
end
