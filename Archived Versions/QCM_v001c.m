function varargout = QCM_v001c(varargin)
%This QCM Program was created by Chyi-Huey Joshua Yeh from the Shull
%Research Group at Northwestern Unviersity.
% QCM_V001C MATLAB code for QCM_v001c.fig
%      QCM_V001C, by itself, creates a new QCM_V001C or raises the existing
%      singleton*.
%
%      H = QCM_V001C returns the handle to a new QCM_V001C or the handle to
%      the existing singleton*.
%
%      QCM_V001C('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in QCM_V001C.M with the given input arguments.
%
%      QCM_V001C('Property','Value',...) creates a new QCM_V001C or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before QCM_v001c_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to QCM_v001c_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help QCM_v001c

% Last Modified by GUIDE v2.5 02-Jul-2014 09:29:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @QCM_v001c_OpeningFcn, ...
                   'gui_OutputFcn',  @QCM_v001c_OutputFcn, ...
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


% --- Executes just before QCM_v001c is made visible.
function QCM_v001c_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to QCM_v001c (see VARARGIN)

% Choose default command line output for QCM_v001c
handles.output = hObject;

%initialize AccessMyVNA program
clc;
format compact;
format long;
h=waitbar(0,'Initializing MATLAB GUI...');
set(h,'WindowStyle','modal');
figure(h);
disp('Initializing MATLAB GUI...');
open('AccessMyVNAv0.7\release\AccessMyVNA.exe');
% Update handles structure
handles.din.freq_range=[4 6; 14 16; 24 26; 34 36; 44 46; 54 56];%this stores the accepted frequency ranges for each harmonic
handles.din.avail_harms=[1 3 5 7 9 11];
handles.din.error_count=1;%declar an error log vounter variable that is stored int he handles structure
handles.din.error_log={};%declare an error log variable that is stored in the handles structure
handles.din.prev_cond=zeros(str2double(get(handles.num_datapoints,'string')),1);
handles.din.harmonic=1;
handles.din.active_harm_primaryaxes1=[];
handles.din.active_harm_primaryaxes2=[];
handles.din.n=1;%starting initial index for FG_frequency
handles.din.max_datapts=1e6;
handles.din.FG_frequency=NaN(handles.din.max_datapts,13);
handles.din.FG_freq_shifts=NaN(handles.din.max_datapts,13);
handles.din.chi_sqr_value=NaN(handles.din.max_datapts,13);
handles.din.set_span_factor_sensitivity=0.1;
handles.din.fit_factor_range=str2double(get(handles.fit_factor,'string'));
set(handles.fit_factor,'string',handles.din.fit_factor_range);
handles.din.default_start_freq=[4.9;14.9;24.9;34.9;44.9;54.9];%set default start frequencies
handles.din.default_end_freq=[5.1;15.1;25.1;35.1;45.1;55.1];%set default end frequencies
handles.din.num_pts=800;%set default number of datapoints
handles.din.flag=0;%this is the toggle state of the raw fig button
for dum=1:2:11
    name1=['start_f',num2str(dum)];
    name2=['end_f',num2str(dum)];
    name3=['num_pts',num2str(dum)];
    set(handles.(name1),'string',num2str(handles.din.default_start_freq((dum+1)/2)));
    set(handles.(name2),'string',num2str(handles.din.default_end_freq((dum+1)/2)));
    set(handles.(name3),'string',['# pts: ',num2str(handles.din.num_pts)]);
end%for dum=1:2:11
waitbar(0.1,h,'Preallocated MATLAB arrays...');
disp('Preallocated MATLAB arrays...');
figure(h);
%set reference frequency shifts and dissipation shifts
handles.din.ref_freq=[5 15 25 35 45 55].*1e6;%units in Hz
handles.din.ref_diss=[100 100 100 100 100 100];%units in Hz
waitbar(0.15,h,'Reference values set...');
%inital formating of axes and buttons, etc.
waitbar(0.2,h,'Formatting plots and legend boxes...');
disp('Formatting plots and legend boxes...');
axes(handles.axes7);
plot(handles.axes7,[0,1],[0,0],'-',[0,1],[0,0],'r-','visible','off');%add a legend box for the raw conductance plots
set(gca,'fontsize',6);%set font size of the legend
legend('Conductance','Susceptance','Location','West');%set location of legend box
%add a legend for the harmonics
marker_color={[0 0 0],[0 0 1],[1 0 0],[0 0.5 0],[1 .8398 0],[.25 .875 .8125]};
harm_label=[{'1st'},{'3rd'},{'5th'},{'7th'},{'9th'},{'11th'}];
figure(h);
set(handles.uipanel8,'visible','off');
set(handles.uipanel4,'visible','off');
for dum=1:6
    waitbar(0.2+dum*0.05,h);
    axes_name=['axes',num2str(13+dum)];
    axes(handles.(axes_name));
    plot(handles.(axes_name),[0,1],[0,0],'o','visible','off','color',...
        marker_color{dum},'markersize',6,'linewidth',1.5);
    set(gca,'fontsize',6,'visible','off');
    l=legend(harm_label{dum},'location','west');
    figure(h);
end%for dum=1:6
figure(h);
set(handles.sa1,'visible','off','color','none');
set(handles.sa2,'visible','off','color','none');
set(handles.sa3,'visible','off','color','none');
set(handles.sa4,'visible','off','color','none');
set(handles.sa5,'visible','off','color','none');
set(handles.sa6,'visible','off','color','none');
set(handles.axes7,'visible','off');
set(handles.peak_center,'visible','off');
set(handles.center1,'value',1);
set(handles.primaryaxes1,'fontsize',8);
set(handles.primaryaxes2,'fontsize',8);
set(handles.maintain_myVNA,'value',1);
xlabel(handles.primaryaxes1,'Time (min)','fontsize',8,'fontweight','bold');
ylabel(handles.primaryaxes1,'Frequency (Hz)','fontsize',8,'fontweight','bold');
xlabel(handles.primaryaxes2,'Time (min)','fontsize',8,'fontweight','bold');
ylabel(handles.primaryaxes2,'Frequency (Hz)','fontsize',8,'fontweight','bold');
set(handles.email_notification,'userdata',0);
set(handles.num_datapoints,'userdata',ones(11,1).*handles.din.num_pts);%set the default number of datapoints for each harmonic
waitbar(0.6,h);
for dum=1:6%add labels to the conductance curves
    waitbar(0.6+dum*0.05,h);
    axname=['axes',num2str(dum)];
    set(handles.(axname),'fontsize',4);
    xlabel(handles.(axname),'Freqency (Hz)','fontsize',6);
    ylabel(handles.(axname),'mSiemens (mS)','fontsize',6);
end%for dum=1:6
%add folder paths
addpath('AccessMyVNAv0.7\AccessMyVNA','AccessMyVNAv0.7\release',...
    'AccessMyVNAv0.7\AccessMyVNA\Debug');
%set default reference time
set(handles.reference_time,'string',datestr(clock,'yy:mm:dd:HH:MM:SS:FFF'));
try
    axes(handles.ukfunc);
    load('other.mat');
    handles.d=imshow(BW);    
    set(handles.d,'buttondownfcn',{@ukfunc_ButtonDownFcn,handles});
end%try
set(handles.uipanel8,'visible','on');
set(handles.uipanel4,'visible','on');
set(handles.text2,'userdata',0);
write_settings(handles,handles.din.harmonic);%this function writes out the settings text file
plot1_choice_Callback(hObject, eventdata, handles);%refresh primaryaxes1
plot2_choice_Callback(hObject, eventdata, handles);%refresh primaryaxes2
handles.default_settings=handles.din;%define a default handles.din state
waitbar(1,h,'MATLAB GUI initiatlized!');
figure(h);
disp('MATLAB GUI initialized!');
guidata(hObject, handles);
figure(h);
delete(h);
try
    delete('qcm_diary.txt');
catch
end

% UIWAIT makes QCM_v001c wait for user response (see UIRESUME)
% uiwait(handles.primary1);


% --- Outputs from this function are returned to the command line.
function varargout = QCM_v001c_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in start.
function start_Callback(hObject, ~, handles)
tic
pause on;
if get(handles.raw_fig,'value')==1%if the raw fig mode is turned on before the recording process, toggle handles.din.flag to 1
    handles.din.flag=1;
    disp('Please turn off the Raw Figure Mode before starting the measurement process!');
    set(handles.status,'string','Status: Please turn off the Raw Figure Mode before starting the measurement process!');
    handles.din.flag=0;
    set(handles.start,'value',1,'string','Record Scan','backgroundcolor',[0 0.5 0]);
    guidata(hObject,handles);
    return
end
%disable some of the features to prevent errors from occuring caused by
%running two blocks of code simultaneously
set(handles.peak_centering,'value',0);
harm_tot=find_num_harms(handles);%find total active harmonics
if isempty(harm_tot)
    harm_tot=1;
    set(handles.harm1,'value',1);
end%if isempty(harm_tot)
set(handles.harmonics_text,'userdata',harm_tot);
peak_centering_Callback(handles.peak_centering, 1, handles);
set(handles.peak_centering,'visible','off');%hide the button
set(handles.debug,'visible','off');%hide the button
set(handles.clear_datapoints,'visible','off');%hid the button
set(handles.reset,'visible','off');
% %//////////////////////////////////////////////////////////////////////////
%This if statement blocks checks to see if the user defined an output
%filename and location to store the data (besides the default output
%filename and location
if strcmp(get(handles.filename_txt,'string'),'<Output Filename>')&&get(handles.start,'value')==1
    choice=questdlg('Do you want to designate a filename and location to store your data?',...
        'Output filename and path confirmation','Yes');
    switch choice
        case 'Yes'
            try
                [output_filename,output_path]=uiputfile('*.mat');
                full_filename=[output_path,output_filename];
                set(handles.filename_txt,'string',[full_filename(1:10),'...',full_filename(end-10:end)],...
                    'tooltipstring',full_filename,'userdata',1);%output filename info
                handles.din.output_filename=output_filename;
                handles.din.output_path=output_path;
            catch 
            end%try
        case 'No'
            handles.din.output_filename=['Default'];
            handles.din.output_path=[''];
        case 'Cancel'
            set(handles.start,'value',0,'string','Record Scan','backgroundcolor',[0 0.5 0]);
            return
    end%switch choice
end%if strcmp(get(handles.filename_txt,'string'),'<Output Filename>')
counter=1;%counter
write_settings(handles,harm_tot(1));%this function writes out the settings text file
%update string of the start button based on the toggle state
if get(handles.start,'value')==1
    set(handles.start,'string','Stop Scan','backgroundcolor','r');
elseif get(handles.start,'value')==0
    set(handles.start,'string','Record Scan','backgroundcolor',[0 0.5 0]);
    set(handles.uipanel1,'visible','off');%hides the settings panel 
    set(handles.status,'string','Status: Stopping the data recording process. Please wait...');
    pause off
    return
end%if get(handles.start,'value')==1
%Check/modify output filename so that errors will not occur during the
%scanning process and storing of spectra data
try
    disp(['Output filename: ',handles.din.output_filename]);
    output_filename=handles.din.output_filename(1:end-4);
    output_filename=strrep(output_filename,' ','_');
    output_filename=strrep(output_filename,'(','_');
    output_filename=strrep(output_filename,')','_');
    output_filename=strrep(output_filename,'.','_');
    output_filename=strrep(output_filename,'-','_');
    if length(output_filename)>namelengthmax
        disp('Error in specifying filename!');
        set(handles.status,'string',['Status: ERROR in specifying filename! Filename is too long!']);
        handles.din.error_log(handles.din.error_count,1)={[datestr(clock),' ERROR in specifying filename! Filename is too long!']};
        handles.din.error_count=handles.din.error_count+1;
        assignin('base','error_log',handles.din.error_log);
        disp('Recording process terminated');
        return
    end%if length(output_filename)>namelengthmax
catch
    disp('Error in specifying filename!');
    set(handles.status,'string',['Status: ERROR in specifying filename!']);
    handles.din.error_log(handles.din.error_count,1)={[datestr(clock),' ERROR in specifying filename!']};
    handles.din.error_count=handles.din.error_count+1;
    assignin('base','error_log',handles.din.error_log);
    disp('Recording process terminated');
    return
end
%//////////////////////////////////////////////////////////////////////////
%designate output file location and name for output data
if get(handles.filename_txt,'userdata')==0
    fg_values=matfile('fg_values.mat','Writable',true);
    spectra = matfile('raw_spectras.mat','Writable',true);%open matfile and set access to writable
else
    fg_values=matfile([handles.din.output_path,handles.din.output_filename],'Writable',true);
    spectra = matfile([handles.din.output_path,handles.din.output_filename(1:end-4),'_raw_spectras.mat'],'Writable',true);%open matfile and set access to writable
end%if get(handles.filename_txt,'userdata')==0
% %//////////////////////////////////////////////////////////////////////////
%Check to see if email notifications are turned on
if isempty(get(handles.email_notification,'userdata'))~=1
    if get(handles.email_notification,'userdata')==1
        diary('qcm_diary.txt');
        diary on;
        disp('#############################');
        disp('Email notifications have been turned on');
        disp(['Notifications will be sent to ',get(handles.uipanel5,'userdata')]);
    end% if get(handles.email_notification,'userdata')==1
end%if isempty(get(handles.email_notification,'userdata'))~=1
%///////////////////////////////////////////////////
%Format reference time, define other variables, and disp other misc. things before initiating while loop
start_time2=datevec(get(handles.reference_time,'string'),'yy:mm:dd:HH:MM:SS:FFF');%get reference time into an appropriate format
n=handles.din.n;
disp('-------------------');
disp('Scan initiated>>>>>>>>');
disp(['Time of initiation: ',datestr(clock)]);
disp(['Reference time: ',datestr(start_time2)]);
while get(handles.start,'value')==1    %<------------while loops begins here!
   harm_tot=find_num_harms(handles);%find total active harmonics
   if isempty(harm_tot)
        harm_tot=1;
        set(handles.harm1,'value',1);
   end%if isempty(harm_tot)
    %//////////////////////////////////////////////////////////////
    %Determine variable name in which the spectra information will be stored
    time_now=datestr(clock,'yy:mm:dd:HH:MM:SS:FFF');%Current time
    time_now1=datevec(time_now,'yy:mm:dd:HH:MM:SS:FFF');%Find current time and make it a vector
    Z=time_now1 - start_time2;%Find difference in time
    time_elapsed=Z(1)*525960+Z(2)*43830+Z(3)*1440+Z(4)*60+Z(5)+Z(6)./60;%fix time into MINUTES
    timestamp=strrep(num2str(time_elapsed),'.','dot');%replace decimal with 'dot'    
    disp('........................................')
    disp(['Timestamp: ', num2str(time_elapsed),' min']);
    %//////////////////////////////////////////////////////////////
    for dum=1:size(harm_tot)
        if get(handles.start,'value')==1
            disp(['Scanning harmonic: ', num2str(harm_tot(dum))]);
            tic
            try
                write_settings(handles,harm_tot(dum));%update the setting txt file
                handles.din.harmonic=harm_tot(dum);%write the current harmonic into the handles.din structure
                [freq,conductance,susceptance,handles]=read_scan(handles);%read the data from the output myVNA c++ output file
                %only run the following if statement if the user wants to see the it dynamically            
                if get(handles.dynamic_fit,'value')==1%this if statement will run the Lorentzian fitting function
                      [G_fit,B_fit,~,~,combine_spectra,G_parameters,B_parameters,handles,I]=Lorentzian_dynamic_fit(handles,freq,conductance,susceptance,[freq,conductance,susceptance]);
                else
                    combine_spectra=[freq,conductance,susceptance,zeros(size(freq,1),4)];
                end%if get(handles.dynamic_fit,'value')==1                
            %output harmonic in appropriate axes
                ax1=['axes',num2str((harm_tot(dum)+1)*0.5)];
                ax2=['sa',num2str((harm_tot(dum)+1)*0.5)];
                axes(handles.(ax1));
            %//////////////////////////////////////////////////////////////
            %write out spectra in specified spectra filename
            try
                spectra.(sprintf([output_filename,'_t_%s_iq_1_ih_',num2str((harm_tot(dum)+1)./2)],timestamp)) = combine_spectra;%renames variable based on harm
                if get(handles.dynamic_fit,'value')==1
                    handles.din.FG_frequency(n,1)=str2double(strrep(timestamp,'dot','.'));%timestamp
                    if get(handles.fit_B_radio,'value')==1
                        handles.din.FG_frequency(n,harm_tot(dum)+1)=mean([G_parameters(1),B_parameters(1)]);%frequency at peak of Lorentzian fit, f0
                        handles.din.FG_frequency(n,harm_tot(dum)+2)=mean([G_parameters(2),B_parameters(2)]);%HMHW of Lorentzian peak, Ga
                    else
                        handles.din.FG_frequency(n,harm_tot(dum)+1)=G_parameters(1);%frequency at peak of Lorentzian fit, f0
                        handles.din.FG_frequency(n,harm_tot(dum)+2)=G_parameters(2);%HMHW of Lorentzian peak, Gamma0
                    end%if get(fit_B_radio,'value')==1
                    handles.din.FG_freq_shifts(n,1)=handles.din.FG_frequency(n,1);%timestamp
                    handles.din.FG_freq_shifts(n,harm_tot(dum)+1)=G_parameters(1)-handles.din.ref_freq((harm_tot(dum)+1)./2);%calculate delta f
                    handles.din.FG_freq_shifts(n,harm_tot(dum)+2)=G_parameters(2)-handles.din.ref_diss((harm_tot(dum)+1)./2);  %calculate delta Gamma
                    %Chi sq calculation (right now it is least squares not chi squares (04012014))
                    handles.din.chi_sqr_value(n,1)=str2double(strrep(timestamp,'dot','.'));%Timestamps chi squared value variable
                    handles.din.chi_sqr_value(n,harm_tot(dum)+1)=sum(combine_spectra(:,6));%stores chi squared for G
                    handles.din.chi_sqr_value(n,harm_tot(dum)+2)=sum(combine_spectra(:,7));%stores chi squared for B         
                    if get(handles.radio_chi,'value')==1 %Show chi squared parameter on plots
                        xsq_name=['X',num2str(harm_tot(dum))];
                        set(handles.(xsq_name),'visible','on');
                        set(handles.(xsq_name),'string',['Xsq = ',num2str(handles.din.chi_sqr_value(n,harm_tot(dum)+1))]);
                        disp(['Xsq = ',num2str(handles.din.chi_sqr_value(n,harm_tot(dum)+1))]);
                    end              
                end%if get(handles.dynamic_fit,'value')==1
            catch
                disp('Error in writing out spectra to specified filename!');
                set(handles.status,'string',['Status: ERROR in saving spectra!']);
                handles.din.error_log(handles.din.error_count,1)={[datestr(clock),' ERROR in saving spectra!']};
                handles.din.error_count=handles.din.error_count+1;
                assignin('base','error_log',handles.din.error_log);
            end
            %//////////////////////////////////////////////////////////////
            catch
               disp('Error in start_callback function!');
               set(handles.status,'string','Status: ERROR in callback function!');
               handles.din.error_log(handles.din.error_count,1)={[datestr(clock),'  ERROR in callback function!']};
               handles.din.error_count=handles.din.error_count+1;
               assignin('base','error_log',handles.din.error_log);
            end%try
            if get(handles.start,'value')==0
                disp('Scan stopped');
            end%if get(handles.start,'value')==0
            counter=counter+1;
            %/////////////////////////////////////////////////////////////////
            %plot the data set
            %this if statement code refreshes the spectra every <user-defined>th iteration of the while loop    
            if mod(counter,str2double(get(handles.refresh_spectra,'string')))==0
                if get(handles.raw_fig,'value')==1%display the plots in raw figure mode
                raw_fig_Callback(handles.raw_fig, 1, handles);
                plot_primaryaxes1(handles,handles.din.FG_frequency,harm_tot,n);
                plot_primaryaxes2(handles,handles.din.FG_frequency,harm_tot,n);
                else%if not, then display the raw spectra in the small axes in the main GUI
                    if get(handles.polar_plot,'value')==0%determine to show the raw data in polar coordinates
                        disp(['Plotting harmonic: ', num2str(harm_tot(dum)),' in ',ax1]);
                        refreshing(handles,harm_tot(dum),1);%show which plot is being refreshed
                        cla(handles.(ax1));
                        cla(handles.(ax2));
                        hold on;
                        if get(handles.show_susceptance,'value')==1
                            plot(handles.(ax1),freq,conductance,'bx-','linewidth',1,'markersize',6)                        
                            set(handles.(ax1),'xlim',[min(freq) max(freq)]);
                            axes(handles.(ax2));
                            plot(handles.(ax2),freq,susceptance,'rx-','linewidth',1,'markersize',6);
                            set(handles.(ax2),'yaxislocation','right','xlim',[min(freq) max(freq)],'color','none','ycolor','r','box','off');
                            set(handles.(ax1),'xlim',[min(freq) max(freq)],'ylim',[min(conductance)-.1*min(conductance),1.1*max(conductance)]);
                        else
                            p1=plot(handles.(ax1),freq,conductance,'bx-','linewidth',1,'markersize',6);
                            set(handles.(ax1),'xlim',[min(freq) max(freq)],'ylim',[min(conductance)-.1*min(conductance),1.1*max(conductance)]);
                        end%if get(handles.show_susceptance,'value')==1
                        hold on;
                        if get(handles.dynamic_fit,'value')==1
                            plot(handles.(ax1),freq,G_fit,'k','linewidth',2);
                            plot(handles.(ax1),freq(I),ones(size(I,1)).*min(conductance),'-','linewidth',2,'color',[0.82031 0.410156 0.11718]);
                            set(handles.(ax1),'xlim',[min(freq) max(freq)]);
                            if get(handles.show_susceptance,'value')==1
                                plot(handles.(ax2),freq,susceptance,'rx-');
                                plot(handles.(ax2),freq,B_fit,'k','linewidth',2);
                                set(handles.(ax2),'yaxislocation','right','xlim',[min(freq) max(freq)],'color','none','ycolor','r','box','off');
                                plot(handles.(ax1),mean([G_parameters(1), B_parameters(1)]),...
                                    mean([G_parameters(4)+G_parameters(5),B_parameters(4)]+G_parameters(5)),'mo','markerfacecolor','m','markersize',6);
                                plot(handles.(ax1),[mean([G_parameters(1),B_parameters(1)])-mean([G_parameters(2),B_parameters(2)]),...
                                    mean([G_parameters(1),B_parameters(1)])+mean([G_parameters(2),B_parameters(2)])+G_parameters(5)],...
                                [mean([G_parameters(4),B_parameters(4)])/2+G_parameters(5),mean([G_parameters(4),B_parameters(4)])/2+G_parameters(5)],...
                                'o','color',[0 0.5 0],'markerfacecolor',[0 0.5 0],'markersize',6);                   
                                peak_track=get(handles.(['peak_track',num2str(handles.din.harmonic)]),'userdata');%extract out the peak tracking conditions
                                if peak_track(1)==1&&peak_track(2)==0%adjust window based on fixed span
                                    current_span=max(freq)-min(freq);
                                    temp_ylim=get(handles.(ax2),'ylim');
                                    plot(handles.(ax2),[mean(freq)-current_span*handles.din.set_span_factor_sensitivity,mean(freq)-current_span*handles.din.set_span_factor_sensitivity],...
                                        temp_ylim,'k-.','linewidth',1);
                                    plot(handles.(ax2),[mean(freq)+current_span*handles.din.set_span_factor_sensitivity,mean(freq)+current_span*handles.din.set_span_factor_sensitivity],...
                                        temp_ylim,'k-.','linewidth',1);
                                end                            
                            else
                                plot(handles.(ax1),G_parameters(1),G_parameters(4),'mo','markerfacecolor','m','markersize',6);
                                plot(handles.(ax1),[G_parameters(1)-G_parameters(2),G_parameters(1)+G_parameters(2)],...
                                [G_parameters(4)/2,G_parameters(4)/2],'o','color',[0 0.5 0],'markerfacecolor',[0 0.5 0],'markersize',6);
                            end%if get(handles.show_susceptance,'value')==1
                            plot_primaryaxes1(handles,handles.din.FG_frequency,harm_tot,n);
                            plot_primaryaxes2(handles,handles.din.FG_frequency,harm_tot,n);
                        end%if get(handles.dynamic_fit,'value')==1
                        hold off;
                        ylabel(handles.(ax1),'mSiemans (mS)','fontsize',6);
                        xlabel(handles.(ax1),'Frequency (Hz)','fontsize',6);
                    else%plot the raw data in polar plot form
                        disp(['Plotting harmonic: ', num2str(harm_tot(dum)),' in ',ax1]);
                        refreshing(handles,harm_tot(dum),1);%show which plot is being refreshed
                        cla(handles.(ax1));
                        axes(handles.(ax1));
                        plot(handles.(ax1),conductance,susceptance,'x-',...
                            'color',[0 0.5 0],'linewidth',1,'markersize',6);
                        axis tight
                        hold on;
                        if get(handles.dynamic_fit,'value')==1&&get(handles.fit_B_radio,'value')==1
                            plot(handles.(ax1),G_fit,B_fit,'k-','linewidth',2);
                            plot(handles.(ax1),G_fit(I),B_fit(I),'-','linewidth',1,'color',[0.82031 0.410156 0.11718]);
                        end%if get(handles.dynamic_fit,'value')==1&&get(handles.fit_B_radio,'value')==1
                        if get(handles.dynamic_fit,'value')==1
                            plot_primaryaxes1(handles,handles.din.FG_frequency,harm_tot,n);
                            plot_primaryaxes2(handles,handles.din.FG_frequency,harm_tot,n);
                        end%if get(handles.dynamic_fit,'value')==1
                        hold off;
                        xlabel(handles.(ax1),'Conductance (mS)','fontsize',6);
                        ylabel(handles.(ax1),'Susceptance (mS)','fontsize',6);
                    end%if get(handles.polar_plot,'value')==1
                    drawnow;
                end%  if get(handles.raw_fig,'value')==1
            end%if mod(counter,str2double(get(handles.refresh_spectra,'string')))==0   
             %//////////////////////////////////////////////////////////////////////
            %this block of code deals with peak tracking
            if get(handles.dynamic_fit,'value')==1%use the fitted parameters to determine how to track the peak
                handles=smart_peak_tracker(handles,freq,conductance,susceptance,G_parameters);
                disp('Adjusting windows based on fitted Lorentzian parameters...');
            else%guess what f0 and gamma0 to determine how to track the peak
                [peak_detect,index]=findpeaks(conductance,'sortstr','descend');
                Gmax=peak_detect(1);%find peak of curve
                f0=freq(index(1));%finds freq at which Gmax happens
                halfg=Gmax./2;%half of the Gmax
                halfg_freq=freq(find(abs(halfg-conductance)==min(abs((halfg-conductance))),1));
                gamma0=abs(halfg_freq-f0);%Guess for gamma, HMHW of peak
                guess=[f0 gamma0 0 Gmax 0];    
                handles=smart_peak_tracker(handles,freq,conductance,susceptance,guess);
                disp('Adjusting windows based on peak of conductance curve...');
            end
            %//////////////////////////////////////////////////////////////////////
            pause(str2double(get(handles.wait_time,'string'))./1000);
            refreshing(handles,harm_tot(dum),0);
            toc
        end%for get(handles.start,'value')==1
    end%for dum=1:size(harm_tot)
    disp(['Datapoint(s): ',num2str(n)]);
    n=n+1;
    %//////////////////////////////////////////////////////////////////////////
    %Autosave code starts here
    if str2double(get(handles.record_time_increment,'string'))>60
        %//////////////////////////////////////////////////////////////////////////
        %Write out chi values, f0, and gamma0 into spectra file
        disp('Saving Data...');
        set(handles.status,'string','Status: Saving data...');
        drawnow;
        reference=char(get(handles.reference_time,'string'),get(handles.wait_time,'string')...
            ,get(handles.num_datapoints,'string'),get(handles.record_time_increment,'string'));%records reference time 
        fg_values.reference=reference;
        spectra.reference=reference;
        if get(handles.dynamic_fit,'value')==1
            fg_values.abs_freq=handles.din.FG_frequency;%save f0 and gamma0 fit data to fg_values.mat
            fg_values.freq_shift=handles.din.FG_freq_shifts;
            fg_values.freq_shift_ref=[handles.din.ref_freq;handles.din.ref_diss];
            fg_values.chisq_values=handles.din.chi_sqr_value;
            disp('Data saved!');
        end%if get(handles.dynamic_fit,'value')==1
        set(handles.status,'string','Status: Data saved! Ready...');
        %//////////////////////////////////////////////////////////////////////////
        %Update handles structure
        for dum=1:2:11
            name=['X',num2str(dum)];
            prev_data=get(handles.(name),'userdata');
            if isempty(prev_data)~=1
                handles.din.(['G_prev',num2str(dum)])=prev_data(1,:);
                handles.din.(['B_prev',num2str(dum)])=prev_data(2,:);
            end%if isempty(prev_data)~=1
        end%for dum=1:2:11
        handles.din.n=n;
        if get(handles.email_notification,'userdata')==1&&mod(n,round(3600/str2double(get(handles.record_time_increment,'string'))))==0
            try
                email_send(handles,['Update notification sent by QCM MATLAB Program.']);
                clc;
            catch
                set(handles.email_notification,'userdata',0);
            end%try
        end%if get(handles.email_notification,'userdata')==1
    elseif mod(n,50)==0
        %//////////////////////////////////////////////////////////////////////////
        %Write out chi values, f0, and gamma0 into spectra file
        disp('Saving Data...');
        set(handles.status,'string','Status: Saving data...');
        drawnow;
        reference=char(get(handles.reference_time,'string'),get(handles.wait_time,'string')...
            ,get(handles.num_datapoints,'string'),get(handles.record_time_increment,'string'));%records reference time 
        fg_values.reference=reference;
        spectra.reference=reference;
        if get(handles.dynamic_fit,'value')==1
            fg_values.abs_freq=handles.din.FG_frequency;%save f0 and gamma0 fit data to fg_values.mat
            fg_values.freq_shift=handles.din.FG_freq_shifts;
            fg_values.freq_shift_ref=[handles.din.ref_freq;handles.din.ref_diss];
            fg_values.chisq_values=handles.din.chi_sqr_value;
            disp('Data saved!');
        end%if get(handles.dynamic_fit,'value')==1
        set(handles.status,'string','Status: Data saved! Ready...');
        %//////////////////////////////////////////////////////////////////////////
        %Update handles structure
        for dum=1:2:11
            name=['X',num2str(dum)];
            prev_data=get(handles.(name),'userdata');
            if isempty(prev_data)~=1
                handles.din.(['G_prev',num2str(dum)])=prev_data(1,:);
                handles.din.(['B_prev',num2str(dum)])=prev_data(2,:);
            end%if isempty(prev_data)~=1
        end%for dum=1:2:11
        handles.din.n=n;
        if mod(n,200)==0&&get(handles.email_notification,'userdata')==1
            try
                email_send(handles,['Update notification sent by QCM MATLAB Program.']);
                clc;
            catch
                set(handles.email_notification,'userdata',0);
            end%try
        end%if mod(n,200)==0
    end%if str2double(get(handles.record_time_increment,'string'))>20
    %//////////////////////////////////////////////////////////////////////////
    if str2double(get(handles.record_time_increment,'string'))-toc>.1
        if str2double(get(handles.record_time_increment,'string'))-toc>5
            hp=waitbar(0,'Pausing before next scan...');
            set(hp,'closerequestfcn',{@pause_func,handles});
            stop1=str2double(get(handles.record_time_increment,'string'))-toc;
            for dum5=0:.1:stop1
                if get(handles.start,'value')==1
                    pause(.1)
                    waitbar(dum5/stop1,hp,['Pausing before next scan...',...
                        num2str(stop1-dum5),'s left']);
                else
                    try
                        delete(hp);
                    catch
                    end
                end%if get(handles.start,'value')==1
            end%for dum5=0:.8:str2double(get(handles.record_time_increment,'string'))   
            pause(mod(str2double(get(handles.record_time_increment,'string')),.8))
            try
                waitbar(1,hp,['Pausing before next scan...0s left']);
                delete(hp)
            catch
            end%try
        else
            stop1=str2double(get(handles.record_time_increment,'string'))-toc;
            for dum5=0:.1:stop1
                if get(handles.start,'value')==1
                    pause(.1)
                else
                end%if get(handles.start,'value')==1
            end%for dum5=0:.8:str2double(get(handles.record_time_increment,'string'))   
            pause(mod(str2double(get(handles.record_time_increment,'string')),.8))
        end%if str2double(get(handles.record_time_increment,'string'))-toc>.1
    end%if str2double(get(handles.record_time_increment,'string'))-toc>0.1
    %//////////////////////////////////////////////////////////////////////////
end%while get(handles.start,'value')==1
%//////////////////////////////////////////////////////////////////////////
%Write out chi values, f0, and gamma0 into spectra file
disp('Saving Data...');
set(handles.status,'string','Status: Saving data...');
drawnow;
reference=char(get(handles.reference_time,'string'),get(handles.wait_time,'string')...
    ,get(handles.num_datapoints,'string'),get(handles.record_time_increment,'string'));%records reference time 
fg_values.reference=reference;
spectra.reference=reference;
if get(handles.dynamic_fit,'value')==1
    fg_values.abs_freq=handles.din.FG_frequency;%save f0 and gamma0 fit data to fg_values.mat
    fg_values.freq_shift=handles.din.FG_freq_shifts;
    fg_values.freq_shift_ref=[handles.din.ref_freq;handles.din.ref_diss];
    fg_values.chisq_values=handles.din.chi_sqr_value;
    disp('Data saved!');
    set(handles.status,'string','Status: Data saved! Ready...');
else
    set(handles.status,'string','Status: Data saved! Ready...');
end%if get(handles.dynamic_fit,'value')==1
%//////////////////////////////////////////////////////////////////////////
%Update handles structure
for dum=1:2:11
    name=['X',num2str(dum)];
    prev_data=get(handles.(name),'userdata');
    if isempty(prev_data)~=1
        handles.din.(['G_prev',num2str(dum)])=prev_data(1,:);
        handles.din.(['B_prev',num2str(dum)])=prev_data(2,:);
    end%if isempty(prev_data)~=1
end%for dum=1:2:11
set(handles.status,'string','Status: Data saved! Ready...');
disp('Data saved! Ready...');
handles.din.n=n;
save_settings_Callback(handles.save_settings, 1, handles);
%//////////////////////////////////////////////////////////////////////////
%Send email notifications
try
    email_send(handles,['Update notification sent by QCM MATLAB Program.']);
    clc;
catch
    set(handles.email_notification,'userdata',0);
end%try
%//////////////////////////////////////////////////////////////////////////
%restore the disable features
set(handles.peak_centering,'visible','on');%display the button
set(handles.debug,'visible','on');%display the button
set(handles.clear_datapoints,'visible','on');%display the button
set(handles.uipanel1,'visible','on');%display uipanel1
set(handles.reset,'visible','on');
diary off;
pause on;
guidata(hObject, handles);

function pause_func(~,~,handles)
set(handles.start,'value',0);
start_Callback(handles.start, 1, handles);

function harm_tot=find_num_harms(handles)
harm_tot=[];
for dum=1:1:6
    harmname=['harm',num2str(handles.din.avail_harms(dum))];
    if get(handles.(harmname),'value')==1
        harm_tot=[harm_tot;handles.din.avail_harms(dum)];
    end%if get(handles.(harmname),'value')==1
end%for dum=1:1:6

% --- Executes on button press in maintain_myVNA.
function maintain_myVNA_Callback(hObject, eventdata, handles)
harm_tot=find_num_harms(handles);
for dum=1:length(harm_tot)
    write_settings(handles,harm_tot(dum));
end%for dum=1:length(harm_tot)
set(handles.status,'string','Status: Settings.txt file succesfully refreshed! Ready...');
disp('Settings.txt file sucessfully refreshed! Ready...');

% --- Executes on button press in set_settings.
function set_settings_Callback(~, ~, handles)
%find active harmonics
harm_tot=find_num_harms(handles);
for dum=1:length(harm_tot)
    write_settings(handles,harm_tot(dum))
end%for dum=1:size(harm_tot,1)

function write_settings(handles,harm_num)
% This if statement writes out the setting.txt file for the selected harmonic harmonic
% (settings01.txt, settings03.txt, etc.)
if harm_num<11
    filename=['AccessMyVNAv0.7\\release\settings0',num2str(harm_num),'.txt'];
else
    filename=['AccessMyVNAv0.7\release\settings',num2str(harm_num),'.txt'];
end%if harm_num<11
fileID=fopen(filename,'w');%write settings value into the settings.txt file
harmname=['harm',num2str(harm_num)];
startname=['start_f',num2str(harm_num)];
endname=['end_f',num2str(harm_num)];
num_pts=get(handles.num_datapoints,'userdata');
if get(handles.(harmname),'value')==1
    fprintf(fileID,'%10.12f\r\n',str2double(get(handles.(startname),'string')));%write start frequency of <dum> harmonic
    fprintf(fileID,'%10.12f\r\n',str2double(get(handles.(endname),'string')));%write out end frequency of <dum> harmonic
    fprintf(fileID,'%10.12f\r\n',handles.din.freq_range((harm_num+1)./2,1));%write out lowerbound of frequency range for the harmonic
    fprintf(fileID,'%10.12f\r\n',handles.din.freq_range((harm_num+1)./2,2));%write out upperbound of frequency range for the harmonic
    fprintf(fileID,'%i\r\n',num_pts(harm_num,1));%<--------------------------
end%if get(handles.(harmname),'value')==1
fclose(fileID);
%write out the settings.txt
fileID1=fopen('AccessMyVNAv0.7\release\settings.txt','w');
fprintf(fileID1,'%i\r\n',get(handles.maintain_myVNA,'value'));%write the toggle state of the maintain)myVNA radio dial
fprintf(fileID1,'%i\r\n',str2double(get(handles.wait_time,'string')));%writes the wait time between measurements
% fprintf(fileID1,'%i\r\n',str2double(get(handles.num_datapoints,'string')));%writes out the number of datapoints to collect between the start and end frequencies (WILL NOT WORK IN VERSION 1.0c and above!)
numberofharms=size(find_num_harms(handles),1);%finds the total number of harmonics
fprintf(fileID1,'%i\r\n',numberofharms);%write out the total number of harmonics that are active
fprintf(fileID1,'%i\r\n',find_num_harms(handles));%write the value of the harmonics
fclose(fileID1);
    
%this function obtains the scan data taken from the VB C++ AccessMyVNAv0.7 program
function [freq,conductance,susceptance,handles]=read_scan(handles)
%csvread(0 function may or may not be faster....
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
        num_pts=get(handles.num_datapoints,'userdata');
        if size(raw,1)==num_pts(handles.din.harmonic,1)*2
            conductance=1e3.*raw(1:num_pts(handles.din.harmonic,1));
            susceptance=1e3.*raw((num_pts(handles.din.harmonic,1)+1):(num_pts(handles.din.harmonic,1)*2));
            freq=[start1:(end1-start1)/num_pts(handles.din.harmonic,1):end1-(end1-start1)/num_pts(handles.din.harmonic,1)]';
            assignin('base','freq',freq);%output values in the "base" or global workspace
            assignin('base','conductance',conductance);
            assignin('base','susceptance',susceptance);
            flag=1;
            if handles.din.error_count>1
                set(handles.status,'string',['Status: Scan successful. Number of errors encountered: ',num2str(handles.din.error_count-1)]);
            end%if handles.din.error>1
        else
            disp(['Size of the raw output file is ',num2str(size(raw,1))])            
            disp('ERROR: SCAN WAS NOT COMPLETED');
            handles.din.error_log(handles.din.error_count,1)={[datestr(clock),'  ERROR: SCAN WAS NOT COMPLETED (read_scan function)']};
            if get(handles.start,'value')==1%attempt to correct the number of errors
                handles.din.error_log(handles.din.error_count,1)={[datestr(clock),'  Attempting to correct problem...']};
                set(handles.status,'string',['Status: ERROR! Number of errors: ',num2str(handles.din.error_count),'; Attempting to correct problem...']);            
                set(handles.num_pts(handles.din.harmonic,1),'string',size(raw,1)/2);
                pause(1);
            else
                write_settings(handles,handles.din.harmonic);
                pause(2);
            end%if get(handles.start,'value')==1        
            handles.din.error_count=handles.din.error_count+1;
            assignin('base','error_log',handles.din.error_log);
            flag=0;
            if handles.din.error_count>=100
            keyboard
            end%if handles.din.error_count>=100
        end%if size(raw,1)==str2double(get(handles.num_datapoints,'string'))*3
        fclose(fid1);%close datafiles     
    catch
        disp('ERROR: INVALID FILE IDENTIFIER. USE FOPEN TO GENERATE A VALID FILE IDENTIFIER');
        handles.din.error_log(handles.din.error_count,1)={[datestr(clock),'  ERROR: INVALID FILE IDENTIFIER. USE FOPEN TO GENERATE A VALID FILE IDENTIFIER']};
        set(handles.status,'string',['Status: ERROR! Number of errors: ',num2str(handles.din.error_count),'; Attempting to correct problem...']);        
        handles.din.error_count=handles.din.error_count+1;
        assignin('base','fid1',fid1);
        assignin('base','error_log',handles.din.error_log);
        flag=0;
        if handles.din.error_count>=100
            keyboard
        end%if handles.din.error_count>=100
    end%try
end%while flag==0

function refreshing(handles,harm,flag)
refresh_name=['refreshing',num2str(harm)];

if flag==1
    set(handles.(refresh_name),'visible','on');
else
    set(handles.(refresh_name),'visible','off');
end %if flag==1

% --- Executes on button press in harm1.
function harm1_Callback(~,~,handles)
set(handles.raw_fig,'userdata',1+get(handles.raw_fig,'userdata'));
% --- Executes on button press in harm3.
function harm3_Callback(~,~,handles)
set(handles.raw_fig,'userdata',3+get(handles.raw_fig,'userdata'));
% --- Executes on button press in harm5.
function harm5_Callback(~,~,handles)
set(handles.raw_fig,'userdata',5+get(handles.raw_fig,'userdata'));
% --- Executes on button press in harm7.
function harm7_Callback(~,~,handles)
set(handles.raw_fig,'userdata',7+get(handles.raw_fig,'userdata'));
% --- Executes on button press in harm9.
function harm9_Callback(~,~,handles)
set(handles.raw_fig,'userdata',9+get(handles.raw_fig,'userdata'));
% --- Executes on button press in harm11.
function harm11_Callback(~,~,handles)
set(handles.raw_fig,'userdata',11+get(handles.raw_fig,'userdata'));


%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
%this block of code deals with checking whether or not the frequency range
%set by the user is valid. If not, it will revert back to the set default
%min and max freq. of the harmonic.

%FIRST HARMONIC
function start_f1_Callback(~, ~, handles)
check_freq_range(1, handles.din.freq_range(1,1), handles.din.freq_range(1,2), handles);
function end_f1_Callback(~, ~, handles)
check_freq_range(1, handles.din.freq_range(1,1), handles.din.freq_range(1,2), handles);

%THIRD HARMONIC
function start_f3_Callback(~, ~, handles)
check_freq_range(3, handles.din.freq_range(2,1), handles.din.freq_range(2,2), handles);
% write_settings(handles,3);
% --- Executes during object creation, after setting all properties.
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
% --- Executes during object creation, after setting all properties.

%this function does the actual check range of the frequencies
function check_freq_range(harm, min_range, max_range, handles)
startname=['start_f',num2str(harm)];
endname=['end_f',num2str(harm)];
%Check start frequency range
if str2num(get(handles.(startname),'string'))<=min_range||str2num(get(handles.(startname),'string'))>=max_range
    set(handles.status,'string',...
        ['Status: ERROR: The frequency range for harmonic number ' num2str(harm),' needs to be between ',...
        num2str(min_range),' to ',num2str(max_range),' MHz! Ready...']);
    set(handles.(startname),'string',min_range+.9);
end% str2num(get(handles.(startname),'string'))<min_range||str2num(get(handles.(startname),'string'))>max_range
if str2num(get(handles.(startname),'string'))>=str2num(get(handles.(endname),'string'))
    if str2num(get(handles.(startname),'string'))==str2num(get(handles.(endname),'string'))
        set(handles.status,'string','The start frequency cannot be the same as the end frequency! Ready...');        
        set(handles.(startname),'string',min_range+.9);
        set(handles.(endname),'string',max_range-.9);
    else
        set(handles.status,'string','Status: ERROR: The start frequency is greater than the end frequency! Ready...');
        set(handles.(startname),'string',min_range+.9);
    end%str2num(get(handles.(startname),'string'))==min_range
end%str2num(get(handles.(startname),'string'))>=str2num(get(handles.(endname),'string'))
%Check end frequency range
if str2num(get(handles.(endname),'string'))<=min_range||str2num(get(handles.(endname),'string'))>=max_range
    set(handles.status,'string',...
        ['Status: ERROR: The frequency range for harmonic number ' num2str(harm),' needs to be between ',...
        num2str(min_range),' to ',num2str(max_range),' MHz! Ready...']);
    set(handles.(endname),'string',max_range-.9);
end% str2num(get(handles.(startname),'string'))<min_range||str2num(get(handles.(startname),'string'))>max_range
if str2num(get(handles.(endname),'string'))<=str2num(get(handles.(startname),'string'))
    set(handles.status,'string','Status: ERROR: The end frequency is less than the start frequency! Ready...');
    if str2num(get(handles.(startname),'string'))==max_range
        set(handles.status,'string','The start frequency cannot be the same as the end frequency! Ready...');
        set(handles.(startname),'string',min_range+.9);
        set(handles.(endname),'string',max_range-.9);        
    else
        set(handles.(endname),'string',max_range-.9);
    end%str2num(get(handles.(startname),'string'))==min_range
end%str2num(get(handles.(startname),'string'))>=str2num(get(handles.(endname),'string'))
%END OF FREQUENCY RANGE CHECK\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


% --- Executes on button press in set_reference_time.
function set_reference_time_Callback(~, ~, handles)
if get(handles.set_reference_time,'value')==1                        
    set(handles.reference_time,'string',datestr(clock,'yy:mm:dd:HH:MM:SS:FFF'));%automatically sets reference time when button is clicked
end



%Functions to fit a Lorentz curve to the spectra data BEGINS HERE-----------
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
function [G_fit,B_fit,G_l_sq,B_l_sq,combine_spectra,G_parameters,B_parameters,handles,I]=Lorentzian_dynamic_fit(handles,freq,conductance,susceptance,combine_spectra)
phi=0;%Assume rotation angle is 0
offset=0;%Assume offset value is 0
factor_range_fit=handles.din.fit_factor_range;
switch get(handles.(['fit',num2str(handles.din.harmonic)]),'userdata')
    case 1%Guess value based on max conductance
        [peak_detect,index]=findpeaks(conductance,'sortstr','descend');
        Gmax=peak_detect(1);%find peak of curve
        f0=freq(index(1));%finds freq at which Gmax happens
        halfg=(Gmax-min(conductance))./2+min(conductance);%half of the Gmax
        halfg_freq=freq(find(abs(halfg-conductance)==min(abs((halfg-conductance))),1));
        gamma0=abs(halfg_freq-f0);%Guess for gamma, HMHW of peak
        p=[f0 gamma0 phi Gmax offset];      
        I=find(freq>=(f0-gamma0*factor_range_fit)&freq<=(gamma0*factor_range_fit+f0)); 
        try
        [G_fit,G_residual,G_parameters]=fit_spectra(p,freq,conductance,I);
        %chi-squared calculation
        G_l_sq=(G_residual.^2)./((str2double(get(handles.num_datapoints,'string'))-1));
        if get(handles.fit_B_radio,'value')==1
            [B_fit,B_residual,B_parameters]=fit_spectra_sus(p,freq,susceptance,I);
            B_l_sq=(B_residual.^2)./((str2double(get(handles.num_datapoints,'string'))-1));
        else
            B_fit=NaN(size(G_fit,1),size(G_fit,2));
            B_l_sq=B_fit;
            B_parameters=[NaN NaN NaN NaN NaN];
        end%if get(handles.fit_B_radio,'value')==1
        combine_spectra=[freq,conductance,susceptance,G_fit,B_fit,G_l_sq,B_l_sq];%put everything in one variable
        catch% tryGuess values based on the Derivative of the Fit
            disp('Fitting based on the Gmax guess  failed!!');
            disp('Attempting to use derivative values to fit...');
            modulus=sqrt((diff(conductance)).^2+(diff(susceptance)).^2);
            freq_mod=freq(1:end-1)+diff(freq)./2;
            [peak_detect,index]=findpeaks(modulus,'sortstr','descend');
            modulus_max=peak_detect(1);%find peak of curve
            f0=freq_mod(index(1));%finds freq at which Gmax happens
            halfg=(modulus_max-min(modulus))./2+min(modulus);%half of the Gmax
            halfg_freq=freq_mod(find(abs(halfg-modulus)==min(abs((halfg-modulus))),1));
            gamma0=abs(halfg_freq-f0);%Guess for gamma, HMHW of peak
            phi=asind(conductance(1)/(sqrt((conductance(1))^2+(susceptance(1))^2)));
            p=[f0 gamma0 phi modulus_max offset];
            [~,~,test]=fit_spectra(p,freq_mod,modulus);
            try% tryGuess values based on the Derivative of the Fit
                [G_fit,G_residual,G_parameters]=fit_spectra([test(1) test(2) p(3:4) mean([conductance(1) conductance(end)])],freq,conductance,I);
                G_fit=lfun4c(G_parameters,freq);
                %chi-squared calculation
                G_l_sq=(G_residual.^2)./((str2double(get(handles.num_datapoints,'string'))-1));
            if get(handles.fit_B_radio,'value')==1
                [B_fit,B_residual,B_parameters]=fit_spectra_sus([test(1) test(2) p(3:4) mean([susceptance(1) susceptance(end)])],freq,susceptance,I);
                B_fit=lfun4s(B_parameters,freq);
                B_l_sq=(B_residual.^2)./((str2double(get(handles.num_datapoints,'string'))-1));
            else
                B_fit=NaN(size(G_fit,1),size(G_fit,2));
                B_l_sq=B_fit;
                B_parameters=[NaN NaN NaN NaN NaN];
            end%if get(handles.fit_B_radio,'value')==1
            combine_spectra=[freq,conductance,susceptance,G_fit,B_fit,G_l_sq,B_l_sq];%put everything in one variable
            disp('Gmax guess values suceeded!');
            catch
                disp('Fit failed!');
                G_fit=nan(size(freq,1),size(freq,2));
                B_fit=nan(size(freq,1),size(freq,2));
                G_parameters=nan(1,5);
                B_parameters=nan(1,5);
                G_l_sq=G_fit;
                B_l_sq=B_fit;
            end%try
        end%try
    case 2  %Guess values based on the Derivative of the Fit
        modulus=sqrt((diff(conductance)).^2+(diff(susceptance)).^2);
        freq_mod=freq(1:end-1)+diff(freq)./2;
        [peak_detect,index]=findpeaks(modulus,'sortstr','descend');
        modulus_max=peak_detect(1);%find peak of curve
        f0=freq_mod(index(1));%finds freq at which Gmax happens
        halfg=(modulus_max-min(modulus))./2+min(modulus);%half of the Gmax
        halfg_freq=freq_mod(find(abs(halfg-modulus)==min(abs((halfg-modulus))),1));
        gamma0=abs(halfg_freq-f0);%Guess for gamma, HMHW of peak
        phi=asind(conductance(1)/(sqrt((conductance(1))^2+(susceptance(1))^2)));
        p=[f0 gamma0 phi modulus_max offset];
        I=find(freq_mod>=(f0-gamma0*factor_range_fit)&freq_mod<=(gamma0*factor_range_fit+f0)); 
        [~,~,test]=fit_spectra(p,freq_mod,modulus,I);             
        try
        [G_fit,G_residual,G_parameters]=fit_spectra([test(1) test(2) p(3:4) mean([conductance(1) conductance(end)])],freq,conductance,I);
        G_fit=lfun4c(G_parameters,freq);
        %chi-squared calculation
        G_l_sq=(G_residual.^2)./((str2double(get(handles.num_datapoints,'string'))-1));
        if get(handles.fit_B_radio,'value')==1
            [B_fit,B_residual,B_parameters]=fit_spectra_sus([test(1) test(2) p(3:4) mean([susceptance(1) susceptance(end)])],freq,susceptance,I);
            B_fit=lfun4s(B_parameters,freq);
            B_l_sq=(B_residual.^2)./((str2double(get(handles.num_datapoints,'string'))-1));
        else
            B_fit=NaN(size(G_fit,1),size(G_fit,2));
            B_l_sq=B_fit;
            B_parameters=[NaN NaN NaN NaN NaN];
        end%if get(handles.fit_B_radio,'value')==1
        combine_spectra=[freq,conductance,susceptance,G_fit,B_fit,G_l_sq,B_l_sq];%put everything in one variable
        catch%try GMAx as guess values
            disp('Fitting based on the derivative failed!!');
            disp('Attempting to use Gmax guess values to fit...');
            [peak_detect,index]=findpeaks(conductance,'sortstr','descend');
            Gmax=peak_detect(1);%find peak of curve
            f0=freq(index(1));%finds freq at which Gmax happens
            halfg=Gmax./2;%half of the Gmax
            halfg_freq=freq(find(abs(halfg-conductance)==min(abs((halfg-conductance))),1));
            gamma0=abs(halfg_freq-f0);%Guess for gamma, HMHW of peak
            p=[f0 gamma0 phi Gmax offset];                
            try
                [G_fit,G_residual,G_parameters]=fit_spectra(p,freq,conductance,I);
                %chi-squared calculation
                G_l_sq=(G_residual.^2)./((str2double(get(handles.num_datapoints,'string'))-1));
            if get(handles.fit_B_radio,'value')==1
                [B_fit,B_residual,B_parameters]=fit_spectra_sus(p,freq,susceptance,I);
                B_l_sq=(B_residual.^2)./((str2double(get(handles.num_datapoints,'string'))-1));
            else
                B_fit=NaN(size(G_fit,1),size(G_fit,2));
                B_l_sq=B_fit;
                B_parameters=[NaN NaN NaN NaN NaN];
            end%if get(handles.fit_B_radio,'value')==1
            combine_spectra=[freq,conductance,susceptance,G_fit,B_fit,G_l_sq,B_l_sq];%put everything in one variable
            disp('Gmax guess values suceeded!');
            catch
                disp('Fit failed!');
                G_fit=nan(size(freq,1),size(freq,2));
                B_fit=nan(size(freq,1),size(freq,2));
                G_parameters=nan(1,5);
                B_parameters=nan(1,5);
                G_l_sq=G_fit;
                B_l_sq=B_fit;
            end%try            
        end%try           
    case 3%Guess value base on the previous fit values
        if isempty(get(handles.(['X',num2str(handles.din.harmonic)]),'userdata'))~=1&&sum(sum(isnan(get(handles.(['X',num2str(handles.din.harmonic)]),'userdata'))))==0
            disp('Previous guess parameters found.');
            prev_par=get(handles.(['X',num2str(handles.din.harmonic)]),'userdata');
            G_prev=prev_par(1,:);
            B_prev=prev_par(2,:);
            I=find(freq>=(G_prev(1)-G_prev(2)*factor_range_fit)&freq<=(G_prev(2)*factor_range_fit+G_prev(1))); 
            [G_fit,G_residual,G_parameters]=fit_spectra(G_prev,freq,conductance,I);
            %chi-squared calculation
            G_l_sq=(G_residual.^2)./((str2double(get(handles.num_datapoints,'string'))-1));            
            if get(handles.fit_B_radio,'value')==1
                [B_fit,B_residual,B_parameters]=fit_spectra_sus(B_prev,freq,susceptance,I);
                B_l_sq=(B_residual.^2)./((str2double(get(handles.num_datapoints,'string'))-1));%chi-squared calculation
            else
                B_fit=NaN(size(G_fit,1),size(G_fit,2));
                B_l_sq=B_fit;
                B_parameters=[NaN NaN NaN NaN NaN];
            end%if get(handles.fit_B_radio,'value')==1
            combine_spectra=[freq,conductance,susceptance,G_fit,B_fit,G_l_sq,B_l_sq];%put everything in one variable
        else%if not try to fit the data by choosing guess values from the derivative of the polar plot
            disp('Previous guess values not found. Guess values will be chosen from the derivative of the polar plot');
            modulus=sqrt((diff(conductance)).^2+(diff(susceptance)).^2);
            freq_mod=freq(1:end-1)+diff(freq)./2;
            [peak_detect,index]=findpeaks(modulus,'sortstr','descend');
            modulus_max=peak_detect(1);%find peak of curve
            f0=freq_mod(index(1));%finds freq at which Gmax happens
            halfg=modulus_max./2;%half of the Gmax
            halfg_freq=freq_mod(find(abs(halfg-modulus)==min(abs((halfg-modulus))),1));
            gamma0=abs(halfg_freq-f0);%Guess for gamma, HMHW of peak
            phi=asind(conductance(1)/(sqrt((conductance(1))^2+(susceptance(1))^2)));
            p=[f0 gamma0 phi modulus_max offset];
            I=find(freq_mod>=(f0-gamma0*factor_range_fit)&freq_mod<=(gamma0*factor_range_fit+f0)); 
            [~,~,test]=fit_spectra(p,freq_mod,modulus,I);
            try
                [G_fit,G_residual,G_parameters]=fit_spectra([test(1) test(2) p(3:4) mean([conductance(1) conductance(end)])],freq,conductance,I);
                %chi-squared calculation
                G_l_sq=(G_residual.^2)./((str2double(get(handles.num_datapoints,'string'))-1));
                if get(handles.fit_B_radio,'value')==1
                    [B_fit,B_residual,B_parameters]=fit_spectra_sus([test(1) test(2) p(3:4) mean([susceptance(1) susceptance(end)])],freq,susceptance,I);
                    B_l_sq=(B_residual.^2)./((str2double(get(handles.num_datapoints,'string'))-1));%chi-squared calculation
                else
                    B_fit=NaN(size(G_fit,1),size(G_fit,2));
                    B_l_sq=B_fit;
                    B_parameters=[NaN NaN NaN NaN NaN];
                end%if get(handles.fit_B_radio,'value')==1
                combine_spectra=[freq,conductance,susceptance,G_fit,B_fit,G_l_sq,B_l_sq];%put everything in one variable
            catch
                disp('Fit failed!');
                G_fit=nan(size(freq,1),size(freq,2));
                B_fit=nan(size(freq,1),size(freq,2));
                G_parameters=nan(1,5);
                B_parameters=nan(1,5);
                G_l_sq=G_fit;
                B_l_sq=B_fit;
            end%try             
        end%if isfield(handles.din,'G_prev')
end%switch 
set(handles.(['X',num2str(handles.din.harmonic)]),'userdata',[G_parameters; B_parameters]);
disp(['G_l_sq: ',num2str(sum(G_l_sq))]);
disp(['B_l_sq: ',num2str(sum(B_l_sq))]);


function [fitted_y,residual,parameters]=fit_spectra(x0,freq_data,y_data,I,lb,ub)%fit spectra to conductance curve
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
if nargin==4
    lb=[0 0 -inf -Inf -Inf];
    ub=[Inf Inf 90 Inf Inf];
end%if nargin==3
options=optimset('display','off','tolfun',1e-10,'tolx',1e-10);
[parameters resnorm residual]=lsqcurvefit(@lfun4c,x0,freq_data(I),y_data(I),lb,ub,options);%use lsqcurvefit function to fit the spectra data to a Lorentz curve
fitted_y=lfun4c(parameters,freq_data);
residual=fitted_y-y_data;
disp('Conductance fitted parameters:');
disp(parameters');

function [fitted_y,residual,parameters]=fit_spectra_sus(x0,freq_data,susceptance_data,I,lb,ub)%fit spectra to susceptance curve
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
if nargin==4
    lb=[0 0 -90 -inf -Inf];
    ub=[Inf Inf 90 Inf Inf];
end%if nargin==3
options=optimset('display','off','tolfun',1e-10,'tolx',1e-10);
[parameters resnorm residual]=lsqcurvefit(@lfun4s,x0,freq_data(I),susceptance_data(I),lb,ub,options);%use lsqcurvefit function to fit the spectra data to a Lorentz curve
fitted_y=lfun4s(parameters,freq_data);
residual=fitted_y-susceptance_data;
disp('Susceptance fitted parameters:');
disp(parameters');

% --- Executes on button press in radio_chi.
function radio_chi_Callback(~, ~, handles)
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
end%if get(handles.fit_B_radio,'value')==1

function F_conductance = lfun4c(p,x)
%Order of parameters in p is as follows
%p(1): f0 maximum frequency
%p(2): gamma0 dissipation
%p(3): phi phse angle difference
%p(4): Gmax maximum conductance
%p(5): Offset value
F_conductance= p(4).*((((x.^2).*((2.*p(2)).^2))./(((((p(1)).^2)-(x.^2)).^2)+...
    ((x.^2).*((2.*p(2)).^2)))).*cosd(p(3))-((((p(1)).^2-x.^2)).*x.*(2.*p(2)))./...
    (((((p(1)).^2)-(x.^2)).^2)+((x.^2).*((2.*p(2)).^2))).*sind(p(3)))+p(5);

function F_susceptance = lfun4s(p,x)
%Order of parameters in p is as follows
%p(1): f0 maximum frequency
%p(2): gamma0 dissipation
%p(3): phi phase angle difference
%p(4): Gmax maximum conductance
%p(5): Offset value
F_susceptance= -p(4).*(-(((x.^2).*((2.*p(2)).^2))./(((((p(1)).^2)-(x.^2)).^2)+...
    ((x.^2).*((2.*p(2)).^2)))).*sind(p(3))-((((p(1)).^2-x.^2)).*x.*(2.*p(2)))./...
    (((((p(1)).^2)-(x.^2)).^2)+((x.^2).*((2.*p(2)).^2))).*cosd(p(3)))+p(5);


% --- Executes on button press in dynamic_fit.
function dynamic_fit_Callback(hObject, eventdata, handles)
if get(handles.dynamic_fit,'value')==0
    set(handles.fit_B_radio,'value',0);
end%if get(handles.dynamic_fit,'value')==0

% --- Executes on button press in fit_B_radio.
function fit_B_radio_Callback(hObject, eventdata, handles)
if get(handles.fit_B_radio,'value')==1%this ensures that the scans will do a lorentzian fit, otherwise there will be an error
    set(handles.dynamic_fit,'value',1);
end%if get(handles.fit_B_radio,'value')==1
    
%%Functions to fit a Lorentz curve to the spectra data ENDS HERE-----------
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


%PEAK CENTERING FUNCTIONS BEGINS HERE//////////////////////////////////////
%//////////////////////////////////////////////////////////////////////////
%//////////////////////////////////////////////////////////////////////////
% --- Executes on button press in peak_centering.
function peak_centering_Callback(hObject, ~, handles)
set_settings_Callback(1, 1, handles);%write out the settings files
set(handles.peak_centering,'userdata',[]);
%turn on peak center uipanel and turn off harm radio dial
set(handles.harm1,'visible','off');
set(handles.harm3,'visible','off');
set(handles.harm5,'visible','off');
set(handles.harm7,'visible','off');
set(handles.harm9,'visible','off');
set(handles.harm11,'visible','off');
set(handles.harmonics_text,'visible','off');
set(handles.peak_center,'visible','on');
set(handles.center1,'value',0);
set(handles.center3,'value',0);
set(handles.center5,'value',0);
set(handles.center7,'value',0);
set(handles.center9,'value',0);
set(handles.center11,'value',0);
if get(handles.peak_centering,'value')==1
    harm_tot=find_num_harms(handles);%find the total number of active harmonics from the harmonics panel (not the peak centering panel)
    set(handles.harmonics_text,'userdata',harm_tot);
    set(handles.peak_centering,'fontweight','bold','foregroundcolor','r');
    set(handles.status,'string','Status: Peak centering mode. Ready...');
else
    %revert active harmonics back to initial state
    %first turn off all harmonics
    for dum=1:2:11
        harm_name=['harm',num2str(dum)];
        set(handles.(harm_name),'value',0);
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
    set(handles.peak_centering,'userdata',[]);
    set(handles.harm1,'visible','on');
    set(handles.harm3,'visible','on');
    set(handles.harm5,'visible','on');
    set(handles.harm7,'visible','on');
    set(handles.harm9,'visible','on');
    set(handles.harm11,'visible','on');
    set(handles.harmonics_text,'visible','on');
    set(handles.peak_center,'visible','off');
    set(handles.center1,'value',0);
    set(handles.center3,'value',0);
    set(handles.center5,'value',0);
    set(handles.center7,'value',0);
    set(handles.center9,'value',0);
    set(handles.center11,'value',0);
    set(handles.peak_centering','fontweight','normal','foregroundcolor','k');
    set(handles.status,'string','Status: Ready...');
end%if get(handles.peak_centering,'value')==1
guidata(hObject, handles);

function center_peak_function(handles,harm,hObject)
try
    dum=1;
    initial_end=str2double(get(handles.(['end_f',num2str(harm(dum))]),'string'));
    initial_start=str2double(get(handles.(['start_f',num2str(harm(dum))]),'string'));
    f1=figure(1);
    freq_range=(initial_end-initial_start).*1e6;%calculate the initial frequency range of the harmonic
    [freq,~,~,handles]=read_scan(handles);
    p(1)=axes;
    p(2)=axes;
    set(f1,'units','normalized','position',[0.01 0.313 0.7 0.467],'toolbar','figure');%adjust location of the figure
    set(p(1),'units','normalized','position',[0.06 0.12 0.5 0.8],'fontsize',10,'buttondownfcn',{@refresh_button2,handles,p,harm});
    set(p(2),'units','normalized','position',[0.06 0.12 0.5 0.8],'fontsize',10,'buttondownfcn',{@refresh_button2,handles,p,harm},'color','none','yaxislocation','right');
    tbh=findall(f1,'type','uitoolbar');
    [fit_button,refresh]=my_buttons();  
    pth2=uipushtool(tbh,'cdata',refresh,'tooltipstring','Refresh raw spectra data',...
        'ClickedCallback',{@refresh_button,handles,p,harm,f1});
    span_panel=uipanel('title','     Span     ','fontweight','bold','position',[.63 .17 .35 .8],...
        'fontsize',10,'bordertype','line','titleposition','centertop','shadowcolor','k',...
        'foregroundcolor','b');
    set_span=uicontrol('parent',span_panel,'style','edit',...
        'unit','normalized','position',[.274 0.35 0.45 0.1],...
        'fontweight','bold','fontsize',10,'backgroundcolor',[1 1 1],...
        'string',(str2double(get(handles.(['end_f',num2str(harm(dum))]),'string'))-...
        str2double(get(handles.(['start_f',num2str(harm(dum))]),'string'))).*1e3);
    set(set_span,'callback',{@manual_set_span,handles,p,harm,set_span});
    increase_span_txt=uicontrol('parent',span_panel,'style','text',...
        'string','Increase span','unit','normalized','position',[0.1 0.88 0.35 0.1],...
        'fontweight','bold','fontsize',10);
    statistics_txt=uicontrol('parent',span_panel,'style','text',...
        'string','','units','normalized','position',[0.05 0.01 0.5 0.32],...
        'fontweight','bold','fontsize',8,'backgroundcolor',[1 1 1]);
    num_data_pts_txt=uicontrol('parent',span_panel,'style','text',...
        'string','# of data points','units','normalized','position',[0.6 0.22 0.4 0.1],...
        'fontweight','bold','fontsize',10);
    num_pts=get(handles.num_datapoints,'userdata');
    num_data_pts_edit=uicontrol('parent',span_panel,'style','edit',...
        'string',num_pts(handles.din.harmonic,1),'units','normalized','position',[0.6 0.13 0.4 0.1],...
        'fontweight','bold','fontsize',10,'backgroundcolor','w');
    set(num_data_pts_edit,'callback',{@store_num_data,handles,p,harm});
    pth1=uipushtool(tbh,'cdata',fit_button,'tooltipstring','Apply a Lorentzian fit',...
        'ClickedCallback',{@myL_fit,handles,p,harm,statistics_txt});
    increase_span_x50=uicontrol('parent',span_panel,'style','pushbutton',...
        'string','x50','unit','normalized','position',[0.1 0.78 0.35 0.1],...
        'fontweight','bold','fontsize',10);
    set(increase_span_x50,'callback',{@span_adjust,handles,p,harm,50,set_span});
    increase_span_x10=uicontrol('parent',span_panel,'style','pushbutton',...
        'string','x10','unit','normalized','position',[0.1 0.68 0.35 0.1],...
        'fontweight','bold','fontsize',10);
    set(increase_span_x10,'callback',{@span_adjust,handles,p,harm,10,set_span});
    increase_span_x5=uicontrol('parent',span_panel,'style','pushbutton',...
        'string','x5','unit','normalized','position',[0.1 0.58 0.35 0.1],...
        'fontweight','bold','fontsize',10);
    set(increase_span_x5,'callback',{@span_adjust,handles,p,harm,5,set_span});
    increase_span_x2=uicontrol('parent',span_panel','style','pushbutton',...
        'string','x2','unit','normalized','position',[0.1 0.48 0.35 0.1],...
        'fontweight','bold','fontsize',10);
    set(increase_span_x2,'callback',{@span_adjust,handles,p,harm,2,set_span});
    decrease_span_txt=uicontrol('parent',span_panel,'style','text',...
        'string','Decrease span','unit','normalized','position',[0.55 0.88 0.35 0.1],...
        'fontweight','bold','fontsize',10);            
    decrease_span_d50=uicontrol('parent',span_panel,'style','pushbutton',...
        'string','/50','unit','normalized','position',[0.55 0.78 0.35 0.1],...
        'fontweight','bold','fontsize',10);
    set(decrease_span_d50,'callback',{@span_adjust,handles,p,harm,1/50,set_span});
    decrease_span_d10=uicontrol('parent',span_panel,'style','pushbutton',...
        'string','/10','unit','normalized','position',[0.55 0.68 0.35 0.1],...
        'fontweight','bold','fontsize',10);
    set(decrease_span_d10,'callback',{@span_adjust,handles,p,harm,1/10,set_span});
    decrease_span_d5=uicontrol('parent',span_panel,'style','pushbutton',...
        'string','/5','unit','normalized','position',[0.55 0.58 0.35 0.1],...
        'fontweight','bold','fontsize',10);
    set(decrease_span_d5,'callback',{@span_adjust,handles,p,harm,1/5,set_span});
    decrease_span_d2=uicontrol('parent',span_panel,'style','pushbutton',...
        'string','/2','unit','normalized','position',[0.55 0.48 0.35 0.1],...
        'fontweight','bold','fontsize',10);
    set(decrease_span_d2,'callback',{@span_adjust,handles,p,harm,1/2,set_span});
    set_span_units=uicontrol('parent',span_panel,'style','text',...
        'unit','normalized','position',[.727 0.33 0.27 0.1],...
        'fontweight','bold','fontsize',10,'string','kHz','horizontalalignment','left');
    fix_span_radio=uicontrol('parent',f1,'style','radiobutton',...
        'unit','normalized','position',[.65 0.01 .1 .1],...
        'fontweight','bold','fontsize',10,'string','Fix span',...
        'horizontalalignment','left','tooltipstring','The span of the frequency range is fixed',...
        'value',0,'backgroundcolor',get(f1,'color'));
    fix_center_radio=uicontrol('parent',f1,'style','radiobutton',...
        'unit','normalized','position',[.75 0.01 .11 .1],...
        'fontweight','bold','fontsize',10,'string','Fix center',...
        'horizontalalignment','left','tooltipstring','The center of the frequency range is fixed',...
        'value',0,'backgroundcolor',get(f1,'color'));
    custom_peak_tracker=uicontrol('parent',f1,'style','radiobutton',...
        'unit','normalized','position',[.86 0.01 .1 .1],...
        'fontweight','bold','fontsize',10,'string','Custom',...
        'horizontalalignment','left','tooltipstring','Clicking this option will run a custom peak tracking algorithm',...
        'value',0,'backgroundcolor',get(f1,'color'));
    guess_values_options=uicontrol('parent',f1,'style','popupmenu',...
        'unit','normalized','position',[.65 0.05 0.3 0.1],...
        'fontweight','bold','fontsize',10,'string',[{'Gmax'};{'Derivative'};{'Previous values'}],...
        'horizontalalignment','left','tooltipstring','Choose guess values for curve fitting.',...
        'value',1);
    set(f1,'CloseRequestFcn',{@my_closereq,handles,freq,[fix_span_radio,fix_center_radio,custom_peak_tracker],harm,guess_values_options,f1});%create a figure with a special custom close request function
    set(fix_span_radio,'callback',{@peak_tracking_flag,handles,[fix_span_radio,fix_center_radio],harm,1});
    set(fix_center_radio,'callback',{@peak_tracking_flag,handles,[fix_span_radio,fix_center_radio],harm,1});
    set(custom_peak_tracker,'callback',{@custom_peak_track_flag,handles,[fix_span_radio,fix_center_radio,custom_peak_tracker],harm});
    set(guess_values_options,'callback',{@store_guess_options,handles,guess_values_options,harm});
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
    refresh_button(0,0,handles,p,harm);%refresh the spectra
    %customize the datacursor mode, the zoom mode, and the pan tool
    dcm_obj=datacursormode(f1);
    set(dcm_obj,'UpdateFcn',{@myupdatefcn,hObject, handles,set_span,p,harm})
    zoomh=zoom(f1);
    set(zoomh,'actionpostcallback',{@myzoomfcn,handles,set_span,p,harm});
    panh=pan;
    set(panh,'actionpostcallback',{@myzoomfcn,handles,set_span,p,harm});
    c_info=getCursorInfo(dcm_obj);
    zoom on;
catch
end%try
guidata(hObject, handles);


% --- Executes when selected object is changed in peak_center.
function peak_center_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in peak_center 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
flag=0;
current_handle=eventdata.NewValue;%get handle of current selected radial dial in peak centering panel
current_harm=get(current_handle,'userdata');
handles.din.harmonic=current_harm;%store current harmonic (from peak centering panel) in handles structure
%Turn off all active radio dials except for the harmonic that is being
%centered. This will improve the refresh rate of the raw conductance
%spectra  during the peak centering process
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
    flag=1;
end%if get(handles.start,'value',1)
handles.din.harmonic=current_harm;
center_peak_function(handles,current_harm,hObject);%center the peak of the selected harmonic fromthe peak centering panel
guidata(hObject, handles);

function output_txt = myupdatefcn(~,event_obj,~, handles,set_span,p,harm)
% This is the function that runs when datacursormode is employed. The
% output output-txt is what appears in the box.
%Determines output box--this is the usual function of datacursor, modified
%to know what the x axis actually is.
% datacursormode on
freq_range=str2double(get(set_span,'string'))*1e3;%frequency range in kHz
pos = get(event_obj,'Position');
output_txt = {['Frequency ',num2str(pos(1),5),' Hz'],...
    ['Y data: ',num2str(pos(2),5)]};
set(handles.peak_centering,'userdata',1);
center=pos(1);
new_start=(center-(freq_range)/2).*1e-6;
new_end=(center+(freq_range)/2).*1e-6;
disp(['Frequency range (MHz): ',num2str(new_start),' to ',num2str(new_end)]);
disp(['frequency span: ',num2str(freq_range)]);
set(handles.(['start_f',num2str(harm)]),'string',num2str(new_start,10));
set(handles.(['end_f',num2str(harm)]),'string',num2str(new_end,10));
datacursormode off;

function store_num_data(hObject,~,handles,p,harm)%store the number of datapoints to record for that particular harmonic
num_pts=get(handles.num_datapoints,'userdata');
num_pts(harm,1)=str2double(get(hObject,'string'));
set(handles.num_datapoints,'userdata',num_pts);
disp(['# of datapoints for harmonic ',num2str(harm),': ',num2str(num_pts(harm,1))]);
name=['num_pts',num2str(harm)];
set(handles.(name),'string',['# pts: ',num2str(num_pts(harm,1))]);


%this function that runs when the user exsits out of the
%peak_centering figure window
function my_closereq(~,~,handles,freq,radio_handles,harm,guess_values_options,f1)
peak_tracking_flag(0,0,handles,radio_handles,harm,2);
custom_peak_track_flag(0,0,handles,radio_handles,harm);
store_guess_options(0,0,handles,guess_values_options,harm);
if isempty(get(handles.peak_centering,'userdata'))
    set(handles.peak_centering,'userdata',[mean(freq),1]);
else
    set(handles.peak_centering,'userdata',[]);
end%if isempty(handles.peak_centering,'userdata')
datacursormode off
delete(f1)
for dum=1:2:11
    harm_name=['center',num2str(dum)];
    set(handles.(harm_name),'value',0);
end%for dum=1:2:11
try
    delete(figure(999));
end%try


%This function that runs when the user clicks on the "Fit"
%button in the figure toolbar of the peak_centering window
function myL_fit(~,~,handles,p,harm_tot,statistics_txt)
[freq,conductance,susceptance,handles]=read_scan(handles);%read the scanned data
combine_spectra=[freq,conductance,susceptance];
fit_B_radio_state=get(handles.fit_B_radio,'value');%save the sate of the handles.fit_b_radio radio dial
set(handles.fit_B_radio,'value',1);
[G_fit,B_fit,G_l_sq,B_l_sq,~,G_parameters,B_parameters,handles,I]=Lorentzian_dynamic_fit(handles,freq,conductance,susceptance,combine_spectra);%fit curve
ave_f0=mean([G_parameters(1) B_parameters(1)]);
ave_g0=mean([G_parameters(2) B_parameters(2)]);
%plot the raw data and the fitted data
cla(p(1));cla(p(2));
axes(p(1));
hold on;     
plot(freq,conductance,'bx-','markersize',10,'linewidth',2);
plot(freq(I),ones(size(I,1)).*min(conductance),'-','linewidth',2,'color',[0.82031 0.410156 0.11718]);
plot(freq,G_fit,'k-','linewidth',2);
plot(ave_f0,G_parameters(4)+G_parameters(5),'o','color',[0 0.5 0],'markerfacecolor',[0 0.5 0],'markersize',10);
plot([ave_f0+ave_g0 ave_f0-ave_g0],...
    [0.5*G_parameters(4)+G_parameters(5),0.5*G_parameters(4)+G_parameters(5)],'mo','markerfacecolor','m','markersize',10);   
axes(p(2));
plot(p(2),freq,susceptance,'rx-','markersize',10,'linewidth',2);hold on;
plot(p(2),freq,B_fit,'k-','linewidth',2);
set(get(p(1),'ylabel'),'string','Conductance (mS)','fontweight','bold','fontsize',12);
set(get(p(2),'ylabel'),'string','Susceptance (mS)','fontweight','bold','fontsize',12);
set(p(1),'box','off','color','none');
set(p(2),'box','off','color','w','yaxislocation','right','ycolor','r','position',get(p(1),'position'),...
    'xlim',get(p(1),'xlim'),'xtick',get(p(1),'xtick'));
axes(p(1));
xlabel(['Harmonic ',num2str(harm_tot),' Frequency (Hz)'],'fontsize',12,'fontweight','bold');
L=legend(p(1),['f_0: ',num2str(ave_f0),' Hz'],['\Gamma_0: ',num2str(ave_g0),' Hz'],'location','best');
set(L,'color','w');
linkaxes(p,'x');
drawnow;
%Calculate relevant statistics for the fit
G_l_sq=(sum(G_l_sq)*1e-3)/str2double(get(handles.num_datapoints,'string'));
B_l_sq=(sum(B_l_sq)*1e-3)/str2double(get(handles.num_datapoints,'string'));
G_r_sq=1-G_l_sq/(norm(conductance-mean(conductance))^2);
B_r_sq=1-B_l_sq/(norm(susceptance-mean(susceptance))^2);
G_stats=['Conductance:     Lsq: ',num2str(G_l_sq,3)];
B_stats=['Susceptance:     Lsq: ',num2str(B_l_sq,3)];
parameters1=['f0:     ',num2str(ave_f0,10),' Hz'];%f0
parameters2=['g0:     ',num2str(ave_g0,10), ' Hz'];%g0
parameters3=['Gmax:     ',num2str(mean([G_parameters(4),B_parameters(4)]),10),' mS'];%Gmax
parameters4=['phi:     ',num2str(mean([G_parameters(3),B_parameters(3)]),10),' degrees'];%phi
parameters5=['G_offset:     ',num2str(G_parameters(5),10),' mS'];%G_offset
parameters6=['B_offset:     ',num2str(B_parameters(5),10),' mS'];%B_offset
set(statistics_txt,'string',[{G_stats};{B_stats};{parameters1};{parameters2};...
    {parameters3};{parameters4};{parameters5};{parameters6}],'horizontalalignment','left');
%Create a polar plot that shows the quality of the fit for both the
%conductance and susceptance curves
figure(999);clf(figure(999));set(gcf,'numbertitle','off','units','normalized','position',[1-.3 0.313 .3 .37]);
plot(conductance,susceptance,'bx','linewidth',2,'markersize',6);hold on;
plot(G_fit,B_fit,'-','color',[0 0.5 0],'linewidth',2.5);
plot(G_fit(I),B_fit(I),'-','linewidth',2,'color',[0.82031 0.410156 0.11718]);
title('Polar plot of susceptance vs. conductance','fontweight','bold','fontsize',12);
xlabel('Conductance (mS)','fontsize',12,'fontweight','bold');
ylabel('Susceptance (mS)','fontsize',12,'fontweight','bold');
set(handles.fit_B_radio,'value',fit_B_radio_state);%resent the sate of the handles.fit_b_radio radio dial to original state

%this function that runs when the refresh button is pressed
%in the toolbar of the peak_centering figure window (this refreshes the raw
%conductance spectra)
function refresh_button(~,~,handles,p,harm,f1)
pause on;
cla(p(1));cla(p(2));
axes(p(1));
set(handles.text2,'userdata',0);
check_freq_range(handles.din.harmonic, handles.din.freq_range(0.5*(handles.din.harmonic+1),1), handles.din.freq_range(0.5*(handles.din.harmonic+1),2), handles);
write_settings(handles,harm);
hold off
txt=text('units','normalized','position',[.1 .9 1],'string','Refreshing...','color','r','edgecolor','r');
h=waitbar(0,'Refreshing spectra plot...');
set(h,'WindowStyle','modal');
set(h,'closerequestfcn',{@pause_func1,handles});
set(p(2),'visible','off');
for dum=0:.1:(str2double(get(handles.wait_time,'string'))/1000)*3
    clc;
    waitbar(dum/((str2double(get(handles.wait_time,'string'))/1000)*3),h,...
        ['Refreshing spectra plot...',num2str((str2double(get(handles.wait_time,'string'))/1000)*3-dum)]);
    pause(.1);
    [freq,conductance,susceptance,handles]=read_scan(handles);
    plot(p(1),freq,conductance,'bx-','markersize',10,'linewidth',2);
    set(p(1),'xlim',[min(freq) max(freq)]);
    if get(handles.text2,'userdata')==1
        break
    end% if get(handles.text2,'userdata')==1
end%for dum=0:.1:(str2double(get(handles.wait_time,'string'))/1000)*3
delete(h);
set(p(2),'visible','on');
[freq,conductance,susceptance,handles]=read_scan(handles);
plot(p(1),freq,conductance,'bx-','linewidth',2,'markersize',10);
axes(p(2));
plot(p(2),freq,susceptance,'rx-','linewidth',2,'markersize',10);
set(p(1),'box','off','xlim',[min(freq) max(freq)],'color','none','units','normalized','position',[0.06 0.12 0.5 0.8]);
set(p(2),'box','off','ycolor','r','xlim',get(p(1),'xlim'),'xtick',get(p(1),'xtick'),'yaxislocation','right','color','w','units','normalized','position',get(p(1),'position'));
get_ylim=get(p(1),'ylim');
set(p(1),'ylim',[get_ylim(1),1.01*get_ylim(2)]);
get_ylim=get(p(1),'ylim');
axes(p(1));
hold on;
set(p(1),'ylim',get_ylim,'buttondownfcn',{@refresh_button2,handles,p,harm});
xlabel('Frequency (Hz)','fontweight','bold','fontsize',12);
set(get(p(1),'ylabel'),'string','Conductance (mS)','fontweight','bold','fontsize',12);
set(get(p(2),'ylabel'),'string','Susceptance (mS)','fontweight','bold','fontsize',12);
linkaxes(p,'x');%link the axes

function pause_func1(~,~,handles)
try
    set(handles.text2,'userdata',1);
end
function refresh_button2(~,~,handles,p,harm)       
pause on
if get(handles.peak_centering,'userdata')==1
    refresh_button(0,0,handles,p,harm);
    set(handles.peak_centering,'userdata',0);
end

%         This function that increases or decreases the span of the raw
%         conductance spectra so that a larger range of frequency values is
%         measured.
function span_adjust(hObject,eventdata,handles,p,harm,factor,set_span)
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
refresh_button(0,0,handles,p,harm);
        
%this function will calculate what the current span of the axes is and
%update the set_span edit text box
function myzoomfcn(~,~,handles,set_span,p,harm)
current_span=get(p(1),'xlim');%extract out the start and end values of the frequency in the figure window
span_calc=abs(current_span(2)-current_span(1))*1e-3;%calculate the span of the figure window (kHz)
set(set_span,'string',num2str(span_calc,10));%display the span in kHz
set(handles.(['start_f',num2str(harm)]),'string',num2str(current_span(1)*1e-6,10));%adjust the start frequency value
set(handles.(['end_f',num2str(harm)]),'string',num2str(current_span(2)*1e-6,10));%adjust the end frequency value
check_freq_range(handles.din.harmonic, handles.din.freq_range(0.5*(handles.din.harmonic+1),1), handles.din.freq_range(0.5*(handles.din.harmonic+1),2), handles);
refresh_button(0,0,handles,p,harm);%refresh the graph by rescanning with the new end and start frequencies

function manual_set_span(~,~,handles,p,harm,set_span)
user_defined_span=str2double(get(set_span,'string'))*1e3;%extract the user defined span (Hz)
current_xlim=get(p(1),'xlim');%extract out the current start and end frequencies
current_center=.5*(current_xlim(1)+current_xlim(2));%calculate the current center
new_xlim=[current_center-user_defined_span/2,current_center+user_defined_span/2].*1e-6;%new start and end freq in MHz
set(handles.(['start_f',num2str(harm)]),'string',num2str(new_xlim(1),10));
set(handles.(['end_f',num2str(harm)]),'string',num2str(new_xlim(2),10));
check_freq_range(handles.din.harmonic, handles.din.freq_range(0.5*(handles.din.harmonic+1),1), handles.din.freq_range(0.5*(handles.din.harmonic+1),2), handles);
refresh_button(0,0,handles,p,harm);%refresh spectra

function peak_tracking_flag(~,~,handles,radio_handles,harm,flag)
harm_name=['peak_track',num2str(harm)];%determine which handle to extract information based on harmonic
peak_track=get(handles.(harm_name),'userdata');%extract out the userdata from the relevant handle
peak_track(1)=get(radio_handles(1),'value');%change the userdata based on the value of the fix span radio dial
peak_track(2)=get(radio_handles(2),'value');%change the userdata based on the value of the fix center radio dial
set(handles.(harm_name),'userdata',peak_track);%update the userdata of the handle
if peak_track(1)==1&&peak_track(2)==1&&flag==1
    warning1=warndlg('WARNING: Fixing both the span and the center can lead to systematic error!',...
        'Warning!');
    set(warning1,'color',[1 1 0]);
    set(handles.(harm_name),'string','Fixed span and fixed center');
end%    if peak_track(1)==1&&peak_track(2)==1
if peak_track(1)==1&&peak_track(2)==0
    set(handles.(harm_name),'string','Fixed span','value',peak_track);
elseif peak_track(1)==0&&peak_track(2)==1
    set(handles.(harm_name),'string','Fixed center','value',peak_track);
elseif peak_track(1)==0&&peak_track(2)==0
    set(handles.(harm_name),'string','Default peak tracking','value',peak_track);
end%if peak_track(1)==1&&peak_track(2)==0

function custom_peak_track_flag(~,~,handles,radio_handles,harm)
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

function store_guess_options(~,~,handles,guess_handle,harm)
fit_name=['fit',num2str(harm)];
guess_option=get(guess_handle,'value');
switch guess_option
    case 1
        set(handles.(fit_name),'string','Gmax','userdata',guess_option);
    case 2
        set(handles.(fit_name),'string','Derivative','userdata',guess_option);
    case 3
        set(handles.(fit_name),'string','Previous Fit','userdata',guess_option);
end%switch guess_option
set(handles.(fit_name),'userdata',guess_option);
%PEAK CENTERING FUNCTIONS ENDS HERE////////////////////////////////////////
%//////////////////////////////////////////////////////////////////////////
%//////////////////////////////////////////////////////////////////////////


% --- Executes on button press in cla_raw.
%This function clears all raw spectra
function cla_raw_Callback(hObject, ~, handles)
cla(handles.primaryaxes1);
cla(handles.primaryaxes2);
for dum=1:6
    chi_name=['X',num2str(dum*2-1)];
    axes_name=['axes',num2str(dum)];
    axes_name2=['sa',num2str(dum)];
    set(handles.(chi_name),'string','Xsq = ');
    cla(handles.(axes_name));
    cla(handles.(axes_name2));
end%for dum=1:6
handles.din.prev_cond=zeros(str2double(get(handles.num_datapoints,'string')),1);
set(handles.status,'string','Status: Plots are cleared! Ready...');
guidata(hObject, handles);

% --- This function wil clear the datapoints in the FG_values field in
% handles.din
function clear_datapoints_Callback(hObject, ~, handles)
confirm=questdlg('Are you sure you want to clear data?',...
    '','Yes','No','No');
switch confirm
    case 'Yes'
    backup=matfile(['deleted data\',datestr(clock,30),'_deleted_data'],'writable',true);%output the deleted data in the deleted data folder with the filename containing the time in 'yyymmddThhmmss' format (iso 8601)
    backup.FG_frequency=handles.din.FG_frequency;
    backup.FG_freq_shifts=handles.din.FG_freq_shifts;
    backup.chi_sq_value=handles.din.chi_sqr_value;
    handles.din.FG_frequency=NaN(handles.din.max_datapts,13);
    handles.din.FG_freq_shifts=NaN(handles.din.max_datapts,13);
    handles.din.chi_sqr_value=NaN(handles.din.max_datapts,13);
    handles.din.n=1;    
    cla_raw_Callback(hObject, 0, handles);
    for dum=1:2:11
        name=['X',num2str(dum)];
        set(handles.(name),'userdata',[]);
    end%for dum=1:2:11
    guidata(hObject, handles);
    set(handles.status,'string','Status: Data has been deleted! A backup of the deleted data can be found in deleted_data.mat. Ready...');
    disp('Data has been deleted! A back of the the deleted data can be found in the deleted data folder.');
    case 'No'
        set(handles.status,'string','Data was not deleted. Ready...');
        disp('Data was not deleted.');
end%switch confirm

function wait_time_Callback(~, ~, handles)
set(handles.status,'string','Status: WARNING: CHANGING THE TIME B/W MEASUREMNTS CAN CAUSE SYNC PROBLEMS! Ready...');

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
set(handles.status,'string','Status: WARNING: CHANGING THE # OF DATAPOINTS CAN CAUSE SYNC PROBLEMS! Ready...');


% --- Executes on button press in show_susceptance.
function show_susceptance_Callback(hObject, eventdata, handles)
if get(handles.show_susceptance,'value')==0
    set(handles.polar_plot,'value',0);
end%if get(handles.show_susceptance,'value')==0

%this function creates a new figure showing the selected raw conductance
%spectra
function raw_fig_Callback(hObject, ~, handles)
set(handles.reset,'visible','on');
for dum=1:6%clear the small axes
    chi_name=['X',num2str(dum*2-1)];
    axes_name=['axes',num2str(dum)];
    axes_name2=['sa',num2str(dum)];
    set(handles.(chi_name),'string','Xsq = ');
    cla(handles.(axes_name));
    cla(handles.(axes_name2));
end%for dum=1:6
if get(handles.raw_fig,'value')==0
    harm_tot=find_num_harms(handles);
    for dum=1:length(harm_tot)
       flag=(harm_tot(dum)+1)/2;
       delete(figure(flag));
    end%for dum=1:length(harm_tot)
    import java.awt.Robot;
    import java.awt.event.*;
    key = Robot;
    key.keyPress(java.awt.event.KeyEvent.VK_ESCAPE);%this programatically presses the "esc" key
    key.keyRelease(java.awt.event.KeyEvent.VK_ESCAPE);%this programatically releases the "esc" key
    set(handles.start,'visible','on');
    set(handles.status,'string','Status: Ready...');
    disp('Exited out of Raw Figure Mode');
end%if get(handles.raw_fig,'value')==1
if get(handles.start,'value')==0&&get(handles.raw_fig,'value')==1
    set(handles.start,'visible','off');
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
                f1=figure(dum);
                clf(figure(dum));
                a=axes;
                plot(a,conductance,susceptance,'x-',...
                    'color',[0 0.5 0],'linewidth',1,'markersize',6);
                axis tight
                hold on;
                if get(handles.dynamic_fit,'value')==1&&get(handles.fit_B_radio,'value')==1
                    [G_fit,B_fit,G_l_sq,B_l_sq,combine_spectra,G_parameters,B_parameters,handles,I]=Lorentzian_dynamic_fit(handles,freq,conductance,susceptance,combine_spectra);
                    plot(a,G_fit,B_fit,'k-','linewidth',2);
                    plot(a,G_fit(I),B_fit(I),'-','linewidth',1,'color',[0.82031 0.410156 0.11718]);
                end%if get(handles.dynamic_fit,'value')==1&&get(handles.fit_B_radio,'value')==1
                ylabel(a,'Susceptance (mS)','fontweight','bold','fontsize',12);
                xlabel(a,'Conductance (mS)','fontweight','bold','fontsize',12);
            elseif get(handles.polar_plot,'value')==0%otherwise, plot things in the frequency domain
                if get(handles.dynamic_fit,'value')==1%this if statement will run the Lorentzian fitting function
                      [G_fit,B_fit,G_l_sq,B_l_sq,combine_spectra,G_parameters,B_parameters,handles,I]=Lorentzian_dynamic_fit(handles,freq,conductance,susceptance,combine_spectra);
                end%if get(handles.dynamic_fit,'value')==1   
                f1=figure(dum);
                clf(figure(dum));
                a=axes;
                plot(a,freq,conductance,'bx-','linewidth',1.5,'markersize',8);
                hold on;
                if get(handles.dynamic_fit,'value')==1&&get(handles.fit_B_radio,'value')==1
                    plot(a,freq(I),ones(size(I,1)).*min(conductance),'-','linewidth',2,'color',[0.82031 0.410156 0.11718]);
                    plot(a,mean([G_parameters(1), B_parameters(1)]),...
                        mean([G_parameters(4)+G_parameters(5),B_parameters(4)]+G_parameters(5)),'mo','markerfacecolor','m','markersize',6);
                    plot(a,[mean([G_parameters(1),B_parameters(1)])-mean([G_parameters(2),B_parameters(2)]),...
                        mean([G_parameters(1),B_parameters(1)])+mean([G_parameters(2),B_parameters(2)])+G_parameters(5)],...
                        [mean([G_parameters(4),B_parameters(4)])/2+G_parameters(5),mean([G_parameters(4),B_parameters(4)])/2+G_parameters(5)],...
                        'o','color',[0 0.5 0],'markerfacecolor',[0 0.5 0],'markersize',6);
                    plot(a,freq,G_fit,'k','linewidth',2);
                    text('units','normalized','position',[.02 .95 1],'string',['Xsq = ',num2str(sum(G_l_sq))],...
                    'fontweight','bold','backgroundcolor','none','edgecolor','k');
                    ylim_a=get(gca,'ylim');
                    b=axes('position',get(a,'position'));
                    plot(b,freq,susceptance,'rx-');
                    hold on;  
                    plot(b,freq,B_fit,'k','linewidth',2);
                elseif get(handles.dynamic_fit,'value')==1&&get(handles.fit_B_radio,'value')==0
                    plot(a,freq(I),ones(size(I,1)).*min(conductance),'-','linewidth',2,'color',[0.82031 0.410156 0.11718]);
                    plot(a,([G_parameters(1)]),...
                        ([G_parameters(4)+G_parameters(5)]),'mo','markerfacecolor','m','markersize',6);
                    plot(a,[([G_parameters(1)])-([G_parameters(2)]),...
                        ([G_parameters(1)])+([G_parameters(2)])+G_parameters(5)],...
                        [([G_parameters(4)])/2+G_parameters(5),([G_parameters(4)])/2+G_parameters(5)],...
                        'o','color',[0 0.5 0],'markerfacecolor',[0 0.5 0],'markersize',6);
                    plot(a,freq,G_fit,'k','linewidth',2);
                    text('units','normalized','position',[.02 .95 1],'string',['Xsq = ',num2str(sum(G_l_sq))],...
                    'fontweight','bold','backgroundcolor','none','edgecolor','k');
                    ylim_a=get(gca,'ylim');
                    b=axes('position',get(a,'position'));
                    plot(b,freq,susceptance,'rx-');
                end%if get(handles.c=dynamic_fit,'value')==1
            set(a,'box','off');                      
            set(a,'ylim',ylim_a);
            set(b,'yaxislocation','right','ycolor','r','color','none','box','off');
            xlabel(a,'Frequency (Hz)','fontweight','bold');
            ylabel(a,'Conductance (S)','fontweight','bold');
            ylabel(b,'Susceptance (S)','fontweight','bold');
            set(get(b,'ylabel'),'rotation',-90,'units','normalized',...
                'position',[1.1 0.5 1]);
            title(['Harmonic number: ',num2str(dum*2-1)],'fontweight','bold');
            end %if get(handles.polar_plot,'value')==1            
        else
            close(figure(dum));
        end%if radio_radio_dials(dum)==1
    end%for dum=1:6
    set(handles.status,'string','Status: Hit enter to refresh spectra');
    disp('Hit enter to refresh spectra');
    pause
end%while get(handles.raw_fig,'value')==1%%get(handles.start,'value',)==1
if get(handles.start,'value')==1&&get(handles.raw_fig,'value')==1
     set(handles.raw_fig,'fontweight','bold','foregroundcolor','r');
    get_radio_dials=[get(handles.harm1,'value');get(handles.harm3,'value');...
        get(handles.harm5,'value');get(handles.harm7,'value');...
        get(handles.harm9,'value');get(handles.harm11,'value')];
    for dum=1:6
        if get_radio_dials(dum)==1
            handles.din.harmonic=dum*2-1;
            [freq,conductance,susceptance,handles]=read_scan(handles);%get scan data
            combine_spectra=[freq,conductance,susceptance];
            if get(handles.dynamic_fit,'value')==1%this if statement will run the Lorentzian fitting function
                  [G_fit,B_fit,G_l_sq,B_l_sq,combine_spectra,~,~,handles,I]=Lorentzian_dynamic_fit(handles,freq,conductance,susceptance,combine_spectra);
            end%if get(handles.dynamic_fit,'value')==1   
            f1=figure(dum);
            clf(figure(dum));
            a=axes;
            plot(a,freq,conductance,'bx-','linewidth',1.5,'markersize',8);
            hold on;
            if get(handles.dynamic_fit,'value')==1
                plot(a,freq(I),ones(size(I,1)).*min(conductance),'-','linewidth',2,'color',[0.82031 0.410156 0.11718]);
            end%if get(handles.c=dynamic_fit,'value')==1
            if get(handles.dynamic_fit,'value')==1%this if statement will run the Lorentzian fitting function            
                plot(freq,G_fit,'k','linewidth',2);
                text('units','normalized','position',[.02 .95 1],'string',['Xsq = ',num2str(sum(G_l_sq))],...
                'fontweight','bold','backgroundcolor','none','edgecolor','k');
            end%            if get(handles.dynamic_fit,'value')==1
            set(a,'box','off');
            ylim_a=get(gca,'ylim');
            b=axes('position',get(a,'position'));
            plot(b,freq,susceptance,'rx-');
            hold on;
            if get(handles.dynamic_fit,'value')==1%this if statement will run the Lorentzian fitting function                        
                plot(freq,B_fit,'k','linewidth',2);
            end%if get(handles.dynamic_fit,'value')==1
            set(a,'ylim',ylim_a);
            set(b,'yaxislocation','right','ycolor','r','color','none','box','off');
            xlabel(a,'Frequency (Hz)','fontweight','bold');
            ylabel(a,'Conductance (S)','fontweight','bold');
            ylabel(b,'Susceptance (S)','fontweight','bold');
            set(get(b,'ylabel'),'rotation',-90,'units','normalized',...
                'position',[1.1 0.5 1]);
            title(['Harmonic number: ',num2str(dum*2-1)],'fontweight','bold');
        else
            close(figure(dum));
        end%if radio_radio_dials(dum)==1
    end%for dum-1:6
end%if get(handles.start,'value')==1
set(handles.raw_fig,'fontweight','normal','foregroundcolor','k');
guidata(hObject, handles);


%///////////////////////////////////////////////////
%PEAK TRACKING CODE BEGINS HERE
%///////////////////////////////////////////////////
function [handles]=smart_peak_tracker(handles,freq,conductance,susceptance,G_parameters)
try
    f0=G_parameters(1);
    gamma0=G_parameters(2);
end
[~,index]=findpeaks(conductance,'sortstr','descend');
peak_f=freq(index(1));
Gmax=conductance(index(1));
halfg=(Gmax-min(conductance))./2+min(conductance);
halfg_freq=abs(freq(find(abs(halfg-conductance)==min(abs((halfg-conductance))),1))-peak_f);
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
            str2double(get(handles.(['start_f',num2str(handles.din.harmonic)]),'string')))*1e6%get the current span of the data in Hz
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
            thresh2=.05*current_span;%Threshold frequency span ini Hz
            LB_peak=peak_f-halfg_freq*6;%lower bound of the resonance peak
            if LB_peak-thresh1>halfg_freq*10%if peak is to thin, zoom into the peak
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
    elseif peak_track(1)==2&&peak_track(2)==0%run custom, user-defined peak tracking algorithm
        %%%%%%%CUSTOM, USER-DEFINED
        %%%%%%%CUSTOM, USER-DEFINED
        %%%%%%%CUSTOM, USER-DEFINED
        %%%%%%%CUSTOM, USER-DEFINED
    end%if fix_span==1&&fix_center==0
    check_freq_range(handles.din.harmonic, handles.din.freq_range(0.5*(handles.din.harmonic+1),1), handles.din.freq_range(0.5*(handles.din.harmonic+1),2), handles);
%///////////////////////////////////////////////////
% PEAK TRACKING CODE ENDS HERE
%///////////////////////////////////////////////////

%this function saves settings into an output file
function save_settings_Callback(hObject, eventdata, handles)
try
    set(handles.status,'string','Status: Saving settings...please wait');drawnow;
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
    settings.fit_B_radio=get(handles.fit_B_radio,'value');
    settings.radio_chi=get(handles.radio_chi,'value');
    settings.num_datapoints2=get(handles.num_datapoints,'userdata');
    settings.n=handles.din.n;%this setting was implmented in version 1.0c
catch
    set(handles.status,'string','Status: ERROR! Unable to save settings file. See Command Window! Ready...');
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
save([settings.output_path,settings.output_filename(1:end-4),'_settings.mat'],'settings');
waitbar(1,h);drawnow;
delete(h);
set(handles.status,'string',['Status: Settings succesfully saved! ',settings.output_filename(1:end-4),'_settings.mat']);
disp('Settings succesfully saved! ');

function waitclose(~,~)

function record_time_increment_Callback(hObject, eventdata, handles)
% hObject    handle to record_time_increment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of record_time_increment as text
%        str2double(get(hObject,'String')) returns contents of record_time_increment as a double


%Load settings that are saved
function load_settings_Callback(hObject, eventdata, handles)
if isempty(get(handles.load_settings,'userdata'))
    try
       variables=open([handles.din.output_path,handles.din.output_filename(1:end-4),'_settings.mat']);
       settings=variables.settings;
       clear('variables');
       set(handles.load_settings,'userdata',1);
    catch
        try
            [settings_filename,settings_path]=uigetfile('*.mat');
            load([settings_path,settings_filename]);
            set(handles.load_settings,'userdata',1);
        catch
            set(handles.status,'string','Status: ERROR! Unable to load settings file. Ready...');
        end%try
    end%try
else
        try
            [settings_filename,settings_path]=uigetfile('*.mat');
            load([settings_path,settings_filename]);
        catch
            set(handles.status,'string','Status: ERROR! Unable to load settings file. Ready...');
        end%try
end%if isempty(get(handles.load_settings,'userdata'))
try
    set(handles.maintain_myVNA,'value',settings.maintain_myVNA);
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
        harm_name=['peak_track',num2str(dum)];
        peak_track=['peak_track',num2str(dum)];
        if settings.(peak_track)(1)==1&&settings.(peak_track)(2)==0
            set(handles.(harm_name),'string','Fixed span');
        elseif settings.(peak_track)(1)==0&&settings.(peak_track)(2)==1
            set(handles.(harm_name),'string','Fixed center');
        elseif settings.(peak_track)(1)==1&&settings.(peak_track)(2)==1
            set(handles.(harm_name),'string','Fixed span and fixed center');
        elseif settings.(peak_track)(1)==2&&settings.(peak_track)(2)==0
            set(handles.(harm_name),'string','Custom peak tracking algorithm');
        else
            set(handles.(harm_name),'string','Default peak tracking algorithm');
        end%if peak_track(1)==1&&peak_track(2)==0
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
    try
        set(handles.num_datapoints,'userdata',settings.num_datapoints2);
    end
    try
        handles.din.n=settings.n;
    catch
        disp('Warning, the variable settings.n was not found!');
        set(handles.status,'string','Warning! Settings might not have been loaded properly! See the Command Window!');
    end
    set(handles.record_time_increment,'string',settings.record_time_increment);
    disp('Scan settings loaded!');
    set(handles.dynamic_fit,'value',settings.dynamic_fit);
    set(handles.radio_chi,'value',settings.radio_chi);
    set(handles.fit_B_radio,'value',settings.fit_B_radio);
    disp('Fitting options loaded!');
    handles.din.output_path=settings.output_path;
    handles.din.output_filename=settings.output_filename;
    handles.din=settings.din;
    disp('handles.din stucture updated!');
    set(handles.filename_txt,'tooltipstring',[handles.din.output_path,handles.din.output_filename],'userdata',1);
    set(handles.status,'string',['Status: Settings, ',settings.output_filename,...
        ', succesfully loaded!']);
    disp(['Saved settings, ',settings.output_filename,'have been successfully loaded!']);
    set_settings_Callback(1,1, handles);%write out the settings file
    disp('For versions 1.0c and above, resetting the handles.din.n index will require manually setting handles.din.n = 1!');
    disp('To do this, access the GUI handles structure via "Access Handles Structure" button. See manual for more details.');
catch
    set(handles.status,'string','Status: ERROR! Unable to load settings file. See Command Window! Ready...');
    disp('You are in debugging mode. ');
    disp('To exit out of debugging mode, click onto the MATLAB Editor Window and push the button that says,"Quit debugging", near the top of the window.')
    disp('Alternatively, you can type ''return'' in the Command Window and hit the "Enter" button.');
    keyboard
end%try


%This functions will output the data into a user specified filename and
%path
function save_data_Callback(hObject, ~, handles)
try
    [output_filename,output_path]=uiputfile('*.mat');
    full_filename=[output_path,output_filename];
    set(handles.filename_txt,'string',[full_filename(1:10),'...',full_filename(end-10:end)],...
        'tooltipstring',full_filename,'userdata',1);%output filename info
    handles.din.output_filename=output_filename;
    handles.din.output_path=output_path;
catch 
end%try
guidata(hObject, handles);


% --- Executes on selection change in plot1_choice.
function plot1_choice_Callback(hObject, eventdata, handles)
choice=get(handles.plot1_choice,'value');
axes(handles.primaryaxes1);
font_size=8;
font_weight='bold';
switch choice
    case 1
        xlabel('');
        ylabel('');
        set(gca,'fontsize',font_size);
    case 2
        xlabel('Time (min.)','fontsize',font_size,'fontweight',font_weight);
        ylabel('\Deltaf (Hz)','fontsize',font_size,'fontweight',font_weight);
        set(gca,'fontsize',font_size);
    case 3
        xlabel('Time (min.)','fontsize',font_size,'fontweight',font_weight);
        ylabel('\Deltaf/n (Hz)','fontsize',font_size,'fontweight',font_weight);
        set(gca,'fontsize',font_size);
    case 4
        xlabel('Time (min.)','fontsize',font_size,'fontweight',font_weight);
        ylabel('\Delta\Gamma (Hz)','fontsize',font_size,'fontweight',font_weight);
        set(gca,'fontsize',font_size);        
    case 5
        xlabel('Time (min.)','fontsize',font_size,'fontweight',font_weight);
        ylabel('\Delta\Gamma/n (Hz)','fontsize',font_size,'fontweight',font_weight);
        set(gca,'fontsize',font_size);        
end%switch choice
cla(handles.primaryaxes1);
num_harms=primaryaxes_harm(handles);
for dum=1:length(num_harms)
    handles.din.harmonic=num_harms(dum);
    plot_primaryaxes1(handles,handles.din.FG_frequency,find_num_harms(handles),handles.din.n);
end

% --- Executes on selection change in plot2_choice.
function plot2_choice_Callback(hObject, eventdata, handles)
choice=get(handles.plot2_choice,'value');
axes(handles.primaryaxes2);
font_size=8;
font_weight='bold';
switch choice
    case 1
        xlabel('');
        ylabel('');
        set(gca,'fontsize',font_size);
    case 2
        xlabel('Time (min.)','fontsize',font_size,'fontweight',font_weight);
        ylabel('\Deltaf (Hz)','fontsize',font_size,'fontweight',font_weight);
        set(gca,'fontsize',font_size);
    case 3
        xlabel('Time (min.)','fontsize',font_size,'fontweight',font_weight);
        ylabel('\Deltaf/n (Hz)','fontsize',font_size,'fontweight',font_weight);
        set(gca,'fontsize',font_size);
    case 4
        xlabel('Time (min.)','fontsize',font_size,'fontweight',font_weight);
        ylabel('\Delta\Gamma (Hz)','fontsize',font_size,'fontweight',font_weight);
        set(gca,'fontsize',font_size);        
    case 5
        xlabel('Time (min.)','fontsize',font_size,'fontweight',font_weight);
        ylabel('\Delta\Gamma/n (Hz)','fontsize',font_size,'fontweight',font_weight);
        set(gca,'fontsize',font_size);        
end%switch choice
cla(handles.primaryaxes2);
num_harms=primaryaxes2_harm(handles);
for dum=1:length(num_harms)
    handles.din.harmonic=num_harms(dum);
    plot_primaryaxes2(handles,handles.din.FG_frequency,find_num_harms(handles),handles.din.n);
end


function plot_primaryaxes1(handles,FG_frequency,harm_tot,n)
marker_color={[0 0 0],[0 0 1],[1 0 0],[0 0.5 0],[1 .8398 0],[.25 .875 .8125]};
axes(handles.primaryaxes1);
hold on;
active_plot_harmonics=[];
flag=1;
for dum=1:2:11
    plot_name_dial=['plot_',num2str(dum)];
    if get(handles.(plot_name_dial),'value')==1&&sum(harm_tot==dum)==1&&dum==handles.din.harmonic
        active_plot_harmonics=[active_plot_harmonics,dum];
        flag=flag+1;
    end%if get(handles.(plot_name_dial),'value')==1
end%dum=1:2:11
dum=(active_plot_harmonics+1)/2;
if isempty(dum)==0
    switch get(handles.plot1_choice,'value')
        case 1
            cla(handles.primaryaxes1);
        case 2%plot frequency shift versus time
            F_frequency_shifts=FG_frequency(1:n,active_plot_harmonics(1)+1)-handles.din.ref_freq((active_plot_harmonics(1)+1)./2);
            plot(FG_frequency(1:n,1),F_frequency_shifts(1:n),'-','color',marker_color{dum},...
                'linestyle','-','marker','o','markersize',6,'markerfacecolor','none');hold on;
            if (max(FG_frequency(:,1)))>=max(get(gca,'xlim'))
                set(gca,'xlim',[FG_frequency(1,1)-1, max(FG_frequency(:,1))*1.2]);
            end% if (max(FG_frequency(:,1)))>=get(gca,'xlim')(1,2)-10  
        case 3%plot frequency shift/harmonic order versus time
            F_frequency_shifts=FG_frequency(1:n,active_plot_harmonics(1)+1)-handles.din.ref_freq((active_plot_harmonics(1)+1)./2);
            plot(FG_frequency(1:n,1),F_frequency_shifts(1:n)./active_plot_harmonics,'-','color',marker_color{dum},...
                'linestyle','-','marker','o','markersize',6,'markerfacecolor','none');hold on;
            if (max(FG_frequency(:,1)))>=max(get(gca,'xlim'))
                set(gca,'xlim',[FG_frequency(1,1)-1, max(FG_frequency(:,1))*1.2]);
            end% if (max(FG_frequency(:,1)))>=get(gca,'xlim')(1,2)-10       
        case 4%plot gamma shift versus time
            G_frequency_shifts= FG_frequency(:,active_plot_harmonics(1)+2)-handles.din.ref_diss((active_plot_harmonics(1)+1)./2);
            plot(FG_frequency(1:n,1),G_frequency_shifts(1:n),'-','color',marker_color{dum},...
                'linestyle','-','marker','o','markersize',6,'markerfacecolor','none');hold on;
            if (max(FG_frequency(:,1)))>=max(get(gca,'xlim'))
                set(gca,'xlim',[FG_frequency(1,1)-1, max(FG_frequency(:,1))*1.2]);
            end% if (max(FG_frequency(:,1)))>=get(gca,'xlim')(1,2)-10                
        case 5%plot gamma shift/harmonic order versus time
            G_frequency_shifts= FG_frequency(:,active_plot_harmonics(1)+2)-handles.din.ref_diss((active_plot_harmonics(1)+1)./2);
            plot(FG_frequency(1:n,1),G_frequency_shifts(1:n)./active_plot_harmonics,'-','color',marker_color{dum},...
                'linestyle','-','marker','o','markersize',6,'markerfacecolor','none');hold on;
            if (max(FG_frequency(:,1)))>=max(get(gca,'xlim'))
                set(gca,'xlim',[FG_frequency(1,1)-1, max(FG_frequency(:,1))*1.2]);
            end% if (max(FG_frequency(:,1)))>=get(gca,'xlim')(1,2)-10            
    end
end%if isempty(dum)==0
del_dataset=get(handles.primaryaxes1,'children');
if length(del_dataset)==length(primaryaxes_harm(handles))*2&&length(primaryaxes_harm(handles))~=1&&length(primaryaxes_harm(handles))>0
    delete(del_dataset(length(primaryaxes_harm(handles))*2-1:length(primaryaxes_harm(handles))*2));
end%if length(del_dataset)>=4


function plot_primaryaxes2(handles,FG_frequency,harm_tot,n)
marker_color={[0 0 0],[0 0 1],[1 0 0],[0 0.5 0],[1 .8398 0],[.25 .875 .8125]};
axes(handles.primaryaxes2);
hold on;
active_plot_harmonics=[];
flag=1;
for dum=1:2:11
    plot_name_dial=['plot2_',num2str(dum)];
    if get(handles.(plot_name_dial),'value')==1&&sum(harm_tot==dum)==1&&dum==handles.din.harmonic
        active_plot_harmonics=[active_plot_harmonics,dum];
        flag=flag+1;
    end%if get(handles.(plot_name_dial),'value')==1
end%dum=1:2:11
dum=(active_plot_harmonics+1)/2;
if isempty(dum)==0
    switch get(handles.plot2_choice,'value')
        case 1
            cla(handles.primaryaxes2);
        case 2%plot frequency shift versus time
            F_frequency_shifts=FG_frequency(1:n,active_plot_harmonics(1)+1)-handles.din.ref_freq((active_plot_harmonics(1)+1)./2);
            plot(FG_frequency(1:n,1),F_frequency_shifts(1:n),'-','color',marker_color{dum},...
                'linestyle','-','marker','o','markersize',6,'markerfacecolor','none');hold on;
            if (max(FG_frequency(:,1)))>=max(get(gca,'xlim'))
                set(gca,'xlim',[FG_frequency(1,1)-1, max(FG_frequency(:,1))*1.2]);
            end% if (max(FG_frequency(:,1)))>=get(gca,'xlim')(1,2)-10  
        case 3%plot frequency shift/harmonic order versus time
            F_frequency_shifts=FG_frequency(1:n,active_plot_harmonics(1)+1)-handles.din.ref_freq((active_plot_harmonics(1)+1)./2);
            plot(FG_frequency(1:n,1),F_frequency_shifts(1:n)./active_plot_harmonics,'-','color',marker_color{dum},...
                'linestyle','-','marker','o','markersize',6,'markerfacecolor','none');hold on;
            if (max(FG_frequency(:,1)))>=max(get(gca,'xlim'))
                set(gca,'xlim',[FG_frequency(1,1)-1, max(FG_frequency(:,1))*1.2]);
            end% if (max(FG_frequency(:,1)))>=get(gca,'xlim')(1,2)-10       
        case 4%plot gamma shift versus time
            G_frequency_shifts= FG_frequency(:,active_plot_harmonics(1)+2)-handles.din.ref_diss((active_plot_harmonics(1)+1)./2);
            plot(FG_frequency(1:n,1),G_frequency_shifts(1:n),'-','color',marker_color{dum},...
                'linestyle','-','marker','o','markersize',6,'markerfacecolor','none');hold on;
            if (max(FG_frequency(:,1)))>=max(get(gca,'xlim'))
                set(gca,'xlim',[FG_frequency(1,1)-1, max(FG_frequency(:,1))*1.2]);
            end% if (max(FG_frequency(:,1)))>=get(gca,'xlim')(1,2)-10                
        case 5%plot gamma shift/harmonic order versus time
            G_frequency_shifts= FG_frequency(:,active_plot_harmonics(1)+2)-handles.din.ref_diss((active_plot_harmonics(1)+1)./2);
            plot(FG_frequency(1:n,1),G_frequency_shifts(1:n)./active_plot_harmonics,'-','color',marker_color{dum},...
                'linestyle','-','marker','o','markersize',6,'markerfacecolor','none');hold on;
            if (max(FG_frequency(:,1)))>=max(get(gca,'xlim'))
                set(gca,'xlim',[FG_frequency(1,1)-1, max(FG_frequency(:,1))*1.2]);
            end% if (max(FG_frequency(:,1)))>=get(gca,'xlim')(1,2)-10            
    end
end%if isempty(dum)==0
del_dataset=get(handles.primaryaxes1,'children');
if length(del_dataset)==length(primaryaxes_harm(handles))*2&&length(primaryaxes_harm(handles))~=1&&isempty(primaryaxes_harm(handles))~=1
    delete(del_dataset(length(primaryaxes_harm(handles))*2-1:length(primaryaxes_harm(handles))*2));
end%if length(del_dataset)>=4


% --- Executes on button press in plot_1st.
function plot_1_Callback(hObject, eventdata, handles)
    cla(handles.primaryaxes1);
    num_harms=primaryaxes_harm(handles);
    for dum=1:length(num_harms)
        handles.din.harmonic=num_harms(dum);
        plot_primaryaxes1(handles,handles.din.FG_frequency,find_num_harms(handles),handles.din.n);
    end

% --- Executes on button press in plot_3rd.
function plot_3_Callback(hObject, eventdata, handles)
    cla(handles.primaryaxes1);
    num_harms=primaryaxes_harm(handles);
    for dum=1:length(num_harms)
        handles.din.harmonic=num_harms(dum);
        plot_primaryaxes1(handles,handles.din.FG_frequency,find_num_harms(handles),handles.din.n);
    end

% --- Executes on button press in plot_5th.
function plot_5_Callback(hObject, eventdata, handles)
    cla(handles.primaryaxes1);
    num_harms=primaryaxes_harm(handles);
    for dum=1:length(num_harms)
        handles.din.harmonic=num_harms(dum);
        plot_primaryaxes1(handles,handles.din.FG_frequency,find_num_harms(handles),handles.din.n);
    end

% --- Executes on button press in plot_7th.
function plot_7_Callback(hObject, eventdata, handles)
    cla(handles.primaryaxes1);
    num_harms=primaryaxes_harm(handles);
    for dum=1:length(num_harms)
        handles.din.harmonic=num_harms(dum);
        plot_primaryaxes1(handles,handles.din.FG_frequency,find_num_harms(handles),handles.din.n);
    end

% --- Executes on button press in plot_9th.
function plot_9_Callback(hObject, eventdata, handles)
    cla(handles.primaryaxes1);
    num_harms=primaryaxes_harm(handles);
    for dum=1:length(num_harms)
        handles.din.harmonic=num_harms(dum);
        plot_primaryaxes1(handles,handles.din.FG_frequency,find_num_harms(handles),handles.din.n);
    end

% --- Executes on button press in plot_11th.
function plot_11_Callback(hObject, eventdata, handles)
    cla(handles.primaryaxes1);
    num_harms=primaryaxes_harm(handles);
    for dum=1:length(num_harms)
        handles.din.harmonic=num_harms(dum);
        plot_primaryaxes1(handles,handles.din.FG_frequency,find_num_harms(handles),handles.din.n);
    end

% --- Executes on button press in plot2_1.
function plot2_1_Callback(hObject, eventdata, handles)
cla(handles.primaryaxes2);
num_harms=primaryaxes2_harm(handles);
    for dum=1:length(num_harms)
        handles.din.harmonic=num_harms(dum);
        plot_primaryaxes2(handles,handles.din.FG_frequency,find_num_harms(handles),handles.din.n);
    end

% --- Executes on button press in plot2_3.
function plot2_3_Callback(hObject, eventdata, handles)
cla(handles.primaryaxes2);
num_harms=primaryaxes2_harm(handles);
    for dum=1:length(num_harms)
        handles.din.harmonic=num_harms(dum);
        plot_primaryaxes2(handles,handles.din.FG_frequency,find_num_harms(handles),handles.din.n);
    end

% --- Executes on button press in plot2_5.
function plot2_5_Callback(hObject, eventdata, handles)
cla(handles.primaryaxes2);
num_harms=primaryaxes2_harm(handles);
    for dum=1:length(num_harms)
        handles.din.harmonic=num_harms(dum);
        plot_primaryaxes2(handles,handles.din.FG_frequency,find_num_harms(handles),handles.din.n);
    end

% --- Executes on button press in plot2_7.
function plot2_7_Callback(hObject, eventdata, handles)
cla(handles.primaryaxes2);
num_harms=primaryaxes2_harm(handles);
    for dum=1:length(num_harms)
        handles.din.harmonic=num_harms(dum);
        plot_primaryaxes2(handles,handles.din.FG_frequency,find_num_harms(handles),handles.din.n);
    end

% --- Executes on button press in plot2_9.
function plot2_9_Callback(hObject, eventdata, handles)
cla(handles.primaryaxes2);
num_harms=primaryaxes2_harm(handles);
    for dum=1:length(num_harms)
        handles.din.harmonic=num_harms(dum);
        plot_primaryaxes2(handles,handles.din.FG_frequency,find_num_harms(handles),handles.din.n);
    end

% --- Executes on button press in plot2_11.
function plot2_11_Callback(hObject, eventdata, handles)
cla(handles.primaryaxes2);
num_harms=primaryaxes2_harm(handles);
    for dum=1:length(num_harms)
        handles.din.harmonic=num_harms(dum);
        plot_primaryaxes2(handles,handles.din.FG_frequency,find_num_harms(handles),handles.din.n);
    end

function num_harms=primaryaxes_harm(handles)
num_harms=[];
for dum=1:2:11
    harm_name=['plot_',num2str(dum)];
    if get(handles.(harm_name),'value')==1
        num_harms=[num_harms, dum];
    end%if get(handles.(harm_name),'value')==1
end%for dum=1:2:11

function num_harms=primaryaxes2_harm(handles)
num_harms=[];
for dum=1:2:11
    harm_name=['plot2_',num2str(dum)];
    if get(handles.(harm_name),'value')==1
        num_harms=[num_harms, dum];
    end%if get(handles.(harm_name),'value')==1
end%for dum=1:2:11
    
function [fit_button,refresh]=my_buttons()
fit_button=[...
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0
0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0
0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0
0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0
0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0
0 1 1 1 1 0 0 1 0 0 1 1 1 1 1 0
0 1 0 0 0 0 0 1 0 0 0 0 1 0 0 0
0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0
0 1 0 0 0 0 0 1 0 0 0 0 1 0 0 0
0 1 0 0 0 0 0 1 0 0 0 0 1 0 0 0
0 1 0 0 0 0 0 1 0 0 0 0 1 0 0 0
0 1 0 0 0 0 0 1 0 0 0 0 1 0 0 0
0 1 0 0 0 0 0 1 0 0 0 0 1 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
fit_button2(:,:,1)=fit_button;
fit_button2(:,:,2)=fit_button;
fit_button2(:,:,3)=fit_button;
fit_button=fit_button2.*-1+1;
refresh1=[4,4,4,4,4,4,4,4,4,4,4,4,3,3,3,3,4,4,4,4,4,4,4,4,4;
    4,4,4,4,4,4,4,4,4,4,4,4,4,3,3,3,3,4,4,4,4,4,4,4,4;
    4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,3,3,3,3,4,4,4,4,4,4;
    4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,3,3,3,3,3,4,4,4,4;
    4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,2,2,3,3,3,3,4,4;
    4,4,4,4,4,4,4,3,3,3,3,3,3,3,4,4,4,40,54,2,3,3,3,3,4;
    4,4,4,4,4,3,23,45,64,77,77,71,62,44,15,4,37,113,124,2,3,3,3,3,3;
    4,4,4,4,6,18,84,155,215,255,255,237,209,152,63,25,125,204,169,2,4,4,4,3,3;
    4,4,4,6,26,151,218,245,251,255,255,253,250,244,231,189,228,243,169,2,4,4,4,4,3;
    4,4,3,41,140,224,249,245,218,174,150,171,213,248,254,241,250,248,169,2,4,4,4,4,4;
    4,4,24,96,221,251,225,167,107,71,54,69,139,217,255,255,255,248,169,2,4,4,4,4,4;
    4,3,61,159,254,247,159,67,9,3,3,35,119,209,255,255,255,248,169,2,4,4,4,4,4;
    4,3,100,215,251,220,69,5,3,5,18,124,212,255,255,255,255,248,169,2,4,4,4,4,4;
    4,4,124,247,245,156,45,4,4,18,136,217,250,255,255,255,255,248,169,2,4,4,4,4,4;
    4,8,132,254,242,130,37,3,4,8,46,69,77,77,77,77,77,75,52,3,4,4,4,4,4;
    4,6,128,251,243,142,40,3,4,4,3,3,3,3,3,3,3,3,3,3,4,4,4,4,4;
    4,2,113,234,248,184,58,6,4,4,4,4,4,5,8,7,5,4,4,4,4,4,4,4,4;
    4,3,86,195,253,240,98,22,5,4,4,4,5,13,30,24,13,6,4,4,4,4,4,4,4;
    4,3,39,128,255,253,203,107,23,2,2,2,15,58,128,119,74,29,4,4,4,4,4,4,4;
    4,4,12,68,187,248,243,210,166,127,110,114,138,164,170,148,79,27,4,4,4,4,4,4,4;
    4,4,3,24,85,174,231,250,240,217,205,208,217,216,187,120,51,14,4,4,4,4,4,4,4;
    4,4,4,3,10,73,154,202,224,234,240,240,221,188,141,62,18,4,4,4,4,4,4,4,4;
    4,4,4,4,4,3,27,80,135,168,186,184,150,90,24,5,4,4,4,4,4,4,4,4,4;
    4,4,4,4,4,4,6,11,16,19,21,21,18,12,6,4,4,4,4,4,4,4,4,4,4;
    4,4,4,4,4,4,4,4,4,3,3,3,3,4,4,4,4,4,4,4,4,4,4,4,4;
    4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4;
    4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4];
refresh(:,:,1)=refresh1./255;
refresh(:,:,2)=refresh1./255;
refresh(:,:,3)=refresh1./255;
refresh=(abs(imresize(refresh,.65)))./max(max(max(imresize(refresh,.65))));


% --- Executes on button press in debug.
function debug_Callback(hObject, eventdata, handles)
assignin('base','handles',handles);
keyboard


% --- Executes on button press in unikitty.
function ukfunc(hObject, eventdata,handles)
% hObject    handle to unikitty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sel_typ = get(gcbf,'SelectionType');
if get(hObject,'userdata')==1
    load('other.mat');
    set(hObject,'style','togglebutton','cdata',imread('unikitty.jpg'));
    set(handles.primary1,'color',[1 .75 .793]);
    set(handles.uipanel2,'backgroundcolor',[1 .75 .793]);
    set(handles.uipanel1,'backgroundcolor',[1 .0781 .5742]);
    set(handles.uipanel4,'backgroundcolor',[1 .0781 .5742]);
    set(handles.uipanel8,'backgroundcolor',[1 .0781 .5742]);
    set(handles.uipanel9,'backgroundcolor',[1 .0781 .5742]);
    set(handles.uk,'userdata',0);
else
    set(hObject,'cdata',[],'style','text');
    set(handles.primary1,'color',[1 1 1]);
    set(handles.uipanel2,'backgroundcolor',[1 1 1]);
    set(handles.uipanel1,'backgroundcolor',[.941 .941 .941]);
    set(handles.uipanel4,'backgroundcolor',[.941 .941 .941]);
    set(handles.uipanel8,'backgroundcolor',[.941 .941 .941]);
    set(handles.uipanel9,'backgroundcolor',[.941 .941 .941]);
    set(handles.uk,'userdata',1);
end


% --- Executes on button press in ukfunc.
function ukfunc_Callback(hObject, eventdata, handles)
% hObject    handle to ukfunc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on mouse press over axes background.
function ukfunc_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to ukfunc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    if get(hObject,'userdata')==1
        delete(hObject);
        load('other.mat');
        handles.d=imshow(easteregg);
        set(handles.d,'buttondownfcn',{@ukfunc_ButtonDownFcn,handles});
        set(handles.primary1,'color',[1 .75 .793]);
        set(handles.uipanel2,'backgroundcolor',[1 .75 .793]);
        set(handles.uipanel1,'backgroundcolor',[1 .0781 .5742]);
        set(handles.uipanel4,'backgroundcolor',[1 .0781 .5742]);
        set(handles.uipanel8,'backgroundcolor',[1 .0781 .5742]);
        set(handles.uipanel9,'backgroundcolor',[1 .0781 .5742]);
        set(handles.ukfunc,'userdata',0);
        set(handles.d,'userdata',0);
    else
        delete(hObject);
        axes(handles.ukfunc);
        load('other.mat');
        handles.d=imshow(BW);    
        set(handles.d,'buttondownfcn',{@ukfunc_ButtonDownFcn,handles});
        set(handles.primary1,'color',[1 1 1]);
        set(handles.uipanel2,'backgroundcolor',[1 1 1]);
        set(handles.uipanel1,'backgroundcolor',[.941 .941 .941]);
        set(handles.uipanel4,'backgroundcolor',[.941 .941 .941]);
        set(handles.uipanel8,'backgroundcolor',[.941 .941 .941]);
        set(handles.uipanel9,'backgroundcolor',[.941 .941 .941]);
        set(handles.ukfunc,'userdata',1,'buttondownfcn',{@ukfunc_ButtonDownFcn,handles},'color',[1 .75 .793]);
        set(handles.d,'userdata',1);
    end
end%try


% --- Executes when user attempts to close primary1.
function primary1_CloseRequestFcn(hObject, eventdata, handles)
set(handles.maintain_myVNA,'value',0);
write_settings(handles,handles.din.harmonic);
delete(hObject);


% --- Executes on button press in email_notification.
% --- Executes on button press in email_notification.
function email_notification_Callback(hObject, eventdata, handles)
disp('Setting up email notifications');
f=figure();
pos=get(f,'position');
set(f,'position',[pos(1) pos(2) pos(3)/2 pos(4)/4]);
toggle_email=uicontrol('style','radiobutton',...
    'string','','units','normalized','position',[0.35 0.4 0.7 0.2],...
    'fontweight','bold','fontsize',8,'backgroundcolor',get(f,'color'),...
    'callback',{@toggle_func,handles},'string','Turn on email notifications');
email=uicontrol('style','edit',...
    'string','','units','normalized','position',[0.35 0.7 0.5 0.2],...
    'fontweight','bold','fontsize',8,'backgroundcolor',[1 1 1],...
    'callback',{@email_func,handles,toggle_email});
set(handles.email_notification,'userdata',1);
uicontrol('style','text','string','Email:','units','normalized',...
    'position',[0.13 0.7 0.21 0.2],'fontweight','bold','fontsize',8,...
    'background',get(f,'color'),'horizontalalignment','right');
function email_func(hObject,~,handles,toggle_email)
set(handles.uipanel5,'userdata',get(hObject,'string'));
disp(['Email notifications will be sent to: ',get(hObject,'string')]);
% if isempty(get(hObject,'string'))==0
%     set(toggle_email,'value',1);
%     set(handles.email_notification,'userdata',get(toggle_email,'value'));
%     disp('Email notifications are turned on');    
% else
%     set(toggle_email,'value',0);
%     set(handles.email_notification,'userdata',get(toggle_email,'value'));
%     disp('Email notifications are turned off');
% end%if isempty(get(hObject,'string'))==0
function toggle_func(hObject,~,handles)
set(handles.email_notification,'userdata',get(hObject,'value'));
if get(hObject,'value')==1
    disp('Email notifications are turned on');
else
    disp('Email notifications are turned off');
end%if get(hObject,'value')==1
function email_send(handles,message)
try
    email=get(handles.uipanel5,'userdata');
    disp(['Sending email to: ',email]);
    mail=['shull.qcm@gmail.com'];
    password=['softy.poly'];
    smtpserver=['smtp.gmail.com'];
    setpref('Internet','SMTP_Server',smtpserver);
    setpref('Internet','E_mail',mail);
    setpref('Internet','SMTP_Username',mail);
    setpref('Internet','SMTP_Password',password);
    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
    props.setProperty('mail.smtp.socketFactory.port','465');
    sendmail(email,['Email notification on the QCM exp ',handles.din.output_filename],message,'qcm_diary.txt');
    disp('Email notification sent!');
catch
    disp('Error in sending email!');
end


% --- Executes on button press in polar_plot.
function polar_plot_Callback(hObject, eventdata, handles)
if get(handles.polar_plot,'value')==1
    set(handles.show_susceptance,'value',1);
end%if get(handles.polar_plot,'value')==1

%This function redefines the fit_factor range for the Lorentz fitting
%process
function fit_factor_Callback(hObject, eventdata, handles)
handles.din.fit_factor_range=str2double(get(handles.fit_factor,'string'));
set(handles.status,'string','Status: Fit factor range sucessfully updated!');
disp('Fit factor range sucessfully updated!');
guidata(hObject, handles);

%this function reset the gui back to its original default state
function handles=reset_fcn(hObject,eventdata,handles)
backup=matfile(['deleted data\',datestr(clock,30),'_deleted_data'],'writable',true);%output the deleted data in the deleted data folder with the filename containing the time in 'yyymmddThhmmss' format (iso 8601)
backup.FG_frequency=handles.din.FG_frequency;
backup.FG_freq_shifts=handles.din.FG_freq_shifts;
backup.chi_sq_value=handles.din.chi_sqr_value;
handles.din.FG_frequency=NaN(handles.din.max_datapts,13);
handles.din.FG_freq_shifts=NaN(handles.din.max_datapts,13);
handles.din.chi_sqr_value=NaN(handles.din.max_datapts,13);
handles.din.n=1;    
cla_raw_Callback(hObject, 0, handles);
for dum=1:2:11
    name=['X',num2str(dum)];
    set(handles.(name),'userdata',[]);
end%for dum=1:2:11
guidata(hObject, handles);
set(handles.status,'string','Status: Data has been deleted! A backup of the deleted data can be found in deleted_data.mat. Ready...');
disp('Data has been deleted! A back of the the deleted data can be found in the deleted data folder.');
handles.din=handles.default_settings;%reset the handles.din state
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
    name10=['plot_',num2str(dum)];
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
    set(handles.(name10),'value',0);
end%for dum=1:2:11
set(handles.refresh_spectra,'string',1);
set(handles.fit_factor,'string',4);
set(handles.dynamic_fit,'value',0);
set(handles.fit_B_radio,'value',0);
set(handles.radio_chi,'value',0);
set(handles.show_susceptance,'value',0);
set(handles.polar_plot,'value',0);
set(handles.filename_txt,'string',['<Output Filename>']);
set(handles.plot1_choice,'value',1);
set(handles.plot2_choice,'value',1);
set(handles.sa1,'visible','off','color','none');
set(handles.sa2,'visible','off','color','none');
set(handles.sa3,'visible','off','color','none');
set(handles.sa4,'visible','off','color','none');
set(handles.sa5,'visible','off','color','none');
set(handles.sa6,'visible','off','color','none');
set(handles.axes7,'visible','off');
set(handles.peak_center,'visible','off');
set(handles.center1,'value',1);
set(handles.primaryaxes1,'fontsize',8);
set(handles.primaryaxes2,'fontsize',8);
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
write_settings(handles,handles.din.harmonic);%this function writes out the settings text file
plot1_choice_Callback(hObject, eventdata, handles);%refresh primaryaxes1
plot2_choice_Callback(hObject, eventdata, handles);%refresh primaryaxes2


% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)
handles=reset_fcn(hObject,eventdata,handles);
set(handles.status,'string','Status: GUI state resetted! Ready...');
guidata(hObject,handles);
