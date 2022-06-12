function SMT_ReadTau_Time_func2(path1,path2,IRFfile,numb,del,saveresultpath)
for id=numb
    dirName = strcat(path1,num2str(id),'\');  
    % pre fit lifetime
    delay=del;   % delay in units of 128ps, relative to the channel with smallest t0
    num_bin=703;
    model.num_chan_IRF=7;     % odd number channel # of ludox meansurement
    model.num_chan_exp=110;   % channel # of ideal exponential decay
    model.left=0;             % # of data points on the right of the peak. 5 is also fine
    model.right=110;          % # of data points on the right of the peak
    model.width=0.128;        % channel width in ns   
    options = optimset('Display','notify','TolFun',1e-16,'TolX',1E-4,'MaxFunEvals',1E5,'MaxIter',1E6); 
    data1=importdata(strcat(path2,IRFfile));  irf=data1(:,1);  % use channel 1 as 
    data2=importdata(strcat(saveresultpath,'fit_128ps_',num2str(id),'.mat'));      Y=data2;
    [IRF, gamma, shift, tau]=PreFit(irf,Y,model,options);   % one component fitting
%    [IRF, gamma, shift, tau1, tau2, r]=PreFit2(irf,Y,model,options);  % two component fitting
    x0=3;
    model.gamma=gamma;
    model.shift=shift;
    model.IRF=IRF;
    files_name=[];
    for i=1:4   % sort file names
        files = dir( fullfile(dirName,['*_ch',num2str(i),'.bin']) );  files = {files.name}';
        num_traj=numel(files);
        ebfret=zeros(num_traj,1);
        for j=1:num_traj
           ind1=strfind(files{j},'traj'); 
           ind2=strfind(files{j},'_ch');
           ebfret(j)=str2double(files{j}(ind1+4:ind2-1));
        end
        [~,I]=sort(ebfret);
        files_name=[files_name,files(I)];
    end
    tau_result=cell(num_traj,1);
    S_result=cell(num_traj,1);
    tau_traj=[];
    S_traj=[];
    Counts=zeros(1,703);
    fprintf('Starting to analyze the lifetime traces!\n');
    for i=1:num_traj
        fid1 = fopen(char(strcat(dirName,files_name(i,1))));
        fid2 = fopen(char(strcat(dirName,files_name(i,2))));
        fid3 = fopen(char(strcat(dirName,files_name(i,3))));
        fid4 = fopen(char(strcat(dirName,files_name(i,4))));
        while (1)
            hist1 = fread(fid1,[1 num_bin],'double');
            hist2 = fread(fid2,[1 num_bin],'double');
            hist3 = fread(fid3,[1 num_bin],'double');
            hist4 = fread(fid4,[1 num_bin],'double');
            Counts=circshift(hist1,-delay(1),2)+circshift(hist2,-delay(2),2)+circshift(hist3,-delay(3),2)+circshift(hist4,-delay(4),2);           
            if (isempty(hist1))
                clear hist1 hist2 hist3 hist4 Counts;
                tau_result{i}=tau_traj;
                S_result{i}=S_traj;
                tau_traj=[];
                S_traj=[];
                break;
            else
                f = @(x)FitTau(x,model,Counts);
%                 tau=fminsearch(f,x0,options);      % fit [lifetime tau]
                  tau=fminbnd(f,0,50);
                if tau<20
                  tau_traj=[tau_traj,tau];
                  [~,S]=FitTau(tau,model,Counts,0);        % # of photons used for fitting
                  S_traj=[S_traj,S];
                end
            end
        end
        fclose('all');    
        fprintf('track# %.0f done!\n',i);
    end
    fclose('all');
    tau_all=cell2mat(tau_result');
    S_all=cell2mat(S_result');
    sticker=zeros(1,num_traj);
    for i=1:num_traj
       sticker(i)= length(tau_result{i}); 
    end
    sticker=cumsum(sticker);
    figure
    plot(tau_all);
    xlabel('time steps');
    ylabel('lifetime');
    set(gca,'FontSize',14);
    for i=1:num_traj
        hold on;
        plot([sticker(i),sticker(i)],[1,6],'r');
    end
save(strcat(saveresultpath,'S',num2str(id),'_bin.mat'),'S_all')
save(strcat(saveresultpath,'timestep_',num2str(id),'.mat'),'sticker')
save(strcat(saveresultpath,'tau_all_',num2str(id),'.mat'),'tau_all')
end
