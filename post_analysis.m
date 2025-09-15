function metrics = post_analysis(G_hat, G0, C0, data_val)
%POST_ANALYSIS  Validate identified plant model against validation data.
%   METRICS = POST_ANALYSIS(G_hat, G0, C0, DATA_VAL) compares the estimated
%   plant G_hat with the true plant G0 using validation dataset DATA_VAL
%   (fields r, u, y, Ts). All models are aligned to the same discrete-time
%   sampling period Ts to avoid "Sampling times must agree" errors.

Ts = data_val.Ts;                 % sampling time used in simulation

% Discrete-time identity (avoid feedback(...,1) with mixed-time models)
I = tf(1,1,Ts);

% Align plant/controller to Ts (no-op if already Ts)
Gd = G0; if G0.Ts ~= Ts, Gd = d2d(G0, Ts); end
Cd = C0; if C0.Ts ~= Ts, Cd = d2d(C0, Ts); end

% Ensure estimated plant has Ts
Gh = tf(G_hat);
if Gh.Ts == 0
    Gh = c2d(Gh, Ts, 'tustin');
elseif Gh.Ts ~= Ts
    Gh = d2d(Gh, Ts);
end

% Validation data
val_ry = iddata(data_val.y, data_val.r, Ts);

% Closed-loop with estimated plant
Tyr_hat = feedback(Gh*Cd, I);

% Fit on validation data
[~, fit] = compare(val_ry, Tyr_hat);

% Plots
figure; bodeplot(Gd, Gh); grid on;
legend('True G_0','Estimated G'); title('Bode magnitude and phase');

figure; step(feedback(Gd*Cd, I), feedback(Gh*Cd, I));
legend('True','Estimated'); title('Closed-loop step response');

figure; resid(val_ry, Tyr_hat); title('Residual analysis');

metrics.fit = fit;
end
