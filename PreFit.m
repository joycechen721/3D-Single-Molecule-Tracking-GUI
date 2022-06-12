function [ IRF, gamma, shift, tau ] = PreFit( irf,hist,model,options)

% irf: coverted from phd file by read_phd() followed by save('.mat','Counts');
% hist: coverted from phd file by read_phd() followed by save('.mat','Counts');

[~,start]=max(irf);  
start=start-round((model.num_chan_IRF-1)/2);
zoom=start(1):start(1)+model.num_chan_IRF-1;  
IRF=irf(zoom);
IRF=IRF/sum(IRF);

model.IRF=IRF;

% fit large # of photons to get good estimation of background and relative shift between IRF and fluorescence decay
x0=[0.1,4,2];
f = @(x)FitLifetime(x,model,hist);
posteriorX=fminsearch(f,x0,options);   % fit [constant background, lifetime tau, and relative shift between IRF and fluorescence decay]

% [~,S,~,~]=FitLifetime(posteriorX,model,hist,1);   % check if fitting is okay
% legend(['S= ',num2str(S),' tau= ',num2str(posteriorX(2))]);

gamma=posteriorX(1);
tau=posteriorX(2);
shift=posteriorX(3);













