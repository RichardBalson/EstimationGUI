function EstimationGUI
%This function generates the GUI for the designed seizure detector
%   Created by Richard Balson 16/04/2013

%J:\JLJ\20130211{67E4360B-DF57-41A9-89BD-AB24922620C9}.eeg
%J:\JLJ\20130124{632926F5-DF3B-4F03-85FC-593FD25EEC65}.eeg
%C:\Users\balsonr\Dropbox\Polymer Project Jonathan)\Test\GUI1\EEG Matlab Sorting.xlsx
%J:\JLJ\20130120{6E9AE138-D330-4BF2-AFC0-C862D1E254D4}.eeg
% H:\Jonathan\Seizure characterise\GUIv2\EEG Matlab Sorting.xlsx


clear
clc
close all

% Create structure used for setting specified by GUI.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(genpath('..\EstimationGUI'));

Option1=1;
Option2=1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI creation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Detector GUI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


h = figure('Name','Seizure Detector');

% Check boxes
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Seizure detection analysis
Seizure_Detection= uicontrol('style','checkbox','parent',h,'units','normalized','position',[0.4 0.9 0.2 0.04],'string','Seizure Detection','callback',@DetectCHK);

% Seizure characterisation
Seizure_Characterise =uicontrol('style','checkbox','parent',h,'units','normalized','position',[0.4 0.85 0.25 0.04],'string','Characterise Seizures','callback',@SeizCharCHK);

% Characterise all data
Characterise_all_data =uicontrol('style','checkbox','parent',h,'units','normalized','position',[0.4 0.8 0.25 0.04],'string','Characterise Data','callback',@BackgCHK);

% Conditional Check boxes
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Available when seizure charcterisation is checked, Check if features need
% to be plotted
Plot_features= uicontrol('style','checkbox','parent',h,'units','normalized','position',[0.7 0.9 0.2 0.04],'string','Plot Features','Visible','off');

Save_data= uicontrol('style','checkbox','parent',h,'units','normalized','position',[0.7 0.85 0.2 0.04],'string','Save Data','Visible','off');

% Availbale when Seizure Detection is checked, check if a comparison
% between detected and annotated seizures needs to be made
Compare_Seizures = uicontrol('style','checkbox','parent',h,'units','normalized','position',[0.7 0.9 0.2 0.04],'string','Compare detected and characterised seizures','Visible','off','Callback',@CompareCHK);


% Text
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Text detailing information for the filepath
uicontrol('style','text','parent',h,'units','normalized','position',[0.1 0.9 0.25 0.04],'string','EEG data Path (c:\...\2012.eeg file)');

% Specify channels text
uicontrol('style','text','parent',h,'units','normalized','position',[0.4 0.6 0.25 0.04],'string','Analyse Channels (1,2,..,8)');

% Conditional text
% ~~~~~~~~~~~~~~~~~~~~

% Available when Seizure Characterise is checked. Details of filepath for
% excel file
EEGSort= uicontrol('style','text','parent',h,'units','normalized','position',[0.1 0.55 0.25 0.04],'string','EEG Seizure Data Times (c:\...\2012Sorted.xls file)','Visible','off');

% Available when Seizure Detection is checked. Details on line length
% threshold.
LineLengthString= uicontrol('style','text','parent',h,'units','normalized','position',[0.1 0.75 0.25 0.04],'string','Line Length Threshold','Visible','off'); %

