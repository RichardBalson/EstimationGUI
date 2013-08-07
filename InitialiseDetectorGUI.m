
% Check boxes
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Seizure detection analysis
Seizure_Detection= uicontrol('style','checkbox','parent',GUIFigure,'units','normalized','position',[0.4 0.9 0.2 0.04],'string','Seizure Detection','callback',@DetectCHK);

% Seizure characterisation
Seizure_Characterise =uicontrol('style','checkbox','parent',GUIFigure,'units','normalized','position',[0.4 0.85 0.25 0.04],'string','Characterise Seizures','callback',@SeizCharCHK);

% Characterise all data
Characterise_all_data =uicontrol('style','checkbox','parent',GUIFigure,'units','normalized','position',[0.4 0.8 0.25 0.04],'string','Characterise Data','callback',@BackgCHK);

Post_process_characterise = uicontrol('style','checkbox','parent',GUIFigure,'units','normalized','position',[0.4 0.6 0.25 0.04],'string','Process Characterised Data','callback',@ProcessData);

% Conditional Check boxes
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Available when seizure charcterisation is checked, Check if features need
% to be plotted
Plot_features= uicontrol('style','checkbox','parent',GUIFigure,'units','normalized','position',[0.7 0.9 0.2 0.04],'string','Plot Features','Visible','off');

Save_data= uicontrol('style','checkbox','parent',GUIFigure,'units','normalized','position',[0.7 0.85 0.2 0.04],'string','Save Data','Visible','off');

% Availbale when Seizure Detection is checked, check if a comparison
% between detected and annotated seizures needs to be made
Compare_Seizures = uicontrol('style','checkbox','parent',GUIFigure,'units','normalized','position',[0.7 0.9 0.2 0.04],'string','Compare detected and characterised seizures','Visible','off','Callback',@CompareCHK);

Post_process_annotate = uicontrol('style','checkbox','parent',GUIFigure,'units','normalized','position',[0.7 0.8 0.22 0.04],'string','Process Characterised Data','Visible','Off');

Select_Channels = uicontrol('style','checkbox','parent',GUIFigure,'units','normalized','position',[0.7 0.85 0.29 0.04],'string','Specify Channels for detector','Visible','off','Callback',@SelectChannels);

Select_Seizure_Duration = uicontrol('style','checkbox','parent',GUIFigure,'units','normalized','position',[0.7 0.8 0.29 0.04],'string','Specify Minimum seizure duration','Visible','off','Callback',@SpecifyDuration);

Process_annotations = uicontrol('style','checkbox','parent',GUIFigure,'units','normalized','position',[0.7 0.9 0.29 0.04],'string','Specify Minimum seizure duration','Visible','off','Callback',@SpecifyDuration);

Process_Seizures = uicontrol('style','checkbox','parent',GUIFigure,'units','normalized','position',[0.7 0.9 0.29 0.04],'string','Specify Minimum seizure duration','Visible','off','Callback',@SpecifyDuration);


% Text
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Text detailing information for the filepath
uicontrol('style','text','parent',GUIFigure,'units','normalized','position',[0.03 0.9 0.35 0.04],'string','EEG data Path (c:\...\2012.eeg file)');

% Specify channels text
uicontrol('style','text','parent',GUIFigure,'units','normalized','position',[0.4 0.55 0.25 0.04],'string','Analyse Channels (1,2,..,8)');

% Conditional text
% ~~~~~~~~~~~~~~~~~~~~

% Available when Seizure Characterise is checked. Details of filepath for
% excel file
EEGSort= uicontrol('style','text','parent',GUIFigure,'units','normalized','position',[0.03 0.55 0.35 0.04],'string','EEG Seizure Data Times (c:\...\2012Sorted.xls file)','Visible','off');

% Available when Seizure Detection is checked. Details on line length
% threshold.
LineLengthString= uicontrol('style','text','parent',GUIFigure,'units','normalized','position',[0.03 0.75 0.35 0.04],'string','Line Length Threshold','Visible','off'); %

