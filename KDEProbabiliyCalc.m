function res = KDEProbabiliyCalc( DifferenceValue, Variance, NumberOfFrames)
%KDEPROBABILIYCALC Summary of this function goes here
%   Detailed explanation goes here
%{
DifferenceValue = double(DifferenceValue);
Variance = double(Variance);

Divisor = 1/(2.0*pi*Variance)^0.5;
Exponent = -0.5 * (DifferenceValue)^2 / Variance;
res = (1/NumberOfFrames) * (exp(Exponent))/Divisor;
%}
res = 0.1;
end

