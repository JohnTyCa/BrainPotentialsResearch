% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 05/02/2019
%
% Current version = v1.1
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
% B     -   Beta values.
% R     -   R value for regression.
% RSq   -   R squared value for regression.
% 
% ======================================================================= %
% Example
% ======================================================================= %
%
% response = rand(10,1,1);
% predictor = rand(10,1,1);
% [b R Rsq] = linearRegression(response,predictor);
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
% 28/10/2019 (v1.1) -   Outputs beta values.
%
% ======================================================================= %

function [B,R,RSq] = linearRegression(response,predictor)

B = polyfit(predictor, response, 1);
f = polyval(B, predictor);
Bbar = mean(response);
SStot = sum((response - Bbar).^2);
SSreg = sum((f - Bbar).^2);
SSres = sum((response - f).^2);
R2 = 1 - SSres/SStot;
R = corrcoef(predictor,response);
RSq = R(1,2).^2;

