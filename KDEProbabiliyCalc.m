function res = KDEProbabiliyCalc( CurrentFramePixelValue, CurrentLoopPixelValue, Variance)
%KDEPROBABILIYCALC Summary of this function goes here
%   Detailed explanation goes here

Divisor = 1/(2*pi*Variance)^0.5;
Exponent = -0.5 * ((CurrentFramePixelValue - CurrentLoopPixelValue)^2) / Variance;
res = (exp(Exponent))/Divisor;

end

