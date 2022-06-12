function del = GetDelay_func(path,file,res)

load(strcat(path,file));
resolution=res*1000;  % ps
[~,I1]=max(Counts(:,1));
[~,I2]=max(Counts(:,2));
[~,I3]=max(Counts(:,3));
[~,I4]=max(Counts(:,4));

ratio=128/resolution;
fprintf('delay 1= %.2f\ndelay 2= %.2f\ndelay 3= %.2f\ndelay 4= %.2f\n',(I1-I3)/ratio,(I2-I3)/ratio,(I3-I3)/ratio,(I4-I3)/ratio);
del = round([(I1-I3)/ratio,(I2-I3)/ratio,(I3-I3)/ratio,(I4-I3)/ratio]);