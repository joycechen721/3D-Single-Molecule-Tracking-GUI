function ExtractTrajInfo_func(expid_all,count_H,dur_L,dur_H,path,saveresultpath)
%% number of files to be analyzed
num_file=length(expid_all);
%% Parameters regarding trajectory data
dt=5e-3;       % update rate 5ms
ST=-1; 
bytes_count =290;
%% create the folder to save the extract data
for i=1:num_file
    expid=expid_all(i);
    folder='';
    root=path;
    filename=[root,folder,'\',num2str(expid)];
    fid=fopen(filename);
    while(1)        
            fseek(fid,bytes_count,'bof');
            Data=fread(fid,'double'); % Labview DBL numeric constant       
            VarNum=8;       
            state =Data(8+8:VarNum:end-0); % LabVIEW: count0,1,2,3 x,y,z, state
            X     =Data(5+8:VarNum:end-3);
            Y     =Data(6+8:VarNum:end-2);
            Z     =Data(7+8:VarNum:end-1);        
            if all(state==fix(state)) && min(state)>=ST && min(X)>=-15 && max(X)<=15 && min(Y)>=-15 && max(Y)<=15 && min(Z)>=-15 && max(Z)<=15;
                break;
            else    
                bytes_count = bytes_count + 1;
            end
    end
    fclose(fid);
    Count0=Data(1+8:VarNum:end-7);   
    Count1=Data(2+8:VarNum:end-6);   
    Count2=Data(3+8:VarNum:end-5);   
    Count3=Data(4+8:VarNum:end-4);   
    state = state(2:end);
    N=length(state);
    Count0=Count0(2:end)/dt/1000;  % Unit kHz
    Count1=Count1(2:end)/dt/1000;  % Unit kHz
    Count2=Count2(2:end)/dt/1000;  % Unit kHz
    Count3=Count3(2:end)/dt/1000;  % Unit kHz
    Count = Count0 + Count1 + Count2 + Count3 ;
    X     =     X(2:end);
    Y     =     Y(2:end);
    Z     =     Z(2:end);
    %% search the tracking data
    ind_1=find(state==ST); 
    N_1=length(ind_1);        % # of "0" in state
    % find # of successful trackings-----------------------------------------
    numTraj=0;                                % # of successful trackings
    for ii=1:N_1-1
        if (ii==1 && ind_1(ii)>1)
            numTraj=numTraj+1;
        end
        if (ind_1(ii+1)-ind_1(ii)>1)
            numTraj=numTraj+1;
        end
    end
    if (ind_1(end)<N)
           numTraj=numTraj+1;
    end 
    fprintf('There are %.0f trajectories\n',numTraj);
    %-----------------------------------------------------------------------
    % find start-end of each successful tracking
    ind_0=zeros(numTraj,2);      % [start,end]
    trajID=2;
    for ii=1:N_1-1
        if (ii==1 && ind_1(ii)>1)
            ind_0(trajID,:)=[1,ind_1(ii)-1];
            trajID=trajID+1;
        end

        if (ind_1(ii+1)-ind_1(ii)>1)
            ind_0(trajID,:)=[ind_1(ii)+1,ind_1(ii+1)-1];
            trajID=trajID+1;
        end
    end
    if (ind_1(end)<N)   %  N=length(state);
           ind_0(trajID,:)=[ind_1(end)+1,N];
    end
    % sort record by tracking duration
    [dur_H,I]=sort(ind_0(:,2)-ind_0(:,1),'descend'); 
    ind_0=ind_0(I,:);          % [start, end]  
    duration=dt*(ind_0(:,2)-ind_0(:,1));       % duration
    %---------------------------------------------------------------------
    % find photon counts information
    avg_count=zeros(size(duration));    % average photon count (kHz) per channel
    for ii=1:length(duration)
        Start=ind_0(ii,1);
        End  =ind_0(ii,2);
        if (Start*End~=0)
            avg_count(ii)=(mean(Count0(Start:End))+mean(Count1(Start:End))+mean(Count2(Start:End))+mean(Count3(Start:End)))/4;
        else
            avg_count(ii)=0;
        end
    end
    obj=[(1:ii)' ind_0 duration avg_count];
    I=(avg_count < count_H)&(duration >= dur_L)&(duration <= dur_H);
    obj=obj(I,:);
    filename=[saveresultpath,'_original_',num2str(expid)];
    xlswrite(filename, obj);
end