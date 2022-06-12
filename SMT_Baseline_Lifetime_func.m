function SMT_Baseline_Lifetime_func(path1,path2,numb,del,saveresultpath)
dirName = strcat(path1,num2str(numb),'\'); 
delay=del;   % delay in units of 128ps, relative to the channel with smallest t0
num_bin=703;  files_name=[];
for i=1:4   % sort file names
    files = dir( fullfile(dirName,['*_ch',num2str(i),'.bin']) );  files = {files.name}';
    num_traj=numel(files);
    temp=zeros(num_traj,1);
    for j=1:num_traj
       ind1=strfind(files{j},'traj'); 
       ind2=strfind(files{j},'_ch');
       temp(j)=str2double(files{j}(ind1+4:ind2-1));
    end
    [~,I]=sort(temp);
    files_name=[files_name,files(I)];
end

fprintf('Obtain the baseline histogram for background noise and shift!\n');
Counts=zeros(1,num_bin);
for i=1:num_traj
    fid1 = fopen(char(strcat(dirName,files_name(i,1))));
    fid2 = fopen(char(strcat(dirName,files_name(i,2))));
    fid3 = fopen(char(strcat(dirName,files_name(i,3))));
    fid4 = fopen(char(strcat(dirName,files_name(i,4))));
    j=0;
    while (1)
        hist1 = fread(fid1,[1 num_bin],'double');
        hist2 = fread(fid2,[1 num_bin],'double');
        hist3 = fread(fid3,[1 num_bin],'double');
        hist4 = fread(fid4,[1 num_bin],'double');
        if (isempty(hist1))
            clear hist1 hist2 hist3 hist4;
            break;
        else
             Counts=Counts+circshift(hist1,-delay(1),2)+circshift(hist2,-delay(2),2)+circshift(hist3,-delay(3),2)+circshift(hist4,-delay(4),2);
        end
    end
    fclose('all');    
    fprintf('track# %.0f done!\n',i);
end

% semilogy(Counts);
save(strcat(saveresultpath,'fit_128ps_',num2str(numb),'.mat'),'Counts')
