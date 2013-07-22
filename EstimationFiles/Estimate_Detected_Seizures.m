function Estimate_Detected_Seizures(Data,fs,Start,Animal_Number, Time_ref, Window_start_time,Estimator_Type,Padding)
% function created by Richard Balson 23/04/2013

% Determing samples for each seizure
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~

[Data_samples,Number_channels] = size(Data);

%
% AMPM = Date(end-1:end); % Get AMPM data
%
% if (((strcmp(AMPM,'AM')) && (Hours~=12))) % Check if time is in AM or at 12PM
%     Hours = Hours +12;
% end
check =0;
Start_sample = Time_ref(:,1)*fs +1;
Duration_sample = Time_ref(:,2)*fs;
Padding_samples = fs*Padding;
Est_start = Start_sample -Padding_samples;
Est_start(Est_start<1) =1;
Est_duration = Duration_sample+Padding_samples;
Est_duration(Est_duration+Est_start-1>Data_samples) = Data_samples-Est_start(end);

t = Time_ref(:,1):1/fs:Time_ref(:,1)+Time_ref(:,2)-1/fs;
t = t+Window_start_time;

try
load TemporaryInit StateEstimatesT PxxT Est_end
catch
    Est_end=0;
end
if Est_end ==Est_start(1)
        Initialise =1;
else
    Initialise =0;
end

States = zeros(1,length(Est_start));
Parameters = zeros(1,length(Est_start));
for j = 1:length(Est_start)
    States(j)=figure('name',['Plot of seizure and its state estimates Animal',int2str(Animal_Number)]);
    Parameters(j) = figure('name',['Plot pof seizure and its parameter estimates Animal',int2str(Animal_Number)]);
    for k =1:Number_channels
        [State_Estimates, Pxx, X_Multi, Pxx_Multi] = EstimateDataGUI(Data(Est_start(j):Est_start(j)+Est_duration(j)-1,k),fs,Initialise,k);
        
        % Plot results
        set(0,'CurrentFigure',States)
        hold on
        subplot(k,9,1),plot(t,Data(k,Est_start(j):Est_end(j)))
        for m = 2:9
            subplot(k,9,m),plot(t,State_Estimates(m-1,:))
        end
        hold on
        set(0,'CurrentFigure',Parameters)
        columns = size(X,1)-8;
        hold on
        subplot(k,columns,1),plot(t,Data(k,Est_start(j):Est_end(j)))
        for m = 2:columns+1
            subplot(k,columns,m),plot(t,State_Estimates(m+7,:))
        end
        hold on
        filename = ['EstimatedDataWendling_Animal_',int2str(Animal_number),'_D_',...
            int2str(Start.Year),'_',int2str(Start.Month),'_',int2str(Start.Day),...
            '_Channel_',int2str(k),...
            'Start-Duration',int2str(Est_start(j)),'-',int2str(Est_duration(j)),'.mat'];
        save(filename,'State_Estimates','Pxx','Yest');
        if (Est_start(end) + Est_duration(end)) == Data_samples
            check =1;
            State_EstimatesT(:,:,m) = State_Estimates(:,end);
            PxxT(:,:,m) = Pxx(:,:,end);
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







