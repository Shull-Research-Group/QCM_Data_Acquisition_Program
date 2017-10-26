function varargout = QCM_v002f_Fenrir(varargin)
%
% Copyright (C) 2016 Joshua Yeh (Shull Research Group, Northwestern Uni.)
% Con   tributing authors: Shu Funato
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%   
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>
%
%
% QCM_V002F_FENRIR MATLAB code for QCM_v002f_Fenrir.fig
%      QCM_V002F_FENRIR, by itself, creates a new QCM_V002F_FENRIR or raises the existing
%      singleton*.
%
%      H = QCM_V002F_FENRIR returns the handle to a new QCM_V002F_FENRIR or the handle to
%      the existing singleton*.
%
%      QCM_V002F_FENRIR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in QCM_V002F_FENRIR.M with the given input arguments.
% 
%      QCM_V002F_FENRIR('Property','Value',...) creates a new QCM_V002F_FENRIR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before QCM_v002f_Fenrir_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to QCM_v002f_Fenrir_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help QCM_v002f_Fenrir

% Last Modified by GUIDE v2.5 18-Aug-2017 15:28:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @QCM_v002f_Fenrir_OpeningFcn, ...
                   'gui_OutputFcn',  @QCM_v002f_Fenrir_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before QCM_v002f_Fenrir is made visible.
function QCM_v002f_Fenrir_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to QCM_v002f_Fenrir (see VARARGIN)

% Choose default command line output for QCM_v002f_Fenrir
handles.output = hObject;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%NOTE: YOU CAN ADJUST THE DEFAULT VALUES/SETTINGS HERE, BUT BE CAREFULL
%WHEN MANIPULATING THE VALUES!! SAVING THE ORIGINAL VERSION IS STRONGLY
%RECOMMENDED.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%initialize AccessMyVNA program
clc; format compact; format long;
handles.GUI_hf=gcf;%store the main GUI handle in the handles structure
pos=get(handles.GUI_hf,'position');%extract the position values of the main GUI handle
set(handles.GUI_hf,'position',[20 pos(2) pos(3) pos(4)])%adjust the main GUI handle position values
h=waitbar(0,'Initializing MATLAB GUI...');
set(h,'WindowStyle','modal');
figure(h);
disp('Initializing MATLAB GUI...');
handles.din.AVNA='AccessMyVNAv0.7\release\AccessMyVNA.exe';%gold version of AccessMyVNA
% handles.din.AVNA='AccessMyVNAv0.7\release\AccessMyVNA_mod021015.exe';% modiied version
try %This try block attempts to kill the AccessMyVNA program through the Windows Command program, this will prevent multiple instances of the same program
    [~,~]=system('taskkill /im "AccessMyVNA.exe"');
    [~,~]=system('taskkill /im "MyVNA.exe"');s
catch
    disp('Error in running commands in Windows Command line');
end%try
% Update handles structure
handles.din.freq_range=[4 6; 14 16; 24 26; 34 36; 44 46; 54 56];%this stores the accepted frequency ranges for each harmonic
handles.din.avail_harms=[1 3 5 7 9 11];%DO NOT CHANGE THIS
handles.din.error_count=1;%declar an error log vounter variable that is stored int he handles structure
handles.din.error_log={};%declare an error log variable that is stored in the handles structure
handles.din.prev_cond=zeros(str2double(get(handles.num_datapoints,'string')),1);
handles.din.harmonic=1;%default current harmonic value
handles.din.active_harm_primaryaxes1=[];%allocate fieldname that will hold the active harmonics that will be plotted
handles.din.active_harm_primaryaxes2=[];%allocate fieldname that will hold the active harmonics that will be plotted
handles.din.n=1;%starting initial index for FG_frequency
handles.din.max_datapts=2.5e4;%maximum datapoints the program will collect
handles.din.FG_frequency=NaN(handles.din.max_datapts,13);%preallocate matrix
handles.din.FG_freq_shifts=NaN(handles.din.max_datapts,13);%preallocate matrix
handles.din.chi_sqr_value=NaN(handles.din.max_datapts,13);%preallocate matrix
handles.din.std_fit=NaN(handles.din.max_datapts,13);%preallocate matrix
handles.din.set_span_factor_sensitivity=0.1;%this factor governs the sensitivity for the "set span" peak tracking algorithm
handles.din.fit_factor_range=6;%this factor influences the width or freq range in which the raw spectras will be fitted
set(handles.fit_factor,'string',handles.din.fit_factor_range);
handles.din.default_start_freq=[4.9;14.9;24.9;34.9;44.9;54.9];%set default start frequencies
handles.din.default_end_freq=[5.1;15.1;25.1;35.1;45.1;55.1];%set default end frequencies
handles.din.num_pts=300;%set default number of datapoints
handles.din.flag=0;%this is the toggle state of the raw fig button
handles.din.output_path=pwd;%set default path directory to current path working directory
handles.din.refit_flag=0;%create a flag that keeps track whether or not raw spectra data has been uploaded (0: no data loaded) (1: loaded)
handles.din.refit.loaded_var=[];%create a dummy variable that will hold any raw spectra data information for refitting processes
handles.din.bare_flag=0;%create a flag that keeps track whether or not a bare crystal data that redefines the reference freq and diss has been loaded (0=unloaded) (1=loaded)
handles.prefs.show_GB=1;%set the default option to show fitted parameters to on
handles.prefs.schedule_toggle=0;%This is the default toggle state of whether or not to run on a measurement schedule or not (1 for yes and 0 for no)
handles.prefs.clc_cw=0;%set default option to clear the command window before recording data
handles.prefs.output_diary=0;%set default option to not save a log of the comman window into a text file
handles.prefs.output_raw=0;%set default option to output the raw data onto the base workspace after each scan
handles.prefs.simul_peak=1;%set default option to fit conductance and susceptance simultaneously
handles.prefs.num_peaks=[1,0,1,0,1,0,1,0,1,0,1];%set default option for the number of peaks the program will maximally fit
handles.prefs.sensitivity(1)=5e-3;%peak sensitivity factor for the 1st harmonic
handles.prefs.sensitivity(3)=5e-3;%peak sensitivity factor for the 3rd harmonic
handles.prefs.sensitivity(5)=5e-3;%peak sensitivity factor for the 5th harmonic
handles.prefs.sensitivity(7)=5e-3;%peak sensitivity factor for the 7th harmonic
handles.prefs.sensitivity(9)=5e-3;%peak sensitivity factor for the 9th harmonic
handles.prefs.sensitivity(11)=5e-3;%peak sensitivity factor for the 11th harmonic
handles.prefs.peak_min(1)=.2;%min. peak finding threshold for the 1st harmonic
handles.prefs.peak_min(3)=.2;%min. peak finding threshold for the 3rd harmonic
handles.prefs.peak_min(5)=.2;%min. peak finding threshold for the 5th harmonic
handles.prefs.peak_min(7)=.2;%min. peak finding threshold for the 7th harmonic
handles.prefs.peak_min(9)=.2;%min. peak finding threshold for the 9th harmonic
handles.prefs.peak_min(11)=.2;%min. peak finding threshold for the 11th harmonic
handles.prefs.measurement_schedule=[];%set the default measurement schedule
handles.prefs.measurement_schedule_rnames={'Start','End'};%row names associated with the measurement scheduler
handles.prefs.schedule_toggle=0;%toggle state of the measurement schedule
handles.prefs.show_dfdg=1;%default state of whether or not to show the freq and bandwidth shifts
handles.prefs.email_recipient=[];%prealloate empty field that will be used to store a recipient email address for the email notfication functionality
handles.prefs.email_host=[];%preallocate empty field that will be used to store the host email address for the email notification functionality
handles.prefs.email_pw=[];%preallocate empty field that will be used to store the password of the host mail address for the email notification functionality
handles.prefs.email_outgoing_server=[];%preallocate empty filed that will be used to store the outgoing email server for the email notification functionality
handles.prefs.plot_dynamic_refresh=1;%this determines whether or not the plot will be dynamically refreshed after each scan
handles.prefs.save_spectra=0;%This determines whether or not the program will save the spectra files in the legacy format (v002d and below or not)
handles.din.refit.counter=1;%this counter is associated with keeping track which variable to load onto the program duringthe refitting process
handles.din.refit_filename=[];%the filename in which the refitting process will be enacted on
handles.din.refit_finish1=0;%this is a flag that represent whether or not all of the spectras for the 1st harmonic is finished refitting (refitting mode)
handles.din.refit_finish3=0;%this is a flag that represent whether or not all of the spectras for the 3rd harmonic is finished refitting (refitting mode)
handles.din.refit_finish5=0;%this is a flag that represent whether or not all of the spectras for the 5th harmonic is finished refitting (refitting mode)
handles.din.refit_finish7=0;%this is a flag that represent whether or not all of the spectras for the 7th harmonic is finished refitting (refitting mode)
handles.din.refit_finish9=0;%this is a flag that represent whether or not all of the spectras for the 9th harmonic is finished refitting (refitting mode)
handles.din.refit_finish11=0;%this is a flag that represent whether or not all of the spectras for the 11th harmonic is finished refitting (refitting mode)
handles.din.bare_path=pwd;%sets the default path directory when loading the bare crystal file
handles.din.refit_raw=[];%creates an empty structure array in which the raw loaded data will be stored in
handles.din.refit_time_index=1;%this index determines where in the loaded variable name to interpret as time
handles.din.refit_path=pwd;%set the default path directory
handles.din.refit_flag1=0;%flag associated with the refitting process
set(handles.wb,'xlim',[0 1]);cla(handles.wb);%set properties associated with the progress bar in between recordings of measurements
set(handles.refit_start,'visible','off');%turn of visibility of starting refit point
set(handles.refit_inc,'visible','off');%turn off visibility of the incremental value for the refitting proces
set(handles.refit_end,'visible','off');%turn off visibility of the ending refit point
filename='AccessMyVNAv0.7\release\state_matlab.txt';%define the filename in which the text file reflects the state of the MATLAB GUI
fileID=fopen(filename,'w');%set the text file to "Writeable"
fprintf(fileID,'%i\r\n',1);%Write in the "state_matlab.txt" with a value on 1, this indicates that the GUI is on and active. A value of zero means that the GUI is closed and inactive.
fclose(fileID);%properly close the filename associated with the file identifier, fileID
for dum=1:2:11%define the start/end frequencies and number of spectral datapoints for each harmonics
    name1=['start_f',num2str(dum)];
    name2=['end_f',num2str(dum)];
    name3=['num_pts',num2str(dum)];
    set(handles.(name1),'string',num2str(handles.din.default_start_freq((dum+1)/2)));
    set(handles.(name2),'string',num2str(handles.din.default_end_freq((dum+1)/2)));
    set(handles.(name3),'string',['# pts: ',num2str(handles.din.num_pts)]);