% Available when Seizure Detection is checked. Details on amplitude
% threshold.
AmplitudeString= uicontrol('style','text','parent',h,'units','normalized','position',[0.1 0.65 0.25 0.04],'string','Amplitude Threshold','Visible','off'); %  (Multiple above mean for seizure, such that if amplitude mean = 0.1 and threshold =3, seizure is classified if the determine amplitude is 0.3 or above

PaddingString = uicontrol('style','text','parent',h,'units','normalized','position',[0.4 0.5 0.25 0.04],'string','Padding for annotations (10)','Visible','off');
% Edit boxes
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Specify EEG data path for analysis
EEG_data_path = uicontrol('style','edit','parent',h,'units','normalized','position',[0.1 0.85 0.25 0.04]);

% Provides details of errors that occur, and that the analysis has started
ErrorMessage = uicontrol('style','edit','parent',h,'units','normalized','position',[0.4 0.25 0.4 0.1],'Visible','off');

ChannelChoice = uicontrol('style','edit','parent',h,'units','normalized','position',[0.4 0.55 0.25 0.04]);

% Optional edit boxes
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Available when Seizure Charaterise is checked. Edit box for details about EEG Seizure Data Times
EEG_Seizure_times_data_path = uicontrol('style','edit','parent',h,'units','normalized','position',[0.1 0.45 0.25 0.04],'Visible','off');

% Avaliablle whne Seizure Detection is checked. Edit box for line length
% threshold specified
LineLengthThreshold = uicontrol('style','edit','parent',h,'units','normalized','position',[0.1 0.7 0.25 0.04],'Visible','off');

% Avaliablle whne Seizure Detection is checked. Edit box for amplitude
% threshold specified
AmplitudeThreshold = uicontrol('style','edit','parent',h,'units','normalized','position',[0.1 0.6 0.25 0.04],'Visible','off');

% Avaliablle whne Seizure Detection is checked. Edit box for amplitude
% threshold specified
Padding = uicontrol('style','edit','parent',h,'units','normalized','position',[0.4 0.45 0.25 0.04],'Visible','off');

% PushButton
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Push button to start analysis
PushStart=uicontrol('style','pushbutton','parent',h,'units','normalized','position',[0.5 0.1 0.25 0.1],'string','Start','callback',@StartProgram);

Browse_EEG_file=uicontrol('style','pushbutton','parent',h,'units','normalized','position',[0.1 0.8 0.1 0.04],'string','Browse','callback',@BrowseEEG);

% Conditional pushbutton
% ~~~~~~~~~~~~~~~~~~
Browse_Annotate_EEG=uicontrol('style','pushbutton','parent',h,'units','normalized','position',[0.1 0.5 0.1 0.04],'string','Browse','callback',@BrowseAnnotate,'Visible','off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Estimate (GUI Additions)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check boxes
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Estimate Detected seizures
Estimate_detected_seizures = uicontrol('style','checkbox','parent',h,'units','normalized','position',[0.4 0.75 0.45 0.04],'string','Estimate parameters for Detected Seizures','callback',@EstDetectCHK);

% Estimate characterised seizures
Estimate_characterised_seizures = uicontrol('style','checkbox','parent',h,'units','normalized','position',[0.4 0.7 0.45 0.04],'string','Estimate parameters for annotated seizures','callback',@EstCharCHK);

% Estimate all data
Estimate_all_data =uicontrol('style','checkbox','parent',h,'units','normalized','position',[0.4 0.65 0.3 0.04],'string','Estimate all data','callback',@EstDataCHK);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Callback function for folder designation
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


 % Callback when Seizure_Detection is checked
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~

    function BrowseEEG(varargin)
        EEG_file_path = uigetdir;
        set(EEG_data_path,'string',EEG_file_path)
    end

    function BrowseAnnotate(varargin)
        [EEG_annotate_file path] = uigetfile('.xlsx');
        set(EEG_Seizure_times_data_path,'string',strcat(path,EEG_annotate_file))
    end


% Callback Functions for Detection
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Callback when Seizure_Detection is checked
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~
    function DetectCHK(varargin)
        if get(Seizure_Detection,'Value') ==1 % Determine if box checked or unchecked
            % Detector
            %~~~~~~~~~~~~~~~~~~~~`     
            set(PaddingString,'Visible','Off'); % Specify padding as off
            set(Padding,'Visible','Off'); % Specify padding as off
            set(Compare_Seizures,'Visible','On'); % Turn on compare seizure check box
            set(Plot_features,'Visible','Off') % Turn off plot features check box
            set(Save_data,'Visible','Off') % Turn off plot features check box
            set(Plot_features,'Value',0);
            set(Save_data,'Value',0);
            set(Seizure_Characterise,'Value',0) % Uncheck Seizure Characterise
            set(Characterise_all_data,'Value',0) % Uncheck Characterise all data
            set(EEGSort,'Visible','Off') % Turn off EEG sort filepath text
            set(Browse_Annotate_EEG,'Visible','Off') % Turn off browse EEG anotate file push button
            set(EEG_Seizure_times_data_path,'Visible','Off') % Turn off EEG sort filepath edit box
            set(LineLengthString,'Visible','On'); % Turn on line length threshold text
            set(AmplitudeString,'Visible','On'); % Turn on amplitude threshold text
            set(LineLengthThreshold,'Visible','On'); % Turn on line length threshold edit box
            set(AmplitudeThreshold,'Visible','On');% Turn on amplitude threshold edit box
            % Estimator
            %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            set(Estimate_characterised_seizures,'Value',0)
            set(Estimate_all_data,'Value',0);
            set(Estimate_all_data,'Value',0);
            set(Estimate_characterised_seizures,'Value',0);
        else % Seizure)Detection unchecked
            % Detector
            %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            set(LineLengthString,'Visible','Off');% Turn off line length threshold text
            set(AmplitudeString,'Visible','Off');% Turn off amplitude threshold text
            set(LineLengthThreshold,'Visible','Off');% Turn off line length threshold edit box
            set(AmplitudeThreshold,'Visible','Off');% Turn off amplitude threshold edit box
            set(Compare_Seizures,'Visible','Off'); % Turn off compare seizure check box
            set(Compare_Seizures,'Value',0);
            % Estimator
            %~~~~~~~~~~~~~~~~~~~~~~~~~~
            set(Estimate_detected_seizures,'Value',0);
        end
    end

% Callback when Seizure_Characterise is checked
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    function SeizCharCHK(varargin)
        if get(Seizure_Characterise,'Value') % Determine if box checked or unchecked
            % Detector
            %~~~~~~~~~~~~~~~~~~~~~~~~~~
            set(PaddingString,'Visible','On'); % Specify padding as on
            set(Padding,'Visible','On'); % Specify padding as on
            set(EEGSort,'Visible','On') % Turn on EEG sort filepath text
            set(EEG_Seizure_times_data_path,'Visible','On')% Turn on EEG sort filepath edit box
            set(Seizure_Detection,'Value',0) % Uncheck Seizure Detection
            set(Save_data,'Visible','On') % Turn off plot features check box
            set(Browse_Annotate_EEG,'Visible','On') % Turn off browse EEG anotate file push button
            set(Characterise_all_data,'Value',0) % Uncheck Characterise all data
            set(Plot_features,'Visible','On') % Turn on plot features check box
            set(LineLengthString,'Visible','Off');% Turn off line length threshold text
            set(AmplitudeString,'Visible','Off');% Turn off amplitude threshold text
            set(LineLengthThreshold,'Visible','Off');% Turn off line length threshold edit box
            set(AmplitudeThreshold,'Visible','Off');% Turn off amplitude threshold edit box
            set(Compare_Seizures,'Visible','Off'); % Turn off compare seizure check box
            set(Compare_Seizures,'Value',0);
            % Estimator
            %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            set(Estimate_all_data,'Value',0);
            set(Estimate_detected_seizures,'Value',0);
        elseif ((get(Seizure_Characterise,'Value') ==0) && (get(Estimate_characterised_seizures,'Value')==0))% Seizure_Characterise unchecked
            % Detector
            %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            set(PaddingString,'Visible','Off'); % Specify padding as off
            set(Padding,'Visible','Off'); % Specify padding as off
            set(EEGSort,'Visible','Off') % Turn off EEG sort filepath text
            set(Browse_Annotate_EEG,'Visible','Off') % Turn off browse EEG anotate file push button
            set(EEG_Seizure_times_data_path,'Visible','Off')% Turn off EEG sort filepath edit box
            set(Save_data,'Visible','Off') % Turn off plot features check box
            set(Save_data,'Value',0);
            set(Plot_features,'Visible','Off');
            set(Plot_features,'Value',0);

        else
            set(Plot_features,'Visible','Off');
            set(Plot_features,'Value',0);
        end
    end

% Callback when Characterise_all_data is checked
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    function BackgCHK(varargin)
        if get(Characterise_all_data,'Value') ==1 % Determine if box checked or unchecked
            % Detector
            %~~~~~~~~~~~~~~~~~~~~
            set(PaddingString,'Visible','Off'); % Specify padding as off
            set(Padding,'Visible','Off'); % Specify padding as off
            set(Plot_features,'Visible','Off') % Turn off plot features check box
            set(Save_data,'Visible','Off') % Turn off plot features check box
            set(Plot_features,'Value',0);
            set(Save_data,'Value',0);
            set(Seizure_Detection,'Value',0) % Uncheck Seizure Detection
            set(Seizure_Characterise,'Value',0) % Uncheck Seizure Characterise
            set(EEGSort,'Visible','Off') % Turn off EEG sort filepath text box
            set(Browse_Annotate_EEG,'Visible','Off') % Turn off browse EEG anotate file push button
            set(EEG_Seizure_times_data_path,'Visible','Off') % Turn off EEG sort filepath edit box
            set(Plot_features,'Visible','Off')% Turn off plot features check box
            set(LineLengthString,'Visible','Off');% Turn off line length threshold text
            set(AmplitudeString,'Visible','Off');% Turn off amplitude threshold text
            set(LineLengthThreshold,'Visible','Off');% Turn off line length threshold edit box
            set(AmplitudeThreshold,'Visible','Off');% Turn off amplitude threshold edit box
            set(Compare_Seizures,'Visible','Off'); % Turn off compare seizure check box
            set(Compare_Seizures,'Value',0);
            %Estimator
            %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            set(Estimate_characterised_seizures,'Value',0);
            set(Estimate_detected_seizures,'Value',0);
        end
    end

% Callback function for estimation of detected seizures
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    function EstDetectCHK(varargin)                   
        if get(Estimate_detected_seizures,'Value') % Determine if checkbox is checked
            % Detector
            %~~~~~~~~~~~~~~~~~~~~~~~~~
            set(LineLengthString,'Visible','On'); % Turn on line length threshold text
            set(AmplitudeString,'Visible','On'); % Turn on amplitude threshold text
            set(LineLengthThreshold,'Visible','On'); % Turn on line length threshold edit box
            set(AmplitudeThreshold,'Visible','On');% Turn on amplitude threshold edit box
            set(Browse_Annotate_EEG,'Visible','Off') % Turn off browse EEG anotate file push button 
            set(Plot_features,'Visible','Off') % Turn off plot features check box
            set(Seizure_Detection,'Value',1); % Check Seizure Detection
            set(Seizure_Characterise,'Value',0) % Uncheck Seizure Characterise
            set(Characterise_all_data,'Value',0) % Uncheck Characterise all data            
            set(EEGSort,'Visible','Off') % Turn off EEG sort filepath text
            set(EEG_Seizure_times_data_path,'Visible','Off') % Turn off EEG sort filepath edit box
            set(Compare_Seizures,'Visible','On'); % Turn on compare seizure check box
            set(PaddingString,'Visible','Off'); % Specify padding as off
            set(Padding,'Visible','Off'); % Specify padding as off   
            set(Save_data,'Visible','Off') % Turn off plot features check box
            set(Plot_features,'Value',0);
            set(Save_data,'Value',0);
            %Estimator
            %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            set(Estimate_characterised_seizures,'Value',0)
            set(Estimate_all_data,'Value',0);
        end
    end

    function EstCharCHK(varargin)
        if get(Estimate_characterised_seizures,'Value')
            % Detector
            %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            set(Browse_Annotate_EEG,'Visible','On') % Turn off browse EEG anotate file push button
            set(PaddingString,'Visible','On'); % Specify padding as on
            set(Padding,'Visible','On'); % Specify padding as on
            set(EEGSort,'Visible','On') % Turn on EEG sort filepath text
            set(EEG_Seizure_times_data_path,'Visible','On')% Turn on EEG sort filepath edit box
            set(Seizure_Detection,'Value',0) % Uncheck Seizure Detection
            set(Characterise_all_data,'Value',0) % Uncheck Characterise all data
            set(Plot_features,'Visible','On') % Turn on plot features check box
            set(LineLengthString,'Visible','Off');% Turn off line length threshold text
            set(AmplitudeString,'Visible','Off');% Turn off amplitude threshold text
            set(LineLengthThreshold,'Visible','Off');% Turn off line length threshold edit box
            set(AmplitudeThreshold,'Visible','Off');% Turn off amplitude threshold edit box
            set(Compare_Seizures,'Visible','Off'); % Turn on compare seizure check box 
            set(Save_data,'Visible','On') % Turn off plot features check box
            %Estimator
            %~~~~~~~~~~~~~~~~~~~~~~~~
            set(Estimate_detected_seizures,'Value',0);
            set(Estimate_all_data,'Value',0);

          elseif ((get(Seizure_Characterise,'Value') ==0) && (get(Estimate_characterised_seizures,'Value')==0))% Seizure_Characterise unchecked
            set(PaddingString,'Visible','Off'); % Specify padding as off
            set(Padding,'Visible','Off'); % Specify padding as off
            set(EEGSort,'Visible','Off') % Turn off EEG sort filepath text
            set(Browse_Annotate_EEG,'Visible','Off') % Turn off browse EEG anotate file push button
            set(Plot_features,'Visible','Off') % Turn off plot features check box
            set(EEG_Seizure_times_data_path,'Visible','Off')% Turn off EEG sort filepath edit box
            set(Save_data,'Visible','Off') % Turn off plot features check box
            set(Plot_features,'Value',0);
            set(Save_data,'Value',0);
        end
    end

    function EstDataCHK(varargin)
        if get(Estimate_all_data,'Value')
            set(Estimate_characterised_seizures,'Value',0)
            set(Estimate_detected_seizures,'Value',0);
            set(Compare_Seizures,'Visible','Off'); % Turn on compare seizure check box
            set(Seizure_Detection,'Value',0) % Uncheck Seizure Detection
            set(Seizure_Characterise,'Value',0) % Uncheck Seizure Characterise
            set(EEGSort,'Visible','Off') % Turn off EEG sort filepath text box
            set(EEG_Seizure_times_data_path,'Visible','Off') % Turn off EEG sort filepath edit box
            set(Plot_features,'Visible','Off')% Turn off plot features check box
            set(LineLengthString,'Visible','Off');% Turn off line length threshold text
            set(AmplitudeString,'Visible','Off');% Turn off amplitude threshold text
            set(LineLengthThreshold,'Visible','Off');% Turn off line length threshold edit box
            set(AmplitudeThreshold,'Visible','Off');% Turn off amplitude threshold edit box
            set(Browse_Annotate_EEG,'Visible','Off') % Turn off browse EEG anotate file push button
            set(PaddingString,'Visible','Off'); % Specify padding as off
            set(Padding,'Visible','Off'); % Specify padding as off
            set(Save_data,'Visible','Off') % Turn off plot features check box
            set(Plot_features,'Value',0);
            set(Save_data,'Value',0);
        end
    end

% Callback when Compare_Seizures is checked
% ~~~~~~~~~~~~~~~~~~~~~~~~~~
    function CompareCHK(varargin)
        if get(Compare_Seizures,'Value') % Check if checkbox is checked          
            set(EEGSort,'Visible','On') % Turn on EEG sort filepath text
            set(Browse_Annotate_EEG,'Visible','On') % Turn off browse EEG anotate file push button
            set(EEG_Seizure_times_data_path,'Visible','On')% Turn on EEG sort filepath edit box
        else
            set(EEGSort,'Visible','Off') % Turn off EEG sort filepath text
            set(Browse_Annotate_EEG,'Visible','Off') % Turn off browse EEG anotate file push button
            set(EEG_Seizure_times_data_path,'Visible','Off')% Turn off EEG sort filepath edit box
        end
    end


% Callback when Start_Program push button is pressed
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    function StartProgram(varargin)
        DetectorSettings = struct('EEGFilepath',{{0}},'ExcelFilepath',{{0}},'PlotFeatures',0,'LLThres',0,'AmpThres',0,'CompareSeizures',0,'Padding','10','Channels',0,'SaveData',0);
        EstimatorSettings = struct();
        EstimatorType = [0 0 0];
        ProgramType = [0 0 0];% Index 1 Detector, 2 characterise seizures, 3 characterise background
        clear filepath LLThres AmpThres Excel_data_filepath % CLear all temporary variables at start of callback
        %         set(PushStart,'Enable','Off') % Disable Push button during analysis
        
        % Detector
        %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        set(ErrorMessage,'Visible','Off') % Turn off error message edit box
        set(ErrorMessage,'string','Analysis Started') % Set error message
        set(ErrorMessage,'Visible','On') % Display error message
        filepath =  get(EEG_data_path,'string'); % Get filepath from edit box
        if isempty(filepath) % Determine if filepath specified
            set(ErrorMessage,'string','No .eeg filepath specified') % Inform user that no filepath is specified
            set(ErrorMessage,'Visible','On') % Show error message
            return % End callback
        else
            DetectorSettings.EEGFilepath=filepath; % Set detector settings with filepath specified
        end
        if get(Seizure_Detection,'Value') ==1 % Check if Seizure_Detection is checked
            LLThres = get(LineLengthThreshold,'string'); % Get value in edit box specifying threshold for line length
            if isempty(LLThres) % Determine if line length threshold is specified
                set(ErrorMessage,'string','No line length threshold specified') % Set errror message
                set(ErrorMessage,'Visible','On')% Display error message
                return % End callback
            else
                DetectorSettings.LLThres = LLThres; % Set line length in detector settings
            end
            AmpThres = get(AmplitudeThreshold,'string'); % Get amplitude threshold from edit box
            if isempty(AmpThres) % Check if an amplitude threshold is specified
                set(ErrorMessage,'string','No amplitude threshold specified') % Set error message
                set(ErrorMessage,'Visible','On') % Display error message
                return % End callback
            else
                DetectorSettings.AmpThres = AmpThres; % Set amplitude threshold in detector settings
            end
            if get(Compare_Seizures,'Value')
                DetectorSettings.CompareSeizures =1;
                Excel_data_filepath =  get(EEG_Seizure_times_data_path,'string'); % Get excel filepath from edit box
                if isempty(Excel_data_filepath)% Check if excel filepath exists
                    set(ErrorMessage,'string','No excel filepath specified') % Set error message
                    set(ErrorMessage,'Visible','On') % Show error message
                    return % End callback
                else
                    DetectorSettings.ExcelFilepath =  Excel_data_filepath; % Set filepath for excel file in detector settings
                end
            end
            if get(Estimate_detected_seizures,'Value')
                EstimatorType =[1 0 0];
            end
            ProgramType = [1 0 0]; % Set the program type to seizure detection
            
        elseif get(Seizure_Characterise,'Value') ==1 % Check if seizure characterisation is checked
            DetectorSettings.PlotFeatures = get(Plot_features,'Value'); % Update detector settings with plot features
            Excel_data_filepath =  get(EEG_Seizure_times_data_path,'string'); % Get excel filepath from edit box
            DetectorSettings.SaveData = get(Save_data,'Value');
            if isempty(Excel_data_filepath)% Check if excel filepath exists
                set(ErrorMessage,'string','No excel filepath specified') % Set error message
                set(ErrorMessage,'Visible','On') % Show error message
                return % End callback
            else
                DetectorSettings.ExcelFilepath = Excel_data_filepath; % Set filepath for excel file in detector settings
            end
            PaddingStr = get(Padding,'string');
            if ~isempty(PaddingStr)
                DetectorSettings.Padding = PaddingStr;
            end
            ProgramType = [0 1 0]; % Set program type to Seizure characterisation
        elseif get(Characterise_all_data,'Value') ==1 % Check if characterise all data is checked
            ProgramType = [0 0 1]; % Set program type to characterise all data
        else % Check if no options selected
            Option1=0;
        end
        if get(Estimate_characterised_seizures,'Value')
            EstimatorType = [0 1 0];
        elseif get(Estimate_all_data,'Value')
            EstimatorType=[0 0 1];
        else
            Option2 =0;
        end
        if ~(Option1 ||Option2)
                set(ErrorMessage,'string','No option selected') % Set error message
                set(ErrorMessage,'Visible','On') % Show error message
                return % End callback
        end
        refreshdata
        ChannelsRequested = get(ChannelChoice,'string');
        if isempty(ChannelsRequested)
            DetectorSettings.Channels ='all';
        else
           DetectorSettings.Channels =ChannelsRequested; 
        end
        Analyse_EEG_GUI_Estimation(DetectorSettings,EstimatorSettings,ProgramType, EstimatorType); % Begin analysis of data
        set(ErrorMessage,'string','Analysis Finished') % Inform user that analysis is finished
    end
end


