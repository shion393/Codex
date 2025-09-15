function metrics = post_analysis(G_hat, G0, C0, data_val)
%POST_ANALYSIS  Validate identified plant model against validation data.
%   METRICS = POST_ANALYSIS(G, G0, C0, DATA) compares the estimated plant
%   G with the true plant G0 using validation dataset DATA (structure with
%   fields r, u, y, Ts).  The controller C0 is used to recreate the closed
%   loop.  Bode and step responses are plotted, together with residual
%   analysis.  The function returns a structure METRICS containing the fit
%   percentage for the output.
%
%   Requires Control System and System Identification Toolboxes.
%
%   See also: SIMULATE_CL, IDENTIFY_TYR_TUR

% iddata for validation
val_ry = iddata(data_val.y, data_val.r, data_val.Ts);

% closed-loop transfer using identified plant
Tyr_hat = feedback(G_hat*C0,1);
[~, fit, ~] = compare(val_ry, Tyr_hat);

% plots
figure; bodeplot(G0, G_hat); grid on;
legend('True G_0','Estimated G'); title('Bode magnitude and phase');

figure; step(feedback(G0*C0,1), feedback(G_hat*C0,1));
legend('True','Estimated'); title('Closed-loop step response');

figure; resid(val_ry, Tyr_hat); title('Residual analysis');

metrics.fit = fit;
end
