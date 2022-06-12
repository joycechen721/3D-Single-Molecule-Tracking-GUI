function [kon, koff] = RateCalculation_fuc(filename)
%% Read the excel file 
A = xlsread(filename);
% clc; clear; close all;
% state 1: large lifetime (unquenched)
% state 2: small lifetime (quenched)
 
dt=15E-3;   % 15ms
%% Use the value from excel file 
p=[A(55,1)	A(55,2);
   A(56,1)	A(56,2)
  ];

std_p12=A(57,1);
std_p21=A(58,1);
%%
p11=p(1,1);
p12=p(1,2);
p21=p(2,1);
p22=p(2,2);

kon=-(p12*log(1 - p21 - p12))/(p12*dt + p21*dt);
koff=-(p21*log(1 - p21 - p12))/(p12*dt + p21*dt);

% standar deviation calculation

kon_p12=-(p12*(p12+p21)+p21*(p12+p21-1)*log(1-p12-p21))/(dt*...
    (p12+p21-1)*(p12+p21)^2);
kon_p21=p12*((p12+p21-1)*log(1-p12-p21)-p12-p21)/(dt*...
    (p12+p21-1)*(p12+p21)^2);
koff_p12=p21*((p12+p21-1)*log(1-p12-p21)-p12-p21)/(dt*...
    (p12+p21-1)*(p12+p21)^2);
koff_p21=-(p21*(p12+p21)+p12*(p12+p21-1)*log(1-p12-p21))/(dt*...
    (p12+p21-1)*(p12+p21)^2);

std_kon=sqrt(kon_p12^2*std_p12^2+kon_p21^2*std_p21^2);
std_koff=sqrt(koff_p12^2*std_p12^2+koff_p21^2*std_p21^2);

fprintf('kon  = %.4f, std(kon)  = %.4f\n', kon,std_kon);
fprintf('koff = %.4f, std(koff) = %.4f\n', koff,std_koff);