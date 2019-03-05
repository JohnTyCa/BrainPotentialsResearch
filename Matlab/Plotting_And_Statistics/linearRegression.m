% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 05/02/2019
%
% Current version = v1.0
%
% Carries out linear regression with a single predictor.
% 
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% response  -   Response variable.
% predictor -   Predictor variable.
%
% ======================================================================= %
% Optional Inputs:
% ======================================================================= %
%
% 
% 
% ======================================================================= %
% Outputs:
% ======================================================================= %
%
% R     -   R value for regression.
% Rsq   -   R squared value for regression.
% 
% ======================================================================= %
% Example
% ======================================================================= %
%
% response = rand(10,1,1);
% predictor = rand(10,1,1);
% [R Rsq] = linearRegression(response,predictor);
% 
% ======================================================================= %
% Dependencies.
% ======================================================================= %
% 
% 
% 
% ======================================================================= %
% UPDATE HISTORY:
%
% 05/02/2019 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function [R Rsq] = linearRegression(response,predictor)

b = polyfit(predictor, response, 1);
f = polyval(b, predictor);
Bbar = mean(response);
SStot = sum((response - Bbar).^2);
SSreg = sum((f - Bbar).^2);
SSres = sum((response - f).^2);
R2 = 1 - SSres/SStot;
R = corrcoef(predictor,response);
Rsq = R(1,2).^2;

