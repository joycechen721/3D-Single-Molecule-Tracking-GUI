% integration time is fixed
function [] = SMT_Tau_Time( srcfile,binfile,channel, traj_info,int_time,id_start )

fid=fopen(srcfile)

if nargin<5
    int_time=1;        % integration time in units of external markers
end

%
% The following represents the readable ASCII file header portion
%

Ident = char(fread(fid, 16, 'char'));
% fprintf(1,'      Identifier: %s\n', Ident);

FormatVersion = deblank(char(fread(fid, 6, 'char')'));
% fprintf(1,'  Format Version: %s\n', FormatVersion);

if not(strcmp(FormatVersion,'2.0'))
    % fprintf(1,'\n\n      Warning: This program is for version 2.0 only. Aborted.');
    STOP;
end;

CreatorName = char(fread(fid, 18, 'char'));
% fprintf(1,'    Creator Name: %s\n', CreatorName);

CreatorVersion = char(fread(fid, 12, 'char'));
% fprintf(1,' Creator Version: %s\n', CreatorVersion);

FileTime = char(fread(fid, 18, 'char'));
% fprintf(1,'       File Time: %s\n', FileTime);

CRLF = char(fread(fid, 2, 'char'));

CommentField = char(fread(fid, 256, 'char'));
% fprintf(1,'         Comment: %s\n', CommentField);


%
% The following is binary file header information
%

Curves = fread(fid, 1, 'int32');
% fprintf(1,'Number of Curves: %d\n', Curves);

BitsPerRecord = fread(fid, 1, 'int32');
% fprintf(1,'   Bits / Record: %d\n', BitsPerRecord);

RoutingChannels = fread(fid, 1, 'int32');
fprintf(1,'Routing Channels: %d\n', RoutingChannels);

NumberOfBoards = fread(fid, 1, 'int32');
% fprintf(1,'Number of Boards: %d\n', NumberOfBoards);

ActiveCurve = fread(fid, 1, 'int32');
% fprintf(1,'    Active Curve: %d\n', ActiveCurve);

MeasurementMode = fread(fid, 1, 'int32');
% fprintf(1,'Measurement Mode: %d\n', MeasurementMode);

SubMode = fread(fid, 1, 'int32');
% fprintf(1,'        Sub-Mode: %d\n', SubMode);

RangeNo = fread(fid, 1, 'int32');
% fprintf(1,'       Range No.: %d\n', RangeNo);

Offset = fread(fid, 1, 'int32');
% fprintf(1,'          Offset: %d ns \n', Offset);

AcquisitionTime = fread(fid, 1, 'int32');
fprintf(1,'Acquisition Time: %d ms \n', AcquisitionTime);

StopAt = fread(fid, 1, 'int32');
fprintf(1,'         Stop At: %d counts \n', StopAt);

StopOnOvfl = fread(fid, 1, 'int32');
% fprintf(1,'Stop on Overflow: %d\n', StopOnOvfl);

Restart = fread(fid, 1, 'int32');
% fprintf(1,'         Restart: %d\n', Restart);

DispLinLog = fread(fid, 1, 'int32');
% fprintf(1,' Display Lin/Log: %d\n', DispLinLog);

DispTimeFrom = fread(fid, 1, 'int32');
% fprintf(1,' Display Time Axis From: %d ns \n', DispTimeFrom);

DispTimeTo = fread(fid, 1, 'int32');
% fprintf(1,'   Display Time Axis To: %d ns \n', DispTimeTo);

DispCountFrom = fread(fid, 1, 'int32');
% fprintf(1,'Display Count Axis From: %d\n', DispCountFrom);

DispCountTo = fread(fid, 1, 'int32');
% fprintf(1,'  Display Count Axis To: %d\n', DispCountTo);

for i = 1:8
    DispCurveMapTo(i) = fread(fid, 1, 'int32');
    DispCurveShow(i) = fread(fid, 1, 'int32');
end;

for i = 1:3
    ParamStart(i) = fread(fid, 1, 'float');
    ParamStep(i) = fread(fid, 1, 'float');
    ParamEnd(i) = fread(fid, 1, 'float');
end;

RepeatMode = fread(fid, 1, 'int32');
% fprintf(1,'        Repeat Mode: %d\n', RepeatMode);

RepeatsPerCurve = fread(fid, 1, 'int32');
% fprintf(1,'     Repeat / Curve: %d\n', RepeatsPerCurve);

RepeatTime = fread(fid, 1, 'int32');
% fprintf(1,'        Repeat Time: %d\n', RepeatTime);

RepeatWait = fread(fid, 1, 'int32');
% fprintf(1,'   Repeat Wait Time: %d\n', RepeatWait);

ScriptName = char(fread(fid, 20, 'char'));
% fprintf(1,'        Script Name: %s\n', ScriptName);


%
% The next is a board specific header
%


HardwareIdent = char(fread(fid, 16, 'char'));
% fprintf(1,'Hardware Identifier: %s\n', HardwareIdent);

HardwareVersion = char(fread(fid, 8, 'char'));
% fprintf(1,'   Hardware Version: %s\n', HardwareVersion);

HardwareSerial = fread(fid, 1, 'int32');
% fprintf(1,'   HW Serial Number: %d\n', HardwareSerial);

SyncDivider = fread(fid, 1, 'int32');
fprintf(1,'       Sync Divider: %d\n', SyncDivider);

CFDZeroCross0 = fread(fid, 1, 'int32');
% fprintf(1,'CFD ZeroCross (Ch0): %4i mV\n', CFDZeroCross0);

CFDLevel0 = fread(fid, 1, 'int32');
% fprintf(1,'CFD Discr     (Ch0): %4i mV\n', CFDLevel0);

CFDZeroCross1 = fread(fid, 1, 'int32');
% fprintf(1,'CFD ZeroCross (Ch1): %4i mV\n', CFDZeroCross1);

CFDLevel1 = fread(fid, 1, 'int32');
% fprintf(1,'CFD Discr     (Ch1): %4i mV\n', CFDLevel1);

Resolution = fread(fid, 1, 'float');
fprintf(1,'         Resolution: %5.6f ns\n', Resolution);

% below is new in format version 2.0

RouterModelCode      = fread(fid, 1, 'int32');
RouterEnabled        = fread(fid, 1, 'int32');

% Router Ch1
RtChan1_InputType    = fread(fid, 1, 'int32');
RtChan1_InputLevel   = fread(fid, 1, 'int32');
RtChan1_InputEdge    = fread(fid, 1, 'int32');
RtChan1_CFDPresent   = fread(fid, 1, 'int32');
RtChan1_CFDLevel     = fread(fid, 1, 'int32');
RtChan1_CFDZeroCross = fread(fid, 1, 'int32');
% Router Ch2
RtChan2_InputType    = fread(fid, 1, 'int32');
RtChan2_InputLevel   = fread(fid, 1, 'int32');
RtChan2_InputEdge    = fread(fid, 1, 'int32');
RtChan2_CFDPresent   = fread(fid, 1, 'int32');
RtChan2_CFDLevel     = fread(fid, 1, 'int32');
RtChan2_CFDZeroCross = fread(fid, 1, 'int32');
% Router Ch3
RtChan3_InputType    = fread(fid, 1, 'int32');
RtChan3_InputLevel   = fread(fid, 1, 'int32');
RtChan3_InputEdge    = fread(fid, 1, 'int32');
RtChan3_CFDPresent   = fread(fid, 1, 'int32');
RtChan3_CFDLevel     = fread(fid, 1, 'int32');
RtChan3_CFDZeroCross = fread(fid, 1, 'int32');
% Router Ch4
RtChan4_InputType    = fread(fid, 1, 'int32');
RtChan4_InputLevel   = fread(fid, 1, 'int32');
RtChan4_InputEdge    = fread(fid, 1, 'int32');
RtChan4_CFDPresent   = fread(fid, 1, 'int32');
RtChan4_CFDLevel     = fread(fid, 1, 'int32');
RtChan4_CFDZeroCross = fread(fid, 1, 'int32');

% Router settings are meaningful only for an existing router:

if RouterModelCode>0
    
    % fprintf(1,'-------------------------------------\n');
    % fprintf(1,'   Router Model Code: %d \n', RouterModelCode);
    % fprintf(1,'      Router Enabled: %d \n', RouterEnabled);
    % fprintf(1,'-------------------------------------\n');
    
    % Router Ch1
    % fprintf(1,'RtChan1 InputType   : %d \n', RtChan1_InputType);
    % fprintf(1,'RtChan1 InputLevel  : %4i mV\n', RtChan1_InputLevel);
    % fprintf(1,'RtChan1 InputEdge   : %d \n', RtChan1_InputEdge);
    % fprintf(1,'RtChan1 CFDPresent  : %d \n', RtChan1_CFDPresent);
    % fprintf(1,'RtChan1 CFDLevel    : %4i mV\n', RtChan1_CFDLevel);
    % fprintf(1,'RtChan1 CFDZeroCross: %4i mV\n', RtChan1_CFDZeroCross);
    % fprintf(1,'-------------------------------------\n');
    
    % Router Ch2
    % fprintf(1,'RtChan2 InputType   : %d \n', RtChan2_InputType);
    % fprintf(1,'RtChan2 InputLevel  : %4i mV\n', RtChan2_InputLevel);
    % fprintf(1,'RtChan2 InputEdge   : %d \n', RtChan2_InputEdge);
    % fprintf(1,'RtChan2 CFDPresent  : %d \n', RtChan2_CFDPresent);
    % fprintf(1,'RtChan2 CFDLevel    : %4i mV\n', RtChan2_CFDLevel);
    % fprintf(1,'RtChan2 CFDZeroCross: %4i mV\n', RtChan2_CFDZeroCross);
    % fprintf(1,'-------------------------------------\n');
    
    % Router Ch3
    % fprintf(1,'RtChan3 InputType   : %d \n', RtChan3_InputType);
    % fprintf(1,'RtChan3 InputLevel  : %4i mV\n', RtChan3_InputLevel);
    % fprintf(1,'RtChan3 InputEdge   : %d \n', RtChan3_InputEdge);
    % fprintf(1,'RtChan3 CFDPresent  : %d \n', RtChan3_CFDPresent);
    % fprintf(1,'RtChan3 CFDLevel    : %4i mV\n', RtChan3_CFDLevel);
    % fprintf(1,'RtChan3 CFDZeroCross: %4i mV\n', RtChan3_CFDZeroCross);
    % fprintf(1,'-------------------------------------\n');
    
    % Router Ch4
    % fprintf(1,'RtChan4 InputType   : %d \n', RtChan4_InputType);
    % fprintf(1,'RtChan4 InputLevel  : %4i mV\n', RtChan4_InputLevel);
    % fprintf(1,'RtChan4 InputEdge   : %d \n', RtChan4_InputEdge);
    % fprintf(1,'RtChan4 CFDPresent  : %d \n', RtChan4_CFDPresent);
    % fprintf(1,'RtChan4 CFDLevel    : %4i mV\n', RtChan4_CFDLevel);
    % fprintf(1,'RtChan4 CFDZeroCross: %4i mV\n', RtChan4_CFDZeroCross);
    % fprintf(1,'-------------------------------------\n');
    
end;

%
% The next is a T3 mode specific header
%

ExtDevices = fread(fid, 1, 'int32');
% fprintf(1,'   External Devices: %d\n', ExtDevices);

Reserved1 = fread(fid, 1, 'int32');
% fprintf(1,'          Reserved1: %d\n', Reserved1);

Reserved2 = fread(fid, 1, 'int32');
% fprintf(1,'          Reserved2: %d\n', Reserved2);

CntRate0 = fread(fid, 1, 'int32');
fprintf(1,'   Count Rate (Ch0): %d Hz\n', CntRate0);

CntRate1 = fread(fid, 1, 'int32');
fprintf(1,'   Count Rate (Ch1): %d Hz\n', CntRate1);

StopAfter = fread(fid, 1, 'int32');
fprintf(1,'         Stop After: %d ms \n', StopAfter);

StopReason = fread(fid, 1, 'int32');
fprintf(1,'        Stop Reason: %d\n', StopReason);

Records = fread(fid, 1, 'uint32');
fprintf(1,'  Number Of Records: %d\n', Records);

ImgHdrSize = fread(fid, 1, 'int32');
% fprintf(1,'Imaging Header Size: %d bytes\n', ImgHdrSize);

%Special header for imaging
ImgHdr = fread(fid, ImgHdrSize, 'int32');

%
%  This reads the T3 mode event records
%

ofltime = 0;
WRAPAROUND=65536;

syncperiod = 1E9/CntRate0;   % in nanoseconds
fprintf(1,'Sync Rate = %d / second\n',CntRate0);
fprintf(1,'Sync Period = %5.4f ns\n',syncperiod);


fprintf(1,'\nThis may take a while...\n');

flag=0;
span=90;           % ns
cnt_M=0;

% sort track
[~,I]=sort(traj_info(:,2));
traj_info=traj_info(I,:);

id_track=1;
num_traj=size(traj_info,1);
FIRST=traj_info(id_track,2);
LAST=traj_info(id_track,3);
num_obs=floor((LAST-FIRST)/int_time);
hist=zeros(num_obs,round(span/Resolution));

fprintf('We are going to get the histogram data!\n');
i=0;
while(i<Records)
    T3Record = fread(fid, 1, 'ubit32');
    chan = bitand(bitshift(T3Record,-28),15);
    if (flag&&chan==channel)              % photon belongs to the trajectory
        dtime = bitand(bitshift(T3Record,-16),4095);
        slot=round(dtime);
        ind_obs=floor((cnt_M-FIRST)/int_time)+1;      
        if (ind_obs<=num_obs) && (slot>0) && (slot<=size(hist,2))
            hist(ind_obs,slot)=hist(ind_obs,slot)+1;
        end
    end
    
    if (chan==15)                                           % This means we have a special record
        markers = bitand(bitshift(T3Record,-16),15);
        if (markers==0)                                   % then this is an overflow record
            ofltime = ofltime + WRAPAROUND;              % and we unwrap the numsync (=time tag) overflow
        else
            cnt_M=cnt_M+1;
            if (cnt_M==FIRST)       % the 1st point of a trajectory found, ready for write
                flag=1;
            end
            if (cnt_M==LAST)         % the last point of a trajectory found, stop writting                      
                fid_bin = fopen([binfile,num2str(id_track+id_start),'_ch',num2str(channel),'.bin'],'w');            
                for j=1:size(hist,1)
                     fwrite(fid_bin,hist(j,:),'double');
                end
                fclose(fid_bin);
                fprintf('track# %.0f done!\n',id_track);
                id_track=id_track+1;  
                flag=0;
                if id_track<=num_traj
                    FIRST=traj_info(id_track,2);
                    LAST=traj_info(id_track,3);
                    num_obs=floor((LAST-FIRST)/int_time);
                    hist=zeros(num_obs,round(span/Resolution));
                else
                    break;
                end
            end
        end
    end
    i=i+1;
end

fclose('all');





