function [Extra_time Duration] = Estimate_Detected_Seizures(Data,fs,Start,Animal_Number, Time_ref, Window_start_time,Padding,Previous_Data)
% function created by Richard Balson 23/04/2013

% Determing samples for each seizure
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~

global GUIFigure

if nargin ==7
    Previous_check =0;
else
    Previous_check =1;
end
[Data_samples,Number_channels] = size(Data);
Extra_time =0;
Duration =[];
%
% AMPM = Date(end-1:end); % Get AMPM data
%
% if (((strcmp(AMPM,'AM')) && (Hours~=12))) % Check if time is in AM or at 12PM
%     Hours = Hours +12;
% end
check =0;
Start_sample = Time_ref(:,1)*fs +1;
Duration_sample = Time_ref(:,2)*fs;
Padding_samples = 2*fs*Padding;
Est_start = Start_sample -Padding_samples;
Est_duration = Duration_sample+Padding_samples;

if Previous_check
    
else
t = Time_ref(:,1):1/fs:Time_ref(:,1)+Time_ref(:,2)-1/fs;
end
t = t+Window_start_time;

try
load TemporaryInit Est_end
catch
    Est_end=0;
end
if Est_end ==t(1)
        Initialise =1;
else
    Initialise =0;
end
% 
% States = zeros(1,length(Est_start))
% Parameters = zeros(1,length(Est_start));
for j = 1:length(Est_start)
    if Est_start(j) <1
        Previous_dur = 1- Est_start(j);
        Previous_start = size(Previous_Data,1) - Previous_dur;
        Est_start(j) =1;
        DataEst = [Previous_Data(Previous_start:end,:);Data(Est_start(j):Est_start(j)+Est_duration(j)-1,:)];
        if any(Est_duration(Est_duration+Est_start-1-Previous_dur>Data_samples))
            Extra_time =1;
            Duration = (Est_duration+Est_start-1-Previous_dur-Data_samples)/fs;
        end
        Est_duration(Est_duration+Est_start-1>Data_samples) = Data_samples-Est_start(end);
    elseif any(Est_duration(Est_duration+Est_start-1>Data_samples))
        Est_duration(Est_duration+Est_start-1>Data_samples) = Data_samples-Est_start(end);
        DataEst = Data(Est_start(j):Est_start(j)+Est_duration(j)-1,:);
        Extra_time =1;
        Duration = (Est_duration+Est_start-1-Data_samples)/fs;
    else
        DataEst = Data(Est_start(j):Est_start(j)+Est_duration(j)-1,:);
    end
%     States(j)=figure('name',['Plot of seizure and its state estimates Animal',int2str(Animal_Number)]);
%     Parameters(j) = figure('name',['Plot pof seizure and its parameter estimates Animal',int2str(Animal_Number)]);
    for k =1:Number_channels
        Start.Animal = Animal_Number;
        Start.WindowTime = t(j,1);
        Start.WindowDuration = Time_ref(j,2)-Time_ref(j,1);
        [State_Estimates, Pxx PxxEnd] = EstimateDataGUI(DataEst(:,k),fs,Initialise,k,Start);
        set(GUIFigure,'HandleVisibility','Off')
        close all;
        set(GUIFigure,'HandleVisibility','On');
%         % Plot results
%         set(0,'CurrentFigure',States)
%         hold on
%         subplot(k,9,1),plot(t,Data(k,Est_start(j):Est_end(j)))
%         for m = 2:9
%             subplot(k,9,m),plot(t,State_Estimates(m-1,:))
%         end
%         hold on
%         set(0,'CurrentFigure',Parameters)
%         columns = size(X,1)-8;
%         hold on
%         subplot(k,columns,1),plot(t,Data(k,Est_start(j):Est_end(j)))
%         for m = 2:columns+1
%             subplot(k,columns,m),plot(t,State_Estimates(m+7,:))
%         end
%         hold on
        filename = ['UKFW_f',int2str(fs),...
        'Ani',int2str(Start.Animal),'Ch',int2str(k),'ST',int2str(Start.WindowTime),...
        'D',int2str(Start.WindowDuration),'SD',int2str(Start.Day),...
        'CD',int2str(Start.CurrentDay),'_',int2str(Start.Month),'_',int2str(Start.Year),'.mat'];
        save(filename,'State_Estimates','Pxx');
        if (Est_start(j) + Est_duration(j)-1) == Data_samples
            check =1;
            StateEstimatesT(:,k) = State_Estimates(:,end);
            PxxT(:,:,k) = PxxEnd;
        end
    end
end
if check
   Est_end = Window_start_time +Data_samples/fs;
   save TemporaryInit StateEstimatesT PxxT Est_end
else
   Est_end =0;
   save TemporaryInit Est_end
end