end%for dum=1:2:11
waitbar(0.1,h,'Preallocated MATLAB arrayso...');
disp('Preallocated MATLAB arrays...');
figure(h);
%set reference frequency shifts and dissipation shifts
handles.din.ref_freq=[5 15 25 35 45 55].*1e6;%units in Hz
handles.din.ref_diss=[0 0 0 0 0 0];%units in Hz
waitbar(0.15,h,'Reference values set...');
%inital formating of axes and buttons, etc.
waitbar(0.2,h,'Formatting plots and legend boxes...');
disp('Formatting plots and legend boxes...');
plot(handles.axes7,[0,1],[nan,nan],'-',[0,1],[nan,nan],'r-','visible','on');%add a legend box for the raw conductance plots
set(handles.axes7,'fontsize',6);%set font size of the legend
uistack(handles.axes7,'top');
l=legend(handles.axes7,'Conductance','Susceptance','Location','West');
set(l,'orientation','horizontal'); %set location of legend box
%add a legend for the harmonics
marker_color={[0 0 0],[0 0 1],[1 0 0],[0 0.5 0],[1 .8398 0],[.25 .875 .8125]};%marker color for the legend
figure(h);
set(handles.uipanel8,'visible','off');
set(handles.uipanel4,'visible','off');
set(handles.peak_finding,'visible','on','userdata',[handles.prefs.sensitivity(1:2:11);handles.prefs.peak_min(1:2:11);handles.prefs.num_peaks(1:2:11)]');
axes(handles.axes14);
for dum=1:6
    waitbar(0.2+dum*0.05,h);
    plot([0,1],[nan,nan],'o','visible','on','color',...
    marker_color{dum},'markersize',6,'linewidth',1.5);
    if verLessThan('matlab','8.3.0.532')%execute if MATLAB version is 2013a or earlier
        hold(handles.axes14);
    else%execute if MATLAB version id 2014b or later
        hold(handles.axes14,'on');
    end%
    figure(h);
end%for dum=1:6
%Create a legend box for the primaryaxes1 and primaryaxes2
l=legend('1st','3rd','5th','7th','9th','11th','location','west');
posL=get(l,'position');
set(l,'orientation','horizontal','fontsize',10,'position',[2.2*posL(1) 1.27*posL(2) posL(3) posL(4)]);
set(handles.axes14,'fontsize',6,'visible','off');
figure(h);
%The following code creates the plot handles for each axes in the GUI.
%There is a plot handle for each harmonic, for the conductance, and for the
%susceptance. So a total of 24 plothandles with an additional
%"miscellaneous" plot handles are created. Predefining plots handles before
%hand makes the plotting process smoother, since the plot handles are not
%being created/destroyed each time a plot on the GUI refreshes.
for dum=1:6%create plot handles for the raw spectra axes
    ax_name1=['axes',num2str(dum)];
    ax_name2=['sa',num2str(dum)];    
    plot_name1=['phantom',num2str(dum),'a'];
    plot_name2=['phantom',num2str(dum),'b'];    
    plot_name3=['phantom',num2str(dum),'c'];
    plot_name4=['phantom',num2str(dum),'d'];
    plot_name5=['phantom',num2str(dum),'e'];
    plot_name6=['phantom',num2str(dum),'f'];
    plot_name7=['phantom',num2str(dum),'g'];
    plot_name8=['phantom',num2str(dum),'h'];
    plot_name9=['phantom',num2str(dum),'i'];
    plot_name10=['phantom',num2str(dum),'j'];
    if verLessThan('matlab','8.3.0.532')%execute if MATLAB version is 2013a or earlier
        hold(handles.(ax_name1));hold(handles.(ax_name2));
    else%execute if MATLAB version id 2014b or later
        hold(handles.(ax_name1),'on');hold(handles.(ax_name2),'on');
    end% if verLessThan('matlab','8.3.0.532')
    handles.spectra_handles.(plot_name1)=plot(handles.(ax_name1),[1,2],[1,1],'bx-','markersize',6,'visible','off','userdata',2*dum-1);
    handles.spectra_handles.(plot_name2)=plot(handles.(ax_name2),[1 2],[1 1],'rx-','markersize',6,'visible','off','userdata',2*dum-1);    
    handles.spectra_handles.(plot_name3)=plot(handles.(ax_name1),[1,2],[1,1],'k-','linewidth',2,'visible','off');
    handles.spectra_handles.(plot_name4)=plot(handles.(ax_name2),[1,2],[1,1],'k-','linewidth',2,'visible','off');
    handles.spectra_handles.(plot_name5)=plot(handles.(ax_name1),[1,2],[1,1],'-','linewidth',2,'color',[0.82031 0.410156 0.11718],'visible','off');
    handles.spectra_handles.(plot_name6)=plot(handles.(ax_name1),[1,2],[1,1],'mo','linewidth',1,'markerfacecolor','m','markersize',6,'visible','off');
    handles.spectra_handles.(plot_name7)=plot(handles.(ax_name1),[1,2],[1,1],'o','linewidth',1,'color',[0 0.5 0],'markerfacecolor',[0 0.5 0],'markersize',6,'visible','off');
    handles.spectra_handles.(plot_name8)=plot(handles.(ax_name1),[1,2],[1,1],'k-.','linewidth',1,'visible','off');
    handles.spectra_handles.(plot_name9)=plot(handles.(ax_name1),[1,2],[1,1],'k-.','linewidth',1,'visible','off');
    handles.spectra_handles.(plot_name10)=plot(handles.(ax_name1),[1,2],[1,1],'x','linewidth',1,'visible','off','color',[0 0.5 0],'markersize',6);
    set(handles.(ax_name2),'visible','off','box','off','yaxislocation','right','color','none','ycolor','r');
    set(handles.(ax_name1),'visible','on','box','off');
    if verLessThan('matlab','8.3.0.532')%execute if MATLAB version is 2013a or earlier
        hold(handles.(ax_name1));hold(handles.(ax_name2));
    else%execute if MATLAB version id 2014b or later
        hold(handles.(ax_name1),'off');hold(handles.(ax_name2),'off');
    end%if verLessThan('matlab','8.3.0.532')
end%for dum-1:6
if verLessThan('matlab','8.3.0.532')%execute if MATLAB version is 2013a or earlier
    hold(handles.primaryaxes1);hold(handles.primaryaxes2);
else%execute if MATLAB version id 2014b or later
    hold(handles.primaryaxes1,'on');hold(handles.primaryaxes2,'on');
end%if verLessThan('matlab','8.3.0.532')
for dum=1:6%create plot handles for the primary axes
    handles.primary_handles.(['phantom',num2str(dum),'a'])=plot(handles.primaryaxes1,[1,2],[1,1],'o-','color',marker_color{dum},'visible','off','userdata',2*dum-1,'markersize',6);    
    handles.primary_handles.(['phantom',num2str(dum),'b'])=plot(handles.primaryaxes2,[1,2],[1,1],'o-','color',marker_color{dum},'visible','off','userdata',2*dum-1,'markersize',6);
end%for dum=1:6
if verLessThan('matlab','8.3.0.532')%execute if MATLAB version is 2013a or earlier
    hold(handles.primaryaxes1);hold(handles.primaryaxes2);
    disp(['This program is designed for MATLAB 2014b or later. Running this program on ',...
        version,' might lead to unexpected bugs! Use at your own risk!']);
else%execute if MATLAB version id 2014b or later
    hold(handles.primaryaxes1,'off');hold(handles.primaryaxes2,'off');
end%if verLessThan('matlab','8.3.0.532')
set(handles.axes7,'visible','off');
set(handles.peak_center,'visible','off');
set(handles.center1,'value',1);
set(handles.primaryaxes1,'fontsize',8);
set(handles.primaryaxes2,'fontsize',8);
set(handles.maintain_myVNA,'value',1);
dcm_obj=datacursormode(handles.primary1);
dcm_obj.Enable='off';
delete(findall([handles.primaryaxes1 handles.primaryaxes2],'Type','hggroup'));
set(dcm_obj,'UpdateFcn',@default_dcm);
xlabel(handles.primaryaxes1,'Time (min)','fontsize',8,'fontweight','bold');
ylabel(handles.primaryaxes1,'Frequency (Hz)','fontsize',8,'fontweight','bold');
xlabel(handles.primaryaxes2,'Time (min)','fontsize',8,'fontweight','bold');
ylabel(handles.primaryaxes2,'Frequency (Hz)','fontsize',8,'fontweight','bold');
set(handles.num_datapoints,'userdata',ones(11,1).*handles.din.num_pts);%set the default number of datapoints for each harmonic
waitbar(0.6,h);
for dum=1:6%add labels to the conductance axes
    waitbar(0.6+dum*0.05,h);
    axname=['axes',num2str(dum)];
    if verLessThan('matlab','8.4.0')%execute if MATLAB version is 2013a or earlier
        set(handles.(axname),'fontsize',4);
    else%execute if MATLAB version id 2014b or later
        set(handles.(axname),'fontsize',4,'fontsmoothing','on');
    end%
    xlabel(handles.(axname),'Freqency (Hz)','fontsize',6);
    ylabel(handles.(axname),'mSiemens (mS)','fontsize',6);
end%for dum=1:6
%add folder paths
addpath('AccessMyVNAv0.7\release');
%set default reference time
set(handles.reference_time,'string',datestr(clock,'yy:mm:dd:HH:MM:SS:FFF'));
%set default appearances and properties for GUI objects
set(handles.uipanel8,'visible','on');
set(handles.uipanel4,'visible','on');
set(handles.text2,'userdata',0);
set(handles.confirm_del,'userdata',0);
set(handles.email_push,'userdata',0);
write_settings(handles,handles.din.harmonic);%this function writes out the settings text file
plot_choice_Callback(handles.plot1_choice, eventdata, handles);%refresh primaryaxes1
plot_choice_Callback(handles.plot2_choice, eventdata, handles);%refresh primaryaxes2
handles.default_settings=handles.din;%define a default handles.din state
waitbar(1,h,'MATLAB GUI initiatlized!');
figure(h);
disp('MATLAB GUI initialized!');
guidata(hObject, handles);
delete(h);
warning('off','MATLAB:DELETE:FileNotFound');%suppress this warning message
try delete('qcm_diary.txt');catch;end;
% UIWAIT makes QCM_v002f_Fenrir wait for user response (see UIRESUME)
% uiwait(handles.primary1);


% --- Outputs from this function are returned to the command line.
function varargout = QCM_v002f_Fenrir_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%% Measurement process
function start_Callback(hObject, ~, handles)
% --- Executes on button press in start.
handles=cla_raw_Callback(hObject, 1, handles);
tic
err_counter=0;
pause on;
if get(handles.raw_fig,'value')==1%if the raw fig mode is turned on before the recording process, toggle handles.din.flag to 1
    handles.din.flag=1;
    disp('Please turn off the Raw Figure Mode before starting the measurement process!');
    set(handles.status,'string','Status: Please turn off the Raw Figure Mode before starting the measurement process!',...
        'backgroundcolor','y','foregroundcolor','r');
    handles.din.flag=0;
    if handles.din.refit_flag==0
        set(handles.start,'value',0,'string','Record Scan','backgroundcolor',[0 0.5 0],'foregroundcolor','w');
    else
        set(handles.start,'value',0,'string','Refit Scan','backgroundcolor',[0 0.5 0],'foregroundcolor','w');
    end%if handles.din.refit_flag==0
    guidata(hObject,handles);
    return
end%get(handles.raw_fig,'value')==1
% %//////////////////////////////////////////////////////////////////////////
%This if statement block checks to see if the user defined an output
%filename and location to store the data (besides the default output
%filename and location
if strcmp(get(handles.filename_txt,'string'),'<Output Filename>')&&get(handles.start,'value')==1
    choice=questdlg('Do you want to designate a filename and location to store your data?',...
        'Output filename and path confirmation','Yes');
    switch choice
        case 'Yes'
            handles=save_data_Callback(hObject, 1, handles);
            if handles.din.refit_flag==0
                try%test if the designated outputfilename is a valid filename
                    test.(handles.din.output_filename)=1;
                    clear test;
                catch err_message
                    assignin('base','err_message',err_message);
                    disp('Filename is not valid! Please use MATLAB variable naming rules.');
                    disp('Please try again');
                    set(handles.status,'string','ERROR!Filename is not valid! PLease use MATLAB variable naming rules. Please try again...',...
                        'backgroundcolor','r','foregroundcolor','k');                    
                    if handles.din.refit_flag==0
                        set(handles.start,'value',0,'string','Record Scan','backgroundcolor',[0 0.5 0],'foregroundcolor','w');
                    else
                        set(handles.start,'value',0,'string','Refit Scan','backgroundcolor',[0 0.5 0],'foregroundcolor','w');
                    end%if handles.din.refit_flag==0
                    return
                end%try    
            end%if handles.din.refit_flag==0
        case 'No'
            handles.din.output_filename='Default';
            handles.din.output_path='';
        case 'Cancel'
            if handles.din.refit_flag==0
                set(handles.start,'value',0,'string','Record Scan','backgroundcolor',[0 0.5 0],'foregroundcolor','w');
            else
                set(handles.start,'value',0,'string','Refit Scan','backgroundcolor',[0 0.5 0],'foregroundcolor','w');
            end%if handles.din.refit_flag==0
            return
    end%switch choice
end%if strcmp(get(handles.filename_txt,'string'),'<Output Filename>')
% %//////////////////////////////////////////////////////////////////////////////////////////////////////
%DISABLE GUI FUNCTIONS
%disable some of the features to prevent errors from occuring caused by
%running two blocks of code simultaneously
set(handles.peak_centering,'value',0);
harm_tot=find_num_harms(handles);%find total active harmonics
if isempty(harm_tot)
    harm_tot=1;
    set(handles.harm1,'value',1);
end%if isempty(harm_tot)
set(handles.harmonics_text,'userdata',harm_tot);%store the harmonic that will be scanned in the userdata property of the harmonic_text gui handle
peak_centering_Callback(handles.peak_centering, 1, handles);drawnow;
set(handles.peak_centering,'visible','off');%hide the button
set(handles.clear_datapoints,'visible','off');%hide the button
set(handles.home_push,'visible','off');%hide the home button
set(handles.del_mode,'visible','off','state','off');%hide the del_mode toolbar button
del_mode_ClickedCallback(handles.del_mode, 1, handles);
set(handles.confirm_del,'visible','off');%hide the confim_del toolbar button
set(handles.refit_start,'style','text');%prevent the user from editing the value during the refitting process
% %/////////////////////////////////////////////////////////////////////////////////////////////////////
counter=1;%counter
write_settings(handles,harm_tot(1));%this function writes out the settings text file
%update string of the start button based on the toggle state
if get(handles.start,'value')==1
    if isempty(findobj('Number',998))==0
        delete(figure(998));
        pref_ClickedCallback(handles.pref, 1, handles);
    end%if isempty(findobj('string','Set Preferences (Beta)','Number',998))==0
    if handles.prefs.clc_cw==1%clear window only when the user specifies to clear the window, this can be set in the user preferences
        clc
    end%if handles.prefs.clc_cw==1
    set(handles.start,'string','Stop Scan','backgroundcolor','r');
elseif get(handles.start,'value')==0
    if handles.din.refit_flag==0
        set(handles.start,'value',0,'string','Record Scan','backgroundcolor',[0 0.5 0],'foregroundcolor','w');
    else
        set(handles.start,'value',0,'string','Refit Scan','backgroundcolor',[0 0.5 0],'foregroundcolor','w');
    end%if handles.din.refit_flag==0
    set(handles.uipanel1,'visible','off');%hides the settings panel 
    set(handles.status,'string','Status: Stopping the data recording process. Please wait...',...
        'backgroundcolor','k','foregroundcolor','r');
    set(handles.raw_fig,'value',0);        
    set(handles.peak_centering,'visible','on');%display the button
    set(handles.clear_datapoints,'visible','on');%display the button
    set(handles.uipanel1,'visible','on');%display uipanel1
    set(handles.home_push,'visible','on');%display the reset button
    set(handles.del_mode,'visible','on');%display the del_mode toolbar button
    return
end%if get(handles.start,'value')==1
%Check/modify output filename so that errors will not occur during the
%scanning process and storing of spectra data
try
    disp(['Output filename: ',handles.din.output_filename]);
    output_filename=handles.din.output_filename;
    output_filename=strrep(output_filename,' ','_');
    output_filename=strrep(output_filename,'(','_');
    output_filename=strrep(output_filename,')','_');
    output_filename=strrep(output_filename,'.','_');
    output_filename=strrep(output_filename,'-','_');
    if length(output_filename)>namelengthmax
        disp('Error in specifying filename!');
        set(handles.status,'string','Status: ERROR in specifying filename! Filename is too long!',...
            'backgroundcolor','r','foregroundcolor','k');
        handles.din.error_log(handles.din.error_count,1)={[datestr(clock),' ERROR in specifying filename! Filename is too long!']};
        handles.din.error_count=handles.din.error_count+1;
        assignin('base','error_log',handles.din.error_log);
        disp('Recording process terminated');
        return
    end%if length(output_filename)>namelengthmax
catch
    disp('Error in specifying filename!');
    set(handles.status,'string','Status: ERROR in specifying filename!','backgroundcolor','r','foregroundcolor','k');
    handles.din.error_log(handles.din.error_count,1)={[datestr(clock),' ERROR in specifying filename!']};
    handles.din.error_count=handles.din.error_count+1;
    assignin('base','error_log',handles.din.error_log);
    disp('Recording process terminated');
    return
end
%///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
%designate output file location and name for output data
if get(handles.filename_txt,'userdata')==0&&handles.din.refit_flag==0    
    spectra = matfile('raw_spectras.mat','Writable',true);%open matfile and set access to writable
elseif get(handles.filename_txt,'userdata')~=0&&handles.din.refit_flag==0
    
    spectra = matfile([handles.din.output_path,handles.din.output_filename,'_raw_spectras.mat'],'Writable',true);%open matfile and set access to writable
end%if get(handles.filename_txt,'userdata')==0
spectra.version=get(handles.text17,'string');%write the version of the matlab gui program that was used to collect the data
if get(handles.filename_txt,'userdata')==0
    fg_values=matfile('fg_values.mat','Writable',true);
else
    fg_values=matfile([handles.din.output_path,handles.din.output_filename],'Writable',true);
end%if get(handles.filename_txt,'userdata')==0
fg_values.version=get(handles.text17,'string');%write the version of the matlab gui program that was used to collect the data
% %///////////////////////////////////////////////////////////////////////////////////////////////////////
%Check to see if email notifications are turned on
if isempty(get(handles.email_push,'userdata'))~=1
    if get(handles.email_push,'userdata')==1
        diary('qcm_diary.txt'); diary on;
        disp('#################################');
        try
            cprintf('blue','Email notifications have been turned on\n');
        catch
            disp('Email notifications have been turned on');
        end%try
        disp(['Notifications will be sent to ',get(handles.prefs.email_recipient,'userdata')]);
    end% if get(handles.email_push,'userdata')==1
end%if isempty(get(handles.email_push,'userdata'))~=1
if handles.prefs.output_diary==1
    try
        cprintf('blue','The Command Window Diary has been turned on\n');
    catch
        disp('The Command Window Diary has been turned on');
    end%try
    diary('qcm_diary.txt'); diary on;
    disp('#################################');
end%if handles.prefs.output_diary==1
% %//////////////////////////////////////////////////////////////////////////////////////////////////////////////
%Check to see if the fitting options were accidentally set to
%"user-defined" values. If so, change it to "Previous Values"
for dum=1:2:11
    if get(handles.(['fit',num2str(dum)]),'userdata')==5||strcmp(get(handles.(['fit',num2str(dum)]),'string'),'User-defined')
        set(handles.(['fit',num2str(dum)]),'userdata',4,'string','Previous values');
    end%if get(handles.(['fit',num2str(dum)]),'userdata')==5
end%for dum=1:2:11
%///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
%Format reference time, define other variables, and disp other misc. things before initiating while loop
start_time2=datevec(get(handles.reference_time,'string'),'yy:mm:dd:HH:MM:SS:FFF');%get reference time into an appropriate format
n=handles.din.n;
disp('-------------------------------');
my_disp('Measurement process initiated>>>>>>>>\n',[0 0 0.7]);
my_disp('Time of initiation: ','text');
my_disp([datestr(clock),'\n'],[0 0.5 0]);
my_disp('Reference time: ','text');
my_disp([datestr(start_time2),'\n'],[0 0.5 0]);
if handles.prefs.schedule_toggle==1%if the measurement scheduler is turned on display the following
    my_disp('Measurement Scheduler has been enabled!\n',[0 0 0.7]);
    for dum=1:size(handles.prefs.measurement_schedule,1)%display the schedule
        my_disp([handles.prefs.measurement_schedule_rnames{dum,1},': '],'text');
        my_disp([handles.prefs.measurement_schedule{dum,1},'\n'],[0 0.5 0]);
    end%for dum=1:size(handles.prefs.measurement_schedule,1)
    start_date_vec=datevec(handles.prefs.measurement_schedule{1,1});%convert the start event to a date vector
    %check to see if the start event should be triggered
    while etime(start_date_vec,clock)>0&&get(handles.start,'value')==1%run this code if we should wait for time to pass before the start event
        set(handles.status,'string',['Status: Start time for measurment is: ',handles.prefs.measurement_schedule{1,1},'........',...
            num2str(etime(start_date_vec,clock)),'s left before start of the measurment process.'],'backgroundcolor','y','foregroundcolor','r');
        drawnow;
        pause(1);
    end%if etime(start_date_vec,clock)<=0
end%if handles.prefs.schedule_toggle==1
handles.din.refit_flag1=0;%reset the refit_flag1

%-------------------------------------------------------------------------------------------------while loop begins here!   
while get(handles.start,'value')==1&&handles.din.refit_flag==0||...
        get(handles.start,'value')==1&&handles.din.refit_flag==1&&...
        sum([handles.din.refit_finish1,handles.din.refit_finish3,...
        handles.din.refit_finish5,handles.din.refit_finish7,...
        handles.din.refit_finish9,handles.din.refit_finish11])==0%<-----------------while loop begins here!
    %/////////////////////////////////////////////////////////////////////////////////////
    %RUN THIS CODE IF THE MEASUREMENT SCHEDULER IS TURNED ON
    if handles.prefs.schedule_toggle==1
        timeline=handles.prefs.measurement_schedule(:,1);%extract out all of the times
        timeline2=ones(size(timeline));%preallocate this array in order to speed the for loop
        for dum=1:size(timeline,1)%determine the relative elapsed time from now to the defined times in the schedule
            timeline2(dum)=etime(datevec(timeline{dum}),clock);
        end%for dum=1:size(timeline,1)
        k=find(timeline2<=0,1,'last');%find the the most recent event that has passed and execute it      
        if handles.prefs.schedule_state(k)==0%execute this code only if the code has not already been executed
            set(handles.record_time_increment,'string',handles.prefs.measurement_schedule{k,2});%set the user-defined recording time increment
            drawnow;%force the computer to display the updated recording time increment
            my_disp(['Initiated ',handles.prefs.measurement_schedule_rnames{k},'!\n'],[0 0 0.7]);
            handles.prefs.schedule_state(k)=1;%remember that this event has already bben excuted and does not need to be executed again
            if k==size(handles.prefs.measurement_schedule,1)%Only execute this code if it is the ending event
                set(handles.start,'value',0);%un toggle the start button
                start_Callback(hObject,1,handles);%stop the measurement process
            end%if k==size(handles.measurement_schedule,1)
        end%if handles.prefs.schedule_state(k)==0        
    end%if get(handles.prefs.schedule_toggle)==1
    %/////////////////////////////////////////////////////////////////////////////////////
   harm_tot=find_num_harms(handles);%find total active harmonics
   if isempty(harm_tot)%if there are no harmonics selected to be recorded by the user, default to recording the first harmonic
        harm_tot=1;
        set(handles.harm1,'value',1);
   end%if isempty(harm_tot)
    %//////////////////////////////////////////////////////////////
    %Determine variable name in which the spectra information will be
    %stored and time stamp information
    if handles.din.refit_flag==0%run this if collecting dynamic data
        time_now=datestr(clock,'yy:mm:dd:HH:MM:SS:FFF');%Current time
        time_now1=datevec(time_now,'yy:mm:dd:HH:MM:SS:FFF');%Find current time and make it a vector
        Z=etime(time_now1,start_time2);%elapsed time in seconds
        time_elapsed=Z./60;%time in minutes
        timestamp=strrep(num2str(time_elapsed),'.','dot');%replace decimal with 'dot' 
        my_disp('---------------------\n',[0 0.5 0]);
        my_disp('Timestamp: ','text');
        my_disp([num2str(time_elapsed),' min\n'],'blue');        
        set(handles.last_time,'string',['Last timepoint: ',num2str(time_elapsed),' min']);
    else%run this if refitting raw spectra data
        try
            try
                rawfile=['h',num2str(harm_tot(1))];
            catch%run this if dum is equal to 1
                rawfile=['h',num2str(harm_tot(2))];
            end%try
                time_elapsed=handles.din.refit_timepoints(handles.din.refit.counter);
                timestamp2=num2str(time_elapsed);%time in minutes                             
                my_disp('---------------------\n',[0 0.5 0]);
                my_disp('Timestamp: ','text');
                my_disp([timestamp2,' min\n'],'blue'); 
                set(handles.last_time,'string',['Last timepoint: time_elapsed min']); 
        catch            
        end%try
    end%if handles.din.refit_flag==0    
    %//////////////////////////////////////////////////////////////
    %if in refitting mode display it in the command window
    if handles.din.refit_flag==1
        try  cprintf('blue','Currently in refitting mode!\n');
        catch;  disp('Currently in refitting mode!');
        end%try
    end%if handles.din.refit_flag==1
    for dum=1:size(harm_tot,1)%this for loop will repeat through a whole cycle of harmonics that will be measured
        my_disp('..............................\n',[0 0.5 0]);        
        try
            handles.din.harmonic=harm_tot(dum);%write the current harmonic into the handles.din structure
            handles.din.n=n;%write the current index datapoint in the handles.din. structure
            if dum==size(harm_tot,1)
                handles.din.refit_flag1=1;
            else
                handles.din.refit_flag1=0;
            end%if dum==size(harm_tot,1)
            [freq,conductance,susceptance,handles]=read_scan(handles);%read the data from the output myVNA c++ output file
        catch err_message
            disp('Error reading data!');
            set(handles.status,'string','Status: ERROR reading data!','foregroundcolor','k','backgroundcolor','r');
            assignin('base','err_message',err_message);            
        end
        if get(handles.start,'value')==1&&handles.din.refit_flag==0||handles.din.refit_flag==1&&handles.din.(['refit_finish',num2str(handles.din.harmonic)])==0
            my_disp('Scanning harmonic: ','cyan');
            my_disp([num2str(harm_tot(dum)),'\n'],'cyan');
            tic
            try                
                %only run the following if statement if the user wants to see the it dynamically            
                if get(handles.dynamic_fit,'value')==1%this if statement will run the Lorentzian fitting function
                      [combine_spectra,GB_parameters,handles,I,std_fit]=Lorentzian_dynamic_fit(handles,freq,conductance,susceptance,[freq,conductance,susceptance]);
                else%if the "dynamic fit" option is not turned on, output the freq, conductance, susceptance as a zero matrix
                    combine_spectra=[freq,conductance,susceptance,zeros(size(freq,1),7)];
                end%if get(handles.dynamic_fit,'value')==1
                G_fit=combine_spectra(:,4);
                B_fit=combine_spectra(:,5);
                %//////////////////////////////////////////////////////////////
                %write out spectra in specified spectra filename
                try
                    if handles.din.refit_flag==0%only run this code if not in "refitting" mode
                        if handles.prefs.save_spectra==1%decide what format to save the raw spectra
                            full_outputfilename=sprintf([output_filename,'_t_%s_iq_1_ih_',num2str((harm_tot(dum)+1)./2)],timestamp);
                            spectra.(full_outputfilename) = combine_spectra;%renames variable based on harm and writes the raw spectra data to <filename?>_raw_spectras.mat                                                                            
                        end%if handles.prefs.save_spectra==1
                        spectra.(['raw_spectra_',num2str(harm_tot(dum))])(n,1:4)={time_elapsed,output_filename,harm_tot(dum),combine_spectra};
                    end%if handles.din.refit_flag==0                    
                    if get(handles.dynamic_fit,'value')==1
                        handles.din.FG_frequency(n,1)=time_elapsed;%timestamp
                        handles.din.FG_frequency(n,harm_tot(dum)+1)=GB_parameters(1)*1e6;%frequency at peak of Lorentzian fit, f0
                        handles.din.FG_frequency(n,harm_tot(dum)+2)=GB_parameters(2)*1e4;%HMHW of Lorentzian peak, Ga
                        handles.din.FG_freq_shifts(n,1)=handles.din.FG_frequency(n,1);%timestamp
                        handles.din.FG_freq_shifts(n,harm_tot(dum)+1)=GB_parameters(1)*1e6-handles.din.ref_freq((harm_tot(dum)+1)./2);%calculate delta f
                        handles.din.FG_freq_shifts(n,harm_tot(dum)+2)=GB_parameters(2)*1e4-handles.din.ref_diss((harm_tot(dum)+1)./2);  %calculate delta Gamma
                        %Chi sq calculation (right now it is least squares not chi squares (04012014))
                        handles.din.chi_sqr_value(n,1)=time_elapsed;%Timestamps chi squared value variable
                        handles.din.chi_sqr_value(n,harm_tot(dum)+1)=sum(combine_spectra(:,6));%stores chi squared for G
                        handles.din.chi_sqr_value(n,harm_tot(dum)+2)=sum(combine_spectra(:,7));%stores chi squared for B 
                        %standard deviation from Lorentz fit using nlparci function
                        handles.din.std_fit(n,1)=time_elapsed;%Timestamp
                        handles.din.std_fit(n,harm_tot(dum)+1)=std_fit(1);%standard deviation of fitted f value
                        handles.din.std_fit(n,harm_tot(dum)+2)=std_fit(2);%standard deviation of fitted gamma value
                        if get(handles.radio_chi,'value')==1 %determine whether or not to show chi squared parameters next to plots
                            xsq_name=['X',num2str(harm_tot(dum))];
                            set(handles.(xsq_name),'visible','on','string',...
                                [char(935),'sq = ',num2str(handles.din.chi_sqr_value(n,harm_tot(dum)+1))],'fontsize',8);
                            disp([char(935),'sq = ',num2str(handles.din.chi_sqr_value(n,harm_tot(dum)+1))]);
                        end%if get(handles.radio_chi,'value')==1 
                        if handles.prefs.show_dfdg==1&&get(handles.radio_chi,'value')==0
                            xsq_name=['X',num2str(harm_tot(dum))];
                            set(handles.(xsq_name),'visible','on','string',...
                                [char(916),'f= ',num2str(GB_parameters(1)*1e6-handles.din.ref_freq((harm_tot(dum)+1)./2),1),...
                                '   ',char(916),char(915),'= ',num2str(GB_parameters(2)*1e4-handles.din.ref_diss((harm_tot(dum)+1)./2),1)],'fontsize',10,...
                                'tooltipstring',['<html>&Delta;f= ',num2str(GB_parameters(1)*1e6-handles.din.ref_freq((harm_tot(dum)+1)./2),8),...
                                ' &Delta;&Gamma;= ',num2str(GB_parameters(2)*1e4-handles.din.ref_diss((harm_tot(dum)+1)./2),8),'</html>']);
                        end%if handles.prefs.show_dfdg==1
                    end%if get(handles.dynamic_fit,'value')==1
                catch err_message
                    disp('Error in writing out spectra to specified filename!');
                    set(handles.status,'string','Status: ERROR in saving spectra!','backgroundcolor','r','foregroundcolor','k');
                    handles.din.error_log(handles.din.error_count,1)={[datestr(clock),' ERROR in saving spectra!']};
                    handles.din.error_count=handles.din.error_count+1;
                    err_counter=err_counter+1;
                    assignin('base','error_log',handles.din.error_log);
                    assignin('base','matlab_err_message',err_message);
                    if get(handles.email_push,'userdata')==1&&mod(err_counter,10)==9;
                        email_send(handles,'An error was detected by the QCM MATLAB Program: ERROR in saving spectra!');
                    end
                end% err_message
            %//////////////////////////////////////////////////////////////
            catch err_message
               disp('Error in start_callback function!');
               set(handles.status,'string','Status: ERROR in callback function!','backgroundcolor','r','foregroundcolor','k');
               handles.din.error_log(handles.din.error_count,1)={[datestr(clock),'  ERROR in callback function!']};
               handles.din.error_count=handles.din.error_count+1;
               err_counter=err_counter+1;
               assignin('base','error_log',handles.din.error_log);
               assignin('base','matlab_err_message',err_message);
                if get(handles.email_push,'userdata')==1&&mod(err_counter,10)==9;
                   email_send(handles,'An error was detected by the QCM MATLAB Program: ERROR in callback function!');
                end               
            end%try err_message
            if get(handles.start,'value')==0
                disp('Scan stopped');
            end%if get(handles.start,'value')==0
            counter=counter+1;
            %/////////////////////////////////////////////////////////////////
            %plot the data set
            %this if statement code refreshes the spectra every <user-defined>th iteration of the while loop    
            %output harmonic in appropriate axes
            ax1=['axes',num2str((harm_tot(dum)+1)*0.5)];
            ax2=['sa',num2str((harm_tot(dum)+1)*0.5)];            
            try
                try%this try statement will turn off the visibility of all of the spectra plothandles
                    set(handles.spectra_handles.(['phantom',num2str((harm_tot(dum)+1)*0.5),'a']),'visible','off');
                    set(handles.spectra_handles.(['phantom',num2str((harm_tot(dum)+1)*0.5),'b']),'visible','off');
                    set(handles.spectra_handles.(['phantom',num2str((harm_tot(dum)+1)*0.5),'c']),'visible','off');
                    set(handles.spectra_handles.(['phantom',num2str((harm_tot(dum)+1)*0.5),'d']),'visible','off');
                    set(handles.spectra_handles.(['phantom',num2str((harm_tot(dum)+1)*0.5),'e']),'visible','off');
                    set(handles.spectra_handles.(['phantom',num2str((harm_tot(dum)+1)*0.5),'f']),'visible','off');
                    set(handles.spectra_handles.(['phantom',num2str((harm_tot(dum)+1)*0.5),'g']),'visible','off');
                    set(handles.spectra_handles.(['phantom',num2str((harm_tot(dum)+1)*0.5),'h']),'visible','off');
                    set(handles.spectra_handles.(['phantom',num2str((harm_tot(dum)+1)*0.5),'i']),'visible','off');
                    set(handles.spectra_handles.(['phantom',num2str((harm_tot(dum)+1)*0.5),'j']),'visible','off');
                catch
                    handles=cla_raw_Callback(hObject, 1, handles);
                end%try
                if mod(counter,str2double(get(handles.refresh_spectra,'string')))==0
                        if get(handles.polar_plot,'value')==0%<-----------------------------------------------------------------------------determine whether or not to show the raw data in polar coordinates
                            disp(['Plotting harmonic: ', num2str(harm_tot(dum)),' in ',ax1]);%show in the command window which harmonic is being plotted
                            refreshing(handles,harm_tot(dum),1);%show which plot is being refreshed                            
                            if get(handles.show_susceptance,'value')==1  %<--------------------------------PLOT BOTH THE CONDUCTANCE AND SUSCEPTANCE
                                set(handles.spectra_handles.(['phantom',num2str((harm_tot(dum)+1)*0.5),'a']),...
                                    'xdata',freq,'ydata',conductance,'visible','on');%plot conductance versus frequency
                                set(handles.spectra_handles.(['phantom',num2str((harm_tot(dum)+1)*0.5),'b']),...
                                    'xdata',freq,'ydata',susceptance,'visible','on');%plot susceptance versus frequency
                                set(handles.(ax1),'xlim',[min(freq) max(freq)],...
                                    'ylim',[min(conductance),min(conductance)+1.2*(max(conductance)-min(conductance))]-0.05*(max(conductance)-min(conductance)));%adjust axes
                                set(handles.(ax2),'xlim',get(handles.(ax1),'xlim'),...
                                    'ylim',[min(susceptance),min(susceptance)+1.2*(max(susceptance)-min(susceptance))]-0.05*(max(susceptance)-min(susceptance)),'visible','on');%adjust axes
                            else%if get(handles.show_susceptance,'value')==1 <-----------------------------ONLY PLOT THE CONDUCTANCE CURVE
                                set(handles.spectra_handles.(['phantom',num2str((harm_tot(dum)+1)*0.5),'a']),...
                                    'xdata',freq,'ydata',conductance,'visible','on');%Plot conductance versus frequency
                                set(handles.(ax1),'xlim',[min(freq) max(freq)],...
                                    'ylim',[min(conductance),min(conductance)+1.2*(max(conductance)-min(conductance))]-0.05*(max(conductance)-min(conductance)));%adjust axes
                            end%if get(handles.show_susceptance,'value')==1
                            if get(handles.dynamic_fit,'value')==1%<---------------------------------------run this block of code if the option to fit the curves dynamically is turned on
                                set(handles.spectra_handles.(['phantom',num2str((harm_tot(dum)+1)*0.5),'c']),...
                                    'xdata',freq,'ydata',G_fit,'visible','on')%Plot the fitted conductance versus the frequency
                                xdata=freq(I);ydata=ones(size(I,1),1)'.*min(conductance);
                                set(handles.spectra_handles.(['phantom',num2str((harm_tot(dum)+1)*0.5),'e']),...
                                    'xdata',xdata,'ydata',ydata,'visible','on');%plot the range in which the dataset was used to find the fitted parameters
                                set(handles.(ax1),'xlim',[min(freq) max(freq)]);%adjust axes
                                if get(handles.show_susceptance,'value')==1%<-------------------------------- SUSCEPTANCE CURVE IS TURNED ON
                                    set(handles.spectra_handles.(['phantom',num2str((harm_tot(dum)+1)*0.5),'d']),...
                                        'xdata',freq,'ydata',B_fit,'visible','on');%plot the fitted susceptance values versus the frequency
                                    set(handles.(ax2),'xlim',get(handles.(ax1),'xlim'),'visible','on');%adjust the axes
                                    if length(GB_parameters)>=6%<------------if plotting 1 peak
                                        set(handles.spectra_handles.(['phantom',num2str((harm_tot(dum)+1)*0.5),'f']),...
                                            'xdata',GB_parameters(1)*1e6,'ydata',GB_parameters(4)+GB_parameters(5),'visible','on');                                    
                                        set(handles.spectra_handles.(['phantom',num2str((harm_tot(dum)+1)*0.5),'g']),...
                                            'xdata',[GB_parameters(1)*1e6-GB_parameters(2)*1e4,GB_parameters(1)*1e6+GB_parameters(2)*1e4],...
                                            'ydata',[GB_parameters(4)/2,GB_parameters(4)/2]+GB_parameters(5),'visible','on');   
                                    end%if length(GB_parameters)>=6
                                    peak_track=get(handles.(['peak_track',num2str(handles.din.harmonic)]),'userdata');%extract out the peak tracking conditions
                                    if peak_track(1)==1&&peak_track(2)==0%if peak tracking algorithm is set to set span, show tolerance interval lines
                                        current_span=max(freq)-min(freq);%extract the span set by the start and end frequencies
                                        temp_ylim=get(handles.(ax1),'ylim');%extract out the current span of the axes
                                        set(handles.spectra_handles.(['phantom',num2str((harm_tot(dum)+1)*0.5),'h']),...
                                            'xdata',[mean(freq)-current_span*handles.din.set_span_factor_sensitivity,mean(freq)-current_span*handles.din.set_span_factor_sensitivity],...
                                            'ydata',temp_ylim,'visible','on');%plot the LOWER bound tolerances for adjusting the start and end frequencies based on the set span algorithm
                                        set(handles.spectra_handles.(['phantom',num2str((harm_tot(dum)+1)*0.5),'i']),...
                                            'xdata',[mean(freq)+current_span*handles.din.set_span_factor_sensitivity,mean(freq)+current_span*handles.din.set_span_factor_sensitivity],...
                                            'ydata',temp_ylim,'visible','on');%plot the UPPER bound tolerances for adjusting the start and end frequencies based on the set span algorithm
                                    end   %if peak_track(1)==1&&peak_track(2)==0
                                    set(handles.(ax1),'ylimmode','auto');
                                    linkaxes([handles.(ax1),handles.(ax2)],'x');%link the xaxis together
                                else%if get(handles.show_susceptance,'value')==1<-------------------------------- SUSCEPTANCE CURVE IS TURNED OFF
                                    peak_track=get(handles.(['peak_track',num2str(handles.din.harmonic)]),'userdata');%extract out the peak tracking conditions
                                    if peak_track(1)==1&&peak_track(2)==0%if peak tracking algorithm is set to set span, show tolerance interval lines
                                        current_span=max(freq)-min(freq);%determine the span of the colleccted data based on the start and end frequencies
                                        temp_ylim=[min(conductance)-.2*abs(min(conductance)),max(conductance)+.2*abs(max(conductance))];%define ylim values for the axes
                                        set(handles.spectra_handles.(['phantom',num2str((harm_tot(dum)+1)*0.5),'h']),...
                                            'xdata',[mean(freq)-current_span*handles.din.set_span_factor_sensitivity,mean(freq)-current_span*handles.din.set_span_factor_sensitivity],...
                                            'ydata',temp_ylim,'visible','on');
                                        set(handles.spectra_handles.(['phantom',num2str((harm_tot(dum)+1)*0.5),'i']),...
                                            'xdata',[mean(freq)+current_span*handles.din.set_span_factor_sensitivity,mean(freq)+current_span*handles.din.set_span_factor_sensitivity],...
                                            'ydata',temp_ylim,'visible','on');
                                    end   %if peak_track(1)==1&&peak_track(2)==0
                                    if length(GB_parameters)>=6%<------------if plotting 1 peak
                                        set(handles.spectra_handles.(['phantom',num2str((harm_tot(dum)+1)*0.5),'f']),...
                                            'xdata',GB_parameters(1)*1e6,'ydata',GB_parameters(4)+GB_parameters(5),'visible','on');                                    
                                        set(handles.spectra_handles.(['phantom',num2str((harm_tot(dum)+1)*0.5),'g']),...
                                            'xdata',[GB_parameters(1)*1e6-GB_parameters(2)*1e4,GB_parameters(1)*1e6+GB_parameters(2)*1e4],...
                                            'ydata',[GB_parameters(4)/2,GB_parameters(4)/2]+GB_parameters(5),'visible','on');   
                                    end%if length(G_parameters)==5
                                    set(handles.(ax1),'ylimmode','auto');
                                end%if get(handles.show_susceptance,'value')==1
                                plot_primaryaxes(handles,handles.din.FG_frequency,harm_tot,n,'a');
                                plot_primaryaxes(handles,handles.din.FG_frequency,harm_tot,n,'b');
                            end%if get(handles.dynamic_fit,'value')==1
                            ylabel(handles.(ax1),'mSiemans (mS)','fontsize',6);
                            xlabel(handles.(ax1),'Frequency (Hz)','fontsize',6);
                        else%<-----------------------------------------------------------------------------plot the raw data in polar plot form
                            disp(['Plotting harmonic: ', num2str(harm_tot(dum)),' in ',ax1]);
                            refreshing(handles,harm_tot(dum),1);%show which plot is being refreshed
                            set(handles.spectra_handles.(['phantom',num2str((harm_tot(dum)+1)*0.5),'j']),...
                                'xdata',conductance,'ydata',susceptance,'visible','on');
                            axis tight
                            if get(handles.dynamic_fit,'value')==1
                                set(handles.spectra_handles.(['phantom',num2str((harm_tot(dum)+1)*0.5),'c']),...
                                    'xdata',G_fit','ydata',B_fit,'visible','on');
                                set(handles.spectra_handles.(['phantom',num2str((harm_tot(dum)+1)*0.5),'e']),...
                                    'xdata',G_fit(I),'ydata',B_fit(I),'visible','on');
                                set(handles.(ax1),'xlim',[min(G_fit) max(G_fit)],'ylim',[min(B_fit) max(B_fit)])
                            end%if get(handles.dynamic_fit,'value')==1
                            if get(handles.dynamic_fit,'value')==1
                                plot_primaryaxes(handles,handles.din.FG_frequency,harm_tot,n,'a');
                                plot_primaryaxes(handles,handles.din.FG_frequency,harm_tot,n,'b');
                            end%if get(handles.dynamic_fit,'value')==1
                            xlabel(handles.(ax1),'Conductance (mS)','fontsize',6);
                            ylabel(handles.(ax1),'Susceptance (mS)','fontsize',6);
                        end%if get(handles.polar_plot,'value')==1
                        drawnow;
                    if get(handles.raw_fig,'value')==1&&handles.din.refit_flag==1%display the plots in raw figure mode
                        clf(figure((handles.din.harmonic+1)/2));
                        rf_axes=copyobj(handles.(ax1),figure((handles.din.harmonic+1)/2));
                        set(rf_axes,'units','normalized','position',[0.13 0.11 0.775 0.815],'fontsize',12);
                    end%if get(handles.raw_fig,'value')==1&&handles.din.refit_flag==0s
                end%if mod(counter,str2double(get(handles.refresh_spectra,'string')))==0   
            catch err_message
               disp('Error in plotting data!');
               set(handles.status,'string','Status: ERROR in plotting data!','backgroundcolor','r','foregroundcolor','k');
               handles.din.error_log(handles.din.error_count,1)={[datestr(clock),'  ERROR in plotting data!']};
               handles.din.error_count=handles.din.error_count+1;
               err_counter=err_counter+1;
               assignin('base','error_log',handles.din.error_log);
               assignin('base','matlab_err_message',err_message);
               handles=cla_raw_Callback(hObject, 1, handles);
                if get(handles.email_push,'userdata')==1&&mod(err_counter,10)==9;
                    email_send(handles,'An error was detected by the QCM MATLAB Program: ERROR in plotting data!');
                end               
            end%try err_message
             %//////////////////////////////////////////////////////////////////////
            %this block of code deals with peak tracking
            if get(handles.dynamic_fit,'value')==1&&handles.din.refit_flag==0%use the fitted parameters to determine how to track the peak
                disp('Tracking peak...');
                try handles=smart_peak_tracker(handles,freq,conductance,susceptance,GB_parameters(1:5)); catch;  end;              
            elseif get(handles.dynamic_fit,'value')~=1&&handles.din.refit_flag==0%guess what f0 and gamma0 to determine how to track the peak
                [peak_detect,index]=findpeaks(conductance,'sortstr','descend');
                Gmax=peak_detect(1);%find peak of curve
                f0=freq(index(1));%finds freq at which Gmax happens
                halfg=Gmax./2;%half of the Gmax
                halfg_freq=freq(find(abs(halfg-conductance)==min(abs((halfg-conductance))),1));
                gamma0=abs(halfg_freq-f0);%Guess for gamma, HMHW of peak
                guess=[f0 gamma0 0 Gmax 0];    
                disp('Tracking peak...');
                handles=smart_peak_tracker(handles,freq,conductance,susceptance,guess);                
            end
            %//////////////////////////////////////////////////////////////////////
            if handles.din.refit_flag==0
                pause(str2double(get(handles.wait_time,'string'))./1000);
            end%if handles.din.refit_flag==0
            refreshing(handles,harm_tot(dum),0);
            temp=toc;
            my_disp('Elapsed time is ','cyan');
            my_disp([num2str(temp),' seconds\n'],'cyan');
        end%for get(handles.start,'value')==1
        write_settings(handles,harm_tot(dum));%update the setting txt file
        if handles.prefs.plot_dynamic_refresh==1
            guidata(handles.primary1,handles);
        end%if handles.prefs.plot_dynamic_refresh==1
    end%for dum=1:size(harm_tot)
    my_disp('Datapoint(s): ','cyan');
    my_disp([num2str(n),'\n'],'cyan');
    set(handles.tot_datapts,'string',['Datapts collected: ',num2str(n)]);   %display total number of collected datapoints for each harmonic
    n=n+1;
    %//////////////////////////////////////////////////////////////////////////
    %Autosave code starts here
    if str2double(get(handles.record_time_increment,'string'))>60
        %//////////////////////////////////////////////////////////////////////////
        %Write out chi values, f0, and gamma0 into spectra file
        disp('Saving Data...');
        set(handles.status,'string','Status: Saving data...','backgroundcolor','k','foregroundcolor','r');
        drawnow;
        reference=char(get(handles.reference_time,'string'),get(handles.wait_time,'string')...
            ,get(handles.num_datapoints,'string'),get(handles.record_time_increment,'string'));%records reference time 
        fg_values.reference=reference;
        if handles.din.refit_flag==0
            spectra.reference=reference;
        end%if handles.din.refit_flag==0
        if get(handles.dynamic_fit,'value')==1
            save_shifts(handles,fg_values);
            disp('Data saved!');
        end%if get(handles.dynamic_fit,'value')==1
        set(handles.status,'string','Status: Data saved! Ready...','backgroundcolor','k','foregroundcolor','r');
        %//////////////////////////////////////////////////////////////////////////
        %Update handles structure
        for dum=1:2:11
            name=['X',num2str(dum)];
            prev_data=get(handles.(name),'userdata');
            if isempty(prev_data)~=1
                handles.din.(['GB_prev',num2str(dum)])=prev_data(1,:);
            end%if isempty(prev_data)~=1
        end%for dum=1:2:11
        handles.din.n=n;
        if get(handles.email_push,'userdata')==1&&mod(n,round(3600/str2double(get(handles.record_time_increment,'string'))))==0
            email_send(handles,'Update notification sent by QCM MATLAB Program.');
        end%if get(handles.email_push,'userdata')==1
    elseif mod(n,50)==0
        %//////////////////////////////////////////////////////////////////////////
        %Write out chi values, f0, and gamma0 into spectra file
        disp('Saving Data...');
        set(handles.status,'string','Status: Saving data...','backgroundcolor','k','foregroundcolor','r');
        drawnow;
        reference=char(get(handles.reference_time,'string'),get(handles.wait_time,'string')...
            ,get(handles.num_datapoints,'string'),get(handles.record_time_increment,'string'));%records reference time 
        fg_values.reference=reference;
        if handles.din.refit_flag==0
            spectra.reference=reference;
        end%if handles.din.refit_flag==0
        if get(handles.dynamic_fit,'value')==1
            save_shifts(handles,fg_values);
            disp('Data saved!');
        end%if get(handles.dynamic_fit,'value')==1
        set(handles.status,'string','Status: Data saved! Ready...','backgroundcolor','k','foregroundcolor','r');
        %//////////////////////////////////////////////////////////////////////////
        %Update handles structure
        for dum=1:2:11
            name=['X',num2str(dum)];
            prev_data=get(handles.(name),'userdata');
            if isempty(prev_data)~=1
                handles.din.(['GB_prev',num2str(dum)])=prev_data(1,:);
            end%if isempty(prev_data)~=1
        end%for dum=1:2:11
        handles.din.n=n;
        if mod(n,200)==0&&get(handles.email_push,'userdata')==1
            email_send(handles,'Update notification sent by QCM MATLAB Program.');
        end%if mod(n,200)==0
    end%if str2double(get(handles.record_time_increment,'string'))>20
    %//////////////////////////////////////////////////////////////////////////
    if str2double(get(handles.record_time_increment,'string'))-toc>.1%this block of code deals with the waitbar that appears at the bottom of the GUI (timer in between scans)
        if str2double(get(handles.record_time_increment,'string'))-toc>5
            hold(handles.wb,'on');
            wbh=barh(handles.wb,0,'facecolor',[0 0.5 0],'edgecolor','g','barwidth',1);         
            wbt=text(0.1,1,'test','parent',handles.wb,'color','w');                          
            stop1=str2double(get(handles.record_time_increment,'string'));
            set(handles.status,'string','Status: Pausing before next scan...','backgroundcolor','k','foregroundcolor','r');
            for dum5=0:.1:stop1
                if get(handles.start,'value')==1
                    pause(.1)
                        set(wbh,'ydata',dum5/stop1);
                        set(wbt,'string',[num2str(stop1-dum5,'%8.2f'),' s left']);
                        set(handles.wb,'xlim',[0 1],'box','off','color','k');
                else
                    try delete(hp); catch; end;%try
                end%if get(handles.start,'value')==1
            end%for dum5=0:.8:str2double(get(handles.record_time_increment,'string'))   
            if handles.din.refit_flag==0
                pause(mod(str2double(get(handles.record_time_increment,'string')),.8))
            end%if handles.din.refit_flag==0
            cla(handles.wb);
        else
            stop1=str2double(get(handles.record_time_increment,'string'));
            for dum5=0:.1:stop1
                if get(handles.start,'value')==1&&handles.din.refit_flag==0
                    pause(.1)
                end%if get(handles.start,'value')==1
            end%for dum5=0:.8:str2double(get(handles.record_time_increment,'string'))  
            if handles.din.refit_flag==0
                pause(mod(str2double(get(handles.record_time_increment,'string')),.8))
            end%if handles.din.refit_flag==0
        end%if str2double(get(handles.record_time_increment,'string'))-toc>.1
    end%if str2double(get(handles.record_time_increment,'string'))-toc>0.1
    %//////////////////////////////////////////////////////////////////////////
    if mod(n,50)>=50%clear up the command window every 50 datapoints
        clc
    end% if mod(n,100)>=50    
end%while get(handles.start,'value')==1
%//////////////////////////////////////////////////////////////////////////
%Write out chi values, f0, and gamma0 into spectra file
disp('Saving Data...');
set(handles.status,'string','Status: Saving data...','backgroundcolor','k','foregroundcolor','r');
drawnow;
reference=char(get(handles.reference_time,'string'),get(handles.wait_time,'string')...
    ,get(handles.num_datapoints,'string'),get(handles.record_time_increment,'string'));%records reference time 
fg_values.reference=reference;
if handles.din.refit_flag==0
    spectra.reference=reference;
end%if handles.din.refit_flag==0
if get(handles.dynamic_fit,'value')==1
    save_shifts(handles,fg_values);
    disp('Data exported and saved!');
    set(handles.status,'string','Status: Data saved! Ready...','backgroundcolor','k','foregroundcolor','r');
else
    set(handles.status,'string','Status: Data saved! Ready...','backgroundcolor','k','foregroundcolor','r');
end%if get(handles.dynamic_fit,'value')==1
%//////////////////////////////////////////////////////////////////////////
%Update handles structure
handles.prefs.schedule_state=zeros(size(handles.prefs.measurement_schedule,1),1);
for dum=1:2:11
    name=['X',num2str(dum)];
    prev_data=get(handles.(name),'userdata');
    if isempty(prev_data)~=1
        handles.din.(['GB_prev',num2str(dum)])=prev_data(1,:);
    end%if isempty(prev_data)~=1
end%for dum=1:2:11
set(handles.status,'string','Status: Data saved! Ready...','backgroundcolor','k','foregroundcolor','r');
disp('handles structure updated! Ready...');
handles.din.n=n;
if handles.din.refit_flag==0
    save_settings_Callback(handles.save_settings, 1, handles);
end%if handles.din.refit_flag==0
%//////////////////////////////////////////////////////////////////////////
%Send email notifications
if get(handles.email_push,'userdata')==1
    email_send(handles,'Update notification sent by QCM MATLAB Program.');
end
diary off; pause on;
if  get(handles.start,'value')==1&&handles.din.refit_flag==1&&...
        sum([handles.din.refit_finish1,handles.din.refit_finish3,...
        handles.din.refit_finish5,...
        handles.din.refit_finish7,...
        handles.din.refit_finish9,...
        handles.din.refit_finish11])>0%after finishing refitting data, reset the start button
    set(handles.start,'value',0);    
    start_Callback(hObject, 1, handles);
    set(handles.refit_start,'style','edit');%allow the user to modify the starting refit datapoint
end% if get(handles.start,'value')==1......
%//////////////////////////////////////////////////////////////////////////
%restore the disable features
set(handles.peak_centering,'visible','on');%display the button
set(handles.clear_datapoints,'visible','on');%display the button
set(handles.uipanel1,'visible','on');%display uipanel1
set(handles.home_push,'visible','on');%display the reset button
set(handles.del_mode,'visible','on');%display the del_mode toolbar button
set(handles.refit_start,'style','edit');%allow the user to modify the starting refit datapoint
if strcmp(get(handles.del_mode,'state'),'on')
    set(handles.confirm_del,'visible','on');%display the confim_del toolbar button
end%if get(handles.del_mode,'enable','on')
cla(handles.wb);set(handles.wb,'color','k','box','off','ytick',[]);
%refresh the primary axes plots
handles=cla_raw_Callback(hObject,1, handles);
plot_choice_Callback(handles.plot1_choice, 1, handles);
plot_choice_Callback(handles.plot2_choice, 1, handles);
guidata(hObject, handles);
function [freq,conductance,susceptance,handles]=read_scan(handles)
%this function obtains the scan data taken from the VB C++ AccessMyVNAv0.7 program
if handles.din.refit_flag==0%run this if collecting live data
    flag=0;
    start1=str2double(get(handles.(['start_f',num2str(handles.din.harmonic)]),'string'))*1e6;%start frequency
    end1=str2double(get(handles.(['end_f',num2str(handles.din.harmonic)]),'string'))*1e6;%end freqeuncy
    if handles.din.harmonic<11
        rawfile=['myVNAdata0',num2str(handles.din.harmonic),'.csv'];
    else
        rawfile=['myVNAdata',num2str(handles.din.harmonic),'.csv'];
    end%if handles.din.harmonic<11
    while flag==0
        try  
            clear('fid1');
            disp(['Rawdatafile: ',rawfile]);
            fid1=fopen(rawfile);%open up frequency range output from the AccessMyVNA program
            raw=cell2mat(textscan(fid1,'%f'));%frequency data
            fclose(fid1);%close datafiles     
            num_pts=get(handles.num_datapoints,'userdata');
            if size(raw,1)==num_pts(handles.din.harmonic,1)*2%check to see if the file contains the correct number of datapoints
                conductance=1e3.*raw(1:num_pts(handles.din.harmonic,1));%conductance values in mS
                susceptance=1e3.*raw((num_pts(handles.din.harmonic,1)+1):(num_pts(handles.din.harmonic,1)*2));%susceptance values in mS
                freq=[start1:(end1-start1)/num_pts(handles.din.harmonic,1):end1-(end1-start1)/num_pts(handles.din.harmonic,1)]';                
                flag=1;
                if handles.din.error_count>1
                    set(handles.status,'string',['Status: Scan successful. Number of errors encountered: ',num2str(handles.din.error_count-1)],'backgroundcolor','k','foregroundcolor','r');
                end%if handles.din.error>1
            else
                disp(['Size of the raw output file is ',num2str(size(raw,1))])            
                disp('ERROR: SCAN WAS NOT COMPLETED');
                handles.din.error_log(handles.din.error_count,1)={[datestr(clock),'  ERROR: SCAN WAS NOT COMPLETED (read_scan function)']};
                if get(handles.start,'value')==1%attempt to correct the number of errors
                    handles.din.error_log(handles.din.error_count,1)={[datestr(clock),'  Attempting to correct problem...']};
                    set(handles.status,'string',['Status: ERROR! Number of errors: ',num2str(handles.din.error_count),'; Attempting to correct problem...'],...
                        'backgroundcolor','r','foregroundcolor','k');            
                    set(handles.num_pts(handles.din.harmonic,1),'string',size(raw,1)/2);
                    pause(1);
                else
                    write_settings(handles,handles.din.harmonic);
                    pause(2);
                end%if get(handles.start,'value')==1        
                if get(handles.peak_centering,'value')==0
                    handles.din.error_count=handles.din.error_count+1;
                    assignin('base','error_log',handles.din.error_log);
                    flag=0;
                    if mod(handles.din.error_count,100)>=50%if the number of errors exceeds 50 counts
                        assignin('base','handles',handles);
                        disp('The GUI program is paused and in debugging mode.');
                        set(handles.status,'string','Status: The GUI program is paused and in debugging mode!','backgroundcolor','y','foregroundcolor','r');
                        try email_send(handles,message); catch; end;%try to send an email saying that there are 50 errors
                        pause(2);
                    end%if handles.din.error_count>=100
                else%if get(handles.peak_centering,'value')==0
                    pause(.5);
                end%if get(handles.peak_centering,'value')==0
            end%if size(raw,1)==str2double(get(handles.num_datapoints,'string'))*3            
        catch
            disp('ERROR: INVALID FILE IDENTIFIER. USE FOPEN TO GENERATE A VALID FILE IDENTIFIER');
            handles.din.error_log(handles.din.error_count,1)={[datestr(clock),'  ERROR: INVALID FILE IDENTIFIER. USE FOPEN TO GENERATE A VALID FILE IDENTIFIER']};
            set(handles.status,'string',['Status: ERROR! Number of errors: ',num2str(handles.din.error_count),'; Attempting to correct problem...',...
                'backgroundcolor','r','foregroundcolor','k']);        
            handles.din.error_count=handles.din.error_count+1;
            assignin('base','fid1',fid1);
            assignin('base','error_log',handles.din.error_log);
            flag=0;
            if mod(handles.din.error_count,100)>=50
                assignin('base','handles',handles);
                disp('The GUI program is paused and in debugging mode.');
                set(handles.status,'string','Status: The GUI program is paused and in debugging mode!','backgroundcolor','y','foregroundcolor','r');
                try email_send(handles,message); catch; end%try to send an email saying that there are 50 errors
                keyboard
            end%if handles.din.error_count>=100
        end%try
    end%while flag==0
else%run this if refitting loaded raw spectra data    
        rawfile=['h',num2str(handles.din.harmonic)];        
        flag=check_version(handles.din.refit.version);%check the version in which the raw spectra was saved in
        
        if handles.din.refit.counter<=length(handles.din.refit_timepoints)
            %extract the current timepoint that is being reffitted
            current_time=handles.din.refit_timepoints(handles.din.refit.counter);
            if get(handles.start,'value')==0
                disp(['Fitting timepoint: ',num2str(current_time),' min']);
            end%if get(handles.start,'value')==0
            if flag==0% do this for raw spectra saved in legacy format
                index=find(cell2mat(handles.din.refit.(rawfile)(:,2))==current_time);
            elseif flag==1% do this if spectra is saved in cell format
                var_name=['raw_spectra_',num2str(handles.din.harmonic)];
                index0=find(~cellfun(@isempty,handles.din.refit_raw.(var_name)(:,1)));%find empty cells
                time_array=nan(length(handles.din.refit_raw.(var_name)(:,1)),1);
                time_array(index0)=cell2mat(handles.din.refit_raw.(var_name)(:,1));
                index=find(time_array==current_time);
            end
        end%if handles.din.refit.counter<=length(handles.din.refit_timepoints)
        
        if handles.din.refit.counter>str2double(get(handles.refit_end,'string'))&&...
                get(handles.peak_centering,'value')==1
            disp('WARNING: Your start time is greater than the end time!!');
        end%if handles.din.refit.counter>str2double(get(handles.refit_end,'string'))&&...
        
        if handles.din.refit.counter<=length(handles.din.refit_timepoints)&&...
                handles.din.(['refit_finish',num2str(handles.din.harmonic)])==0&&...
            handles.din.refit.counter<=str2double(get(handles.refit_end,'string'))&&...
            isempty(index)==0%check to see if data was collected at that harmonic and whether the refit process should be continued
            if flag==0% do this for raw spectra saved in legacy format
                var_name=handles.din.refit.(rawfile){index,1};%extract out the variable name containing the spectra file
                rawdata=handles.din.refit_raw.(var_name);%extract out the rawdata from the loaded spectra data for refitting                
            elseif flag==1% do this if spectra is saved in cell format
                var_name=['raw_spectra_',num2str(handles.din.harmonic)];
                rawdata=handles.din.refit_raw.(var_name){index,4};%extract out the raw data                         
            end
            freq=rawdata(:,1);%frequency array from the loaded spectra
            conductance=rawdata(:,2);%conductance array from the loaded spectra
            susceptance=rawdata(:,3);%suscpetance array from the loaded array
            set(handles.(['start_f',num2str(handles.din.harmonic)]),'string',min(freq)/1e6);%redefine the start frequency for the harmonic
            set(handles.(['end_f',num2str(handles.din.harmonic)]),'string',max(freq)/1e6);%redefine the end frequency for the harmonic        
            handles.din.(['refit_finish',num2str(handles.din.harmonic)])=0;
        elseif handles.din.refit.counter>length(handles.din.refit_timepoints)||...
            handles.din.refit.counter>str2double(get(handles.refit_end,'string'))
        %if no data was found for that harmonic, output empty arrays for freq, conductance, and susceptance
            freq=[];        conductance=[];        susceptance=[];        
            handles.din.(['refit_finish',num2str(handles.din.harmonic)])=1;
        elseif handles.din.refit.counter<=length(handles.din.refit_timepoints)&&...
                handles.din.(['refit_finish',num2str(handles.din.harmonic)])==0&&...
            handles.din.refit.counter<=str2double(get(handles.refit_end,'string'))&&...
            isempty(index)==1
        freq=[];        conductance=[];        susceptance=[];
        else
            %if no data was found for that harmonic, output empty arrays for freq, conductance, and susceptance
            freq=[];        conductance=[];        susceptance=[];
            handles.din.(['refit_finish',num2str(handles.din.harmonic)])=1;
        end%if handles.din.refit_counter<=length(handles.din.refit.(rawfile))
        
        if get(handles.peak_centering,'value')==0&&handles.din.refit_flag1==1&&...
                handles.din.refit.counter<=length(handles.din.refit_timepoints)==1
            refit_inc=str2double(get(handles.refit_inc,'string'));            
            %refresh the start datapoint on the gui
            set(handles.refit_start,'string',handles.din.refit.counter,...
                'tooltipstring',['Starting datapoint: ',num2str(handles.din.refit_timepoints(handles.din.refit.counter),4),' min']);
            handles.din.refit.counter=handles.din.refit.counter+refit_inc;
        end%if get(peak_centering,'value')==0    
end%if handles.din.refit_flag==0
try
    if handles.prefs.output_raw==1%output values in the "base" or global workspace
        assignin('base','freq',freq);
        assignin('base','conductance',conductance);
        assignin('base','susceptance',susceptance);
    end%if handles.prefs.output_raw==1
end%try

function harm1_Callback(~,~,handles)
% --- Executes on button press in harm1.
set(handles.raw_fig,'userdata',1+get(handles.raw_fig,'userdata'));
function harm3_Callback(~,~,handles)
% --- Executes on button press in harm3.
set(handles.raw_fig,'userdata',3+get(handles.raw_fig,'userdata'));
function harm5_Callback(~,~,handles)
% --- Executes on button press in harm5.
set(handles.raw_fig,'userdata',5+get(handles.raw_fig,'userdata'));
function harm7_Callback(~,~,handles)
% --- Executes on button press in harm7.
set(handles.raw_fig,'userdata',7+get(handles.raw_fig,'userdata'));
function harm9_Callback(~,~,handles)
% --- Executes on button press in harm9.
set(handles.raw_fig,'userdata',9+get(handles.raw_fig,'userdata'));
function harm11_Callback(~,~,handles)
% --- Executes on button press in harm11.
set(handles.raw_fig,'userdata',11+get(handles.raw_fig,'userdata'));

%% Check frequency range functions
%FIRST HARMONIC
function start_f1_Callback(~, ~, handles)
check_freq_range(1, handles.din.freq_range(1,1), handles.din.freq_range(1,2), handles);
function end_f1_Callback(~, ~, handles)
check_freq_range(1, handles.din.freq_range(1,1), handles.din.freq_range(1,2), handles);

%THIRD HARMONIC
function start_f3_Callback(~, ~, handles)
check_freq_range(3, handles.din.freq_range(2,1), handles.din.freq_range(2,2), handles);
function end_f3_Callback(~, ~, handles)
check_freq_range(3, handles.din.freq_range(2,1), handles.din.freq_range(2,2), handles);

%5TH HARMONIC
function start_f5_Callback(~, ~, handles)
check_freq_range(5, handles.din.freq_range(3,1), handles.din.freq_range(3,2), handles);
function end_f5_Callback(~, ~, handles)
check_freq_range(5, handles.din.freq_range(3,1), handles.din.freq_range(3,2), handles);

%7TH HARMONIC
function start_f7_Callback(~, ~, handles)
check_freq_range(7, handles.din.freq_range(4,1), handles.din.freq_range(4,2), handles);
function end_f7_Callback(~, ~, handles)
check_freq_range(7, handles.din.freq_range(4,1), handles.din.freq_range(4,2), handles);

%9TH HARMONIC
function start_f9_Callback(~, ~, handles)
check_freq_range(9, handles.din.freq_range(5,1), handles.din.freq_range(5,2), handles);
function end_f9_Callback(~, ~, handles)
check_freq_range(9, handles.din.freq_range(5,1), handles.din.freq_range(5,2), handles);

%11TH HARMONIC
function start_f11_Callback(~, ~, handles)
check_freq_range(11, handles.din.freq_range(6,1), handles.din.freq_range(6,2), handles);
function end_f11_Callback(~, ~, handles)
check_freq_range(11, handles.din.freq_range(6,1), handles.din.freq_range(6,2), handles);

function check_freq_range(harm, min_range, max_range, handles)
startname=['start_f',num2str(harm)];
endname=['end_f',num2str(harm)];
%Check start frequency range
if str2double(get(handles.(startname),'string'))<=min_range||str2double(get(handles.(startname),'string'))>=max_range
    set(handles.status,'string',...
        ['Status: ERROR: The frequency range for harmonic number ' num2str(harm),' needs to be between ',...
        num2str(min_range),' to ',num2str(max_range),' MHz! Ready...'],'backgroundcolor','r','foregroundcolor','k');
    set(handles.(startname),'string',min_range+.9);
end% str2num(get(handles.(startname),'string'))<min_range||str2num(get(handles.(startname),'string'))>max_range
if str2double(get(handles.(startname),'string'))>=str2double(get(handles.(endname),'string'))
    if str2double(get(handles.(startname),'string'))==str2double(get(handles.(endname),'string'))
        set(handles.status,'string','The start frequency cannot be the same as the end frequency! Ready...','backgroundcolor','y','foregroundcolor','r');        
        set(handles.(startname),'string',min_range+.9);
        set(handles.(endname),'string',max_range-.9);
    else
        set(handles.status,'string','Status: ERROR: The start frequency is greater than the end frequency! Ready...','backgroundcolor','r','foregroundcolor','k');
        set(handles.(startname),'string',min_range+.9);
    end%str2num(get(handles.(startname),'string'))==min_range
end%str2num(get(handles.(startname),'string'))>=str2num(get(handles.(endname),'string'))
%Check end frequency range
if str2double(get(handles.(endname),'string'))<=min_range||str2double(get(handles.(endname),'string'))>=max_range
    set(handles.status,'string',...
        ['Status: ERROR: The frequency range for harmonic number ' num2str(harm),' needs to be between ',...
        num2str(min_range),' to ',num2str(max_range),' MHz! Ready...'],'backgroundcolor','r','foregroundcolor','k');
    set(handles.(endname),'string',max_range-.9);
end% str2num(get(handles.(startname),'string'))<min_range||str2num(get(handles.(startname),'string'))>max_range
if str2double(get(handles.(endname),'string'))<=str2double(get(handles.(startname),'string'))
    set(handles.status,'string','Status: ERROR: The end frequency is less than the start frequency! Ready...','backgroundcolor','r','foregroundcolor','k');
    if str2double(get(handles.(startname),'string'))==max_range
        set(handles.status,'string','The start frequency cannot be the same as the end frequency! Ready...','backgroundcolor','y','foregroundcolor','r');
        set(handles.(startname),'string',min_range+.9);
        set(handles.(endname),'string',max_range-.9);        
    else
        set(handles.(endname),'string',max_range-.9);
    end%str2num(get(handles.(startname),'string'))==min_range
end%str2num(get(handles.(startname),'string'))>=str2num(get(handles.(endname),'string'))


%% Functions to fit a Lorentz curve to the spectra data
function [combine_spectra,GB_parameters,handles,I,std_fit]=...
    Lorentzian_dynamic_fit(handles,freq,conductance,susceptance,combine_spectra)
factor_range_fit=handles.din.fit_factor_range;
%make sure to change user-defined values to previous values if the user is
%conducting the measurements. This prevents the program from pausing and
%waiting for the user to input the guess parameters in the middle of a
%measurement.
if  get(handles.(['fit',num2str(handles.din.harmonic)]),'userdata')==5&&get(handles.start,'value')==1
    set(handles.(['fit',num2str(handles.din.harmonic)]),'userdata',4,'string','Previous values');
end%if  get(handles.(['fit',num2str(handles.din.harmonic)]),'userdata')
if get(handles.start,'value')==0; disp('Fitting...'); end;
G_fit=nan(size(freq,1),size(freq,2));
B_fit=nan(size(freq,1),size(freq,2));  I=1;
switch get(handles.(['fit',num2str(handles.din.harmonic)]),'userdata')
    case 1%Guess value based on max conductance
        [guess,f0,gamma0]=G_guess(freq,conductance,susceptance,handles,'Conductance (mS)');
        if isempty(guess)==1
            GB_fit=[];GB_fit=[];GB_parameters=[];I=[];combine_spectra=[];std_fit=[];
            return
        end%if isempty(guess)
        I=find(freq>=(f0-gamma0*factor_range_fit)&freq<=(gamma0*factor_range_fit+f0)); 
        try %fitting with Gmax initial guesses
            [GB_fit,GB_residual,GB_parameters,std_fit]=fit_spectra(handles,[freq,conductance,susceptance],guess,I);
        catch% tryGuess values based on the Derivative of the Fit
            disp('Fitting based on the Gmax guess  failed!!');
            disp('Attempting to use derivative values to fit...');
            [p,freq_mod,modulus,~,~]=deriv_guess(freq,conductance,susceptance,handles);
            if isempty(p)==1
                GB_fit=[];GB_fit=[];GB_parameters=[];I=[];combine_spectra=[];std_fit=[];
                return
            end%if isempty(guess)
            [~,~,test,~]=fit_spectra_con(p,freq_mod,modulus,handles.prefs.show_GB);
            guess=[test(1) test(2) p(3:4) mean([conductance(1) conductance(end)])];%guess values
            try% tryGuess values based on the Derivative of the Fit
                [GB_fit,GB_residual,GB_parameters,std_fit]=fit_spectra(handles,[freq,conductance,susceptance],guess,I);
                disp('Gmax guess values suceeded!');
            catch%if fit fails, output nan arrays
                disp('Fit failed!');                                           
            end%try
        end%try
    case 2  %Guess values based on the Derivative of the Fit
        [guess,freq_mod,modulus,f0,gamma0]=deriv_guess(freq,conductance,susceptance,handles);
        if isempty(guess)==1
            GB_fit=[];GB_fit=[];GB_parameters=[];I=[];combine_spectra=[];std_fit=[];
            return
        end%if isempty(guess)
        I=find(freq_mod>=(f0-gamma0*factor_range_fit)&freq_mod<=(gamma0*factor_range_fit+f0)); 
        try
            [GB_fit,GB_residual,GB_parameters,std_fit]=fit_spectra(handles,[freq conductance susceptance],guess,I);
        catch%try GMAx as guess values
            disp('Fitting based on the derivative failed!!');
            disp('Attempting to use Gmax guess values to fit...');
            [guess,~,~]=G_guess(freq,conductance,susceptance,handles,'Conductance (mS)');       
            if isempty(guess)==1
                GB_fit=[];GB_fit=[];GB_parameters=[];I=[];combine_spectra=[];std_fit=[];
                return
            end%if isempty(guess)
            try
                [GB_fit,GB_residual,GB_parameters,std_fit]=fit_spectra(handles,[freq conductance susceptance],guess,I);
                disp('Gmax guess values suceeded!');
            catch%if fit fails, output nan arrays
                disp('Fit failed!');
            end%try            
        end%try           
    case 4%Guess value base on the previous fit values
        if isempty(get(handles.(['X',num2str(handles.din.harmonic)]),'userdata'))~=1&&...
                sum(sum(isnan(get(handles.(['X',num2str(handles.din.harmonic)]),'userdata'))))==0
            disp('Previous guess parameters found.');
            prev_par=get(handles.(['X',num2str(handles.din.harmonic)]),'userdata');
            guess=prev_par(1,:);
            I=find(freq>=(guess(1)-guess(2)*factor_range_fit)&freq<=(guess(2)*factor_range_fit+guess(1))); 
            try
                [GB_fit,GB_residual,GB_parameters,std_fit]=fit_spectra(handles,[freq conductance susceptance],guess,I);
            catch
                [guess,freq_mod,~,f0,gamma0]=deriv_guess(freq,conductance,susceptance,handles);
                if isempty(guess)==1
                    GB_fit=[];GB_fit=[];GB_parameters=[];I=[];combine_spectra=[];std_fit=[];
                    return
                end%if isempty(guess)
                I=find(freq_mod>=(f0-gamma0*factor_range_fit)&freq_mod<=(gamma0*factor_range_fit+f0)); 
                try
                    [GB_fit,GB_residual,GB_parameters,std_fit]=fit_spectra(handles,[freq conductance susceptance],guess,I);                   
                catch%if fit fails, output nan arrays
                    disp('Fit failed!');
                end%try  
            end            
        else%if not try to fit the data by choosing guess values from the derivative of the polar plot
            disp('Previous guess values not found. Guess values will be chosen from the derivative of the polar plot');
            [guess,freq_mod,~,f0,gamma0]=deriv_guess(freq,conductance,susceptance,handles);
            if isempty(guess)==1
                GB_fit=[];GB_fit=[];GB_parameters=[];I=[];combine_spectra=[];std_fit=[];
                return
            end%if isempty(guess)
            I=find(freq_mod>=(f0-gamma0*factor_range_fit)&freq_mod<=(gamma0*factor_range_fit+f0)); 
            try
                [GB_fit,GB_residual,GB_parameters,std_fit]=fit_spectra(handles,[freq conductance susceptance],guess,I);                
            catch%if fit fails, output nan arrays
                disp('Fit failed!');
            end%try             
        end%if isfield(handles.din,'G_prev')
        if isempty(guess)==1
            GB_fit=[];GB_fit=[];GB_parameters=[];I=[];combine_spectra=[];std_fit=[];
            return
        end%if isempty(guess)
    case 3%Use the susceptance spectra to find the guess values
        [guess,f0,gamma0]=G_guess(freq,susceptance,conductance,handles,'Susceptance (mS)');
        if isempty(guess)==1
            GB_fit=[];GB_fit=[];GB_parameters=[];I=[];combine_spectra=[];
            return
        end%if isempty(guess)
        I=find(freq>=(f0-gamma0*factor_range_fit)&freq<=(gamma0*factor_range_fit+f0)); 
        try %fitting with Gmax initial guesses
            [GB_fit,GB_residual,GB_parameters,std_fit]=fit_spectra(handles,[freq,conductance,susceptance],guess,I);            
        catch% tryGuess values based on the Derivative of the Fit
            disp('Fitting based on the Gmax guess  failed!!');
            disp('Attempting to use derivative values to fit...');
            [p,freq_mod,modulus,~,~]=deriv_guess(freq,conductance,susceptance,handles);
            if isempty(p)==1
                GB_fit=[];GB_fit=[];GB_parameters=[];I=[];combine_spectra=[];std_fit=[];
                return
            end%if isempty(guess)
            [~,~,test,~]=fit_spectra_con(p,freq_mod,modulus,handles.prefs.show_GB);
            guess=[test(1) test(2) p(3:4) mean([conductance(1) conductance(end)])];%guess values
            try% tryGuess values based on the Derivative of the Fit
                [GB_fit,GB_residual,GB_parameters,std_fit]=fit_spectra(handles,[freq,conductance,susceptance],guess,I);
                disp('Gmax guess values suceeded!');
            catch%if fit fails, output nan arrays
                disp('Fit failed!');                                              
            end%try
        end%try
    case 5%Guess values based on user defined parameters
        user_peaks=questdlg('How many peaks do you wish to define?','User defined peaks',...
            'Two','Three','Cancel','Two');%ask how many peaks to fit
        switch user_peaks
            case 'Two'%fit 2 peaks
                %provide starting guess values for user to edit
                try
                    [peak_detect,index]=findpeaks(smooth(smooth(conductance),7),'minpeakprominence',peak_sens((handles.din.harmonic+1)/2,1),...
                        'minpeakheight',(max(conductance)-min(conductance))*peak_sens((handles.din.harmonic+1)/2,2)+min(conductance));
                catch
                    [peak_detect,index]=findpeaks(smooth(conductance),'sortstr','descend');
                end%try 
                Gmax=peak_detect(1);%find peak of curve, Gmax refers to the maximum of the conductance
                f0=freq(index(1));%finds freq at which Gmax happens
                halfg=(Gmax-min(conductance))./2+min(conductance);%half of the Gmax
                halfg_freq=freq(find(abs(halfg-conductance)==min(abs((halfg-conductance))),1));%estimate of Gamma value
                gamma0=abs(halfg_freq-f0);%Guess for gamma, HMHW of peak
                offset=0; phi=0;
                try
                    guess=get(handles.(['X',num2str(handles.din.harmonic)]),'userdata');
                    guess=[[guess(1,1:5)';guess(2,5)],[guess(1,6:10)';guess(2,10)]];
                catch                                       
                    try
                        guess=[[f0;gamma0;phi;Gmax;offset;offset],...
                        [freq(index(2));gamma0/4;phi;peak_detect(2);offset;offset]];           
                    catch
                        guess=[[f0;gamma0;phi;Gmax;offset;offset],...
                        [freq(index(1));gamma0/4;phi;peak_detect(1);offset;offset]];     
                    end%try
                end
                figure(997);clf(figure(997));pos=get(figure(997),'position');set(figure(997),'position',[pos(1) pos(2) 400 300]);
                ud_table=uitable(figure(997),'units','normalized','position',[0.05 0.05 0.9 0.9],'data',guess,...
                    'RowName',[{'freq.'},{'gamma0'},{'\phi'},{'Gmax'},{'Cond. offset'},{'Sus. Offset'}],...
                    'ColumnName',[{'Peak 1'},{'Peak 2'}],'CellEditCallback',{@ud_values,handles},...
                    'ColumnEditable',[true true]);%create table for the user to input the guess values
                ud_confirm=uicontrol('style','pushbutton','string','OK','parent',figure(997),'backgroundcolor',[0.75 0.75 0.75],...
                    'callback',@ud_confirm_callback,'userdata',0);
                waitfor(ud_confirm,'userdata');%wait for the user until the "OK" button is pressed
                set(figure(997),'visible','off');drawnow;
                guess=get(ud_table,'data');%extract the user-defined guess values
                disp('Using user-defined values');
                I=find(freq>=(f0-gamma0*factor_range_fit)&freq<=(gamma0*factor_range_fit+f0)); 
                guess=[guess(1,1),guess(2,1),guess(3,1),guess(4,1),guess(5,1),...
                    guess(1,2),guess(2,2),guess(3,2),guess(4,2),sum([guess(5,2),guess(6,1),guess(6,2)])];%reformat the guess array
                %set the number of peaks to fit to 2
                peak_sens=get(handles.peak_finding,'userdata');
                peak_sens(handles.din.harmonic,3)=2;
                set(handles.peak_finding,'userdata',peak_sens);
                try% tryGuess values based on user-input values
                    [GB_fit,GB_residual,GB_parameters,std_fit]=fit_spectra(handles,[freq,conductance,susceptance],guess,I);
                    disp('User-defined fit completed!');
                catch%if fit fails, output nan arrays
                    disp('Fit failed!');                               
                end%try
            case 'Three'%fit 3 peaks
                %provide starting guess values for user to edit
                try
                    [peak_detect,index]=findpeaks(smooth(smooth(conductance),7),'minpeakprominence',peak_sens((handles.din.harmonic+1)/2,1),...
                        'minpeakheight',(max(conductance)-min(conductance))*peak_sens((handles.din.harmonic+1)/2,2)+min(conductance));
                catch
                    [peak_detect,index]=findpeaks(smooth(conductance),'sortstr','descend');
                end%try 
                Gmax=peak_detect(1);%find peak of curve
                f0=freq(index(1));%finds freq at which Gmax happens
                halfg=(Gmax-min(conductance))./2+min(conductance);%half of the Gmax
                halfg_freq=freq(find(abs(halfg-conductance)==min(abs((halfg-conductance))),1));
                gamma0=abs(halfg_freq-f0);%Guess for gamma, HMHW of peak
                offset=0; phi=0;
                try
                    guess=get(handles.(['X',num2str(handles.din.harmonic)]),'userdata');
                    guess=[[guess(1,1:5)';guess(2,5)],[guess(1,6:10)';guess(2,10)],[guess(1,11:15)';guess(2,15)]];
                catch                                       
                    try
                        guess=[[f0;gamma0;phi;Gmax;offset;offset],...
                        [freq(index(2));gamma0/4;phi;peak_detect(2);offset;offset],...
                        [freq(index(3));gamma0/4;phi;peak_detect(3);offset;offset]];           
                    catch
                        guess=[[f0;gamma0;phi;Gmax;offset;offset],...
                        [freq(index(1));gamma0/4;phi;peak_detect(1);offset;offset],...
                        [freq(index(1));gamma0/4;phi;peak_detect(1);offset;offset]];     
                    end%try
                end       
                figure(997);clf(figure(997));pos=get(figure(997),'position');set(figure(997),'position',[pos(1) pos(2) 450 300]);
                ud_table=uitable(figure(997),'units','normalized','position',[0.05 0.05 0.9 0.9],'data',guess,...
                    'RowName',[{'freq.'},{'gamma0'},{'\phi'},{'Gmax'},{'Cond. offset'},{'Sus. Offset'}],...
                    'ColumnName',[{'Peak 1'},{'Peak 2'},{'Peak 3'}],'CellEditCallback',{@ud_values,handles},...
                    'ColumnEditable',[true true true]);%create table for the user to input the guess values
                ud_confirm=uicontrol('style','pushbutton','string','OK','parent',figure(997),'backgroundcolor',[0.75 0.75 0.75],...
                    'callback',@ud_confirm_callback,'userdata',0);
                waitfor(ud_confirm,'userdata');%wait for the user until the "OK" button is pressed
                set(figure(997),'visible','off');drawnow;
                guess=get(ud_table,'data');%extract the user-defined guess values
                disp('Using user-defined values');
                I=find(freq>=(f0-gamma0*factor_range_fit)&freq<=(gamma0*factor_range_fit+f0)); 
                guess=[guess(1,1),guess(2,1),guess(3,1),guess(4,1),sum([guess(5,1) guess(5,2) guess(5,3)]),...
                    guess(1,2),guess(2,2),guess(3,2),guess(4,2),...
                    guess(1,3),guess(2,3),guess(3,3),guess(4,3),sum([guess(6,1),guess(6,2),guess(6,3)])];%reformat the guess array
                %set the number of peaks to fit to 3
                peak_sens=get(handles.peak_finding,'userdata');
                peak_sens(handles.din.harmonic,3)=3;
                set(handles.peak_finding,'userdata',peak_sens);
                try% tryGuess values based on user-input values
                    [GB_fit,GB_residual,GB_parameters,std_fit]=fit_spectra(handles,[freq,conductance,susceptance],guess,I);                    
                    disp('User-defined fit completed!');
                catch%if fit fails, output nan arrays
                    disp('Fit failed!');                                   
                end%try
            case 'Cancel'%cancel user defined values and bring back to default Gmax choice
                set(handles.(['fit',num2str(handles.din.harmonic)]),'userdata',1);
                set(get(handles.reference_time,'userdata'),'value',1);%reset the guess value choice to Gmax
        end%switch user_peaks    
end%switch
combine_spectra=[freq,conductance,susceptance,GB_fit,GB_residual];%put everything in one variable
GB_parameters=par_check(GB_parameters);
set(handles.(['X',num2str(handles.din.harmonic)]),'userdata',GB_parameters);
if handles.prefs.show_GB==1
    disp(['G_l_sq: ',num2str(sum(GB_residual(:,1)))]);
    disp(['B_l_sq: ',num2str(sum(GB_residual(:,2)))]);
end%if handles.prefs.show_GB==1
function GB_parameters=par_check(GB_parameters)
%this function checks to see that the first 5 values in the parmeters
%variable is the most left one, representing the harmonic peak
if length(GB_parameters)==10
    if GB_parameters(1)>GB_parameters(6)
        GB_parameters=[GB_parameters(6:9),GB_parameters(5),GB_parameters(1:4),GB_parameters(10)];
    end%if G_parameters(1)>G_parameters(5)
elseif length(GB_parameters)==14
    test=[GB_parameters(1) GB_parameters(6) GB_parameters(10)];
    I=find(test==min(test));
    switch I
        case 2
            GB_parameters=[GB_parameters(6:9) GB_parameters(5) GB_parameters(1:4) GB_parameters(10:15)];
        case 3
            GB_parameters=[GB_parameters(10:14) GB_parameters(5) GB_parameters(1:4) GB_parameters(6:9) GB_parameters(15)];
    end%switch I
end%if length(G_parameters)==10
function [guess,f0,gamma0]=G_guess(freq,conductance,susceptance,handles,ylab)
%this function finds the guess values based on the max conductance value of
%the raw spectra
phi=0;%Assume rotation angle is 0
offset=0;%Assume offset value is 0
peak_sens=get(handles.peak_finding,'userdata');
try
    [peak_detect,index]=findpeaks(smooth(smooth(conductance),7),'minpeakprominence',peak_sens((handles.din.harmonic+1)/2,1),...
        'minpeakheight',(max(conductance)-min(conductance))*peak_sens((handles.din.harmonic+1)/2,2)+min(conductance));
catch
    [peak_detect,index]=findpeaks(smooth(conductance),'sortstr','descend');
end%try
flag=preview_peak_identification(freq,conductance,index,ylab,handles);
if flag==1
    guess=[]; f0=[]; gamma0=[];
    return
end%flag==1
Gmax=peak_detect(1);%find peak of curve
f0=freq(index(1));%finds freq at which Gmax happens
halfg=(Gmax-min(conductance))./2+min(conductance);%half of the Gmax
halfg_freq=freq(find(abs(halfg-conductance)==min(abs((halfg-conductance))),1));
gamma0=abs(halfg_freq-f0);%Guess for gamma, HMHW of peak
if peak_sens((handles.din.harmonic+1)/2,3)>=1&&size(peak_detect,1)>0
    guess=[f0/1e6 gamma0/1e4 phi*1e2 Gmax offset 0];
end%if peak_sens((handles.din.harmonic+1)/2,3)==1&&size(peak_detect,1)==1
if peak_sens((handles.din.harmonic+1)/2,3)>=2&&size(peak_detect,1)>1
    guess=[f0/1e6 gamma0/1e4 phi*1e2 Gmax offset...
        freq(index(2))/1e6 gamma0/2/1e4 phi*1e2 peak_detect(2) offset];
end%if peak_sens((handles.din.harmonic+1)/2,3)>=2&&size(peak_detect,1)>1
if peak_sens((handles.din.harmonic+1)/2,3)>=3&&size(peak_detect,1)>2
    guess=[f0/1e6 gamma0/1e4 phi*1e2 Gmax offset...
        freq(index(2))/1e6 gamma0/2/1e4 phi*1e2 peak_detect(2)...
        freq(index(3))/1e6 gamma0/2/1e4 phi*1e2 peak_detect(3) offset];
end%if peak_sens((handles.din.harmonic+1)/2,3)>=3&&size(peak_detect,1)>2
function [guess,freq_mod,modulus,f0,gamma0]=deriv_guess(freq,conductance,susceptance,handles)
%this function finds the guess values based on the derivative of the raw
%spectra
phi=0;%Assume rotation angle is 0
offset=0;%Assume offset value is 0
modulus=sqrt((diff(conductance)).^2+(diff(susceptance)).^2);
freq_mod=freq(1:end-1)+diff(freq)./2;
peak_sens=get(handles.peak_finding,'userdata');
try
    [peak_detect,index]=findpeaks(smooth(modulus,9),'minpeakprominence',peak_sens((handles.din.harmonic+1)/2,1),...
        'minpeakheight',(max(smooth(modulus,9))-min(smooth(modulus,9)))*peak_sens((handles.din.harmonic+1)/2,2)+min(smooth(modulus,9)));
catch
    [peak_detect,index]=findpeaks(smooth(modulus,9),'sortstr','descend');
end%try
flag=preview_peak_identification(freq_mod,modulus,index,'Modulus (mS)',handles);
if flag==1
    guess=[]; f0=[]; gamma0=[];freq_mod=[];modulus=[];
    return
end%flag==1
if isempty(peak_detect)
    disp('No peak detected!');
    guess=[]; f0=[]; gamma0=[];freq_mod=[];modulus=[];
    set(handles.status,'string','Status: No peak detected!','foregroundcolor','k','backgroundcolor','r');
    return
end%if isempty(peak_detect)
modulus=smooth(modulus,9);%smooth out the dataset
modulus_max=peak_detect(1);%find peak of curve
f0=freq_mod(index(1));%finds freq at which Gmax happens
halfg=(modulus_max-min(modulus))./2+min(modulus);%half of the Gmax
halfg_freq=freq_mod(find(abs(halfg-modulus)==min(abs((halfg-modulus))),1));
gamma0=abs(halfg_freq-f0);%Guess for gamma, HMHW of peak
phi=asind(conductance(1)/(sqrt((conductance(1))^2+(susceptance(1))^2)));%guess of the phase angle between the conductance and susceptance
if peak_sens((handles.din.harmonic+1)/2,3)>=1&&size(peak_detect,1)>0
    guess=[f0/1e6 gamma0/1e4 phi*1e2 modulus_max offset 0];
end%if peak_sens((handles.din.harmonic+1)/2,3)==1&&size(peak_detect,1)==1
if peak_sens((handles.din.harmonic+1)/2,3)>=2&&size(peak_detect,1)>1
    guess=[f0/1e6 gamma0/1e4 phi*1e2 modulus_max offset...
        freq(index(2)) gamma0/2/1e4 phi*1e2 peak_detect(2) offset];
end%if peak_sens((handles.din.harmonic+1)/2,3)==2&&size(peak_detect,1)>1
if peak_sens((handles.din.harmonic+1)/2,3)>=3&&size(peak_detect,1)>2
    guess=[f0/1e6 gamma0/1e4 phi*1e2 modulus_max offset...
        freq(index(2)) gamma0/2/1e4 phi*1e2 peak_detect(2) offset...
        freq(index(3)) gamma0/2/1e4 phi*1e2 peak_detect(3) offset];
end%if peak_sens((handles.din.harmonic+1)/2,3)>=3&&size(peak_detect,1)>2
function flag=preview_peak_identification(freq,ydata,index,ylabel_str,handles)
%This function shows what peaks were identified and asks for confirmation
%whether the peaks have been properly identified.
flag=0;
if (get(handles.start,'value')==0&&get(handles.peak_centering,'value')==1)||...
        (get(handles.start,'value')==0&&strcmp(handles.select_spectra.State,'on'))
    figure(998);clf(figure(998));
    set(figure(998),'units','normalized','position',[.725 .01 .25 .25],...
    'numbertitle','off','name','Peak identification','tag','refit2');
    plot(freq,smooth(smooth(ydata,7)));hold on;
    plot(freq(index),ydata(index),'-x','linewidth',2,'markersize',10);
    xlabel('Freq (Hz)');
    ylabel(ylabel_str);
    L=legend('Smoothed data',['Identified peaks: ',num2str(length(index))],'location','best');
    set(L,'fontsize',8)
    drawnow;
    button=questdlg('Continue or cancel fitting?','Fitting paused...','Continue','Cancel','Continue');
    switch button
        case 'Continue'
            flag=0;
        case 'Cancel'
            flag=1;
            disp('Peak fitting canceled!');
    end
end%et(handles.start,'value')==0
function [GB_fit,GB_residual,GB_parameters,std_fit]=fit_spectra(handles,raw_data,guess,I)
%This function tries to fit the raw spectra using the provided guess values
freq=raw_data(:,1);
conductance=raw_data(:,2);
susceptance=raw_data(:,3);
tic
[GB_fit,GB_residual,GB_parameters,std_fit]=fit_spectra_both(guess,freq,conductance,susceptance,handles.prefs.num_peaks,I,handles);
toc
function [fitted_y,residual,parameters,std_fit]=fit_spectra_con(x0,freq_data,y_data,I,show_GB,lb,ub)%fit spectra to conductance curve
%This function takes the starting guess values ('guess_values'_) and fits a
%Lorentz curve to the the x_data and y_data. The variable 'guess_values' 
%needs to be a 1x5 array. The designation foe each elements is as follows:
%p(1): f0 maximum frequency
%p(2): gamma0 dissipation
%p(3): phi phse angle difference
%p(4): Gmax maximum conductance
%p(5): Offset value
%Variables, 'lb' and 'ub', defines the lower and upper bound of each of the
%guess_paramters. Both 'lb' and 'ub' are 1x5 array.
if nargin==5
    lb=[0 0 -inf -90 -100];
    ub=[Inf Inf 90 100 100];
end%if nargin==5
options=optimset('display','off','tolfun',1e-10,'tolx',1e-10);
run('Lorentz_eqns.m');%load the Lorentz anonymous functions into workspace
[parameters,resnorm,residual,exitflag,output,lambda,jacobian]=lsqcurvefit(@lfun4c,x0,freq_data(I),y_data(I),lb,ub,options);%use lsqcurvefit function to fit the spectra data to a Lorentz curve
fitted_y=lfun4c(parameters,freq_data);
residual=fitted_y-y_data;
if show_GB==1%checck to see whether or not to show the parameters
    disp('Conductance fitted parameters:');
    disp(parameters');
end%if handles.prefs.show_GB==1
ci=nlparci(parameters,residual,'jacobian',jacobian);%calculate 95% confidence interval
std_fit0=diff(ci,1,2)./4;%Assume that 1/4th of ci represents the std
std_fit=[std_fit0(1)*1e6 std_fit0(2)*1e4];%calculated std for Df and Dg
function [fitted_y,residual,parameters,std_fit]=fit_spectra_sus(x0,freq_data,susceptance_data,I,show_GB,lb,ub)%fit spectra to susceptance curve
%This function takes the starting guess values ('guess_values'_) and fits a
%Lorentz curve to the the x_data and y_data. The variable 'guess_values' 
%needs to be a 1x5 array. The designation foe each elements is as follows:
%p(1): f0 maximum frequency
%p(2): gamma0 dissipation
%p(3): phi phase angle difference
%p(4): Gmax maximum conductance
%p(5): Offset value
%Variables, 'lb' and 'ub', defines the lower and upper bound of each of the
%guess_paramters. Both 'lb' and 'ub' are 1x5 array.
if nargin==5
    lb=[0 0 -90 -90 -100];
    ub=[Inf Inf 90 100 100];
end%if nargin==5
options=optimset('display','off','tolfun',1e-10,'tolx',1e-10);
run('Lorentz_eqns.m');%load the Lorentz anonymous functions into workspace
[parameters,resnorm,residual,exitflag,output,lambda,jacobian]=lsqcurvefit(@lfun4s,x0,freq_data(I),susceptance_data(I),lb,ub,options);%use lsqcurvefit function to fit the spectra data to a Lorentz curve
fitted_y=lfun4s(parameters,freq_data);
residual=fitted_y-susceptance_data;
if show_GB==1%checck to see whether or not to show the parameters
    disp('Susceptance fitted parameters:');
    disp(parameters');
end%if handles.prefs.show_GB==1
ci=nlparci(parameters,residual,'jacobian',jacobian);%calculate 95% confidence interval
std_fit0=diff(ci,1,2)./4;%Assume that 1/4th of ci represents the std
std_fit=[std_fit0(1)*1e6 std_fit0(2)*1e4];%calculated std for Df and Dg
function [fitted_y,residual,parameters,std_fit]=fit_spectra_both(x0,freq_data,conductance,susceptance,num_peaks,I,handles,lb,ub)
%This function fits both the conductance and susceptance curves simultaneously.
%x0: fitted parameters (see lfun4_both)
%freq_data: frequency array
%conductance: conductance array
%susceptance: susceptance array
%num_peaks: number of peaks to be fitted
%I: indices of conductance and susceptance that will be used for the fitting
%lb: lower bound
%ub: upper bound
options=optimset('display','off','tolfun',1e-10,'tolx',1e-10,'MaxFunEvals',1e6,'maxiter',1e6);
run('Lorentz_eqns.m');%load the Lorentz anonymous functions into workspace
if length(x0)==6%fitting code for one peak
    if nargin==7
        lb=[.999*min(freq_data)/1e6 0 -180*1e2 0 -1000 -1000];%lower bound
        ub=[1.001*max(freq_data)/1e6 2*(max(freq_data)-min(freq_data))/1e4 180*1e2 1000 1000 1000];%upper bound
    end
    [parameters,resnorm,residual,exitflag,output,lambda,jacobian]=lsqcurvefit(lfun4_both_1,x0,freq_data,[conductance susceptance],lb,ub,options);
    fitted_y=lfun4_both_1(parameters,freq_data);    
    disp('Fitting 1 peak');
elseif length(x0)==10%fitting code for two peaks
    if nargin==7
        lb=[.999*min(freq_data)/1e6 0 -180*1e2 -1000 -1000,...%1st peak
            .999*min(freq_data)/1e6 0 -180*1e2 -1000 -1000];%2nd peak
        ub=[1.001*max(freq_data)/1e6 2*(max(freq_data)-min(freq_data))/1e4 180*1e2 1000 1000,...%1st peak
            1.001*max(freq_data)/1e6 2*(max(freq_data)-min(freq_data))/1e4 180*1e2 1000 1000];%2nd peak
    end
    [parameters,resnorm,residual,exitflag,output,lambda,jacobian]=lsqcurvefit(lfun4_both_2,x0,freq_data,[smooth(conductance,9) smooth(susceptance,9)],lb,ub,options);
    fitted_y=lfun4_both_2(parameters,freq_data);
    disp('Fitting 2 peaks');
elseif length(x0)==14%fitting code for three peaks
    if nargin==7
        lb=[.999*min(freq_data/1e6) 0 -180*1e2 -1000 -1000,...%1st peak
            .999*min(freq_data)/1e6 0 -180*1e2 -1000,...%2nd peak
            .999*min(freq_data)/1e6 0 -180*1e2 -1000,-1000];%3rd peak
        ub=[1.001*max(freq_data)/1e6 2*(max(freq_data)-min(freq_data))/1e4 180*1e2 1000 1000,...%1st peak
            1.001*max(freq_data)/1e6 2*(max(freq_data)-min(freq_data))/1e4 180*1e2 1000,...%2nd peak
            1.001*max(freq_data)/1e6 2*(max(freq_data)-min(freq_data))/1e4 180*1e2 1000 1000];%3rd peak
    end
    [parameters,resnorm,residual,exitflag,output,lambda,jacobian]=lsqcurvefit(lfun4_both_3,x0,freq_data,[smooth(conductance) smooth(susceptance)],lb,ub,options);
    fitted_y=lfun4_both_3(parameters,freq_data);
    disp('Fitting 3 peaks');
end% if numpeaks==1
residual=[fitted_y(:,1)-conductance,fitted_y(:,2)-susceptance];
ci=nlparci(parameters,residual,'jacobian',jacobian);%calculate 95% confidence interval
std_fit0=diff(ci,1,2)./4;%Assume that 1/4th of ci represents the std
std_fit=[std_fit0(1)*1e6 std_fit0(2)*1e4];%calculated std for Df and Dg
function radio_chi_Callback(~, ~, handles)
% --- Executes on button press in radio_chi.
if get(handles.dynamic_fit,'value')==1
    if get(handles.radio_chi,'value')==1
        for dum=1:6
            chi_name=['X',num2str(dum*2-1)];
            set(handles.(chi_name),'visible','on');
        end% for dum=1:6  
    else
        for dum=1:6
            chi_name=['X',num2str(dum*2-1)];
            set(handles.(chi_name),'visible','off');
        end% for dum=1:6  
    end%if get(handles.radio_chi,'value')==1
else
end%if get(handles.dynamic_fit,'value')==1
if get(handles.radio_chi,'value')==1%this ensures that the scans will do a lorentzian fit, othersie there will be an error
    set(handles.dynamic_fit,'value',1);
end%if get(handles.radio_chi,'value')==1
function ud_values(hObject,event,handles)
function ud_confirm_callback(hObject,~)
set(hObject,'userdata',randi(10));


%% Peak centering and peak tracking functions
function peak_centering_Callback(hObject, ~, handles)
set_settings_Callback(1, 1, handles);%write out the settings files
set(handles.peak_centering,'userdata',[]);
%turn on peak center uipanel and turn off harm radio dial
set(handles.harmonics_text,'visible','off');
set(handles.peak_center,'visible','on');
for dum=1:2:11
        harmname=['harm',num2str(dum)];
        centname=['center',num2str(dum)];
        set(handles.(harmname),'visible','off');
        set(handles.(centname),'value',0,'visible','on');
end%for dum=1:2:11
if get(handles.peak_centering,'value')==1%if peak centering button is turned on
    harm_tot=find_num_harms(handles);%find the total number of active harmonics from the harmonics panel (not the peak centering panel)
    set(handles.harmonics_text,'userdata',harm_tot);
    set(handles.peak_centering,'fontweight','bold','foregroundcolor','r');
    set(handles.status,'string','Status: Peak centering mode. Ready...','backgroundcolor','k','foregroundcolor','r');
else%if peak centering button is turned off
    %revert active harmonics back to initial state
    %first turn off all harmonics
    for dum=1:2:11
        harm_name=['harm',num2str(dum)];
        set(handles.(harm_name),'value',0);
        write_settings(handles,dum);%refresh the settings files
        disp(['Settings refreshed for ',harm_name,'!']);
        set(handles.status,'string','Status: Settings refreshed!','backgroundcolor','k','foregroundcolor','r');
        drawnow;
    end%for dum=1:2:11
    %turn back initial active harmonics back on
    active_harm=get(handles.harmonics_text,'userdata');
    for dum=1:length(active_harm)
        harm_name=['harm',num2str(active_harm(dum))];
        set(handles.(harm_name),'value',1);
    end%for dum=1:length(harm_tot)
    if flag==1%if the start button was running previously, turn it back on
        set(handles.start,'value',1);
    end%flag==1
    %turn on/off appropriate radio dials and handle objects
    set(handles.peak_centering,'userdata',[]);
    set(handles.harmonics_text,'visible','on');
    set(handles.peak_center,'visible','off');
    for dum=1:2:11
        harmname=['harm',num2str(dum)];
        centname=['center',num2str(dum)];
        set(handles.(harmname),'visible','on');
        set(handles.(centname),'visible','off');
    end%for dum=1:2:11
    set(handles.peak_centering','fontweight','normal','foregroundcolor','k');
    set(handles.status,'string','Status: Ready...','backgroundcolor','k','foregroundcolor','r');
end%if get(handles.peak_centering,'value')==1
guidata(hObject, handles);
set_settings_Callback(handles.set_settings, 1, handles);
function center_peak_function(handles,harm,hObject)
%This function creates a figure containing buttons and text boxes that will
%be used in locating the resonance peaks.
try
    initial_end=str2double(get(handles.(['end_f',num2str(harm)]),'string'));
    initial_start=str2double(get(handles.(['start_f',num2str(harm)]),'string'));
    f1=figure(harm); set(f1,'name',['Harmonic: ', num2str(harm)]);
    freq_range=(initial_end-initial_start).*1e6;%calculate the initial frequency range of the harmonic
    [freq,~,~,handles]=read_scan(handles);
    p(1)=axes;  p(2)=axes;
    %based on the harmonic number determine the xy coordinates
    if harm==1||harm==3||harm==5
        factorx=((harm+1)*0.5-1)*(1/5);
        factory=0.5;
    elseif harm==7||harm==9||harm==11
        factorx=((harm+1)*0.5-4)*(1/5);
        factory=0.1;
    end%if harm==1||harm==3||harm==5
    set(f1,'units','normalized','position',[0.00476+factorx factory 0.5 0.33333],'toolbar','figure');%adjust location of the figure
    set(p(1),'units','normalized','position',[0.06 0.2 0.5 0.7],'fontsize',10,'buttondownfcn',{@refresh_button2,handles,p});
    set(p(2),'units','normalized','position',[0.06 0.2 0.5 0.7],'fontsize',10,'buttondownfcn',{@refresh_button2,handles,p},'color','none','yaxislocation','right');
    tbh=findall(f1,'type','uitoolbar');
    [fit_button,refresh]=my_buttons();  
    pth2=uipushtool(tbh,'cdata',refresh,'tooltipstring','Refresh raw spectra data',...
        'ClickedCallback',{@refresh_button,handles,p});
    span_panel=uipanel('title','Span','fontweight','bold','position',[.63 .2 .35 .8],...
        'fontsize',10,'bordertype','line','titleposition','centertop','shadowcolor','k',...
        'foregroundcolor','b');
    set_span=uicontrol('parent',span_panel,'style','edit',...
        'unit','normalized','position',[.274 0.415 0.45 0.08],...
        'fontweight','bold','fontsize',10,'backgroundcolor',[1 1 1],...
        'string',(str2double(get(handles.(['end_f',num2str(harm)]),'string'))-...
        str2double(get(handles.(['start_f',num2str(harm)]),'string'))).*1e3);
    set(set_span,'callback',{@manual_set_span,handles,p,set_span});
    increase_span_txt=uicontrol('parent',span_panel,'style','text',...
        'string','Increase span','unit','normalized','position',[0.08 0.88 0.4 0.1],...
        'fontweight','bold','fontsize',10);  
    statistics_txt=uicontrol('parent',span_panel,'style','edit',...
        'string','','units','normalized','position',[0.01 0.01 0.6 0.38],...
        'fontweight','bold','fontsize',8,'backgroundcolor',[1 1 1],...
        'enable','inactive','max',10);
    num_data_pts_txt=uicontrol('parent',span_panel,'style','text',...
        'string','# of data points','units','normalized','position',[0.65 0.22 0.35 0.1],...
        'fontweight','bold','fontsize',10);
    num_pts=get(handles.num_datapoints,'userdata');
    num_data_pts_edit=uicontrol('parent',span_panel,'style','edit',...
        'string',num_pts(handles.din.harmonic,1),'units','normalized',...
        'position',[0.7 0.13 0.2 0.1],...
        'fontweight','bold','fontsize',10,'backgroundcolor','w');
    set(num_data_pts_edit,'callback',{@store_num_data,handles,p});
    pth1=uipushtool(tbh,'cdata',fit_button,'tooltipstring','Apply a Lorentzian fit',...
        'ClickedCallback',{@myL_fit,handles,p,statistics_txt});
    pth2=uipushtool(tbh,'cdata',get(handles.peak_finding,'cdata'),'tooltipstring','Peak finding options.',...
        'ClickedCallback',{@peak_finding_ClickedCallback,handles});
    increase_span_x50=uicontrol('parent',span_panel,'style','pushbutton',...
        'string','x50','unit','normalized','position',[0.1 0.8 0.35 0.1],...
        'fontweight','bold','fontsize',10);
    set(increase_span_x50,'callback',{@span_adjust,handles,p,50,set_span});
    increase_span_x10=uicontrol('parent',span_panel,'style','pushbutton',...
        'string','x10','unit','normalized','position',[0.1 0.7 0.35 0.1],...
        'fontweight','bold','fontsize',10);
    set(increase_span_x10,'callback',{@span_adjust,handles,p,10,set_span});
    increase_span_x5=uicontrol('parent',span_panel,'style','pushbutton',...
        'string','x5','unit','normalized','position',[0.1 0.6 0.35 0.1],...
        'fontweight','bold','fontsize',10);
    set(increase_span_x5,'callback',{@span_adjust,handles,p,5,set_span});
    increase_span_x2=uicontrol('parent',span_panel','style','pushbutton',...
        'string','x2','unit','normalized','position',[0.1 0.5 0.35 0.1],...
        'fontweight','bold','fontsize',10);
    set(increase_span_x2,'callback',{@span_adjust,handles,p,2,set_span});
    decrease_span_txt=uicontrol('parent',span_panel,'style','text',...
        'string','Decrease span','unit','normalized','position',[0.55 0.88 0.35 0.1],...
        'fontweight','bold','fontsize',10);            
    decrease_span_d50=uicontrol('parent',span_panel,'style','pushbutton',...
        'string','/50','unit','normalized','position',[0.55 0.8 0.35 0.1],...
        'fontweight','bold','fontsize',10);
    set(decrease_span_d50,'callback',{@span_adjust,handles,p,1/50,set_span});
    decrease_span_d10=uicontrol('parent',span_panel,'style','pushbutton',...
        'string','/10','unit','normalized','position',[0.55 0.7 0.35 0.1],...
        'fontweight','bold','fontsize',10);
    set(decrease_span_d10,'callback',{@span_adjust,handles,p,1/10,set_span});
    decrease_span_d5=uicontrol('parent',span_panel,'style','pushbutton',...
        'string','/5','unit','normalized','position',[0.55 0.6 0.35 0.1],...
        'fontweight','bold','fontsize',10);
    set(decrease_span_d5,'callback',{@span_adjust,handles,p,1/5,set_span});
    decrease_span_d2=uicontrol('parent',span_panel,'style','pushbutton',...
        'string','/2','unit','normalized','position',[0.55 0.5 0.35 0.1],...
        'fontweight','bold','fontsize',10);
    set(decrease_span_d2,'callback',{@span_adjust,handles,p,1/2,set_span});
    set_span_units=uicontrol('parent',span_panel,'style','text',...
        'unit','normalized','position',[.727 0.38 0.27 0.1],...
        'fontweight','bold','fontsize',10,'string','kHz','horizontalalignment','left');
    fix_span_radio=uicontrol('parent',f1,'style','radiobutton',...
        'unit','normalized','position',[.65 0.03 .1 .1],...
        'fontweight','bold','fontsize',10,'string','Fix span',...
        'horizontalalignment','left','tooltipstring','The span of the frequency range is fixed',...
        'value',0,'backgroundcolor',get(f1,'color'));
    fix_center_radio=uicontrol('parent',f1,'style','radiobutton',...
        'unit','normalized','position',[.75 0.03 .11 .1],...
        'fontweight','bold','fontsize',10,'string','Fix center',...
        'horizontalalignment','left','tooltipstring','The center of the frequency range is fixed',...
        'value',0,'backgroundcolor',get(f1,'color'));
    custom_peak_tracker=uicontrol('parent',f1,'style','radiobutton',...
        'unit','normalized','position',[.86 0.03 .1 .1],...
        'fontweight','bold','fontsize',10,'string','Custom',...
        'horizontalalignment','left','tooltipstring','Clicking this option will run a custom peak tracking algorithm',...
        'value',0,'backgroundcolor',get(f1,'color'));
    guess_values_options=uicontrol('parent',f1,'style','popupmenu',...
        'unit','normalized','position',[.65 0.09 0.3 0.1],...
        'fontweight','bold','fontsize',10,'string',[{'Gmax'};{'Derivative'};{'Bmax'};{'Previous values'};{'User-defined'}],...
        'horizontalalignment','left','tooltipstring','Choose guess values for curve fitting.',...
        'value',1);
    set(handles.reference_time,'userdata',guess_values_options);%store the handles of the guess_value_options in the handles.refernce_time userdata field
    %Callback functions
    set(f1,'CloseRequestFcn',{@my_closereq,handles,freq,...
        [fix_span_radio,fix_center_radio,custom_peak_tracker],guess_values_options,f1,p});%create a figure with a special custom close request function
    set(fix_span_radio,'callback',{@peak_tracking_flag,handles,[fix_span_radio,fix_center_radio],1,p});
    set(fix_center_radio,'callback',{@peak_tracking_flag,handles,[fix_span_radio,fix_center_radio],1,p});
    set(custom_peak_tracker,'callback',{@custom_peak_track_flag,handles,[fix_span_radio,fix_center_radio,custom_peak_tracker],p});
    set(guess_values_options,'callback',{@store_guess_options,handles,guess_values_options,p});
    %load the current peak tracking and guess value settings
    radio_values=[get(handles.(['peak_track',num2str(harm)]),'userdata'),get(handles.(['fit',num2str(harm)]),'userdata')];
    if radio_values(1)==2
        set(custom_peak_tracker,'value',1);
        set(fix_span_radio,'value',0);
        set(fix_center_radio,'value',0);
    else
        set(fix_span_radio,'value',radio_values(1));
        set(fix_center_radio,'value',radio_values(2));
    end%if radio_values(1)==2
    set(guess_values_options,'value',radio_values(3));
    refresh_button(0,0,handles,p);%refresh the spectra
    %customize the datacursor mode, the zoom mode, and the pan tool
    dcm_obj=datacursormode(f1);
    set(dcm_obj,'UpdateFcn',{@myupdatefcn,handles,set_span,p})
    zoomh=zoom(f1);
    set(zoomh,'actionpostcallback',{@myzoomfcn,handles,set_span,p},'motion','horizontal','enable','on');
    
    panh=pan;
    set(panh,'actionpostcallback',{@myzoomfcn,handles,set_span,p},'motion','horizontal');
    c_info=getCursorInfo(dcm_obj);    
catch err_message
    assignin('base','err_message',err_message);
    disp('Error in peak centering mode!');
    set(handles.status,'string','Status: ERROR in peak centering mode!','foregroundcolor','k','backgroundcolor','r');
end%try
guidata(hObject, handles);
function peak_center_SelectionChangeFcn(hObject, eventdata, handles)
% --- Executes when selected object is changed in peak_center.
current_harm=get(hObject,'userdata');
handles.din.harmonic=current_harm;%store current harmonic (from peak centering panel) in handles structure
%Turn off all active radio dials except for the harmonic that is being
%centered. This will improve the refresh rate of the raw conductance
%spectra  during the peak centering process
set(handles.status,'string','Status: Ready...','backgroundcolor','k','foregroundcolor','r');
for dum=1:2:11
    harm_name=['harm',num2str(dum)];
    if dum~=current_harm;
        set(handles.(harm_name),'value',0);
    else
        set(handles.(harm_name),'value',1);
    end%if dum~=current_harm
end%for dum=1:2:11
write_settings(handles,current_harm);%update the settings text files
%if the start function is running, pause this while loop
if get(handles.start,'value')==1;
    set(handles.start,'value',0);
end%if get(handles.start,'value',1)
handles.din.harmonic=current_harm;
center_peak_function(handles,current_harm,hObject);%center the peak of the selected harmonic fromthe peak centering panel
guidata(hObject, handles);
function output_txt = myupdatefcn(~,event_obj,handles,set_span,p)
% This is the function that runs when datacursormode is employed. The
% output output-txt is what appears in the box.
%Determines output box--this is the usual function of datacursor, modified
%to know what the x axis actually is.
% datacursormode on
harm=get(get(p(1),'parent'),'number');%get the harmonic associated with the figure window
freq_range=str2double(get(set_span,'string'))*1e3;%frequency range in kHz
pos = get(event_obj,'Position');%get the position of the datacursor point
line_h=event_obj.Target;%line handle associeated with the selected datapoint
hObject.TipHandle.Interpreter='tex';%Set the interperter to tex so that greek symbols show up properly
output_txt = {['Frequency ',num2str(pos(1),5),' Hz'],...
    [get(get(line_h.Parent,'YLabel'),'string'),': ',num2str(pos(2),5)]};
set(handles.peak_centering,'userdata',1);
center=pos(1);
new_start=(center-(freq_range)/2).*1e-6;
new_end=(center+(freq_range)/2).*1e-6;
disp(['Frequency range (MHz): ',num2str(new_start),' to ',num2str(new_end)]);
disp(['frequency span: ',num2str(freq_range)]);
set(handles.(['start_f',num2str(harm)]),'string',num2str(new_start,10));
set(handles.(['end_f',num2str(harm)]),'string',num2str(new_end,10));
datacursormode off;
function store_num_data(hObject,~,handles,p)
%store the number of datapoints to record for that particular harmonic
harm=get(get(p(1),'parent'),'number');%get the harmonic associated with the figure window
num_pts=get(handles.num_datapoints,'userdata');
num_pts(harm,1)=str2double(get(hObject,'string'));
set(handles.num_datapoints,'userdata',num_pts);
disp(['# of datapoints for harmonic ',num2str(harm),': ',num2str(num_pts(harm,1))]);
name=['num_pts',num2str(harm)];
set(handles.(name),'string',['# pts: ',num2str(num_pts(harm,1))]);
function my_closereq(~,~,handles,freq,radio_handles,guess_values_options,f1,p)
%this function that runs when the user exsits out of the
%peak_centering figure window
harm=get(get(p(1),'parent'),'number');%get the harmonic associated with the figure window
peak_tracking_flag(0,0,handles,radio_handles,2,p);
custom_peak_track_flag(0,0,handles,radio_handles,p);
store_guess_options(0,0,handles,guess_values_options,p);
if isempty(get(handles.peak_centering,'userdata'))
    set(handles.peak_centering,'userdata',[mean(freq),1]);
else
    set(handles.peak_centering,'userdata',[]);
end%if isempty(handles.peak_centering,'userdata')
datacursormode off
delete(f1)
harm_name=['center',num2str(harm)];
set(handles.(harm_name),'value',0);
try delete(figure(999));delete(figure(998));delete(figure(996));delete(figure(997)); catch; end;%try
function myL_fit(~,~,handles,p,statistics_txt)
%This function that runs when the user clicks on the "Fit"
%button in the figure toolbar of the peak_centering window
harm=get(get(p(1),'parent'),'number');%get the harmonic associated with the figure window
handles=confirm_peak_finding(handles.peak_finding, 1, handles);%ask the user whether or not the peak(s) is/are the right one
figure(999);clf(figure(999));
set(gcf,'numbertitle','off','name',['Polar plot, Harmonic: ',num2str(harm)],...
    'units','normalized','position',[.725 0.4 .25 .35]);%create new figure window plotting the polar plot
temp=text(1,1,'Fitting...');set(temp,'parent',p(1),'units','normalized','position',[0.4 0.5],'fontsize',28,'fontweight','bold');drawnow;
[freq,conductance,susceptance,handles]=read_scan(handles);%read the scanned data
combine_spectra=[freq,conductance,susceptance];
[combine_spectra,GB_parameters,handles,I,std_fit]=Lorentzian_dynamic_fit(handles,freq,conductance,susceptance,combine_spectra);%fit curve
delete(temp);
if isempty(GB_parameters)
    delete(figure(999));delete(figure(998));
    return
end%if isempty(G_fit)
ave_f0=GB_parameters(1)*1e6;%resonance (Hz)
ave_g0=GB_parameters(2)*1e4;%HMHW (Hz)
GB_fit=combine_spectra(:,4:5);
GB_residual=combine_spectra(:,6:7);
%plot the raw data and the fitted data
figure(harm);%plot the data in the corresponding figure associated with the current harmonic
cla(p(1));cla(p(2));
try%this try block is needed, since the hold function changed in recent matlab versions
    hold(p(1),'on'); hold(p(2),'on');
catch
    axes(p(1)); hold on;
    axes(p(2)); hold on;
end
temp=text(1,1,'Plotting...');set(temp,'parent',p(1),'units','normalized','position',[0.4 0.5],'fontsize',28,'fontweight','bold');drawnow;
plot(p(1),freq,conductance,'bx-','markersize',10,'linewidth',2);
plot(p(1),freq(I),ones(size(I,1),1).*min(conductance),'-','linewidth',2,'color',[0.82031 0.410156 0.11718]);
plot(p(1),freq,GB_fit(:,1),'k-','linewidth',2);
axes(p(2));
plot(p(2),freq,susceptance,'rx-','markersize',10,'linewidth',2);hold on;
plot(p(2),freq,GB_fit(:,2),'k-','linewidth',2);
set(get(p(1),'ylabel'),'string','Conductance (mS)','fontweight','bold','fontsize',12);
set(get(p(2),'ylabel'),'string','Susceptance (mS)','fontweight','bold','fontsize',12);
axes(p(1));
xlabel(['Harmonic ',num2str(harm),', Frequency (Hz)'],'fontsize',12,'fontweight','bold');
set(get(p(2),'xlabel'),'string',get(get(p(1),'xlabel'),'string'));
linkaxes(p,'x');
%Calculate relevant statistics for the fit
G_l_sq=(sum(GB_residual(:,1))*1e-3)/str2double(get(handles.num_datapoints,'string'));
B_l_sq=(sum(GB_residual(:,2))*1e-3)/str2double(get(handles.num_datapoints,'string'));
G_r_sq=1-G_l_sq/(norm(conductance-mean(conductance))^2);
B_r_sq=1-B_l_sq/(norm(susceptance-mean(susceptance))^2);
G_stats=['Conductance:     Lsq: ',num2str(G_l_sq,3)];
B_stats=['Susceptance:     Lsq: ',num2str(B_l_sq,3)];
parameters1=['f:     ',num2str(ave_f0/1e6,10),' MHz'];%f0
parameters2=[char(915),':     ',num2str(ave_g0,10), ' Hz'];%g0
parameters3=['Gmax:     ',num2str(GB_parameters(4),10),' mS'];%Gmax
parameters4=[char(966),':     ',num2str(GB_parameters(3),10),' deg.'];%phi
run('Lorentz_eqns.m');
if length(GB_parameters)==6%single peak fitting    
    plot(p(1),ave_f0,sum(GB_parameters(4:5)),'o','color',[0 0.5 0],'markerfacecolor',[0 0.5 0],'markersize',10);
    plot(p(1),[ave_f0+ave_g0 ave_f0-ave_g0],...
    [0.5*GB_parameters(4)+GB_parameters(5),0.5*GB_parameters(4)+GB_parameters(5)],'mo','markerfacecolor','m','markersize',10);   
    parameters5=['G_offset:     ',num2str(GB_parameters(5),10),' mS'];%G_offset
    parameters6=['B_offset:     ',num2str(GB_parameters(6),10),' mS'];%B_offset
elseif length(GB_parameters)==10%double peak fitting
    plot(p(1),ave_f0,sum(GB_parameters(4:5)),'o','color',[0 0.5 0],'markerfacecolor',[0 0.5 0],'markersize',10);
    plot(p(1),[ave_f0+ave_g0 ave_f0-ave_g0],...
    [0.5*GB_parameters(4)+GB_parameters(5),0.5*GB_parameters(4)+GB_parameters(5)],'mo','markerfacecolor','m','markersize',10);   
    plot(p(1),[GB_parameters(1),GB_parameters(6)].*1e6,[GB_parameters(4),GB_parameters(9)]+GB_parameters(5),'gx','linewidth',2,'markersize',10);
    plot(p(1),freq,lfun4c(GB_parameters(1:5),freq)+GB_parameters(5),'g--');
    plot(p(1),freq,lfun4c(GB_parameters(6:9),freq)+GB_parameters(5),'g--');    
    parameters5=['G_offset:     ',num2str(GB_parameters(5),10),' mS'];%G_offset
    parameters6=['B_offset:     ',num2str(GB_parameters(10),10),' mS'];%B_offset
elseif length(GB_parameters)==14%triple peak fitting
    plot(p(1),ave_f0,sum(GB_parameters(4:5)),'o','color',[0 0.5 0],'markerfacecolor',[0 0.5 0],'markersize',10);
    plot(p(1),[ave_f0+ave_g0 ave_f0-ave_g0],...
    [0.5*GB_parameters(4)+GB_parameters(5),0.5*GB_parameters(4)+GB_parameters(5)],'mo','markerfacecolor','m','markersize',10);   
    plot(p(1),freq,lfun4c(GB_parameters(1:4),freq)+GB_parameters(5),'g--');
    plot(p(1),freq,lfun4c(GB_parameters(6:9),freq)+GB_parameters(5),'g--');
    plot(p(1),freq,lfun4c(GB_parameters(10:13),freq)+GB_parameters(5),'g--');
    plot(p(1),[GB_parameters(1),GB_parameters(6),GB_parameters(10)].*1e6,[GB_parameters(4),GB_parameters(9),GB_parameters(13)]+GB_parameters(5),'gx','linewidth',2,'markersize',10);
    parameters5=['G_offset:     ',num2str(GB_parameters(5),10),' mS'];%G_offset
    parameters6=['B_offset:     ',num2str(GB_parameters(14),10),' mS'];%B_offset
end%if length(GB_parameters)==5
set(p(1),'box','off','color','none');
set(p(2),'box','off','color','w','yaxislocation','right','ycolor','r','position',get(p(1),'position'),...
    'xlim',get(p(1),'xlim'),'xtick',get(p(1),'xtick'));
uistack(p(1),'top');
set(statistics_txt,'string',[{G_stats};{B_stats};{parameters1};{parameters2};...
    {parameters3};{parameters4};{parameters5};{parameters6}],'horizontalalignment','left');
%Create a polar plot that shows the quality of the fit for both the
%conductance and susceptance curves
figure(999);
plot(conductance,susceptance,'bx','linewidth',2,'markersize',6);hold on;
plot(GB_fit(:,1),GB_fit(:,2),'-','color',[0 0.5 0],'linewidth',2.5);
plot(GB_fit(I,1),GB_fit(I,2),'-','linewidth',2,'color',[0.82031 0.410156 0.11718]);
title('Polar plot of susceptance vs. conductance','fontweight','bold','fontsize',12);
xlabel('Conductance (mS)','fontsize',12,'fontweight','bold');
ylabel('Susceptance (mS)','fontsize',12,'fontweight','bold');
set(p(1),'ylimmode','auto','xlimmode','auto');
delete(temp);
function refresh_button(~,~,handles,p)
%this function runs when the refresh button is pressed
%in the toolbar of the peak_centering figure window (this refreshes the raw
%conductance spectra)
pause on;
harm=get(get(p(1),'parent'),'number');%get the harmonic associated with the figure window
for dum=1:2:11%turn off all active harmonics
    set(handles.(['harm',num2str(dum)]),'value',0);
end%for dum=1:2:11
set(handles.(['harm',num2str(harm)]),'value',1);%turn on curent harmonic defined by the figure window
cla(p);
set(handles.text2,'userdata',0);
check_freq_range(handles.din.harmonic, handles.din.freq_range(0.5*(harm+1),1), handles.din.freq_range(0.5*(harm+1),2), handles);
write_settings(handles,harm);%refresh the settings
hold off
text('units','normalized','position',[.1 .9 1],'string','Refreshing...','color','r','edgecolor','r');
h=waitbar(0,'Refreshing spectra plot...');
set(h,'WindowStyle','modal','closerequestfcn',{@pause_func1,handles});
set(p(2),'visible','off');
[freq,conductance,~,handles]=read_scan(handles);%get the spectra readings
plot(p(1),freq,conductance,'bx-','markersize',10,'linewidth',2);
linkdata(p(1).Parent,'on');%link the data to the plot
if handles.din.refit_flag==0%only execute if user is not in refit mode
    for dum=0:.1:(str2double(get(handles.wait_time,'string'))/1000*2)
        clc;
        waitbar(dum/((str2double(get(handles.wait_time,'string'))/1000*2)),h,...
            ['Refreshing spectra plot...',num2str((str2double(get(handles.wait_time,'string'))/1000*2)-dum)]);
        pause(.1);
        [freq,conductance,~,handles]=read_scan(handles);
        set(p(1),'xlim',[min(freq) max(freq)]);
        if get(handles.text2,'userdata')==1
            break
        end% if get(handles.text2,'userdata')==1
    end%for dum=0:.1:(str2double(get(handles.wait_time,'string'))/1000)*3
end%if handles.din.refit_flag==0
delete(h);
set(p(2),'visible','on');
delete(findall(p(2),'type','line','color','r','marker','x'));
[freq,conductance,susceptance,handles]=read_scan(handles);
plot(p(1),freq,conductance,'bx-','linewidth',2,'markersize',10);
plot(p(2),freq,susceptance,'rx-','linewidth',2,'markersize',10);
set(p(1),'box','off','xlim',[min(freq) max(freq)],'color','none','units','normalized','position',[0.06 0.2 0.5 0.75]);
set(p(2),'box','off','ycolor','r','xlim',get(p(1),'xlim'),'xtick',get(p(1),'xtick'),'yaxislocation','right','color','w','units','normalized','position',get(p(1),'position'));
get_ylim=get(p(1),'ylim');
set(p(1),'ylim',[get_ylim(1),1.01*get_ylim(2)]);
get_ylim=get(p(1),'ylim');
hold on;
set(p(1),'ylim',get_ylim,'buttondownfcn',{@refresh_button2,handles,p});
xlabel('Frequency (Hz)','fontweight','bold','fontsize',12);
set(get(p(1),'ylabel'),'string','Conductance (mS)','fontweight','bold','fontsize',12);
set(get(p(2),'ylabel'),'string','Susceptance (mS)','fontweight','bold','fontsize',12);
linkaxes(p,'x');%link the axes
uistack(p(1),'top');
drawnow;
function pause_func1(~,~,handles)
try set(handles.text2,'userdata',1); catch; end;
function refresh_button2(~,~,handles,p)       
pause on
if get(handles.peak_centering,'userdata')==1
    refresh_button(0,0,handles,p);
    set(handles.peak_centering,'userdata',0);
end
function span_adjust(~,~,handles,p,factor,set_span)
% This function that increases or decreases the span of the raw
% conductance spectra so that a larger range of frequency values is
% measured.
harm=get(get(p(1),'parent'),'number');%get the harmonic associated with the figure window
txt=text('units','normalized','position',[.1 .9 1],'string','Refreshing...','color','r','edgecolor','r');
[freq,~,~,handles]=read_scan(handles);
start1=str2double(get(handles.(['start_f',num2str(harm)]),'string'))*1e6;%extract start frequency(Hz)
end1=str2double(get(handles.(['end_f',num2str(harm)]),'string'))*1e6;%extract end frequency(Hz)        
new_span=factor*(end1-start1);%calculate new span
new_start1=(((end1+start1)/2)-new_span/2)*1e-6;%set new start frequency
new_end1=(((end1+start1)/2)+new_span/2)*1e-6;%set new end frequency
if new_start1<=0
    new_start1=1;
    check_freq_range(harm, handles.din.freq_range((harm+1)/2,1), handles.din.freq_range((harm+1)/2,2), handles);
end%if new_start1<=0
if new_end1>=60
    new_end1=59;
end;
set(handles.(['start_f',num2str(harm)]),'string',num2str(new_start1,10));
set(handles.(['end_f',num2str(harm)]),'string',num2str(new_end1,10));
set(set_span,'string',(new_end1-new_start1)*1e3);
check_freq_range(handles.din.harmonic, handles.din.freq_range(0.5*(handles.din.harmonic+1),1), handles.din.freq_range(0.5*(handles.din.harmonic+1),2), handles);
refresh_button(0,0,handles,p);
function myzoomfcn(~,~,handles,set_span,p)
%this function will calculate what the current span of the axes is and
%update the set_span edit text box
harm=get(get(p(1),'parent'),'number');%get the harmonic associated with the figure window
current_span=get(p(1),'xlim');%extract out the start and end values of the frequency in the figure window
span_calc=abs(current_span(2)-current_span(1))*1e-3;%calculate the span of the figure window (kHz)
set(set_span,'string',num2str(span_calc,10));%display the span in kHz
set(handles.(['start_f',num2str(harm)]),'string',num2str(current_span(1)*1e-6,10));%adjust the start frequency value
set(handles.(['end_f',num2str(harm)]),'string',num2str(current_span(2)*1e-6,10));%adjust the end frequency value
check_freq_range(handles.din.harmonic, handles.din.freq_range(0.5*(handles.din.harmonic+1),1), handles.din.freq_range(0.5*(handles.din.harmonic+1),2), handles);
refresh_button(0,0,handles,p);%refresh the graph by rescanning with the new end and start frequencies
function manual_set_span(~,~,handles,p,set_span)
harm=get(get(p(1),'parent'),'number');%get the harmonic associated with the figure window
user_defined_span=str2double(get(set_span,'string'))*1e3;%extract the user defined span (Hz)
current_xlim=get(p(1),'xlim');%extract out the current start and end frequencies
current_center=.5*(current_xlim(1)+current_xlim(2));%calculate the current center
new_xlim=[current_center-user_defined_span/2,current_center+user_defined_span/2].*1e-6;%new start and end freq in MHz
set(handles.(['start_f',num2str(harm)]),'string',num2str(new_xlim(1),10));
set(handles.(['end_f',num2str(harm)]),'string',num2str(new_xlim(2),10));
check_freq_range(handles.din.harmonic, handles.din.freq_range(0.5*(handles.din.harmonic+1),1), handles.din.freq_range(0.5*(handles.din.harmonic+1),2), handles);
refresh_button(0,0,handles,p);%refresh spectra
function peak_tracking_flag(~,~,handles,radio_handles,flag,p)
harm=get(get(p(1),'parent'),'number');%get the harmonic associated with the figure window
harm_name=['peak_track',num2str(harm)];%determine which handle to extract information based on harmonic
peak_track=get(handles.(harm_name),'userdata');%extract out the userdata from the relevant handle
peak_track(1)=get(radio_handles(1),'value');%change the userdata based on the value of the fix span radio dial
peak_track(2)=get(radio_handles(2),'value');%change the userdata based on the value of the fix center radio dial
set(handles.(harm_name),'userdata',peak_track);%update the userdata of the handle
if peak_track(1)==1&&peak_track(2)==1&&flag==1
    warning1=warndlg('WARNING: Fixing both the span and the center can lead to systematic error!',...
        'Warning!');
    set(warning1,'color',[1 1 0]);
    set(handles.(harm_name),'string','Fixed span + center');
end%    if peak_track(1)==1&&peak_track(2)==1
if peak_track(1)==1&&peak_track(2)==0
    set(handles.(harm_name),'string','Fixed span','value',peak_track);
elseif peak_track(1)==0&&peak_track(2)==1
    set(handles.(harm_name),'string','Fixed center','value',peak_track);
elseif peak_track(1)==0&&peak_track(2)==0
    set(handles.(harm_name),'string','Default peak tracking','value',peak_track);
end%if peak_track(1)==1&&peak_track(2)==0
function custom_peak_track_flag(~,~,handles,radio_handles,p)
harm=get(get(p(1),'parent'),'number');%get the harmonic associated with the figure window
harm_name=['peak_track',num2str(harm)];%determine which handle to extract information based on harmonic
custom_track=get(radio_handles(3),'value');%get the value for the custom_peak_tracker radio dial
if custom_track==1
    set(radio_handles(1),'value',0);%set the fix span radio dial to 0
    set(radio_handles(2),'value',0);%set the fix center radio dial to 0
    if custom_track==1
        set(handles.(harm_name),'userdata',[2 0],'string','Custom peak tracking algorithm');%update the userdata of the handle
    else
        set(handles.(harm_name),'userdata',[0 0],'string','Default peak tracking algorithm');%update the userdata of the handle
    end%if custom_track==1
end%if custom_track==1
function store_guess_options(~,~,handles,guess_handle,p)
harm=get(get(p(1),'parent'),'number');%get the harmonic associated with the figure window
fit_name=['fit',num2str(harm)];
guess_option=get(guess_handle,'value');
switch guess_option
    case 1
        set(handles.(fit_name),'string','Gmax','userdata',guess_option);
    case 2
        set(handles.(fit_name),'string','Derivative','userdata',guess_option);
    case 3
        set(handles.(fit_name),'string','Bmax','userdata',guess_option);
    case 4
        set(handles.(fit_name),'string','Previous Fit','userdata',guess_option);
    case 5
        set(handles.(fit_name),'string','User-defined','userdata',guess_option);
end%switch guess_option
set(handles.(fit_name),'userdata',guess_option);
function handles=confirm_peak_finding(~, ~, handles)
%store the preferences for finding the peak
data=get(handles.peak_finding,'userdata');
for dum=1:2:11
    handles.prefs.sensitivity(dum)=data(0.5*(dum+1),1);
    handles.prefs.peak_min(dum)=data(0.5*(dum+1),2);
    handles.prefs.num_peaks(dum)=data(0.5*(dum+1),3);
end%for dum=1:2:11
guidata(handles.primary1,handles);
function [handles]=peak_finding_ClickedCallback(~, ~, handles)
%This function creates a figure containing a table displaying the
%preferences for finding the resonance peaks
close(figure(996)); figure(996);
pos=get(figure(996),'position');
set(figure(996),'position',[pos(1)/2 pos(2)/15 pos(3)/1 pos(4)/2]);
set(figure(996),'menubar','none','toolbar','none','numbertitle','off','name','Peak finding options');
%names of columns and rows of table
rnames={'1st','3rd','5th','7th','9th','11th'};
cnames={'peak prominence sensitivity factor','peak minimum threshold','Max # peaks'};
handles=guidata(handles.primary1);
data=[handles.prefs.sensitivity(1:2:11);handles.prefs.peak_min(1:2:11);handles.prefs.num_peaks(1:2:11)];
find_peak_options=uitable('units','normalized','position',[0.05 0.15 .9 .8],...
    'columnname',cnames,'rowname',rnames,'data',data','fontsize',10,...
    'columneditable',logical([1 1 1]),'celleditcallback',{@fpo,handles});%create the table
uicontrol('style','pushbutton','string','table properties','units','normalized',...
    'position',[0.7 0.02 .25 .1],'callback',{@ins});
set(figure(996),'closerequestfcn',{@fp_close,handles,find_peak_options});
function fpo(hObject,~,handles)
data=get(hObject,'data');
set(handles.peak_finding,'userdata',data);
confirm_peak_finding(hObject,1,handles);
disp('Peak sensitivity options set!');
function ins(hObject,~)
inspect(hObject);
function fp_close(hObject,~,handles,find_peak_options)
data=get(find_peak_options,'data');
set(handles.peak_finding,'userdata',data);
delete(hObject);
disp('Peak sensitivity options are set!');
function [handles]=smart_peak_tracker(handles,freq,conductance,susceptance,G_parameters)
try
    f0=G_parameters(1);
    gamma0=G_parameters(2);
catch
end%try
%Determine whether to use the conducatnace or array or susceptance array to
%track the peak.
name=['fit',num2str(handles.din.harmonic)];%determine the structure field that should be used to extract out the initial-guessing method
%This if-statement checks to see if the initial guess values are based on
%"BMax" option (for fitting the Lorentz curve). Usually when "BMax" is
%turned on, the susceptance plots will be more accurate to track the
%resonance peak instead of the conductance peak.
if get(handles.(name),'userdata')==3%If BMax is turned on
    resonance=susceptance;
else
    resonance=conductance;
end%if get(handles.(name),'userdata')==3
[~,index]=findpeaks(resonance,'sortstr','descend');
peak_f=freq(index(1));
Gmax=resonance(index(1));%determine the estimated associated conductance (or susceptance) value at the resonance peak
halfg=(Gmax-min(resonance))./2+min(resonance);%determine the estimated half-max conductance (or susceptance) of the resonance peak
halfg_freq=abs(freq(find(abs(halfg-resonance)==min(abs((halfg-resonance))),1))-peak_f);
peak_track=get(handles.(['peak_track',num2str(handles.din.harmonic)]),'userdata');%extract out the peak tracking conditions
    if peak_track(1)==1&&peak_track(2)==0%adjust window based on fixed span
        current_span=(str2double(get(handles.(['end_f',num2str(handles.din.harmonic)]),'string'))-...
            str2double(get(handles.(['start_f',num2str(handles.din.harmonic)]),'string')))*1e6;%get the current span of the data in Hz
        if abs(mean([freq(1),freq(end)])-peak_f)>handles.din.set_span_factor_sensitivity*current_span
            new_xlim=[(peak_f-.5*current_span),(peak_f+.5*current_span)].*1e-6;%new start and end frequencies in MHz
            set(handles.(['start_f',num2str(handles.din.harmonic)]),'string',num2str(new_xlim(1),12));%set new start freq in MHz
            set(handles.(['end_f',num2str(handles.din.harmonic)]),'string',num2str(new_xlim(2),12));%set new end freq in MHz
        end%if abs(mean([freq(1),freq(end)])-f0)>0.25*current_span
    elseif peak_track(1)==0&&peak_track(2)==1%adjust window based on fixed center
        current_xlim=[str2double(get(handles.(['start_f',num2str(handles.din.harmonic)]),'string')),...
            str2double(get(handles.(['end_f',num2str(handles.din.harmonic)]),'string'))].*1e6;%get current start and end frequencies of the data in Hz
        current_center=((str2double(get(handles.(['start_f',num2str(handles.din.harmonic)]),'string'))+...
            str2double(get(handles.(['end_f',num2str(handles.din.harmonic)]),'string')))*1e6)/2;%get the current center of the data in Hz
        peak_xlim=[peak_f-halfg_freq*3,peak_f+halfg_freq*3];%find the starting and ending frequency of only the peak in Hz
            if sum(abs(current_xlim-([current_center-3*halfg_freq,current_center+3*halfg_freq])))>3e3
                new_xlim=[current_center-3*halfg_freq,current_center+3*halfg_freq].*1e-6;%set new start and end freq based on the location of the peak in MHz
                set(handles.(['start_f',num2str(handles.din.harmonic)]),'string',num2str(new_xlim(1),10));%set new start freq in MHz
                set(handles.(['end_f',num2str(handles.din.harmonic)]),'string',num2str(new_xlim(2),10));%set new end freq in MHz
            end
    elseif peak_track(1)==1&&peak_track(2)==1%adjust window based on fixed span and fixed center
        %do not adjust the start and end freq. this is not idea esp. if the
        %resonance peaks is shifting over a function of time.
    elseif peak_track(1)==0&&peak_track(2)==0%adjust window if neither span or center is fixed (default)
        current_xlim=[str2double(get(handles.(['start_f',num2str(handles.din.harmonic)]),'string')),...
            str2double(get(handles.(['end_f',num2str(handles.din.harmonic)]),'string'))];%get current start and end frequencies of the data in MHz        
        current_span=(str2double(get(handles.(['end_f',num2str(handles.din.harmonic)]),'string'))-...
            str2double(get(handles.(['start_f',num2str(handles.din.harmonic)]),'string')))*1e6;%get the current span of the data in Hz
        if (mean(current_xlim)*1e6-peak_f)>1*current_span/12
            new_xlim=(current_xlim*1e6-current_span/15)*1e-6;%new start and end frequencies in MHz
            set(handles.(['start_f',num2str(handles.din.harmonic)]),'string',num2str(new_xlim(1),12));%set new start freq in MHz
            set(handles.(['end_f',num2str(handles.din.harmonic)]),'string',num2str(new_xlim(2),12));%set new end freq in MHz
        elseif (mean(current_xlim)*1e6-peak_f)<-1*current_span/12
            new_xlim=(current_xlim*1e6+current_span/15)*1e-6;%new start and end frequencies in MHz
            set(handles.(['start_f',num2str(handles.din.harmonic)]),'string',num2str(new_xlim(1),12));%set new start freq in MHz
            set(handles.(['end_f',num2str(handles.din.harmonic)]),'string',num2str(new_xlim(2),12));%set new end freq in MHz
        else
            thresh1=.05*current_span+current_xlim(1)*1e6;%Threshold frequency in Hz
            thresh2=.03*current_span;%Threshold frequency span in Hz
            LB_peak=peak_f-halfg_freq*3;%lower bound of the resonance peak
            if LB_peak-thresh1>halfg_freq*8%if peak is to thin, zoom into the peak
                new_xlim(1)=(current_xlim(1)*1e6+thresh2)*1e-6;%MHz
                new_xlim(2)=(current_xlim(2)*1e6-thresh2)*1e-6;%MHz
                set(handles.(['start_f',num2str(handles.din.harmonic)]),'string',num2str(new_xlim(1),12));%set new start freq in MHz
                set(handles.(['end_f',num2str(handles.din.harmonic)]),'string',num2str(new_xlim(2),12));%set new end freq in M
            elseif thresh1-LB_peak>-halfg_freq*5%if the peak is too fat, zoom out of the peak
                new_xlim(1)=(current_xlim(1)*1e6-thresh2)*1e-6;%MHz
                new_xlim(2)=(current_xlim(2)*1e6+thresh2)*1e-6;%MHz
                set(handles.(['start_f',num2str(handles.din.harmonic)]),'string',num2str(new_xlim(1),12));%set new start freq in MHz
                set(handles.(['end_f',num2str(handles.din.harmonic)]),'string',num2str(new_xlim(2),12));%set new end freq in M
            end%if LB_peak-thresh1>halfg_freq*6*1.5            
        end% if abs(set_xlim(1)-current_xlim(1))*1e6>1e3||abs(current_xlim(2)-set_xlim(2))*1e6>1e3
    elseif peak_track(1)==2&&peak_track(2)==0%run custom, 	 tracking algorithm
        %%%%%%%CUSTOM, USER-DEFINED
        %%%%%%%CUSTOM, USER-DEFINED
        %%%%%%%CUSTOM, USER-DEFINED
        %%%%%%%CUSTOM, USER-DEFINED
    end%if fix_span==1&&fix_center==0
    check_freq_range(handles.din.harmonic, handles.din.freq_range(0.5*(handles.din.harmonic+1),1), handles.din.freq_range(0.5*(handles.din.harmonic+1),2), handles);
function center1_Callback(hObject, eventdata, handles)
% --- Executes on button press in center1.
if get(hObject,'value')==1
    peak_center_SelectionChangeFcn(hObject, eventdata, handles)
end%if get(hObject,'value')==1
function center3_Callback(hObject, eventdata, handles)
% --- Executes on button press in center3.
if get(hObject,'value')==1
    peak_center_SelectionChangeFcn(hObject, eventdata, handles)
end%if get(hObject,'value')==1
function center5_Callback(hObject, eventdata, handles)
% --- Executes on button press in center5.
if get(hObject,'value')==1
    peak_center_SelectionChangeFcn(hObject, eventdata, handles)
end%if get(hObject,'value')==1
function center7_Callback(hObject, eventdata, handles)
% --- Executes on button press in center7.
if get(hObject,'value')==1
    peak_center_SelectionChangeFcn(hObject, eventdata, handles)
end%if get(hObject,'value')==1
function center9_Callback(hObject, eventdata, handles)
% --- Executes on button press in center9.
if get(hObject,'value')==1
    peak_center_SelectionChangeFcn(hObject, eventdata, handles)
end%if get(hObject,'value')==1
function center11_Callback(hObject, eventdata, handles)
% --- Executes on button press in center11.
if get(hObject,'value')==1
    peak_center_SelectionChangeFcn(hObject, eventdata, handles)
end%if get(hObject,'value')==1


function handles=cla_raw_Callback(hObject, ~, handles)
% --- Executes on button press in cla_raw.
%This function clears all raw spectra
marker_color={[0 0 0],[0 0 1],[1 0 0],[0 0.5 0],[1 .8398 0],[.25 .875 .8125]};
cla(handles.primaryaxes1);cla(handles.primaryaxes2);
if ishold(handles.primaryaxes1)==0
    if verLessThan('matlab','8.4.0')%execute if MATLAB version is 2013a or earlier
        hold(handles.primaryaxes1);
    else%execute if MATLAB version id 2014b or later
        hold(handles.primaryaxes1,'on');
    end%  if verLessThan('matlab','8.4.0')
end%if ishold(handles.primaryaxes1)==0
if ishold(handles.primaryaxes2)==0    
    if verLessThan('matlab','8.4.0')%execute if MATLAB version is 2013a or earlier
        hold(handles.primaryaxes2);
    else%execute if MATLAB version id 2014b or later
        hold(handles.primaryaxes2,'on');
    end%    if ishold(handles.primaryaxes2)==0    
end%if ishold(handles.primaryaxes2)==0
for dum=1:6%create plot handles for the primary axes
    handles.primary_handles.(['phantom',num2str(dum),'a'])=plot(handles.primaryaxes1,[1,2],[1,1],'o-','color',marker_color{dum},'visible','off','userdata',2*dum-1,'markersize',6);    
    handles.primary_handles.(['phantom',num2str(dum),'b'])=plot(handles.primaryaxes2,[1,2],[1,1],'o-','color',marker_color{dum},'visible','off','userdata',2*dum-1,'markersize',6);
end%for dum=1:6
if verLessThan('matlab','8.4.0')%execute if MATLAB version is 2013a or earlier
        hold(handles.primaryaxes1);hold(handles.primaryaxes2);
    else%execute if MATLAB version id 2014b or later
        hold(handles.primaryaxes1,'off');hold(handles.primaryaxes2,'off');
end%  if verLessThan('matlab','8.4.0')
for dum0=1:6
    chi_name=['X',num2str(dum0*2-1)];
    axes_name=['axes',num2str(dum0)];
    axes_name2=['sa',num2str(dum0)];
%     set(handles.(chi_name),'string','Xsq = ');
    cla(handles.(axes_name));    cla(handles.(axes_name2));    
end%for dum=1:6
for dum=1:6
    ax_name1=['axes',num2str(dum)];
    ax_name2=['sa',num2str(dum)];    
    plot_name1=['phantom',num2str(dum),'a'];
    plot_name2=['phantom',num2str(dum),'b'];    
    plot_name3=['phantom',num2str(dum),'c'];
    plot_name4=['phantom',num2str(dum),'d'];
    plot_name5=['phantom',num2str(dum),'e'];
    plot_name6=['phantom',num2str(dum),'f'];
    plot_name7=['phantom',num2str(dum),'g'];
    plot_name8=['phantom',num2str(dum),'h'];
    plot_name9=['phantom',num2str(dum),'i'];
    plot_name10=['phantom',num2str(dum),'j'];    
    if verLessThan('matlab','8.4.0')%execute if MATLAB version is 2013a or earlier
        hold(handles.(ax_name1));hold(handles.(ax_name2));
    else%execute if MATLAB version id 2014b or later
        hold(handles.(ax_name1),'on');hold(handles.(ax_name2),'on');
    end%
    handles.spectra_handles.(plot_name1)=plot(handles.(ax_name1),[1,2],[1,1],...
        'bx-','markersize',6,'visible','off','userdata',2*dum-1);hold on;
    handles.spectra_handles.(plot_name2)=plot(handles.(ax_name2),[1 2],[1 1],...
        'rx-','markersize',6,'visible','off','userdata',2*dum-1);hold on;
    handles.spectra_handles.(plot_name10)=plot(handles.(ax_name1),[1,2],[1,1]...
        ,'x','linewidth',1,'visible','off','color',[0 0.5 0],'markersize',6);hold on;
    handles.spectra_handles.(plot_name3)=plot(handles.(ax_name1),[1,2],[1,1],...
        'k-','linewidth',2,'visible','off');hold on;
    handles.spectra_handles.(plot_name4)=plot(handles.(ax_name2),[1,2],[1,1],...
        'k-','linewidth',2,'visible','off');hold on;
    handles.spectra_handles.(plot_name5)=plot(handles.(ax_name1),[1,2],[1,1],...
        '-','linewidth',2,'color',[0.82031 0.410156 0.11718],'visible','off');hold on;
    handles.spectra_handles.(plot_name6)=plot(handles.(ax_name1),[1,2],[1,1],...
        'mo','linewidth',1,'markerfacecolor','m','markersize',6,'visible','off');hold on;
    handles.spectra_handles.(plot_name7)=plot(handles.(ax_name1),[1,2],[1,1],...
        'o','linewidth',1,'color',[0 0.5 0],'markerfacecolor',[0 0.5 0],...
        'markersize',6,'visible','off');hold on;
    handles.spectra_handles.(plot_name8)=plot(handles.(ax_name1),[1,2],[1,1],...
        'k-.','linewidth',1,'visible','off');hold on;
    handles.spectra_handles.(plot_name9)=plot(handles.(ax_name1),[1,2],[1,1],...
        'k-.','linewidth',1,'visible','off');hold on;    
    set(handles.(ax_name1),'visible','on','box','off');
    set(handles.(ax_name2),'visible','off','box','off','yaxislocation','right','color','none','ycolor','r');    
    if verLessThan('matlab','8.4.0')%execute if MATLAB version is 2013a or earlier
        hold(handles.(ax_name1));hold(handles.(ax_name2));
    else%execute if MATLAB version id 2014b or later
        hold(handles.(ax_name1),'off');hold(handles.(ax_name2),'off');
    end%
    if handles.prefs.clc_cw==1
        clc;
    end%if handles.prefs.clc_cw==1        
end%for dum-1:6
handles.din.prev_cond=zeros(str2double(get(handles.num_datapoints,'string')),1);
set(handles.status,'string','Status: Plots are reset! Ready...','backgroundcolor','k','foregroundcolor','r');
guidata(hObject, handles);

function clear_datapoints_Callback(hObject, ~, handles)
% --- This function wil clear the datapoints in the FG_values field in handles.din
confirm=questdlg('Are you sure you want to clear data?',...
    '','Yes','No','No');
switch confirm
    case 'Yes'
    %output the deleted data in the deleted data folder with the filename containing the time in 'yyymmddThhmmss' format (iso 8601)
    backup=matfile(['deleted data\',datestr(clock,30),'_deleted_data'],'writable',true);
    backup.FG_frequency=handles.din.FG_frequency;
    backup.FG_freq_shifts=handles.din.FG_freq_shifts;
    backup.chi_sq_value=handles.din.chi_sqr_value;
    handles.din.FG_frequency=NaN(handles.din.max_datapts,13);
    handles.din.FG_freq_shifts=NaN(handles.din.max_datapts,13);
    handles.din.chi_sqr_value=NaN(handles.din.max_datapts,13);
    handles.din.n=1;    
    handles=cla_raw_Callback(hObject, 0, handles);
    handles.din.refit_finish1=0;
    handles.din.refit_finish3=0;
    handles.din.refit_finish5=0;
    handles.din.refit_finish7=0;
    handles.din.refit_finish9=0;
    handles.din.refit_finish11=0;
    handles.din.refit.counter=1;
    for dum=1:2:11
        name=['X',num2str(dum)];
        set(handles.(name),'userdata',[]);
    end%for dum=1:2:11
    guidata(hObject, handles);
    set(handles.status,'string',...
        'Status: Data has been deleted! A backup of the deleted data can be found in deleted_data.mat. Ready...',...
        'backgroundcolor','k','foregroundcolor','r');
    disp('Data has been deleted! A backup of the the deleted data can be found in the deleted data folder.');
    case 'No'
        set(handles.status,'string','Data was not deleted. Ready...');
        disp('Data was not deleted.');
end%switch confirm

function wait_time_Callback(~, ~, handles)
set(handles.status,'string','Status: WARNING: CHANGING THE TIME B/W MEASUREMNTS CAN CAUSE SYNC PROBLEMS! Ready...',...
    'backgroundcolor','y','foregroundcolor','r');

function num_datapoints_Callback(~, ~, handles)
num_datapoints=str2double(get(handles.num_datapoints,'string'));
round_num_datapoints=round(num_datapoints/100)*100;
if round_num_datapoints<2
    round_num_datapoints=2;
end%if round_num_datapoints<2
if round_num_datapoints>=2000
    round_num_datapoints=1999;
end%if round_num_datapoints=1999
set(handles.num_datapoints,'string',round_num_datapoints);
set(handles.status,'string','Status: WARNING: CHANGING THE # OF DATAPOINTS CAN CAUSE SYNC PROBLEMS! Ready...',...
    'backgroundcolor','y','foregroundcolor','r');

function handles=raw_fig_Callback(hObject, ~, handles)
%this function creates a new figure showing the selected raw conductance
%spectra
set(handles.home_push,'visible','on');
if get(handles.raw_fig,'value')==0%add if statement related to recording process
    harm_tot=find_num_harms(handles);
    for dum=1:length(harm_tot)
       flag=(harm_tot(dum)+1)/2;
       delete(figure(flag));
    end%for dum=1:length(harm_tot
    set(handles.start,'visible','on');
    if strcmp(get(handles.start,'string'),'Record Scan')==1&&get(handles.start,'value')==0%warn the user to break out of pause inthe command window
        h=msgbox('Click into the command window and hit enter to resume!','Alert!');
        set(h,'color','y');        
        disp('Click into the command window and hit enter to exit out of Raw Figure Mode!');
    end% if strcmp(get(handles.start,'string','Record Scan')==1&&get(handles.start,'value')==0    
end%if get(handles.raw_fig,'value')==1
if get(handles.start,'value')==0&&get(handles.raw_fig,'value')==1
    handles=cla_raw_Callback(hObject,1,handles);
    set(handles.start,'visible','off');
    disp('Plotting raw spectra(s)');
    set(handles.status,'string','Status: Plotting raw spectra(s)','foregroundcolor','r','backgroundcolor','k');drawnow;
else
    set(handles.start,'visible','on');
end%if get(handles.start,'value')==0
while get(handles.raw_fig,'value')==1&&get(handles.start,'value')==0
    set(handles.raw_fig,'fontweight','bold','foregroundcolor','r');
    get_radio_dials=[get(handles.harm1,'value');get(handles.harm3,'value');...
        get(handles.harm5,'value');get(handles.harm7,'value');...
        get(handles.harm9,'value');get(handles.harm11,'value')];
    for dum=1:6
        if get_radio_dials(dum)==1
            handles.din.harmonic=dum*2-1;
            [freq,conductance,susceptance,handles]=read_scan(handles);%get scan data
            combine_spectra=[freq,conductance,susceptance];
            if get(handles.polar_plot,'value')==1%run this block of code if the polar plot dial is checked
                f1=figure(dum);  clf(figure(dum));   a=axes;
                plot(a,conductance,susceptance,'x-','color',[0 0.5 0],'linewidth',1,'markersize',6);
                axis tight;  hold on;
                if get(handles.dynamic_fit,'value')==1
                    [combine_spectra,GB_parameters,handles,I,std_fit]=Lorentzian_dynamic_fit(handles,freq,conductance,susceptance,combine_spectra);
                    GB_residual=combine_spectra(:,6:7);
                    GB_fit=combine_spectra(:,4:5);
                    G_l_sq=(sum(GB_residual(:,1))*1e-3)/str2double(get(handles.num_datapoints,'string'));
                    B_l_sq=(sum(GB_residual(:,2))*1e-3)/str2double(get(handles.num_datapoints,'string'));
                    plot(a,GB_fit(:,1),GB_fit(:,2),'k-','linewidth',2);
                    plot(a,GB_fit(I,1),GB_fit(I,2),'-','linewidth',1,'color',[0.82031 0.410156 0.11718]);
                end%if get(handles.dynamic_fit,'value')==1
                ylabel(a,'Susceptance (mS)','fontweight','bold','fontsize',12);
                xlabel(a,'Conductance (mS)','fontweight','bold','fontsize',12);
            elseif get(handles.polar_plot,'value')==0%otherwise, plot things in the frequency domain
                if get(handles.dynamic_fit,'value')==1%this if statement will run the Lorentzian fitting function
                    [combine_spectra,GB_parameters,handles,I,std_fit]=Lorentzian_dynamic_fit(handles,freq,conductance,susceptance,combine_spectra);
                    GB_residual=combine_spectra(:,6:7);
                    GB_fit=combine_spectra(:,4:5);
                    G_l_sq=(sum(GB_residual(:,1))*1e-3)/str2double(get(handles.num_datapoints,'string'));
                    B_l_sq=(sum(GB_residual(:,2))*1e-3)/str2double(get(handles.num_datapoints,'string'));
                end%if get(handles.dynamic_fit,'value')==1   
                f1=figure(dum);  clf(figure(dum));   a=axes;
                plot(a,freq,conductance,'bx-','linewidth',1.5,'markersize',8);   hold on;
                if get(handles.dynamic_fit,'value')==1
                    plot(a,freq(I),ones(size(I,1),1).*min(conductance),'-','linewidth',2,'color',[0.82031 0.410156 0.11718]);
                    plot(a,freq,GB_fit(:,1),'k','linewidth',2);
                    plot(a,GB_parameters(1)*1e6,GB_parameters(4)+GB_parameters(5),'mo','markerfacecolor','m','markersize',6);
                    plot(a,[GB_parameters(1)*1e6-GB_parameters(2)*1e4,GB_parameters(1)*1e6+GB_parameters(2)*1e4],...
                        [0.5*GB_parameters(4)+GB_parameters(5),0.5*GB_parameters(4)+GB_parameters(5)],...
                        'o','color',[0 0.5 0],'markerfacecolor',[0 0.5 0],'markersize',6);                    
                    text('units','normalized','position',[.02 .92 1],'string',...
                        {['Xsq = ',num2str(sum(G_l_sq))];...
                        ['f = ',num2str(GB_parameters(1)),'\pm',num2str(std_fit(1)/1e6),' MHz'];...
                        ['\Gamma = ',num2str(GB_parameters(2)*1e4),'\pm',num2str(std_fit(2)),' Hz']},...
                    'fontweight','bold','backgroundcolor','none','edgecolor','k');
                    ylim_a=get(gca,'ylim');
                    b=axes('position',get(a,'position'));
                    plot(b,freq,susceptance,'rx-');   hold on;  
                    plot(b,freq,GB_fit(:,2),'k','linewidth',2);
                    set(a,'box','off','ylim',ylim_a);                      
                    set(b,'yaxislocation','right','ycolor','r','color','none','box','off');
                    xlabel(a,'Frequency (Hz)','fontweight','bold');
                    ylabel(a,'Conductance (mS)','fontweight','bold');
                    ylabel(b,'Susceptance (mS)','fontweight','bold');
                    set(get(b,'ylabel'),'rotation',-90,'units','normalized','position',[1.11 0.5 1]);
                    set(b,'position',get(a,'position'));
                    title(['Harmonic number: ',num2str(dum*2-1)],'fontweight','bold');
                end%if get(handles.c=dynamic_fit,'value')==1                        
            end %if get(handles.polar_plot,'value')==1            
        else
            delete(figure(dum));
        end%if radio_radio_dials(dum)==1
    end%for dum=1:6
    if handles.din.refit_flag==0
        set(handles.status,'string','Status: Hit enter to refresh spectra','backgroundcolor','k','foregroundcolor','r');
        disp('Hit enter to refresh spectra');
        pause
    else
        set(handles.status,'string','Status: Plotting finished!','backgroundcolor','k','foregroundcolor','r');drawnow;
        waitfor(handles.raw_fig,'value');
        set(handles.status,'string','Status: Exiting Raw Figure Mode...','backgroundcolor','k','foregroundcolor','r');drawnow;
    end%if handles.din.redit_flag==0    
    disp('Exited out of Raw Figure Mode');    
end%while get(handles.raw_fig,'value')==1%%get(handles.start,'value',)==0
if strcmp(get(handles.start,'string'),'Record Scan')==1||strcmp(get(handles.start,'string'),'Refit Scan')
    set(handles.start,'value',0);
end%strcmp(get(handles.start,'string'),'Stop Scan')==1
set(handles.raw_fig,'fontweight','normal','foregroundcolor','k');
delete([figure(1),figure(2),figure(3),figure(4),figure(5),figure(6)]);
%refresh the primary axes plots
set(handles.status,'string','Status: Ready...','backgroundcolor','k','foregroundcolor','r');drawnow;
plot_choice_Callback(handles.plot1_choice, 1, handles);
plot_choice_Callback(handles.plot2_choice, 1, handles);
guidata(hObject, handles);


%% Functions related to loading and saving settings and data
function set_settings_Callback(~, ~, handles)
% --- Executes on button press in set_settings.
%find active harmonics
harm_tot=find_num_harms(handles);
for dum=1:length(harm_tot)
    write_settings(handles,harm_tot(dum))
end%for dum=1:size(harm_tot,1)
set(handles.status,'string','Status: Settings have been set! Ready...','backgroundcolor','k','foregroundcolor','r');
disp('Settings have been set! Ready...');
function write_settings(handles,harm_num)
% This if statement writes out the setting.txt file for the selected harmonic harmonic
% (settings01.txt, settings03.txt, etc.)
if harm_num<11
    filename=['AccessMyVNAv0.7\release\settings0',num2str(harm_num),'.txt'];
else
    filename=['AccessMyVNAv0.7\release\settings',num2str(harm_num),'.txt'];
end%if harm_num<11
fileID=fopen(filename,'w');%write settings value into the settings.txt file
harmname=['harm',num2str(harm_num)];
startname=['start_f',num2str(harm_num)];
endname=['end_f',num2str(harm_num)];
num_pts=get(handles.num_datapoints,'userdata');
try
    if get(handles.(harmname),'value')==1
        fprintf(fileID,'%10.12f\r\n',str2double(get(handles.(startname),'string')));%write start frequency of <dum> harmonic
        fprintf(fileID,'%10.12f\r\n',str2double(get(handles.(endname),'string')));%write out end frequency of <dum> harmonic
        fprintf(fileID,'%10.12f\r\n',handles.din.freq_range((harm_num+1)./2,1));%write out lowerbound of frequency range for the harmonic
        fprintf(fileID,'%10.12f\r\n',handles.din.freq_range((harm_num+1)./2,2));%write out upperbound of frequency range for the harmonic
        fprintf(fileID,'%i\r\n',num_pts(harm_num,1));%write out the number of datapoints
    end%if get(handles.(harmname),'value')==1
    fclose(fileID);
catch
    disp('Could not write the settings file!')
end
%write out the settings.txt
try
    fileID1=fopen('AccessMyVNAv0.7\release\settings.txt','w');
    fprintf(fileID1,'%i\r\n',get(handles.maintain_myVNA,'value'));%write the toggle state of the maintain)myVNA radio dial
    fprintf(fileID1,'%i\r\n',str2double(get(handles.wait_time,'string')));%writes the wait time between measurements
    numberofharms=size(find_num_harms(handles),1);%finds the total number of harmonics
    fprintf(fileID1,'%i\r\n',numberofharms);%write out the total number of harmonics that are active
    fprintf(fileID1,'%i\r\n',find_num_harms(handles));%write the value of the harmonics
    fclose(fileID1);
catch err_message
    assignin('base','err_message',err_message);
    set(handles.status,'string','Status: Error in writing the settings.txt file!','foregroundcolor','k','backgroundcolor','r');
end
function save_settings_Callback(~, ~, handles)
%this function saves settings into an output file
try
    set(handles.status,'string','Status: Saving settings...please wait','backgroundcolor','k','foregroundcolor','r');drawnow;
    disp('Saving settings...please wait');
    h=waitbar(0,'Saving settings...');
    set(h,'CloseRequestFcn',@waitclose);
    hw=findobj(h,'Type','Patch');
    set(hw,'EdgeColor','k','FaceColor',[0 0.5 0]) % changes the color to green
    settings.maintain_myVNA=get(handles.maintain_myVNA,'value');
    settings.harm1=get(handles.harm1,'value');
    settings.harm3=get(handles.harm3,'value');
    settings.harm5=get(handles.harm5,'value');
    settings.harm7=get(handles.harm7,'value');
    settings.harm9=get(handles.harm9,'value');
    settings.harm11=get(handles.harm11,'value');
    settings.peak_track1=get(handles.peak_track1,'userdata');
    settings.peak_track3=get(handles.peak_track3,'userdata');
    settings.peak_track5=get(handles.peak_track5,'userdata');
    settings.peak_track7=get(handles.peak_track7,'userdata');
    settings.peak_track9=get(handles.peak_track9,'userdata');
    settings.peak_track11=get(handles.peak_track11,'userdata');
    settings.fit1=get(handles.fit1,'userdata');
    settings.fit3=get(handles.fit3,'userdata');
    settings.fit5=get(handles.fit5,'userdata');
    settings.fit7=get(handles.fit7,'userdata');
    settings.fit9=get(handles.fit9,'userdata');
    settings.fit11=get(handles.fit11,'userdata');
    waitbar(.2,h);drawnow;
    settings.X1_prev_par=get(handles.X1,'userdata');
    settings.X3_prev_par=get(handles.X3,'userdata');
    settings.X5_prev_par=get(handles.X5,'userdata');
    settings.X7_prev_par=get(handles.X7,'userdata');
    settings.X9_prev_par=get(handles.X9,'userdata');
    settings.X11_prev_par=get(handles.X11,'userdata');
    waitbar(.4,h);drawnow;
    settings.start_f1=get(handles.start_f1,'string');
    settings.end_f1=get(handles.end_f1,'string');
    settings.start_f3=get(handles.start_f3,'string');
    settings.end_f3=get(handles.end_f3,'string');
    settings.start_f5=get(handles.start_f5,'string');
    settings.end_f5=get(handles.end_f5,'string');
    settings.start_f7=get(handles.start_f7,'string');
    settings.end_f7=get(handles.end_f7,'string');
    settings.start_f9=get(handles.start_f9,'string');
    settings.end_f9=get(handles.end_f9,'string');
    settings.start_f11=get(handles.start_f11,'string');
    settings.end_f11=get(handles.end_f11,'string');
    waitbar(.6,h);drawnow;
    settings.refresh_spectra=get(handles.refresh_spectra,'string');
    settings.reference_time=get(handles.reference_time,'string');
    settings.wait_time=get(handles.wait_time,'string');
    settings.num_datapoints=get(handles.num_datapoints,'string');
    settings.record_time_increment=get(handles.record_time_increment,'string');
    settings.dynamic_fit=get(handles.dynamic_fit,'value');
    settings.radio_chi=get(handles.radio_chi,'value');
    settings.num_datapoints2=get(handles.num_datapoints,'userdata');
    settings.n=handles.din.n;%this setting was implmented in version 1.0c
catch
    set(handles.status,'string','Status: ERROR! Unable to save settings file. See Command Window! Ready...',...
        'backgroundcolor','r','foregroundcolor','k');
    disp('To exit out of debugging mode, click onto the MATLAB Editor Window and push the button that says,"Quit debugging", near the top of the window.')
    disp('Alternatively, you can type ''return'' in the Command Window and hit the "Enter" button.');
    keyboard;
end%try
try
    settings.output_filename=handles.din.output_filename;
    settings.output_path=handles.din.output_path;
catch
    settings.output_filename='defaultxxxx';
    settings.output_path='';
end%try
settings.din=handles.din;
waitbar(.8,h);drawnow;
version=get(handles.text17,'string');%write the version of the matlab gui program that was used to collect the data
save([settings.output_path,settings.output_filename,'_settings.mat'],'settings','version');
waitbar(1,h);drawnow;
delete(h);
set(handles.status,'string',['Status: Settings succesfully saved! ',settings.output_filename,'_settings.mat']);
disp('Settings succesfully saved! ');
function load_settings_Callback(hObject, ~, handles)
%This function loads the settings that were saved
disp('   ');
output_path=handles.din.output_path;
try
    output_filename=handles.din.output_filename;
    if isempty(handles.din.output_filename)==1
        handles.din.output_filename='';
        output_filename='';
    end%if isempty(handles.din.output_filename)==1
catch
    output_filename='';
    handles.din.output_filename=output_filename;
end
if isempty(get(handles.load_settings,'userdata'))
    try
       variables=open([handles.din.output_path,handles.din.output_filename,'_settings.mat']);
       settings=variables.settings;
       clear('variables');
       set(handles.load_settings,'userdata',1);
    catch
        try
            [settings_filename,settings_path,filter_index]=uigetfile('*.mat','Designate settings file name and location',handles.din.output_path);
            if settings_filename==0%run this if user hits 'cancel'
                settings_path='';
                settings_filename='Default_settings.mat';
            end
            load([settings_path,settings_filename]);
            set(handles.load_settings,'userdata',1);
        catch
            set(handles.status,'string','Status: ERROR! Unable to load settings file. Ready...',...
                'backgroundcolor','r','foregroundcolor','k');
        end%try
    end%try
else
        try
            [settings_filename,settings_path,filter_index]=uigetfile('*.mat','Designate settings file name and location',handles.din.output_path);
            load([settings_path,settings_filename]);
        catch
            set(handles.status,'string','Status: ERROR! Unable to load settings file. Ready...',...
                'backgroundcolor','r','foregroundcolor','k');
        end%try
end%if isempty(get(handles.load_settings,'userdata'))
try
%     set(handles.maintain_myVNA,'value',settings.maintain_myVNA);
    set(handles.harm1,'value',settings.harm1);
    set(handles.harm3,'value',settings.harm3);
    set(handles.harm5,'value',settings.harm5);
    set(handles.harm7,'value',settings.harm7);
    set(handles.harm9,'value',settings.harm9);
    set(handles.harm11,'value',settings.harm11);
    set(handles.peak_track1,'userdata',settings.peak_track1);
    set(handles.peak_track3,'userdata',settings.peak_track3);
    set(handles.peak_track5,'userdata',settings.peak_track5);
    set(handles.peak_track7,'userdata',settings.peak_track7);
    set(handles.peak_track9,'userdata',settings.peak_track9);
    set(handles.peak_track11,'userdata',settings.peak_track11);
    set(handles.fit1,'userdata',settings.fit1);
    set(handles.fit3,'userdata',settings.fit3);
    set(handles.fit5,'userdata',settings.fit5);
    set(handles.fit7,'userdata',settings.fit7);
    set(handles.fit9,'userdata',settings.fit9);
    set(handles.fit11,'userdata',settings.fit11);
    for dum=1:2:11
        name=['fit',num2str(dum)];
        if settings.(name)==1
            set(handles.(name),'string','Gmax');
        elseif settings.(name)==2
            set(handles.(name),'string','Derivative');
        elseif settings.(name)==3
            set(handles.(name),'string','Bmax');
        elseif settings.(name)==4
            set(handles.(name),'string','Previous Values');
        end%if settings.(name)==1
    end
    for dum=1:2:11
        harm_name=['peak_track',num2str(dum)];
        peak_track=['peak_track',num2str(dum)];
        pts_name=['num_pts',num2str(dum)];
        if settings.(peak_track)(1)==1&&settings.(peak_track)(2)==0
            set(handles.(harm_name),'string','Fixed span');
        elseif settings.(peak_track)(1)==0&&settings.(peak_track)(2)==1
            set(handles.(harm_name),'string','Fixed center');
        elseif settings.(peak_track)(1)==1&&settings.(peak_track)(2)==1
            set(handles.(harm_name),'string','Fixed span + center');
        elseif settings.(peak_track)(1)==2&&settings.(peak_track)(2)==0
            set(handles.(harm_name),'string','Custom peak tracking algorithm');
        else
            set(handles.(harm_name),'string','Default peak tracking algorithm');
        end%if peak_track(1)==1&&peak_track(2)==0
        set(handles.(pts_name),'string',['# pts: ',num2str(settings.num_datapoints2(dum))]);
    end% for dum=1:2:11
    disp('handles.harm settings loaded!');
    disp('handles.center settings loaded!');
    set(handles.X1,'userdata',settings.X1_prev_par);
    set(handles.X3,'userdata',settings.X3_prev_par);
    set(handles.X5,'userdata',settings.X5_prev_par);
    set(handles.X7,'userdata',settings.X7_prev_par);
    set(handles.X9,'userdata',settings.X9_prev_par);
    set(handles.X11,'userdata',settings.X11_prev_par);
    disp('handles.X settings loaded1');
    set(handles.start_f1,'string',settings.start_f1);
    set(handles.end_f1,'string',settings.end_f1);
    set(handles.start_f3,'string',settings.start_f3);
    set(handles.end_f3,'string',settings.end_f3);
    set(handles.start_f5,'string',settings.start_f5);
    set(handles.end_f5,'string',settings.end_f5);
    set(handles.start_f7,'string',settings.start_f7);
    set(handles.end_f7,'string',settings.end_f7);
    set(handles.start_f9,'string',settings.start_f9);
    set(handles.end_f9,'string',settings.end_f9);
    set(handles.start_f11,'string',settings.start_f11);
    set(handles.end_f11,'string',settings.end_f11);
    disp('Start and end frequency values loaded!');
    set(handles.refresh_spectra,'string',settings.refresh_spectra);
    set(handles.reference_time,'string',settings.reference_time);
    set(handles.wait_time,'string',settings.wait_time);
    set(handles.num_datapoints,'string',settings.num_datapoints);
    try set(handles.num_datapoints,'userdata',settings.num_datapoints2); catch; end;
    set(handles.record_time_increment,'string',settings.record_time_increment);
    disp('Scan settings loaded!');
    set(handles.dynamic_fit,'value',settings.dynamic_fit);
    set(handles.radio_chi,'value',settings.radio_chi);
    disp('Fitting options loaded!');
    disp('handles.din stucture updated!');
    [~,temp,~]=fileparts(handles.din.output_filename);
    set(handles.filename_txt,'tooltipstring',['<html>Filename: ',temp,'.mat<br />Filepath: ',handles.din.output_path,'</html>'],'userdata',1);
    set(handles.status,'string',['Status: Settings, ',settings.output_filename,...
        ', succesfully loaded!'],'backgroundcolor','k','foregroundcolor','r');
    disp(['Saved settings, ',settings.output_filename,' have been successfully loaded!']);
    set_settings_Callback(1,1, handles);%write out the settings file   
    handles.din.output_path=output_path;%preserve original values of the output path and filename
    handles.din.output_filename=output_filename;
catch err_msg
    assignin('base','err_msg',err_msg);
    if filter_index~=0
        set(handles.status,'string','Status: ERROR! Unable to load settings file. See Command Window! Ready...',...
            'backgroundcolor','r','foregroundcolor','k');
        disp('You are in debugging mode. ');
        disp('To exit out of debugging mode, click onto the MATLAB Editor Window and push the button that says,"Quit debugging", near the top of the window.')
        disp('Alternatively, you can type ''return'' in the Command Window and hit the "Enter" button.');
        keyboard
    end%if filter_index~=0
end%try
disp(' ');
guidata(hObject, handles);
function handles=save_data_Callback(hObject, ~, handles)
%This functions will output the data into a user specified filename and
%path
try
    [output_filename,output_path]=uiputfile('*.mat','Designate output file name and location',handles.din.output_path);
    [~, output_filename, ~] = fileparts(output_filename);
    full_filename=[output_path,output_filename];
    set(handles.filename_txt,'string',[full_filename(1:10),'...',full_filename(end-10:end)],...
        'tooltipstring',['<html>Filename: ',output_filename,'.mat<br />Filepath: ',output_path,'</html>'],'userdata',1);%output filename info
    handles.din.output_filename=output_filename;
    handles.din.output_path=output_path;
    disp('Files saved to:');
    disp([output_path,output_filename,'.mat']);
catch 
end%try
guidata(hObject, handles);
function append_data_Callback(hObject, eventdata, handles)
%this function asks the user to load the file inwhich the new data will be
%appended to
[append_filename,append_path,~]=uigetfile('*.mat','Select existing freq shift data',handles.din.output_path);
if ischar(append_filename)==0
    disp('Loading/appending file canceled');
    return
end
load([append_path,append_filename]);
%clear out the store FG shifts and absolute values by replacing all the
%values as nan
handles.din.FG_frequency=NaN(handles.din.max_datapts,13);
handles.din.FG_freq_shifts=NaN(handles.din.max_datapts,13);
handles.din.chi_sqr_value=NaN(handles.din.max_datapts,13);
nan_location=find(isnan(abs_freq(:,1)),1,'first');%find the first nan datapoint from the time column of the abs_freq variable
if isempty(nan_location)==1
    nan_location=size(abs_freq,1);
end%if isempty(nan_location)==1
%import in the data from the file to-be-appended to the current handles structure
handles.din.FG_frequency(1:nan_location,:)=abs_freq(1:nan_location,:);
handles.din.chi_sqr_value(1:nan_location,:)=chisq_values(1:nan_location,:);
handles.din.FG_freq_shifts(1:nan_location,:)=freq_shift(1:nan_location,:);
handles.din.ref_freq=freq_shift_ref(1,:);
handles.din.ref_diss=freq_shift_ref(2,:);
handles.din.n=find(isnan(abs_freq(:,1)),1,'first');
if isempty(handles.din.n)==1
    handles.din.n=nan_location+1;
end%if isempty(handles.din.n)==1
set(handles.reference_time,'string',reference(1,:));%redefine the reference time to the reference time from the file being appended
[~, append_filename, ~] = fileparts(append_filename);
handles.din.output_filename=append_filename;
handles.din.output_path=append_path;
set(handles.filename_txt,'string',[append_path(1:8),'...',append_filename],'tooltipstring',['<html>Filename: ',append_filename,'.mat<br />Filepath: ',append_path,'</html>']);
load_settings_Callback(hObject, eventdata, handles)%this will load the settings associated with the file being appended
plot_primaryaxes(handles,handles.din.FG_frequency,find_num_harms(handles),handles.din.n,'a');
plot_primaryaxes(handles,handles.din.FG_frequency,find_num_harms(handles),handles.din.n,'b');
guidata(hObject,handles);


%% Plotting in primaryaxes1 and primaryaxes2
function plot_choice_Callback(hObject,~,handles)
font_size=8;
font_weight='bold';
if strcmp(hObject.Tag,'plot1_choice')||strcmp(hObject.Tag,'primary1')
    pa1='primaryaxes1';
    pa2='a';
    choice=get(handles.plot1_choice,'value');
elseif strcmp(hObject.Tag,'plot2_choice')||strcmp(hObject.Tag,'primary2')
    pa1='primaryaxes2';
    pa2='b';    
    choice=get(handles.plot2_choice,'value');
end
num_harms=primaryaxes_harm(handles,pa2);
switch choice
    case 1
        xlabel(handles.(pa1),'');
        ylabel(handles.(pa1),'');
    case 2
        xlabel(handles.(pa1),'Time (min.)');
        ylabel(handles.(pa1),'\Deltaf (Hz)');
    case 3
        xlabel(handles.(pa1),'Time (min.)');
        ylabel(handles.(pa1),'\Deltaf/n (Hz)');
    case 4
        xlabel(handles.(pa1),'Time (min.)');
        ylabel(handles.(pa1),'\Delta\Gamma (Hz)');       
    case 5 %bulk calculations of viscelastic phase angle, phi
        xlabel(handles.(pa1),'Time (min.)');
        ylabel(handles.(pa1),'\phi (deg.)');  
    case 6
        xlabel(handles.(pa1),'Time (min.)');
        ylabel(handles.(pa1),'|G^*_n|\rho (Pa\cdotg/cm^3)');
    case 7
        xlabel(handles.(pa1),'Time (min.)');
        ylabel(handles.(pa1),'\DeltaM (g/m^2)');
end%switch choice
set(handles.(pa1),'fontsize',font_size);  
set(findall(handles.(pa1),'type','text'),'fontweight',font_weight,'fontsize',font_size);
for dum=1:6%hide the plot handles
    try
        set(handles.primary_handles.(['phantom',num2str(dum),pa2]),'visible','off');
    catch
        handles=cla_raw_Callback(handles.cla_raw,1,handles);
    end%try
end%for dum1:6
for dum=1:length(num_harms)
    handles.din.harmonic=num_harms(dum);
    if strcmp(hObject.Tag,'plot1_choice')||strcmp(hObject.Tag,'primary1')
        plot_primaryaxes(handles,handles.din.FG_frequency,find_num_harms(handles),handles.din.n,'a');
    elseif strcmp(hObject.Tag,'plot2_choice')||strcmp(hObject.Tag,'primary2')
        plot_primaryaxes(handles,handles.din.FG_frequency,find_num_harms(handles),handles.din.n,'b');
    end
end
function plot_primaryaxes(handles,FG_frequency,harm_tot,n,pa2)
hold on;
active_plot_harmonics=[];
flag=1;
current_harm=handles.din.harmonic;
if strcmp(pa2,'a')
    plot_choice='plot1_choice';
    pa1='plot_';
    pa3='primaryaxes1';
    yt1='ytick1';
elseif strcmp(pa2,'b')
    plot_choice='plot2_choice';
    pa1='plot2_';
    pa3='primaryaxes2';
    yt1='ytick2';
end
if handles.prefs.plot_dynamic_refresh==1
    handles=guidata(handles.primary1);
end%if handles.prefs.plot_dynamic_refresh==1
for dum=1:2:11
    plot_name_dial=[pa1,num2str(dum)];
    if get(handles.(plot_name_dial),'value')==1&&sum(harm_tot==dum)==1&&dum==current_harm
        active_plot_harmonics=[active_plot_harmonics,dum];
        flag=flag+1;
    end%if get(handles.(plot_name_dial),'value')==1
end%dum=1:2:11
dum=(active_plot_harmonics+1)/2;
zq=8.84e6;
f1=5e6;
if isempty(dum)==0
    F_frequency_shifts=FG_frequency(1:n,active_plot_harmonics(1)+1)-handles.din.ref_freq((active_plot_harmonics(1)+1)./2);
    G_frequency_shifts=FG_frequency(:,active_plot_harmonics(1)+2)-handles.din.ref_diss((active_plot_harmonics(1)+1)./2);
    switch get(handles.(plot_choice),'value')
        case 1
            for pdum=1:6%hide the plot handles
                set(handles.primary_handles.(['phantom',num2str(pdum),pa2]),'visible','off');
            end%for dum1:6
            units=[];
        case 2%plot frequency shift versus time            
            set(handles.primary_handles.(['phantom',num2str(dum),pa2]),'xdata',FG_frequency(1:n,1),'ydata',F_frequency_shifts(1:n),'visible','on');
            units='Hz';
        case 3%plot frequency shift/harmonic order versus time            
            set(handles.primary_handles.(['phantom',num2str(dum),pa2]),'xdata',FG_frequency(1:n,1),'ydata',F_frequency_shifts(1:n)./active_plot_harmonics,'visible','on');
            units='Hz';
        case 4%plot gamma shift versus time            
            set(handles.primary_handles.(['phantom',num2str(dum),pa2]),'xdata',FG_frequency(1:n,1),'ydata',G_frequency_shifts(1:n),'visible','on');
            units='Hz';
        case 5%plot viscoelastic phase angle (phi) versus time          
            set(handles.primary_handles.(['phantom',num2str(dum),pa2]),'xdata',FG_frequency(1:n,1),...
                'ydata',-2.*atand(F_frequency_shifts(1:n)./G_frequency_shifts(1:n)),'visible','on');
            units='deg.';
        case 6           
            phi=-2.*atand(F_frequency_shifts(1:n)./G_frequency_shifts(1:n));            
            grho=(pi.*zq.*G_frequency_shifts(1:n)./f1./cosd(phi./2)).^2./1000;%i units of Pa.g/cc
            set(handles.primary_handles.(['phantom',num2str(dum),pa2]),'xdata',FG_frequency(1:n,1),...
                'ydata',grho,'visible','on');
            units=['Pa',char(183),'g/cc'];
        case 7%plot Sauerbrey mass
            M=-F_frequency_shifts.*zq./2./f1.^2./2./active_plot_harmonics.*1000;%Areal mass in g/m^2
            set(handles.primary_handles.(['phantom',num2str(dum),pa2]),'xdata',FG_frequency(1:n,1),...
                'ydata',M,'visible','on');
            units='g/m^2';            
    end
    yt=get(handles.(pa3),'ytick');    
    set(handles.(yt1),'string',[num2str(abs(yt(1)-yt(2))),' ',units],...
        'tooltipstring',['<html>Y-tick interval<br/>',num2str(abs(yt(1)-yt(2))),' ',units,'<html/>']);
end%if isempty(dum)==0
function plot_helper(hObject,~,handles)
%This is the callback function for the plot1 radio dials (associated with
%the top primary axes plot). This function is used as a callback function
%for the radial dials associated with primaryaxes1 and primaryaxes2.
if length(hObject.Tag)==6%if the radial dials associated with primaryaxes1
    pa='primaryaxes1';
    pa2='a';
elseif length(hObject.Tag)==7%if the radial dials associated with primaryaxes2
    pa='primaryaxes2';
    pa2='b';
end
for dum=1:6%hide the plot handles
    set(handles.primary_handles.(['phantom',num2str(dum),pa2]),'visible','off');
    yt=get(handles.primaryaxes1,'ytick');    
    set(handles.ytick1,'string',[num2str(abs(yt(1)-yt(2))),' Hz']);
end%for dum1:6
num_harms=primaryaxes_harm(handles,pa2);
for dum=1:length(num_harms)
    handles.din.harmonic=num_harms(dum);
    plot_primaryaxes(handles,handles.din.FG_frequency,find_num_harms(handles),handles.din.n,pa2);
end
function num_harms=primaryaxes_harm(handles,pa2)
%this function provides the number active harmonics that are being plotted
%in handles.primaryaxes1
num_harms=[];
for dum=1:2:11
    if strcmp(pa2,'a')
        harm_name=['plot_',num2str(dum)];
    elseif strcmp(pa2,'b')
        harm_name=['plot2_',num2str(dum)];
    end    
    if get(handles.(harm_name),'value')==1 
        num_harms=[num_harms, dum];
    end%if get(handles.(harm_name),'value')==1
end%for dum=1:2:11
function uipushtool6_ClickedCallback(~, ~, handles)
% Modifying primaryaxes properties toolbar button
%these function allows the user to manipulate the plot properties manually
inspect(handles.primaryaxes1);
function uipushtool7_ClickedCallback(~, ~, handles)
% Modifying primaryaxes properties toolbar button
%these function allows the user to manipulate the plot properties manually
inspect(handles.primaryaxes2);

%% Functions related to email notifications
function email_notification_Callback(~, ~, handles)
%this function creates a figure window that asks the user to input an email
%adress to send the smail notifications to
disp('Setting up email notifications');
delete(figure(900));
f=figure(900);
pos=get(f,'position');
set(f,'position',[pos(1) pos(2) pos(3)/1.7 pos(4)/2],'menubar','none','numbertitle','off','name','Email setup');
txt=uicontrol('style','text','string','Be sure to click "Apply" to update settings!','units','normalized',...
    'fontweight','bold','fontsize',8,'position',[0.005 0.07 0.999 0.2/2],'backgroundcolor',get(f,'color'),...
    'horizontalalignment','left');
toggle_email=uicontrol('style','radiobutton',...
    'string','','units','normalized','position',[0.01 0.73 0.7 0.2/2],...
    'fontweight','bold','fontsize',8,'backgroundcolor',get(f,'color'),...
    'callback',{@toggle_func,handles,txt},'string','Turn on email notifications',...
    'value',get(handles.email_push,'userdata'));
email=uicontrol('style','edit',...
    'string',handles.prefs.email_recipient,'units','normalized','position',[0.33 0.86 0.6 0.1],...
    'fontsize',8,'backgroundcolor',[1 1 1],'horizontalalignment','left');
outserver=uicontrol('style','edit','units','normalized','position',[0.33 0.62 0.6 0.1],...
    'tooltipstring','(e.g. smtp.gmail.com)','string',handles.prefs.email_outgoing_server,...
    'horizontalalignment','left');
outserver_txt=uicontrol('style','text','string','Outgoing server:','units','normalized',...
    'position',[0.001 0.60 0.3 0.1],'fontweight','bold','fontsize',8,'horizontalalignment','right');
host_email=uicontrol('style','edit','units','normalized','position',[0.33 0.49 0.6 0.1],...
    'string',handles.prefs.email_host,'horizontalalignment','left');
host_email_txt=uicontrol('style','text','string','Host email: ','units','normalized',...
    'position',[0.001 0.47 0.3 0.1],'fontweight','bold','fontsize',8,'horizontalalignment','right');
host_email_pw=uicontrol('style','edit','units','normalized','position',[0.33 0.36 0.6 0.1],...
    'string',handles.prefs.email_pw,'horizontalalignment','left');
host_email_pw_txt=uicontrol('style','text','string','Email pw:','units','normalized',...
    'position',[0.001 0.35 0.3 0.1],'fontweight','bold','fontsize',8,'horizontalalignment','right');
uicontrol('style','text','string','Email recipient:','units','normalized',...
    'position',[0.001 0.85 0.3 0.1],'fontweight','bold','fontsize',8,...
    'background',get(f,'color'),'horizontalalignment','right');
apply_button=uicontrol('style','pushbutton','units','normalized','string','Apply',...
    'position',[0.78 0.001 0.2 0.1],'backgroundcolor',[0.8 0.8 0.8],...
    'callback',{@set_email_options,handles,outserver,host_email,host_email_pw,txt,toggle_email,email});
test_email_notification=uicontrol('style','pushbutton','units','normalized',...
    'string','Test connection','tooltipstring','The program will attempt to send an email to test if the settings have set correctly',...
    'backgroundcolor',[0.8 0.8 0.8],'position',[0.45 0.001 0.3 0.1],'callback',{@test_email,handles});
function test_email(hObject,~,handles)
disp('Testing connection...');
handles=guidata(handles.primary1);%update handles structure
guidata(handles.primary1,handles);
set(handles.status,'string','Status: Testing connection for email notification...','foregroundcolor','r','backgroundcolor','k');
email_send(handles,['This is a test message sent using the QCM acquisition program.' 10 'Version: ',handles.text17.String]);
function set_email_options(hObject,~,handles,outserver,host_email,host_email_pw,txt,toggle_email,email)
%check to see if all of the fields have been fillied out
handles.prefs.email_recipient=email.String;%the email the notifications will be sent to
handles.prefs.email_host=host_email.String;%the email host
handles.prefs.email_pw=host_email_pw.String;%password associated with the email host
handles.prefs.email_outgoing_server=outserver.String;%the outgoing email server (e.g. smtp.gmail.com)
if isempty(outserver.String)==0&&isempty(host_email.String)==0&&isempty(host_email_pw.String)==0&&...
    toggle_email.Value==1    
    handles.email_push.UserData=1;%save the toggle state of the email notification    
elseif toggle_email.Value==0%if the radio dial for turning on email notifications is set to off state
    handles.email_push.UserData=0;%save the toggle state of the email notification
else
    set(txt,'string','Error! Make sure to fill all req. fields','foregroundcolor','r');
end
guidata(handles.primary1,handles);%update the handle structure
function toggle_func(hObject,~,handles,txt)
set(handles.email_push,'userdata',get(hObject,'value'));
if get(hObject,'value')==1
    disp('Email notifications are turned on');
    set(handles.status,'string',['Status: Email notifications are turned on and will be sent to: ',get(handles.prefs.email_recipient,'userdata')],...
        'backgroundcolor','k','foregroundcolor','r');
    set(txt,'string',['Emails will be sent to: ',get(handles.prefs.email_recipient,'userdata')],'foregroundcolor','k');
    set(handles.email_push,'userdata',1);
    guidata(handles.primary1,handles);
else
    disp('Email notifications are turned off');
    set(handles.status,'string','Status: Email notifications are turned off','backgroundcolor','k','foregroundcolor','r');
    set(txt,'string','Email notifications turned off','foregroundcolor','k');
    set(handles.email_push,'userdata',0);
    guidata(handles.primary1,handles);
end%if get(hObject,'value')==1
function email_push_ClickedCallback(hObject, eventdata, handles)
email_notification_Callback(hObject, eventdata, handles)
guidata(hObject,handles);
function email_send(handles,message)
try
    drawnow; pause(1);
    try
        set(handles.GUI_hf,'paperpositionmode','auto');
        print(handles.GUI_hf,'-djpeg','email files/screenshot.jpg');%save a jpg of the entire GUI figure
        email=handles.prefs.email_recipient;
        disp(['Sending email to: ',email]);
        setpref('Internet','SMTP_Server',handles.prefs.email_outgoing_server);
        setpref('Internet','E_mail',handles.prefs.email_host);
        setpref('Internet','SMTP_Username',handles.prefs.email_host);
        setpref('Internet','SMTP_Password',handles.prefs.email_pw);
        props = java.lang.System.getProperties;%Java script
        props.setProperty('mail.smtp.auth','true');
        props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
        props.setProperty('mail.smtp.socketFactory.port','465');
        if handles.start.Value==1
            sendmail(email,['Email notification on the QCM exp ',handles.din.output_filename],message,{'qcm_diary.txt','email files/screenshot.jpg'});
        else
            sendmail(email,'Email test notification',message);
        end%if handles.start.Value==1
        disp('Email notification sent!');
    catch email_err
        assignin('base','email_err',email_err);
        disp('Error in sending email!');
    end
catch
    set(handles.email_push,'userdata',0)
end%try


%% Reset the GUI state to default settings
function handles=reset_fcn(hObject,eventdata,handles)
%this function reset the gui back to its original default state
%Note that this function will not reset the preferences that were set or
%changed!!!
backup=matfile(['deleted data\',datestr(clock,30),'_deleted_data'],'writable',true);%output the deleted data in the deleted data folder with the filename containing the time in 'yyymmddThhmmss' format (iso 8601)
backup.FG_frequency=handles.din.FG_frequency;
backup.FG_freq_shifts=handles.din.FG_freq_shifts;
backup.chi_sq_value=handles.din.chi_sqr_value;
handles.din.FG_frequency=NaN(handles.din.max_datapts,13);
handles.din.FG_freq_shifts=NaN(handles.din.max_datapts,13);
handles.din.chi_sqr_value=NaN(handles.din.max_datapts,13);
handles.din.n=1;    
handles.din.bare_flag=0;
handles.din.refit_flag=0;
handles.din.refit.loaded_var=[];
handles.din.ref_freq=handles.default_settings.ref_freq;
handles.din.ref_diss=handles.default_settings.ref_diss;
handles.din.refit.counter=1;
handles.din.refit_filename=[];
handles.din.refit_raw=[];
handles.din.refit_flag1=0;
handles.din.refit_time_index=1;
try
    rmfield(handles.din,'raw_spectra_path');
    rmfield(handles.din,'raw_spectra_file');
end
set(handles.refit,'tooltipstring','Refit pre-existing raw spectras');
set(handles.peak_centering,'visible','on');%display the button
set(handles.clear_datapoints,'visible','on');%display the button
set(handles.uipanel1,'visible','on');%display uipanel1
set(handles.home_push,'visible','on');%display the reset button
set(handles.del_mode,'visible','on');%display the del_mode toolbar button
if strcmp(get(handles.del_mode,'state'),'on')
    set(handles.confirm_del,'visible','on');%display the confim_del toolbar button
end%if get(handles.del_mode,'enable','on')
set(handles.dynamic_fit,'value',1);
set(handles.maintain_myVNA,'value',1);
set(handles.start,'string','Record Scan','foregroundcolor','w','backgroundcolor',[0 0.5 0]);
set(handles.load_bare,'tooltipstring','Load bare crystal data');
set(handles.filename_txt,'userdata',0);
handles=cla_raw_Callback(hObject, 0, handles);
for dum=1:2:11
    name=['X',num2str(dum)];
    set(handles.(name),'userdata',[]);
end%for dum=1:2:11
guidata(hObject, handles);
set(handles.status,'string','Status: Data has been deleted from the GUI! A backup of the deleted data can be found in deleted_data.mat. Ready...',...
    'backgroundcolor','k','foregroundcolor','r');
disp('Data has been deleted from the GUI! A backup of the the deleted data can be found in the deleted data folder.');
output_path=handles.din.output_path;%preserve the last opened location
refit_path=handles.din.refit_path;
bare_path=handles.din.bare_path;
handles.din=handles.default_settings;%reset the handles.din state
handles.din.refit_path=refit_path;
handles.din.bare_path=bare_path;
handles.din.output_path=output_path;
handles.din.output_filename=[];
for dum=1:2:11
    name1=['harm',num2str(dum)];
    name2=['center',num2str(dum)];
    name3=['start_f',num2str(dum)];
    name4=['end_f',num2str(dum)];
    name5=['refreshing',num2str(dum)];
    name6=['X',num2str(dum)];
    name7=['peak_track',num2str(dum)];
    name8=['fit',num2str(dum)];
    name9=['num_pts',num2str(dum)];
    name10=['sa',num2str(0.5*(dum+1))];
    name11=['refit_finish',num2str(dum)];
    if dum==1
        set(handles.(name1),'value',1,'userdata',[0 0]);
    else
        set(handles.(name1),'value',0,'userdata',[0 0]);
    end%if dum==1
    set(handles.(name3),'string',num2str(handles.din.default_start_freq((dum+1)/2)),'userdata',1);
    set(handles.(name4),'string',num2str(handles.din.default_end_freq((dum+1)/2)));
    set(handles.(name5),'visible','off');
    set(handles.(name6),'visible','off','string','Xsq = ');
    set(handles.(name7),'string','Default Peak Tracking','userdata',[0 0]);
    set(handles.(name8),'string','Gmax','userdata',1);
    set(handles.(name9),'string',['# pts: ',num2str(handles.din.num_pts)]);
    set(handles.(name10),'visible','off','color','none');
    handles.din.(name11)=0;
end%for dum=1:2:11
set(handles.refresh_spectra,'string',1);
set(handles.fit_factor,'string',4);
set(handles.radio_chi,'value',0);
set(handles.show_susceptance,'value',0);
set(handles.polar_plot,'value',0);
set(handles.filename_txt,'string','<Output Filename>','tooltipstring','');
set(handles.axes7,'visible','off');
set(handles.peak_center,'visible','off');
set(handles.center1,'value',1);
set(handles.primaryaxes1,'fontsize',8,'xlimmode','auto','ylimmode','auto');
set(handles.primaryaxes2,'fontsize',8,'xlimmode','auto','ylimmode','auto');
set(handles.maintain_myVNA,'value',1);
set(handles.uipanel8,'visible','on');
set(handles.uipanel4,'visible','on');
set(handles.text2,'userdata',0);
set(handles.fit_factor,'string',handles.din.fit_factor_range);
set(gca,'fontsize',6);%set font size of the legend
set(handles.reference_time,'string',datestr(clock,'yy:mm:dd:HH:MM:SS:FFF'));
set(handles.uipanel8,'visible','on');
set(handles.uipanel4,'visible','on');
set(handles.text2,'userdata',0);
set(handles.peak_centering,'visible','on');
set(handles.clear_datapoints,'visible','on');
set(handles.start,'visible','on');
set(handles.load_settings,'userdata',[]);
set(handles.tot_datapts,'string','Datapts collected: ');
set(handles.last_time,'string','Last timepoint: ');
set(handles.harm1,'value',1);
set(handles.harm3,'value',1);
set(handles.harm5,'value',1);
set(handles.refit_start,'visible','off','string',1,'tooltipstring','Starting datapoint');
set(handles.refit_inc,'visible','off');
set(handles.refit_end,'visible','off','string',100,'tooltipstring','Ending datapoint');
write_settings(handles,handles.din.harmonic);%this function writes out the settings text file
plot_choice_Callback(handles.plot1_choice, eventdata, handles);%refresh primaryaxes1
plot_choice_Callback(handles.plot2_choice, eventdata, handles);%refresh primaryaxes2
cla(handles.wb);
set(handles.wb,'color','k','box','off','ytick',[]);
%if the peak_centering toggle button is turned on, turn it off
if get(handles.peak_centering,'value')==1
    peak_centering_Callback(hObject, 1, handles);
    set(handles.peak_centering,'value',0,'foregroundcolor','k','fontweight','normal');%toggle the peak centering button back to 0
end
function home_push_ClickedCallback(hObject, eventdata, handles)
handles=reset_fcn(hObject,eventdata,handles);
set(handles.status,'string','Status: GUI state resetted! Ready...','backgroundcolor','k','foregroundcolor','r');
guidata(hObject,handles);


%% Functions related to deleting datapoints
function del_mode_ClickedCallback(hObject, ~, handles)
if strcmp(get(hObject,'state'),'on')%Run this code if the delete points mode has been turned on
    set(handles.confirm_del,'visible','on','separator','on');%if delete points mode is turned on, turn the delete confirmation button to visible
    b=brush;%Allow the delete mode to act like a "brush", the same brush tool that is found in normal figure windows
    set(b,'enable','on','color',[.6 .2 .1]);%Define properties associated with the brush tool
    set(handles.status,'string',...
        ['Status: Currently in "Delete datapts" mode. Push the Delete button on the keyboard to temporarily remove datapoint(s).',...
        ' Note that replotting w/o confirming deletion will not not delete the points permanently!'],...
        'backgroundcolor','k','foregroundcolor','r')
    harm_tot=find_num_harms(handles);%determine the total number of harmonics
    for dum2=1:length(harm_tot)
        handles.din.harmonic=harm_tot(dum2);%define current active harmonic
        plot_primaryaxes(handles,handles.din.FG_frequency,harm_tot,handles.din.n,'a');%refresh/replot the primaryaxes1
        plot_primaryaxes(handles,handles.din.FG_frequency,harm_tot,handles.din.n,'b');%refresh/replot the primaryaxes2
    end
else%Rune this code is the delete points mode has been turned off
    set(handles.confirm_del,'visible','off','separator','off');
    set(handles.status,'string','Status: Ready...','backgroundcolor','k','foregroundcolor','r');
    brush off
    uiresume(gcf);
    harm_tot=find_num_harms(handles);%find the total number of harmonics
    handles=cla_raw_Callback(hObject,1,handles);%clear the axes
    for dum2=1:length(harm_tot)
        handles.din.harmonic=harm_tot(dum2);        
        plot_primaryaxes(handles,handles.din.FG_frequency,harm_tot,handles.din.n,'a');%refresh/replot the primaryaxes1
        plot_primaryaxes(handles,handles.din.FG_frequency,harm_tot,handles.din.n,'b');%refresh/replot the primaryaxes2
    end
end%if get(hObject,'value')==1
function confirm_del_ClickedCallback(hObject, ~, handles)
current_axes=[{'primaryaxes1'},{'primaryaxes2'}];
for dum0=1:2
    name0=['primaryaxes',num2str(dum0)];
    temp=get(handles.(current_axes{dum0}),'children');
    plotted_harms=[];
    for dum=1:length(temp)
        plotted_harms=[plotted_harms,get(temp(dum),'userdata')];
    end%for dum=1:length(temp)
    plotted_harms=sort(plotted_harms);
    for dum=1:length(temp)
        name=['harm',num2str(get(temp(dum),'userdata'))];
        ydata.(name)=get(temp(dum),'ydata');
        nan_location.(name0).(name)=find(isnan(ydata.(name)));
    end%for dum-1:length(temp)
    nan_location.(name0).harms=plotted_harms;
end%for dum0=1:2
if isempty(nan_location)==0%create a message prompting user to confirm deletion of points
    choice=questdlg('Are you sure you want to permanently delete the selected datapoint(s)?','Confirm deletion','Yes','No','Undo','Yes');
    switch choice
        case 'Yes'%delete the frequency shift values that was deleted by the use
            set(handles.confirm_del,'userdata',1);
            for dum3=1:2
                name0=['primaryaxes',num2str(dum3)];                
                harms=nan_location.(name0).harms;
                for dum4=1:length(harms)
                    name1=['harm',num2str(harms(dum4))];
                    indices=nan_location.(name0).(name1);
                    col=harms(dum4)+1;
                    handles.din.FG_frequency(indices,col:col+1)=nan(length(indices),2);
                    handles.din.FG_freq_shifts(indices,col:col+1)=nan(length(indices),2);
                    handles.din.chi_sqr_value(indices,col:col+1)=nan(length(indices),2);
                end%for dum4=1:length(harms)
            end%for dum3=1:2
            harm_tot=find_num_harms(handles);
            for dum2=1:length(harm_tot)
                handles.din.harmonic=harm_tot(dum2);
                plot_primaryaxes(handles,handles.din.FG_frequency,harm_tot,handles.din.n,'a');%refresh/replot the primaryaxes1
                plot_primaryaxes(handles,handles.din.FG_frequency,harm_tot,handles.din.n,'b');%refresh/replot the primaryaxes2
            end
        case 'No'
        case 'Undo'%replot the original datapoints
            harm_tot=find_num_harms(handles);
            for dum2=1:length(harm_tot)
                handles.din.harmonic=harm_tot(dum2);
                plot_primaryaxes(handles,handles.din.FG_frequency,harm_tot,handles.din.n,'a');
                plot_primaryaxes(handles,handles.din.FG_frequency,harm_tot,handles.din.n,'b');
            end
    end%switch choice
end%if isempty(nan_location)
%//////////////////////////////////////////////////////////////////////////
%Write out chi values, f0, and gamma0 into spectra file
fg_values=matfile([handles.din.output_path,handles.din.output_filename],'Writable',true);
spectra = matfile([handles.din.output_path,handles.din.output_filename,'_raw_spectras.mat'],'Writable',true);%open matfile and set access to writable
disp('Saving Data...');
set(handles.status,'string','Status: Saving data...','backgroundcolor','k','foregroundcolor','r');
drawnow;
reference=char(get(handles.reference_time,'string'),get(handles.wait_time,'string')...
    ,get(handles.num_datapoints,'string'),get(handles.record_time_increment,'string'));%records reference time 
fg_values.reference=reference;
if handles.din.refit_flag==0
    spectra.reference=reference;
end%if handles.din.refit_flag==0
fg_values.abs_freq=handles.din.FG_frequency;%save f0 and gamma0 fit data to fg_values.mat
fg_values.freq_shift=handles.din.FG_freq_shifts;
fg_values.freq_shift_ref=[handles.din.ref_freq;handles.din.ref_diss];
fg_values.chisq_values=handles.din.chi_sqr_value;
disp(['Data successfully saved to: ',handles.din.output_path,handles.din.output_filename]);
set(handles.status,'string','Status: Data saved! Ready...','backgroundcolor','k','foregroundcolor','r');
%//////////////////////////////////////////////////////////////////////////
set(handles.confirm_del,'userdata',0);
uiresume;
guidata(hObject,handles);


%% Debugging toolbar button
function debug_ClickedCallback(~, ~, handles)%for debugging purposes
assignin('base','handles',handles);
keyboard;


%% Help toolbar button
function uipushtool8_ClickedCallback(~, ~, ~)
try
    open('QCM MATLAB manual/QCM MATLAB manual v. 2.0e.pdf');
catch
    disp('QCM MATLAB manual not found!');
end


%% Preferences toolbar button and supporting functions
function pref_ClickedCallback(hObject, ~, handles)
%the purpose of this function is to provide a gui to set preferences for the program
pref=figure(998);clf(figure(998));%create the figure
%Create the relevant objects in the preferences
set(pref,'dockcontrols','off','name','Set Preferences','toolbar','none','menubar','none','numbertitle','off','color','w','position',[680 300 590 500]);
cwo_panel=uipanel('title','Command Window and Workspace options','foregroundcolor','b','fontweight','bold',...
    'position',[0 0.8 1 0.2]);
radio_GB_values=uicontrol('style','radio','value',handles.prefs.show_GB,'tooltipstring','Display the fitted parameters in the command window.',...
    'units','normalized','position',[0.03 0.75 0.5 0.2],'backgroundcolor',get(cwo_panel,'backgroundcolor'),...
    'string','Display fitted parameters in the command window','parent',cwo_panel);
radio_clc_cw=uicontrol('style','radio','value',handles.prefs.clc_cw,'tooltipstring','Clear the command window before start of data collection process.',...
    'string','Clear command window before data collection','parent',cwo_panel,'units','normalized','position',[0.03 0.5 0.5 0.2]);
radio_output_raw=uicontrol('style','radio','value',handles.prefs.output_raw,'tooltipstring','Output raw data onto the base workspace after each scan.',...
    'string','Output raw data onto workspace','parent',cwo_panel,'units','normalized','position',[0.03 0.25 0.5 0.2]);
radio_diary=uicontrol('style','radio','value',handles.prefs.output_diary,'tooltipstring','Save the command window lof into a text file',...
    'string','Save the Command Window into a text file','parent',cwo_panel,'units','normalized','position',[0.03 0 0.5 0.2]);
fit_option_panel=uipanel('title','Additional spectra fitting options','foregroundcolor','b','fontweight','bold',...
    'position',[0 0.6 1 0.2]);
save_spectra=uicontrol('style','radio','string','Save/read spectra using legacy format','units','normalized',...
    'parent',fit_option_panel,'position',[0.03 0.8 0.4 0.25],'value',handles.prefs.save_spectra,...
    'tooltipstring','Save/read the raw spectra using the legacy format (version 002d and below)');
fit_options_panel=uipanel('title','Fitting options','foregroundcolor','b','fontweight','bold','position',[0 0.4 1 0.2]);
show_dfdg=uicontrol('style','radio','units','normalized','parent',fit_options_panel,'position',[0.03 .75 .5 .2],...
    'string',['Show ',char(916),'f and ',char(916),char(915)],'tooltipstring','Show frequency and bandwith shifts','value',handles.prefs.show_dfdg,...
    'tooltipstring','Toggle display of del_f and del_g values');
schedule_panel=uipanel('title','Set Measurement Schedule','foregroundcolor','b','fontweight','bold','position',[0 0.045 1 0.4]);
radio_on_off_schedule=uicontrol('style','radio','value',handles.prefs.schedule_toggle,'tooltipstring','Turn on/off the measurement scheduler',...
    'string','Turn on Measurement Scheduler','parent',schedule_panel,'units','normalized','position',[0.03 0.75 0.5 0.2]);
set_pref=uicontrol('style','pushbutton','string','Set Preferences','backgroundcolor',[0.71 0.71 0.71],'units','normalized',...
    'position',[0.8 0.005 0.2 0.04],'fontweight','bold');
status=uicontrol('style','text','string','Status: ','fontweight','bold','fontsize',9,'units','normalized',...
    'position',[0.005 0.005 0.6 0.04],'horizontalalignment','left','backgroundcolor','w','foregroundcolor','b');
schedule_table=uitable(schedule_panel,...
    'data',handles.prefs.measurement_schedule,'units','normalized','position',[0.03 0.015 0.66 0.7],...
    'ColumnName',{'<HTML><b> yyyy-mm-dd HH:MM:SS </b></html>','<HTML><b> Recording increment time (s) </b></html>'},...
    'RowName',handles.prefs.measurement_schedule_rnames,'visible','off','columneditable',logical([1 1]));
add_row=uicontrol('style','pushbutton','string','Add event','parent',schedule_panel,'units','normalized','position',[0.35 0.88 0.15 0.12],...
    'fontweight','bold','foregroundcolor',[0 0.5 0],'visible','off','backgroundcolor',[.71 .71 .71],'tooltipstring','Add a new event.');
del_row=uicontrol('style','pushbutton','string','Delete event','parent',schedule_panel,'units','normalized','position',[0.35 0.75 0.15 0.12],...
    'fontweight','bold','foregroundcolor','r','visible','off','backgroundcolor',[.71 .71 .71],'tooltipstring','Delete the last event.');
reset_row=uicontrol('style','pushbutton','string','Reset schedule','parent',schedule_panel,'units','normalized','position',[0.51 0.75 0.18 .12],...
    'fontweight','bold','foregroundcolor','k','visible','off','backgroundcolor',[.71 .71 .71]);
set(set_pref,'callback',{@set_pref1,hObject,handles,set_pref,radio_GB_values,radio_clc_cw,radio_output_raw,...
    schedule_table,radio_on_off_schedule,show_dfdg,status,radio_diary,save_spectra});
%Define the Callback functions for the objects in the figure window
set(schedule_table,'celleditcallback',{@schedule_table_callback,handles,schedule_table});
set(radio_on_off_schedule,'callback',{@scheduler_onoff,hObject,handles,radio_on_off_schedule,schedule_table,add_row,del_row,reset_row,status,flag});
set(add_row,'callback',{@add_row_callback,handles,add_row,schedule_table});
set(del_row,'callback',{@del_row_callback,handles,del_row,schedule_table});
set(reset_row,'callback',{@reset_row_callback,handles,reset_row,schedule_table});
set(show_dfdg,'callback',{@show_dfdg_callback,handles,show_dfdg,status});
if get(handles.start,'value')==1%if the measurement is ongoing, prevent the user from editing the measurement schedule
    set(schedule_table,'columneditable',logical([0 0]));
end%if get(handles.start,'value')==1
handles.prefs.show_GB=get(radio_GB_values,'value');
scheduler_onoff(1,1,hObject,handles,radio_on_off_schedule,schedule_table,add_row,del_row,reset_row,status,1);
guidata(hObject,handles);
function show_dfdg_callback(~,~,handles,show_dfdg,status)
if get(show_dfdg,'value')==1%if this option is enabled
    set(handles.status,'string','Status: Enabling show_dfdg will disable the option to show Xsq values!',...
        'foregroundcolor','r','backgroundcolor','y');
    disp('Enabling show_dfdg will disable the option to show Xsq values!');
    set(status,'string','Enabling show_dfdg will disable the option to show Xsq values!');
else
    set(handles.status,'string','Status: Disabling show_dfdg will enable the option to show Xsq values!',...
        'foregroundcolor','r','backgroundcolor','y');
    disp('Disabling show_dfdg will enable the option to show Xsq values!');
    set(status,'string','Disabling show_dfdg will enable the option to show Xsq values!');
end%if get(show_dfdg,'value')==1
function schedule_table_callback(~,callbackdata,handles,schedule_table)
schedule=get(schedule_table,'data');
try
    if callbackdata.Indices(2)==1
        datevec(callbackdata.EditData);%check to see if the user has inputted the time correctly into the schedule
        schedule{callbackdata.Indices(1),callbackdata.Indices(2)}=datestr(callbackdata.EditData,'yyyy-mm-dd HH:MM:SS');
    elseif callbackdata.Indices(2)==2  %check to see if the user has inputted the time b/w measurements correctly into the schedule
        if isnan(str2double(callbackdata.EditData))==1
            disp('ERROR! Please check that date is inputted properly.');
        else
            schedule(callbackdata.Indices(1),callbackdata.Indices(2))={str2double(callbackdata.EditData)};                  
        end%if isnan(str2double(callbackdata.EditData))==1
    end%if callbackdata.Indices(2)==1
    %if everything has been inputted correctly, check to make sure the
    %events are ordered in chronological order.
    schedule2=schedule;
    schedule2(callbackdata.Indices(1),callbackdata.Indices(2))={'Sorting...'};
    set(schedule_table,'data',schedule2,'columneditable',logical([0 0]));
    pause(1);
    timeline=schedule(:,1);%extract out all of the times
    timeline2=ones(size(timeline));
    for dum=1:size(timeline,1)
        timeline2(dum)=etime(datevec(timeline{dum}),clock);
    end%for dum=1:size(timeline,1)
    [~,I]=sort(timeline2,'ascend');%sort the times in ascending roder
    schedule=schedule(I,:);%rearrange the schedule in chronological order
    set(schedule_table,'data',schedule,'columneditable',logical([1 1]));
catch
    schedule(callbackdata.Indices(1),callbackdata.Indices(2))={'Invalid! Boo you suck :P'};
    set(schedule_table,'data',schedule,'columneditable',logical([0 0]));
    pause(1);
    schedule(callbackdata.Indices(1),callbackdata.Indices(2))={callbackdata.PreviousData};
    set(schedule_table,'data',schedule,'columneditable',logical([1 1]));
end
function reset_row_callback(~,~,handles,reset_row,schedule_table)
%determine the current time in this format: 'yyyy-mm-dd HH:MM:SS'
current_time=datevec(now);%determine the current time
current_time2=[num2str(current_time(1)),'-',num2str(current_time(2)),'-',...
    num2str(current_time(3)),' ',num2str(current_time(4)),':',num2str(current_time(5)),':',num2str(current_time(6),2)];
end_time=datevec(now+1);%determine time 24 hours from now, this will be the default end time
current_time3=[num2str(end_time(1)),'-',num2str(end_time(2)),'-',num2str(end_time(3)),...
    ' ',num2str(end_time(4)),':',num2str(end_time(5)),':',num2str(end_time(6),2)];
schedule={current_time2,get(handles.record_time_increment,'string');current_time3,get(handles.record_time_increment,'string')};        
set(schedule_table,'data',schedule,'rowname',{'Start','End'});
function del_row_callback(~,~,handles,del_row,schedule_table)
schedule=get(schedule_table,'data');%get the data from the table
num_rows=size(schedule,1);%get the number of rows in the table
rnames=get(schedule_table,'rowname');%get the rownames from the table
if num_rows>2
    schedule=[schedule(1:end-2,:);schedule(end,:)];%take out the last event
    rnames=[rnames(1:end-2,:);rnames(end,:)];%take out the last event
    set(schedule_table,'data',schedule,'rowname',rnames);%update the schedule table with the new changes
end%if num_rows>2
function add_row_callback(~,~,handles,add_row,schedule_table)
schedule=get(schedule_table,'data');%get the data from the table
num_rows=size(schedule,1);%get the number of rows in the table
if num_rows==2%if the table only contains a start and end row
    new_schedule=[schedule(1,:);schedule(1,:);schedule(2,:)];%create a new schedule
    rnames={'Start','Event 1','End'};
else%if the table already contains more than 2 rows
    new_schedule=[schedule(1:end-1,:);schedule(end-1,:);schedule(end,:)];
    rnames=get(schedule_table,'rowname');
    rnames=[rnames(1:end-1);['Event ',num2str(num_rows-1)];rnames(end)];
end%if num_row==2
set(schedule_table,'data',new_schedule,'rowname',rnames);%update the schedule table
function scheduler_onoff(~,~,hObject,handles,radio_on_off_schedule,schedule_table,add_row,del_row,reset_row,status,flag)
if size(flag,1)~=1%this flag variable determines when it is necessary to display the state of the scheduler
    flag=1;
end%if flag~=1||flag~=0
if get(radio_on_off_schedule,'value')==1&&flag==1
    if isempty(handles.prefs.measurement_schedule)==1%run this code if the measurement schedule is empty
        %determine the current time in this format: 'yyyy-mm-dd HH:MM:SS'
        current_time=datevec(now);%determine the current time
        current_time2=[num2str(current_time(1)),'-',num2str(current_time(2)),'-',...
            num2str(current_time(3)),' ',num2str(current_time(4)),':',num2str(current_time(5)),':',num2str(current_time(6),2)];
        end_time=datevec(now+1);%determine time 24 hours from now, this will be the default end time
        current_time3=[num2str(end_time(1)),'-',num2str(end_time(2)),'-',num2str(end_time(3)),...
            ' ',num2str(end_time(4)),':',num2str(end_time(5)),':',num2str(end_time(6),2)];
        schedule={current_time2,get(handles.record_time_increment,'string');current_time3,get(handles.record_time_increment,'string')};        
        set(schedule_table,'data',schedule);
    end%if isempty(handles.din.measurement_schedule)==1
    set(schedule_table,'visible','on');
    set(add_row,'visible','on');
    set(del_row,'visible','on');
    set(reset_row,'visible','on');
    set(handles.status,'string','Status: Measurement Scheduler is enabled!','foregroundcolor','r','backgroundcolor','k');
    set(status,'string','Status: Measurement Scheduler is enabled!');
    disp('Measurement Scheduler is enabled!');
elseif get(radio_on_off_schedule,'value')==0&&flag==1%if the radio dial is off, hide the table and buttons in the panel
    set(schedule_table,'visible','off');
    set(add_row,'visible','off');
    set(del_row,'visible','off');
    set(reset_row,'visible','off');
    set(handles.status,'string','Status: Measurement Scheduler is disabled!','foregroundcolor','r','backgroundcolor','k');
    set(status,'string','Status: Measurement Scheduler is disabled!');
    disp('Measurement Scheduler has been disabled!');
end%if get(hObject,'value')==1
function set_pref1(~,~,hObject,handles,set_pref,radio_GB_values,radio_clc_cw,...
    radio_output_raw,schedule_table,radio_on_off_schedule,...
    show_dfdg,status,radio_diary,save_spectra)
%this sets the user preferences for the entire GUI (work in progress...)
handles.prefs.show_GB=get(radio_GB_values,'value');
handles.prefs.clc_cw=get(radio_clc_cw,'value');
handles.prefs.output_raw=get(radio_output_raw,'value');
handles.prefs.measurement_schedule=get(schedule_table,'data');
handles.prefs.schedule_toggle=get(radio_on_off_schedule,'value');
handles.prefs.measurement_schedule_rnames=get(schedule_table,'rowname');
handles.prefs.schedule_state=zeros(size(get(schedule_table,'data'),1),1);
handles.prefs.show_dfdg=get(show_dfdg,'value');
handles.prefs.output_diary=get(radio_diary,'value');
handles.prefs.save_spectra=save_spectra.Value;
if handles.prefs.show_dfdg==1%determine whether or not to enable/diable th radio_chi option
    set(handles.radio_chi,'value',0,'visible','off');
else
    set(handles.radio_chi,'value',1,'visible','on');    
end%if handles.prefs.show_dfdg==1
set(handles.status,'string','Status: Preferences set!','backgroundcolor','k','foregroundcolor','r');%update the status bar
disp('Preferences updated!');%show in the command window that the preferences have been successfully saved
set(status,'string','Status: Preferences updated!');
guidata(hObject,handles);%save/update the handles structure


%% Load bare crystal data toolbar button
function load_bare_ClickedCallback(hObject, ~, handles)
disp('Importing bare .mat file');
set(handles.status,'string','Status: Importing bare crystal .mat file',...
    'foregroundcolor','r','backgroundcolor','k');
[filename,pathfile,~]=uigetfile('.mat', 'Load bare crystal datafile',handles.din.bare_path);%prompt user to choose the bare crystal file
set(handles.status,'string','Status: Importing .mat file...');
drawnow;
if isempty(filename)%run this code if the user cancels out of loading the bare crystal file
    set(handles.status,'string','Status: Unable to load bare crystal datafile',...
        'foregroundcolor','k','backgroundcolor','r');
    return
end%if isempty(filename)
try
    load([pathfile,filename]);%load the datafile
    for dum1=2:size(abs_freq,2)%find the number of columns in the abs_freq variable loaded from the bare crystal file and calculate the average
        temp=abs_freq(:,dum1);%extract out the designated column
        if mod(dum1,2)==0&&isnan(nanmean(temp))==0%if the column is associated with delta f
            handles.din.ref_freq(dum1/2)=nanmean(temp);%calculate the average and redefine the reference harmonic frequencies
        elseif mod(dum1,2)==1&&isnan(nanmean(temp))==0%if the column is associated with delta gamma
            handles.din.ref_diss((dum1-1)/2)=nanmean(temp);%calculate the average and redefine the reference harmonic dissipations
        end%if mod(dum1,2)==0&&isnan(mean(temp))==0%if the column is associated with delta f
    end%for dum1=2:size(abs_freq,2)
    disp('Reference frequency and dissipation values have been redefined.');
    disp(['ref_freq: ',num2str(handles.din.ref_freq)]);
    disp(['ref_diss: ',num2str(handles.din.ref_diss)]);
    %redefine the frequency shifts relative to the loaded bare crystal reference values
    handles.din.FG_freq_shifts=[handles.din.FG_frequency(:,1),...
        handles.din.FG_frequency(:,2)-handles.din.ref_freq(1),handles.din.FG_frequency(:,3)-handles.din.ref_diss(:,1),...
        handles.din.FG_frequency(:,4)-handles.din.ref_freq(2),handles.din.FG_frequency(:,5)-handles.din.ref_diss(:,2),...
        handles.din.FG_frequency(:,6)-handles.din.ref_freq(3),handles.din.FG_frequency(:,7)-handles.din.ref_diss(:,3),...
        handles.din.FG_frequency(:,8)-handles.din.ref_freq(4),handles.din.FG_frequency(:,9)-handles.din.ref_diss(:,4),...
        handles.din.FG_frequency(:,10)-handles.din.ref_freq(5),handles.din.FG_frequency(:,11)-handles.din.ref_diss(:,5),...
        handles.din.FG_frequency(:,12)-handles.din.ref_freq(6),handles.din.FG_frequency(:,13)-handles.din.ref_diss(:,6)];
    set(handles.status,'string',['Status: Bare crystal file, ',filename,', successfully loaded!'],...
        'foregroundcolor','r','backgroundcolor','k');
    disp(['Status: Bare crystal file, ',filename,', successfully loaded!']);
    handles.din.bare_flag=1;%turn on the flag, showing that a bare crystal was loaded
    handles.din.bare_path=pathfile;
    set(hObject,'tooltipstring',['<html>Bare crystal loaded on ',datestr(clock),'<br />Filename: ',filename,'<br />Filepath: ',pathfile,'</html>']);
    plot_primaryaxes(handles,handles.din.FG_frequency,find_num_harms(handles),handles.din.n,'a');
    plot_primaryaxes(handles,handles.din.FG_frequency,find_num_harms(handles),handles.din.n,'b');
    save_shifts_ClickedCallback(handles.save_shifts,1,handles);%autpmatically save the data after loading the bare crystal data
    guidata(hObject, handles);
catch err_message
    assignin('base','err_message',err_message);
    set(handles.status,'string','Status: Error in loading bare crystal file!',...
        'foregroundcolor','k','backgroundcolor','r');
    disp('Error in loading bare crystal file!');
    return
end%try

%% Refit raw spectra toolbar button
function refit_ClickedCallback(hObject, eventdata, handles)
%this function allows the use to take take data and have it be "refitted"
bare_flag=handles.din.bare_flag;
ref_freq=handles.din.ref_freq;
ref_diss=handles.din.ref_diss;
tooltip=get(handles.load_bare,'tooltipstring');%get the tooltip string from the load bare icon
handles=reset_fcn(hObject,eventdata,handles);%reset the handles structure of the GUI
handles.din.ref_freq=ref_freq;
handles.din.ref_diss=ref_diss;
handles.din.bare_flag=bare_flag;
set(handles.load_bare,'tooltipstring',tooltip);%since the handles structure was resetted, restore the original tooltip string
[filenamer,pathfiler,~]=uigetfile('*_raw_spectras.mat', 'Load raw spectra datafile',handles.din.refit_path);%prompt the user to load a .m file containing the raw spectra data
if isempty(filenamer)%check to see if the user push the cancel button, if so, cancel
    return
end%if isempty(filename)
set(handles.status,'string','Status: Importing raw spectra .m data...',...
    'foregroundcolor','r','backgroundcolor','k');
drawnow;
if isempty(filenamer)||isnumeric(filenamer)%if no file was chosen, show error and return
    set(handles.status,'string','Status: Unable to load raw spectra datafile!',...
        'foregroundcolor','k','backgroundcolor','r');
    disp('Unable to load raw spectra datafile!');
    return
end
if handles.din.bare_flag==1%check to see whether or not a bare crystal was already loaded
    %if the bare crystal data has been loaded, confirm with the user that
    %the loaded bare crystal file is the "right" bare crystal file
    choice=questdlg('Bare crystal reference data detected. Do you want to use reference values defined by the loaded bare crystal data? ',...
        'Bare crystal reference data detected!',...
        'Yes',sprintf('No, use default'),sprintf('No, upload another'),'Yes');
    switch choice
        case 'Yes'
        case 'No, use default reference values'
            handles.din.ref_freq=handles.default_settings.ref_freq;
            handles.din.ref_diss=handles.default_settings.ref_diss;
        case 'No, let me upload another bare crystal datafile'
            disp('Importing bare .mat file');
            set(handles.status,'string','Status: Importing bare crystal .mat file',...
                'foregroundcolor','r','backgroundcolor','k');
            [filename,pathfile,~]=uigetfile('.mat', 'Load bare crystal datafile',handles.din.bare_path);%prompt user to choose the bare crystal file
            set(handles.status,'string','Status: Importing .mat file...');
            drawnow;
            if isempty(filename)%run this code if the user cancels out of loading the bare crystal file
                set(handles.status,'string','Status: Unable to load bare crystal datafile',...
                    'foregroundcolor','k','backgroundcolor','r');
                return
            end%if isempty(filename)
            load([pathfile,filename]);%load the datafile
            try
                for dum1=2:size(abs_freq,2)%find the number of columns in the abs_freq variable loaded from the bare crystal file and calculate the average
                    temp=abs_freq(:,dum1);%extract out the designated column
                    if mod(dum1,2)==0%if the column is associated with delta f
                        handles.din.ref_freq(dum1/2)=nanmean(temp);%calculate the average and redefine the reference harmonic frequencies
                    elseif mod(dum1,2)==1%if the column is associated with delta gamma
                        handles.din.ref_diss((dum1-1)/2)=nanmean(temp);%calculate the average and redefine the reference harmonic dissipations
                    end
                end%for dum1=2:size(abs_freq,2)
                disp('Reference frequency and dissipation values have been redefined.');
                disp(['ref_freq: ',num2str(handles.din.ref_freq)]);
                disp(['ref_diss: ',num2str(handles.din.ref_diss)]);
                %redefine the frequency shifts relative to the loaded bare crystal reference values
                handles.din.FG_freq_shifts=[handles.din.FG_frequency(:,1),...
                    handles.din.FG_frequency(:,2)-handles.din.ref_freq(1),handles.din.FG_frequency(:,3)-handles.din.ref_diss(:,1),...
                    handles.din.FG_frequency(:,4)-handles.din.ref_freq(2),handles.din.FG_frequency(:,5)-handles.din.ref_diss(:,2),...
                    handles.din.FG_frequency(:,6)-handles.din.ref_freq(3),handles.din.FG_frequency(:,7)-handles.din.ref_diss(:,3),...
                    handles.din.FG_frequency(:,8)-handles.din.ref_freq(4),handles.din.FG_frequency(:,9)-handles.din.ref_diss(:,4),...
                    handles.din.FG_frequency(:,10)-handles.din.ref_freq(5),handles.din.FG_frequency(:,11)-handles.din.ref_diss(:,5),...
                    handles.din.FG_frequency(:,12)-handles.din.ref_freq(6),handles.din.FG_frequency(:,13)-handles.din.ref_diss(:,6)];
                set(handles.status,'string',['Status: Bare crystal file, ',filename,', successfully loaded!'],...
                    'foregroundcolor','r','backgroundcolor','k');
                disp(['Status: Bare crystal file, ',filename,', successfully loaded!']);
                handles.din.bare_flag=1;%turn on the flag, showing that a bare crystal was loaded
                set(handles.load_bare,'tooltipstring',['<html>Bare crystal loaded on ',datestr(clock),'<br />Filename: ',filename,'<br />Filepath: ',pathfile,'</html>']);
                guidata(hObject, handles);
            catch err_message
                assignin('base','err_message',err_message);
                set(handles.status,'string','Status: Error in loading bare crystal file!',...
                    'foregroundcolor','k','backgroundcolor','r');
                disp('Error in loading bare crystal file!');
                return
            end%try
    end%switch choice
end%if handles.din.bare_flag==1
try
    hwait=waitbar(0,'Please wait... (This can take awhile)');
    loaded_var=load([pathfiler,filenamer]);%load the raw spectra data    
    set(handles.reference_time,'string',loaded_var.reference(1,:));%extract out the reference time
    loaded_var=rmfield(loaded_var,'reference');%remove the reference fieldname from the structure variable
    try loaded_var=rmfield(loaded_var,'dum'); catch;end;%remove any miscellaneous variables
    handles.din.refit.version=loaded_var.version;%version in which the raw spectra was saved in
    flag=check_version(handles.din.refit.version);
    try loaded_var=rmfield(loaded_var,'version');catch;end;%remove any miscellaneous variables
    handles.din.refit_raw=loaded_var;
    handles.din.refit.loaded_var=fieldnames(loaded_var);%extract all of the variable fieldnames
        
    if flag==1
        handles.din.refit_timepoints=[];
        for dum=1:size(handles.din.refit.loaded_var,1)
            if strcmp(handles.din.refit.loaded_var{dum}(1:11),'raw_spectra')==1&&...
                length(handles.din.refit.loaded_var{dum})<15
                handles.din.refit_timepoints=...
                    [handles.din.refit_timepoints;cell2mat(loaded_var.(handles.din.refit.loaded_var{dum})(:,1))];            
            end
        end
        handles.din.refit_timepoints=sort(unique(handles.din.refit_timepoints));        
    elseif flag==0
        %create counter for each harmonic
        c.h1=1;c.h3=1;c.h5=1;c.h7=1;c.h9=1;c.h11=1;    
        test0=handles.din.refit.loaded_var{1};
        %determine where in the variable name contains the information on the
        %associated timepoint in which the data was collected
        for dum=1:size(test0,2)-3
            test1=test0(dum:1:dum+2);
            if strcmp(test1,'_t_')
                handles.din.refit_time_index=dum+3;
            end
        end
        %sort the data from start to finish based on time
        timepoints=strrep(handles.din.refit.loaded_var,'dot','.');
        for dum=1:size(timepoints,1)
            try waitbar((dum)/(length(handles.din.refit.loaded_var)*2),hwait); catch end;%try
            edit1=timepoints{dum};  edit1=edit1(handles.din.refit_time_index:end-10);
            timepoints{dum}=str2double(edit1);
        end    
        [~,I]=sort(cell2mat(timepoints),1);
        handles.din.refit.loaded_var=handles.din.refit.loaded_var(I);
        for dum=1:length(handles.din.refit.loaded_var)%categorize filednames according to the harmonic number
            try waitbar((dum+length(handles.din.refit.loaded_var))/(length(handles.din.refit.loaded_var)*2),hwait); catch; end;%try
            harm=str2double(handles.din.refit.loaded_var{dum}(end))*2-1;%determine the harmonic associated with the variable
            if isnan(harm)==0
                handles.din.refit.(['h',num2str(harm)]){c.(['h',num2str(harm)]),1}=handles.din.refit.loaded_var{dum};%store the variable name in the apropriate fieldname associated with the harmonic number
                %determine the associated timepoint and store is as a double
                test0=handles.din.refit.loaded_var{dum};
                for dum=1:size(test0,2)-3
                    test1=test0(dum:1:dum+2);
                    if strcmp(test1,'_t_')
                        index=dum+3;
                    end
                end
                tp=strrep(test0,'dot','.'); tp=tp(index:end-10); tp=str2double(tp);
                handles.din.refit.(['h',num2str(harm)]){c.(['h',num2str(harm)]),2}=tp;
                c.(['h',num2str(harm)])=c.(['h',num2str(harm)])+1;%update counter
            end%if isnan(harm)==0
        end%for dum=1:length(handles.din.refit_loaded_var)    
        handles.din.refit_timepoints=unique(cell2mat(timepoints));
    end
    try delete(hwait); catch; end;%try
    handles.din.refit_flag=1;%turn on the flag indicating that raw spectra data has been loaded
    set(handles.start,'string','Refit data','foregroundcolor','w','backgroundcolor',[0 0.5 0]);
    set(handles.status,'string','Status: Raw spectra data loaded successfully!','foregroundcolor','r','backgroundcolor','k');
    set(handles.refit,'tooltipstring',['<html>Refit pre-existing raw spectras<br />Filename: ',filenamer,'<br />Pathfile: ',pathfiler,'</html>']);
    disp('Raw spectra data loaded successfully!');
    handles.din.refit_filename=filenamer;
    handles.din.refit_path=pathfiler;    
    %turn on the range and incremental datapoints edit boxes
    set(handles.refit_start,'visible','on','string',1,...
        'tooltipstring',['Starting datapoint: ',num2str(handles.din.refit_timepoints(1),4),' min']);
    set(handles.refit_inc,'visible','on');
    set(handles.refit_end,'visible','on','string',length(handles.din.refit_timepoints),...
        'tooltipstring',['Ending datapoint: ',num2str(handles.din.refit_timepoints(end),4),' min']);
    guidata(hObject,handles);
catch err_message
    assignin('base','err_message',err_message);
    disp('Error in loading raw spectra datafile!');
    set(handles.status,'string','Status: Error in loading raw spectra datafile!',...
        'foregroundcolor','k','backgroundcolor','r');
end%try

%% Save the frequency and dissiaption shifts toolbar button
function save_shifts_ClickedCallback(~, ~, handles)
%This function saves the frequency shifts to the designated file
try
    if get(handles.filename_txt,'userdata')==0%if no filename was designated, save to default file
        fg_values=matfile('fg_values.mat','Writable',true);%create matfile object
    else
        fg_values=matfile([handles.din.output_path,handles.din.output_filename],'Writable',true);%create matfile object
    end%if get(handles.filename_txt,'userdata')==0
    %Write out chi values, f0, and gamma0 into spectra file
    disp('Saving Data...');
    set(handles.status,'string','Status: Saving data...','backgroundcolor','k','foregroundcolor','r');
    drawnow;
    reference=char(get(handles.reference_time,'string'),get(handles.wait_time,'string')...
        ,get(handles.num_datapoints,'string'),get(handles.record_time_increment,'string'));%records reference time 
    fg_values.reference=reference;
    if get(handles.dynamic_fit,'value')==1%check to see if the dynamic fit option is turned on
        fg_values.abs_freq=handles.din.FG_frequency;%save f0 and gamma0 fit data to fg_values.mat
        fg_values.freq_shift=handles.din.FG_freq_shifts;%save relative freq shifts
        fg_values.freq_shift_ref=[handles.din.ref_freq;handles.din.ref_diss];%save the reference freq values used to calc. relative freq shfits
        fg_values.chisq_values=handles.din.chi_sqr_value;%save the chisq values
        disp('Data saved!');
        set(handles.status,'string','Status: Data saved! Ready...','backgroundcolor','k','foregroundcolor','r');
    else
        set(handles.status,'string','Status: No data to save! Make sure the dynamic fit radio is turned on! Ready...','backgroundcolor','y','foregroundcolor','r');
    end%if get(handles.dynamic_fit,'value')==1
    if get(handles.filename_txt,'userdata')==0%if there is no filename that was designated, save to default location
        disp(['Data successfully saved to: fg_values.mat']);
    else
        disp(['Data successfully saved to: ',handles.din.output_path,handles.din.output_filename,'.mat']);
    end%if get(handles.filename_txt,'userdata')==0
    set(handles.status,'string','Status: Data successfully saved!','backgroundcolor','k','foregroundcolor','r');
catch err_msg
    assignin('base','err_msg',err_msg);
    disp('Error in saving frequency and dissipation shifts!');
    set(handles.status,'string','Status: ERROR in saving frequency and dissipation shifts!',...
        'backgroundcolor','r','foregroundcolor','k');
end%try

%% Run AccessMyVNA.exe toolbar button
function exe_vna_ClickedCallback(hObject, ~, handles)
%internally execute the AccessMyVNA program
%This is a toglle button callback
if strcmp(get(hObject,'state'),'on')==1
    try %This try block attempts to kill the AccessMyVNA program through the Windows Command program, this will prevent multiple instances of the same program
        [~,~]=system('taskkill /im "AccessMyVNA.exe" /T /F');
        [~,~]=system('taskkill /im "MyVNA.exe"');
    catch
        disp('Error in running commands in Windows Command line');
    end%try
    open(handles.din.AVNA);
else
    try %This try block attempts to kill the AccessMyVNA program through the Windows Command program, this will prevent multiple instances of the same program
        [~,~]=system('taskkill /im "AccessMyVNA.exe" /T /F');
        [~,~]=system('taskkill /im "MyVNA.exe"');
    catch
        disp('Error in running commands in Windows Command line');
    end%try
end%if get(hObject,'value')==1

%% Zoom in/out toolbar button
function zoom_out_ClickedCallback(hObject, eventdata, handles)
if strcmp(hObject.State,'on')
    z=zoom(handles.primary1);
    set(z,'Direction','out','Enable','on','ActionPostCallback',{@update_tick_display,handles});        
else
    z=zoom(handles.primary1);
    set(z,'Enable','off');
end
function zoom_in_ClickedCallback(hObject, eventdata, handles)
if strcmp(hObject.State,'on')
    my_zoom=zoom(handles.primary1);
    set(my_zoom,'Direction','in','Enable','on' ,'ActionPostCallback',{@update_tick_display,handles});        
else    
    z=zoom(handles.primary1);
    z.Enable='off';
end

%% Raw spectra of selected datapoints toolbar button
function select_spectra_ClickedCallback(hObject, eventdata, handles)
if strcmp(hObject.State,'on')==1
    dcm_obj=datacursormode(handles.primary1);
    dcm_obj.Enable='on';
    delete(findall([handles.primaryaxes1 handles.primaryaxes2],'Type','hggroup'));
    set(dcm_obj,'UpdateFcn',@select_spectra_fcn);
else
    dcm_obj=datacursormode(handles.primary1);
    dcm_obj.Enable='off';
    delete(findall([handles.primaryaxes1 handles.primaryaxes2],'Type','hggroup'));
    set(dcm_obj,'UpdateFcn',@default_dcm);
    delete(findall(0,'type','figure','tag',['refit']));
    delete(figure(999));
    delete(figure(998));
end

%% Data cursor mode toolbar button
function output_txt=default_dcm(hObject,event_obj)
pos = get(event_obj,'Position');
line_h=event_obj.Target;%line handle associeated with the selected datapoint
harm=line_h.UserData;%harmonic of the line handle associated with the selected datapoint
timepoint=pos(1);%timepoint associated with the datapoint
handles=guidata(findall(0,'tag','primary1','type','figure'));
handles.din.dcm_obj_pos=pos;
handles.din.dcm_obj_target=event_obj.Target;%store the line handle associated with the seleected datapoint
index=find(handles.din.FG_frequency(:,1)==timepoint);
hObject.TipHandle.Interpreter='tex';%Set the interperter to tex so that greek symbols show up properly
%output text that shows up with the data cursor
output_txt={['Time (min): ',num2str(pos(1))];...
        [get(get(line_h.Parent,'YLabel'),'string'),': ',num2str(pos(2))];...
        ['Harmonic: ',num2str(harm)];...
        ['Index: ',num2str(index)]};


%% Function related to refitting raw spectras
function refit_start_Callback(hObject, ~, handles)
if str2double(get(hObject,'string'))<1||str2double(get(hObject,'string'))>str2double(get(handles.refit_end,'string'))
    set(hObject,'string',1);
end%if str2double(get(hObject,'string'))<1||str2double(get(hObject,'string'))>str2double(get(handles.refit_end,'string'))
handles.din.refit.counter=str2double(get(handles.refit_start,'string'));
disp(['Reftting process will begin at datapoint: ',num2str(handles.din.refit.counter)]);
%reset the finish counter for each harmonic
for dum=1:11
    name=['refit_finish',num2str(dum)];
    handles.din.(name)=0;
end%for dum=1:11
set(handles.refit_start,'tooltipstring',['Starting datapoint: ',num2str(handles.din.refit_timepoints(handles.din.refit.counter),4),' min']);
guidata(handles.start,handles);
function refit_inc_Callback(~, ~, handles)
function refit_end_Callback(hObject, ~, handles)
if str2double(get(hObject,'string'))>length(handles.din.refit_timepoints)||str2double(get(hObject,'string'))<str2double(get(handles.refit_start,'string'))
    set(hObject,'string',length(handles.din.refit_timepoints));
end%if str2double(get(hObject,'string'))>length(handles.din.refit_timepoints)
try
    set(handles.refit_end,'tooltipstring',['Ending datapoint: ',num2str(handles.din.refit_timepoints(str2double(get(hObject,'string'))),4),' min']);
catch
end

%% Misc. functions
%This function checks to see if the maximum number of peaks to fit is from
%1 to 3.
function harm_tot=find_num_harms(handles)
%This function finds the total number of harmonics the user has set to
%measure and record.
harm_tot=[];
for dum=1:1:6
    harmname=['harm',num2str(handles.din.avail_harms(dum))];
    if get(handles.(harmname),'value')==1
        harm_tot=[harm_tot;handles.din.avail_harms(dum)];
    end%if get(handles.(harmname),'value')==1
end%for dum=1:1:6
function num_peaks_check(~,~,num_peaks_edit)
value=str2double(get(num_peaks_edit,'string'));
if mod(value,1)~=0 || value>3 || value<1
    set(num_peaks_edit,'string',2);
end%if mod(value,1)~=0 || value>3 || value<1
function flag=check_version(version)
%This function checks the version of the loaded raw spectra
flag=1;
disp('Checking raw spectra version...');
switch version
    case 'QCM Version 1.0b, Shull Research Group'
        flag=0;
    case 'QCM Version 1.0c, Shull Research Group'
        flag=0;
    case 'QCM Version 2.0a, Shull Research Group'
        flag=0;
    case 'QCM Version 2.0b_Bigfoot, Shull Research Group'
        flag=0;
    case 'QCM Version 2.0c_Cthulhu, Shull Research Group'
        flag=0;
    case 'QCM Version 2.0d_Drakon, Shull Research Group'
        flag=0;
    case 'QCM Version 2.0d_Eurynomos, Shull Research Group'
        flag=0;
end
if flag==0
    disp('Legacy format detected for the raw spectra file!')
end
function my_disp(msg,color)
%This function was created to help simplify the code. Specifically it deals
%with how things are outputted into the command window. This code relies on
%undocumented MATLAB code. Thus, it is placed in a try block.
%msg: message to output into command window
%color of the output text
try
    cprintf(color,msg);
catch
    disp(msg);
end%try
function update_tick_display(~,~,handles)
%This function determines the y-tik values of primaryaxes1 and primaryaxes2
%and displays it on the GUI (in order to aid interpreting plots)
yt1=get(handles.primaryaxes1,'ytick');
yt2=get(handles.primaryaxes2,'ytick');
choice1=get(handles.plot1_choice,'value');
choice2=get(handles.plot2_choice,'value');
if choice1==1
    units1=[];
elseif choice1==5
    units='deg.';
elseif choice1==6
    units1=['Pa',char(183),'g/cc'];
elseif choice1==7
    units='g/m^2';
else
    units1='Hz';
end
if choice2==1
    units2=[];
elseif choice2==5
    units2='deg.';
elseif choice2==6
    units2=['Pa',char(183),'g/cc'];
else
    units2='Hz';
end
handles.ytick1.String=[num2str(abs(yt1(1)-yt1(2))),' ',units1];
handles.ytick1.TooltipString=['<html>Y-tick interval<br/>',[num2str(abs(yt1(1)-yt1(2))),' ',units1],'<html/>'];
handles.ytick2.String=[num2str(abs(yt2(1)-yt2(2))),' ',units2];
handles.ytick2.TooltipString=['<html>Y-tick interval<br/>',[num2str(abs(yt2(1)-yt2(2))),' ',units2],'<html/>'];
function refreshing(handles,harm,flag)
refresh_name=['refreshing',num2str(harm)];

if flag==1
    set(handles.(refresh_name),'visible','on');
else
    set(handles.(refresh_name),'visible','off');
end %if flag==1
function save_shifts(handles,fg_values)
fg_values.abs_freq=handles.din.FG_frequency;%save f0 and gamma0 fit data to fg_values.mat
fg_values.freq_shift=handles.din.FG_freq_shifts;
fg_values.freq_shift_ref=[handles.din.ref_freq;handles.din.ref_diss];
fg_values.chisq_values=handles.din.chi_sqr_value;
fg_values.std_fit=handles.din.std_fit;
function pause_func(~,~,handles)
%Keep this function!
set(handles.start,'value',0);
start_Callback(handles.start, 1, handles);
function maintain_myVNA_Callback(~, ~, handles)
% --- Executes on button press in maintain_myVNA.
% This radial dial is hidden from the user
harm_tot=find_num_harms(handles);%find the total numbe of harmonics
for dum=1:length(harm_tot)
    write_settings(handles,harm_tot(dum));%update the settings text file associated with each harmonic defined by the dum variable
end%for dum=1:length(harm_tot)
set(handles.status,'string','Status: Settings.txt file succesfully refreshed! Ready...','backgroundcolor','k','foregroundcolor','r');
disp('Settings.txt file sucessfully refreshed! Ready...');

function primary1_CloseRequestFcn(hObject, ~, handles)
% --- Executes when user attempts to close primary1.
%This try block attempts to kill the AccessMyVNA program through the Windows Command program, 
%this will prevent multiple instances of the same program

%This adds an extra layer of redundancy
try %try to run code in Windows cmd (force quitting exe files)
    [~,~]=system('taskkill /im "AccessMyVNA.exe" /T /F');
    [~,~]=system('taskkill /im "MyVNA.exe"');
catch
    disp('Error in running commands in Windows Command line');
end%try
filename='AccessMyVNAv0.7\release\state_matlab.txt';
fileID=fopen(filename,'w');
fprintf(fileID,'%i\r\n',0);
fclose(fileID);
set(handles.wait_time,'string',1);
set(handles.maintain_myVNA,'value',0);
write_settings(handles,handles.din.harmonic);
delete(hObject);
function polar_plot_Callback(~, ~, handles)
% --- Executes on button press in polar_plot.
if get(handles.polar_plot,'value')==1
    set(handles.show_susceptance,'value',1);
end%if get(handles.polar_plot,'value')==1
function fit_factor_Callback(hObject, ~, handles)
%This function redefines the fit_factor range for the Lorentz fitting
%process
handles.din.fit_factor_range=str2double(get(handles.fit_factor,'string'));
set(handles.status,'string','Status: Fit factor range sucessfully updated!','backgroundcolor','k','foregroundcolor','r');
disp('Fit factor range sucessfully updated!');
guidata(hObject, handles);
function show_susceptance_Callback(~, ~, handles)
% --- Executes on button press in show_susceptance.
if get(handles.show_susceptance,'value')==0
    set(handles.polar_plot,'value',0);
end%if get(handles.show_susceptance,'value')==0
function set_reference_time_Callback(~, ~, handles)
% --- Executes on button press in set_reference_time.
if get(handles.set_reference_time,'value')==1                        
    set(handles.reference_time,'string',datestr(clock,'yy:mm:dd:HH:MM:SS:FFF'));%automatically sets reference time when button is clicked
end%if get(handles.set_reference_time,'value')==1   

%% Refitting selected datapoints and related functions
function output_txt=select_spectra_fcn(hObject,event_obj)
pos=get(event_obj,'Position');%get position of the datacursor point
handles=guidata(findall(0,'tag','primary1','type','figure'));
handles.din.dcm_obj_pos=pos;
filename=handles.din.output_filename;
try%look for raw_spectras file based on base name of file
    disp('Loading raw spectras file');
    set(handles.status,'string','Status: Loading raw spectras file');
    if isfield(handles.din,'raw_spectra_path')==0
        rs_file=[handles.din.output_path,handles.din.output_filename,'_raw_spectras.mat'];%raw spectras filename
    else
        rs_file=[handles.din.raw_spectra_path,handles.din.raw_spectra_file];
        [~,filename,~]=fileparts(rs_file);
        filename=filename(1:end-13);
    end
    if exist(rs_file,'file')==0
        disp('No raw spectra file detected! Please select corresponding raw spectra file...');
        set(handles.status,'string','Status: No raw spectra file detected! Please select corresponding raw spectra file...',...
            'backgroundcolor','y','foregroundcolor','r');
        [filename,pathname,~]=uigetfile('*_raw_spectras.mat','Load raw spectra datafile',handles.din.output_path);
        handles.din.raw_spectra_path=pathname;
        handles.din.raw_spectra_file=filename;
        rs_file=[pathname,filename];
        [~,filename,~]=fileparts(rs_file);
        filename=filename(1:end-13);
        disp('Selected raw spectra loaded!');
        set(handles.status,'string','Status: Selected raw spectra loaded!',...
            'backgroundcolor','k','foregroundcolor','r');
    end
    line_h=event_obj.Target;%line handle to the selected datapoint
    harm=line_h.UserData;%harmonic associated witht the selected datapoint
    handles.din.harmonic=harm;%store harmonic in handles structure
    handles.din.dcm_obj_target=event_obj.Target;%store the line handle associated with the seleected datapoint
    guidata(handles.primary1,handles);%refresh handles structure
    
    timepoint=pos(1);%timpoint associated with the seleected datapoint
    index=find(handles.din.FG_frequency(:,1)==timepoint);    
    m=matfile(rs_file);%matfile object to the raw spectras datafile              
    flag=check_version(m.version);%check the version
    if flag==0%if things are saved in legacy format
        timepoint=strrep(num2str(pos(1)),'.','dot');
        varname=sprintf([filename,'_t_%s_iq_1_ih_',num2str(0.5*(harm+1))],timepoint);
        spectra=m.(varname);%load the associated spectra of the selected datapoint
    elseif flag==1%if things are saved in raw spectra cell format
        varname=['raw_spectra_',num2str(harm)];
        time_array=m.(varname)(:,1);%get cell array of timepoints
        index0=find(cellfun(@isempty,time_array));%find potential empty cells
        if isempty(index0)==0
            time_array(index0)={nan};%replace empty cells with nans
        end
        time_array=cell2mat(time_array);
        index=find(time_array==timepoint);
        spectra=cell2mat(m.(varname)(index,4));
    end
    refit_select_spectra(spectra,handles,harm,pos(1),index);%show the spectra in a new figure
    hObject.TipHandle.Interpreter='tex';%Set the interperter to tex so that greek symbols show up properly
    
    assignin('base','spectra',spectra);%copy variable to the base workspace
    disp('Raw spectra loaded!');
    set(handles.status,'string','Status: Raw spectra loaded!');
    %Output text that shows up with the datacursor
    output_txt={['Time (min): ',num2str(pos(1))];...
        [get(get(line_h.Parent,'YLabel'),'string'),': ',num2str(pos(2))];...
        ['Harm.: ',num2str(harm)];...
        ['Index: ',num2str(index)]};
catch
    disp('Error in loading raw spectra file.');
end
function refit_select_spectra(spectra,handles,harm,timepoint,index)
%Plot the raw spectra data
f1.f=figure(harm); clf(f1.f);
set(f1.f,'closerequestfcn',@rss_close,'tag',['refit'],...
    'name',['Harm. ',num2str(harm),', Index: ',num2str(index),', Timepoint: ',num2str(timepoint),' min.']);
f1.a1=axes; hold(f1.a1,'on');
f1.a2=axes; hold(f1.a2,'on');
f1.a1.Position=[0.15 0.3 0.7 0.6];
set(f1.a1,'color','none');
uistack(f1.a1,'top');
h=zoom(f1.f);
set(h,'motion','horizontal','enable','on');
set(f1.a2,'position',f1.a1.Position,'yaxislocation','right','xaxislocation','top','xtick',[]);
plot(f1.a1,spectra(:,1),spectra(:,2),'bx');
plot(f1.a2,spectra(:,1),spectra(:,3),'rx');
set(findall(f1.f,'type','axes'),'box','off','fontsize',12);
xlabel(f1.a1,'Frequency (Hz)');
ylabel(f1.a1,'Conductance (mS)','color','b');
y2=ylabel(f1.a2,'Susceptance (mS)');
set(y2,'color','r','rotation',-90,'verticalalignment','bottom');
set(findall(f1.f,'type','text'),'fontweight','bold');
linkaxes([f1.a1 f1.a2],'x');
delete(findall(f1.f,'tag','find_peaks'));

%Add additional uicontrol elements
guess_method=uicontrol('style','popupmenu','units','normalized',...
    'string',{'Gmax';'Derivative';'Bmax';'Previous values'},'value',4,...
    'position',[0.1 0.03 0.2 0.1],'parent',f1.f,'tooltipstring','Guess method',...
    'fontsize',12,'tag','guess_method','callback',{@guess_method_callback,harm,handles});%popupmenu for the guessing method for initial fitting values
uicontrol('style','pushbutton','string','Fit','tag','fit','parent',f1.f,...
    'units','normalized','position',[0.35 0.055 0.1 0.075],'fontsize',12,...
    'tooltipstring','Refit the spectra','fontweight','bold',...
    'callback',{@select_spectra_fit,handles,f1,guess_method,spectra,harm});%Fit push button
uicontrol('style','pushbutton','string','Accept','tag','accept','parent',f1.f,...
    'units','normalized','position',[0.5 0.055 0.15 0.075],'fontsize',12,...
    'tooltipstring','Accept the new fit','visible','off','foregroundcolor',[0 0.5 0],...
    'fontweight','bold','callback',{@accept});%acept push button
uicontrol('style','pushbutton','string','Remove','tag','remove','parent',f1.f,...
    'units','normalized','position',[0.7 0.055 0.15 0.075],'fontsize',12,...
    'tooltipstring','Remove this spectra','visible','on','foregroundcolor','r',...
    'fontweight','bold','callback',{@accept},'userdata',0);%remove pushbutton
uicontrol('style','radiobutton','string','Only fit within axes span','tag','fit_axes_span','parent',f1.f,...
    'units','normalized','position',[0.35 0.005 0.4 0.05],'fontsize',12,'value',1,...
    'tooltipstring','Reft the spectra only within the span of the plot axes');%refit span radio button
tbh=findall(f1.f,'type','uitoolbar');
uipushtool(tbh,'cdata',get(handles.peak_finding,'cdata'),'tooltipstring','Peak finding options.',...
    'ClickedCallback',{@peak_finding_ClickedCallback,handles},'tag','find_peaks');
guess_method_callback(guess_method,1,harm,handles);
function guess_method_callback(hObject,~,harm,handles)
set(handles.(['fit',num2str(harm)]),'userdata',hObject.Value);
function rss_close(hObject,~)%custom close figure function
delete(hObject);
delete(figure(999));
delete(figure(998));
function accept(hObject,~)
handles=guidata(findall(0,'type','figure','tag','primary1'));%get handles structure
Target0=handles.din.dcm_obj_target;
Target=findall(handles.uipanel8,'type','line','color',Target0.Color,'userdata',Target0.UserData);%get line handle of the selected datapoint
Target2=findall(handles.uipanel9,'type','line','color',Target.Color,'userdata',Target.UserData);
plot_selection=findall(handles.uipanel8,'style','popupmenu');
plot_selection2=findall(handles.uipanel9,'style','popupmenu');
pos=handles.din.dcm_obj_pos;
timepoint=pos(1);%timepoint of selected datapoint in min
index=find(handles.din.FG_frequency==timepoint);
harm=Target.UserData;%harmonic of selected datapoint
if length(hObject.UserData)==5%if accept the refitting results
    handles.din.FG_freq_shifts(index,harm+1)=hObject.UserData(2);%new freq shift value
    handles.din.FG_freq_shifts(index,harm+2)=hObject.UserData(3);%new dissipation shift value
    handles.din.FG_frequency(index,harm+1)=hObject.UserData(4);%new abs freq
    handles.din.FG_frequency(index,harm+2)=hObject.UserData(5);%new abs dissipation    
    index2=find(Target.XData==timepoint);
    switch plot_selection.Value
        case 1%none
        case 2%f vs. time
            Target.YData(index2)=hObject.UserData(2);
        case 3%f/n vs. time
            Target.YData(index2)=hObject.UserData(2)/harm;
        case 4%g vs. time
            Target.YData(index2)=hObject.UserData(3);
        case 5%g/n vs. time
            Target.YData(index2)=hObject.UserData(3)/harm;
    end
    switch plot_selection2.Value
        case 1%none
        case 2%f vs. time
            Target2.YData(index2)=hObject.UserData(2);
        case 3%f/n vs. time
            Target2.YData(index2)=hObject.UserData(2)/harm;
        case 4%g vs. time
            Target2.YData(index2)=hObject.UserData(3);
        case 5%g/n vs. time
            Target2.YData(index2)=hObject.UserData(3)/harm;
    end
elseif hObject.UserData==0%if want to remove the spectra or datapoint
    handles.din.FG_freq_shifts(index,harm+1)=nan;%new freq shift value
    handles.din.FG_freq_shifts(index,harm+2)=nan;%new dissipation shift value
    handles.din.FG_frequency(index,harm+1)=nan;%new abs freq
    handles.din.FG_frequency(index,harm+2)=nan;%new abs dissipation    
    index2=find(Target.XData==timepoint);
    switch plot_selection.Value
        case 1%none
        case 2%f vs. time
            Target.YData(index2)=nan;
        case 3%f/n vs. time
            Target.YData(index2)=nan;
        case 4%g vs. time
            Target.YData(index2)=nan;
        case 5%g/n vs. time
            Target.YData(index2)=nan;
    end
    switch plot_selection2.Value
        case 1%none
        case 2%f vs. time
            Target2.YData(index2)=nan;
        case 3%f/n vs. time
            Target2.YData(index2)=nan;
        case 4%g vs. time
            Target2.YData(index2)=nan;
        case 5%g/n vs. time
            Target2.YData(index2)=nan;
    end
    delete(findall(0,'type','figure','tag','refit'));
end
guidata(handles.primary1,handles);
disp('Accepted new fit!');
set(handles.status,'string','Status: Accepted new fit!');
function select_spectra_fit(hObject,~,handles,f1,guess_method,spectra,harm)
%clean up the axes
delete(findall(f1.f,'type','line','linestyle','-','marker','none'));
delete(findall(f1.f,'type','line','color','m'));
delete(findall(f1.f,'type','line','color',[0 0.5 0]));
delete(findall(f1.f,'type','line','color','g'));
handles=confirm_peak_finding(handles.peak_finding, 1, handles);%ask the user whether or not the peak(s) is/are the right one

figure(999);clf(figure(999));
set(gcf,'numbertitle','off','name',['Polar plot, Harmonic: ',num2str(harm)],...
    'units','normalized','position',[.725 0.4 .25 .35]);%create new figure window plotting the polar plot
temp=text(1,1,'Fitting...');set(temp,'parent',f1.a2,'units','normalized','position',[0.4 0.5],'fontsize',28,'fontweight','bold');drawnow;
combine_spectra=spectra(:,1:3);
freq=spectra(:,1);%frequency in Hz
conductance=spectra(:,2);%conductance in mS
susceptance=spectra(:,3);%susceptance in mS
fit_span_option=findall(f1.f,'tag','fit_axes_span');
if fit_span_option.Value==1%if this option is selected, fit only within the span of the axes limits
    xlim0=f1.a1.XLim;%get the xlimits of the axes
    index=find(freq>=xlim0(1)&freq<=xlim0(2));
    freq=freq(index);
    conductance=conductance(index);
    susceptance=susceptance(index);
    combine_spectra=combine_spectra(index,:);
end%if fit_span_option.Value==1
[combine_spectra,GB_parameters,handles,I,std_fit]=Lorentzian_dynamic_fit(handles,freq,conductance,susceptance,combine_spectra);%fit curve
delete(temp);drawnow;
if isempty(GB_parameters)
    delete(figure(999));delete(figure(998));
    return
end%if isempty(G_fit)
p=[f1.a1 f1.a2];
ave_f0=GB_parameters(1)*1e6;%resonance (Hz)
ave_g0=GB_parameters(2)*1e4;%HMHW (Hz)
GB_fit=combine_spectra(:,4:5);
GB_residual=combine_spectra(:,6:7);

%plot the raw data and the fitted data
temp=text(1,1,'Plotting...');set(temp,'parent',f1.a2,'units','normalized','position',[0.4 0.5],'fontsize',28,'fontweight','bold');drawnow;
plot(p(1),freq(I),ones(size(I,1),1).*min(conductance),'-','linewidth',2,'color',[0.82031 0.410156 0.11718]);
plot(p(1),freq,GB_fit(:,1),'k-','linewidth',2);
plot(p(2),freq,GB_fit(:,2),'k-','linewidth',2);
linkaxes(p,'x');
run('Lorentz_eqns.m');%load the Lorentz equations
if length(GB_parameters)==6%single peak fitting
    plot(p(1),ave_f0,sum(GB_parameters(4:5)),'o','color',[0 0.5 0],'markerfacecolor',[0 0.5 0],'markersize',10);
    plot(p(1),[ave_f0+ave_g0 ave_f0-ave_g0],...
    [0.5*GB_parameters(4)+GB_parameters(5),0.5*GB_parameters(4)+GB_parameters(5)],'mo','markerfacecolor','m','markersize',10);   
    parameters5=['G_offset:     ',num2str(GB_parameters(5),10),' mS'];%G_offset
    parameters6=['B_offset:     ',num2str(GB_parameters(6),10),' mS'];%B_offset
elseif length(GB_parameters)==10% double peak fitting
    plot(p(1),ave_f0,sum(GB_parameters(4:5)),'o','color',[0 0.5 0],'markerfacecolor',[0 0.5 0],'markersize',10);
    plot(p(1),[ave_f0+ave_g0 ave_f0-ave_g0],...
    [0.5*GB_parameters(4)+GB_parameters(5),0.5*GB_parameters(4)+GB_parameters(5)],'mo','markerfacecolor','m','markersize',10);   
    plot(p(1),[GB_parameters(1),GB_parameters(6)].*1e6,[GB_parameters(4),GB_parameters(9)]+GB_parameters(5),'gx','linewidth',2,'markersize',10);
    plot(p(1),freq,lfun4c(GB_parameters(1:5),freq)+GB_parameters(5),'g--');
    plot(p(1),freq,lfun4c(GB_parameters(6:9),freq)+GB_parameters(5),'g--');    
    parameters5=['G_offset:     ',num2str(GB_parameters(5),10),' mS'];%G_offset
    parameters6=['B_offset:     ',num2str(GB_parameters(10),10),' mS'];%B_offset
elseif length(GB_parameters)==14%triple peak fitting
    plot(p(1),ave_f0,sum(GB_parameters(4:5)),'o','color',[0 0.5 0],'markerfacecolor',[0 0.5 0],'markersize',10);
    plot(p(1),[ave_f0+ave_g0 ave_f0-ave_g0],...
    [0.5*GB_parameters(4)+GB_parameters(5),0.5*GB_parameters(4)+GB_parameters(5)],'mo','markerfacecolor','m','markersize',10);   
    plot(p(1),freq,lfun4c(GB_parameters(1:4),freq)+GB_parameters(5),'g--');
    plot(p(1),freq,lfun4c(GB_parameters(6:9),freq)+GB_parameters(5),'g--');
    plot(p(1),freq,lfun4c(GB_parameters(10:13),freq)+GB_parameters(5),'g--');
    plot(p(1),[GB_parameters(1),GB_parameters(6),GB_parameters(10)].*1e6,[GB_parameters(4),GB_parameters(9),GB_parameters(13)]+GB_parameters(5),'gx','linewidth',2,'markersize',10);
    parameters5=['G_offset:     ',num2str(GB_parameters(5),10),' mS'];%G_offset
    parameters6=['B_offset:     ',num2str(GB_parameters(14),10),' mS'];%B_offset
end%if length(GB_parameters)==5
%Create a polar plot that shows the quality of the fit for both the
%conductance and susceptance curves
figure(999);
set(figure(999),'tag','refit1');
plot(conductance,susceptance,'bx','linewidth',2,'markersize',6);hold on;
plot(GB_fit(:,1),GB_fit(:,2),'-','color',[0 0.5 0],'linewidth',2.5);
plot(GB_fit(I,1),GB_fit(I,2),'-','linewidth',2,'color',[0.82031 0.410156 0.11718]);
title('Polar plot of susceptance vs. conductance','fontweight','bold','fontsize',12);
xlabel('Conductance (mS)','fontsize',12,'fontweight','bold');
ylabel('Susceptance (mS)','fontsize',12,'fontweight','bold');
set(f1.a1,'ylimmode','auto','xlimmode','auto');
delete(temp);

%Display correction to freq and gamma shift
pos=handles.din.dcm_obj_pos;
abs_f=GB_parameters(1);%refitted resonance frequency
abs_g=GB_parameters(2);%refitted resonance bandwidth
timepoint=pos(1);%Timepoint of the selected datapoint
index=find(handles.din.FG_frequency(:,1)==timepoint);
abs_f0=handles.din.FG_frequency(index,harm+1);%original resonance frequency
abs_g0=handles.din.FG_frequency(index,harm+2);%original resonance bandwidth
f0_shift=handles.din.FG_freq_shifts(index,harm+1);%original frequnecy shift
g0_shift=handles.din.FG_freq_shifts(index,harm+2);%original bandwidth shift
del_f_new=abs_f*1e6-handles.din.ref_freq((harm+1)/2);%calculated refitted frequency shift
del_g_new=abs_g*1e4-handles.din.ref_diss((harm+1)/2);%calculated refitted bandwith shift
f_corr=del_f_new-f0_shift;%correction to frequency
g_corr=del_g_new-g0_shift;%correction to dissipation
delete(findall(f1.f,'tag','info'));
if fit_span_option.Value==1%if this option is selected, fit only within the span of the axes limits
    set(p,'xlim',xlim0);drawnow;
end
str={['\Deltaf_{original}: ',num2str(f0_shift,4),' Hz'];...
    ['\Deltaf_{new}: ',num2str(del_f_new,4),'\pm',num2str(std_fit(1),2),' Hz'];...
    ['\Deltaf_{correction}: ',num2str(f_corr,4),' Hz'];...
    ['  '];...
    ['\Delta\Gamma_{original}: ',num2str(g0_shift,4),' Hz'];...
    ['\Delta\Gamma_{new}: ',num2str(del_g_new,4),'\pm',num2str(std_fit(2),2),' Hz'];...
    ['\Delta\Gamma_{correction}: ',num2str(g_corr,4),' Hz']};
figure(harm);
info=annotation('textbox',[0.55 0.5 0.3 0.4]);
set(info,'string',str,'tag','info','backgroundcolor','w','edgecolor','k',...
    'facealpha',0.65,'edgecolor','none','fitboxtotext','on','margin',0);%show info in text box in plot axes
set(findall(f1.f,'tag','accept'),'visible','on',...
    'userdata',[index,del_f_new,del_g_new,abs_f*1e6,abs_g*1e4]);
