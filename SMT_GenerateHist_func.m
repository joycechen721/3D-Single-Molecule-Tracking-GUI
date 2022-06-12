function SMT_GenerateHist_func(openpath,savepath,numb,saveresultpath)
mode=0;
group_folder=openpath;
local_folder=savepath;
id_start=0;    % 0 by default, # of track already there
switch mode
    case 0
        int_time=3;    % lifetime integration time, in units of 5ms
        for id=numb
        mkdir(strcat(local_folder,num2str(id)));
        traj_info=xlsread(strcat(saveresultpath,'_original_',num2str(id),'.xls'));
        srcfile=strcat(group_folder,num2str(id),'.pt3');
        binfile=strcat(local_folder,num2str(id),'\traj');
            parfor channel=1:4;             
                SMT_Tau_Time(srcfile,binfile,channel,traj_info,int_time,id_start);
            end
        end
        
    case 1
        int_photon=200;       
        for id=numb
            mkdir(strcat(local_folder,num2str(id)));
            traj_info=xlsread(strcat(group_folder,'_original_',num2str(id),'.xls'));
            srcfile=strcat(group_folder,num2str(id),'.pt3');
            binfile=strcat(local_folder,num2str(id),'\traj');       
            SMT_Tau_Photon(srcfile,binfile,traj_info,int_photon );
        end
end