% Available when Seizure Detection is checked. Details on amplitude
% threshold.
AmplitudeString= uicontrol('style','text','parent',GUIFigure,'units','normalized','position',[0.03 0.65 0.35 0.04],'string','Amplitude Threshold','Visible','off'); %  (Multiple above mean for seizure, such that if amplitude mean = 0.1 and threshold =3, seizure is classified if the determine amplitude is 0.3 or above

PaddingString = uicontrol('style','text','parent',GUIFigure,'units','normalized','position',[0.4 0.45 0.25 0.04],'string','Padding for annotations (10)','Visible','off');

ChannelText = uicontrol('style','text','parent',GUIFigure,'units','normalized','position',[0.7 0.7 0.29 0.08],'string','Select Channels (1,2,3,4)','Visible','off');

DurationText = uicontrol('style','text','parent',GUIFigure,'units','normalized','position',[0.7 0.55 0.29 0.08],'string','Specify Minimum Seizure Duration (5s)','Visible','off');

% SeizureSplit = uicontrol('style','text','parent',GUIFigure,'units','normalized','position',[0.03 0.55 0.35 0.04],'string','Split Seizure','Visible','off');

% PostprocessString = uicontrol('style','text','parent',GUIFigure,'units','normalized','position',[0.03 0.55 0.35 0.04],'string','Characterised seizures Excel file','Visible','off');
% Edit boxes
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Specify EEG data path for analysis
EEG_data_path = uicontrol('style','edit','parent',GUIFigure,'units','normalized','position',[0.03 0.85 0.35 0.04]);

% Provides details of errors that occur, and that the analysis has started
ErrorMessage = uicontrol('style','edit','parent',GUIFigure,'units','normalized','position',[0.4 0.3 0.4 0.2],'Visible','off');

ChannelChoice = uicontrol('style','edit','parent',GUIFigure,'units','normalized','position',[0.4 0.5 0.25 0.04]);

% Optional edit boxes
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Available when Seizure Charaterise is checked. Edit box for details about EEG Seizure Data Times
EEG_Seizure_times_data_path = uicontrol('style','edit','parent',GUIFigure,'units','normalized','position',[0.03 0.45 0.35 0.04],'Visible','off');

% Avaliablle whne Seizure Detection is checked. Edit box for line length
% threshold specified
LineLengthThreshold = uicontrol('style','edit','parent',GUIFigure,'units','normalized','position',[0.03 0.7 0.35 0.04],'Visible','off');

% Avaliablle whne Seizure Detection is checked. Edit box for amplitude
% threshold specified
AmplitudeThreshold = uicontrol('style','edit','parent',GUIFigure,'units','normalized','position',[0.03 0.6 0.35 0.04],'Visible','off');

% Avaliablle whne Seizure Detection is checked. Edit box for amplitude
% threshold specified
Padding = uicontrol('style','edit','parent',GUIFigure,'units','normalized','position',[0.4 0.4 0.25 0.04],'Visible','off');

Channel = uicontrol('style','edit','parent',GUIFigure,'units','normalized','position',[0.7 0.65 0.29 0.04],'Visible','off');

SeizureDuration = uicontrol('style','edit','parent',GUIFigure,'units','normalized','position',[0.7 0.5 0.29 0.04],'Visible','off');

% PushButton
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Push button to start analysis
PushStart=uicontrol('style','pushbutton','parent',GUIFigure,'units','normalized','position',[0.5 0.1 0.25 0.1],'string','Start','callback',@StartProgram);

Browse_EEG_file=uicontrol('style','pushbutton','parent',GUIFigure,'units','normalized','position',[0.03 0.8 0.15 0.04],'string','Browse','callback',@BrowseEEG);

% Conditional pushbutton
% ~~~~~~~~~~~~~~~~~~
Browse_Annotate_EEG=uicontrol('style','pushbutton','parent',GUIFigure,'units','normalized','position',[0.03 0.5 0.15 0.04],'string','Browse','callback',@BrowseAnnotate,'Visible','off');
