% reference 1: Brand, L. C. E. O., et al. "Single-molecule identification of Coumarin-120 by time-resolved fluorescence detection: Comparison of one-and two-photon excitation in solution." 
%              The Journal of Physical Chemistry A 101.24 (1997): 4313-4321.
% reference 2: Zander, Christoph, et al. "Single-molecule detection by two-photon excitation of fluorescence." BiOS'97, Part of Photonics West. International Society for Optics and Photonics, 1997.
% reference 3: Köllner, M., et al. "Fluorescence pattern recognition for ultrasensitive molecule identification: comparison of experimental data and theoretical approximations." Chemical physics letters 250.3 (1996): 355-360.
% reference 4: DNA-Atto647N lifetime data can be found in Grunwald, Christian, et al. "Quantum-yield-optimized fluorophores for site-specific labeling and super-resolution imaging." Journal of the American Chemical Society 133.21 (2011): 8090-8093.

function [varargout] = FitTau(priorfit,model,histogram,PLOT)
% assume background is constant through all the channels
% input:
% model: structure includes instrument response function (IRF), # of
% pnts on the left and right of fluorescence maximum, channel width,
% channel # of IRF measurement (K1) and ideal exponential decay (K2)
% histogram:  ywave of the fluorescence decay histogram
% tau: lifetime in ns
% gamma: the fraction of background signal due to the prompt Raman
% scattering

gamma=model.gamma;
shift=model.shift;
tau=priorfit;

f=1;   % # of fitted parameters
t=model.width*(0:model.num_chan_exp-1);
idealFit=conv(exp(-t/tau),model.IRF);  % ideal measurement
idealFit=circshift(idealFit,20,2);

% align idealFit and histogram by their maxima
[~,posmax1]=max(idealFit);
[~,posmax2]=max(histogram); 

posmax2=posmax2-round(shift);

left=min([model.left,posmax1-1,posmax2-1]);
right=min([model.right,length(idealFit)-posmax1,length(histogram)-posmax2]);
Fit=idealFit(posmax1-left:posmax1+right);
hist=histogram(posmax2-left:posmax2+right);


S=sum(hist);
k=length(hist);
Fit=gamma^2/k+(1-gamma^2)*Fit/sum(Fit);
I=0;
for i=1:length(hist)
    if hist(i)~=0
        I=I+2/(k-1-f)*hist(i).*log(hist(i)/S./Fit(i));
    end
end

varargout{1}=I;
if (nargin>3)
     varargout{2}=S;
     varargout{3}=S*Fit;
     varargout{4}=hist;
    if (PLOT==1)
        [~,maxFitted]=max(varargout{3});
        [~,maxToBeFit]=max(varargout{4});
        maxToBeFit=maxToBeFit-round(shift);
        t_Fitted=model.width*(1:length(varargout{3}));
        t_ToBeFit=model.width*((1:length(varargout{4}))+(maxFitted-maxToBeFit));
        figure;
        plot(t_Fitted,varargout{3}); hold on; % 
        scatter(t_ToBeFit,varargout{4}); % ,
        legend('Fitted','Raw');                  
        figure;
        plot(S*Fit-hist,'r');
    end
    
end

