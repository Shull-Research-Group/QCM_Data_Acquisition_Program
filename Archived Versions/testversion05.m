function varargout = testversion05(varargin)
% TESTVERSION05 MATLAB code for testversion05.fig
%      TESTVERSION05, by itself, creates a new TESTVERSION05 or raises the existing
%      singleton*.
%
%      H = TESTVERSION05 returns the handle to a new TESTVERSION05 or the handle to
%      the existing singleton*.
%
%      TESTVERSION05('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TESTVERSION05.M with the given input arguments.
%
%      TESTVERSION05('Property','Value',...) creates a new TESTVERSION05 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before testversion05_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to testversion05_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help testversion05

% Last Modified by GUIDE v2.5 25-Mar-2014 03:33:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @testversion05_OpeningFcn, ...
                   'gui_OutputFcn',  @testversion05_OutputFcn, ...
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


% --- Executes just before testversion05 is made visible.
function testversion05_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to testversion05 (see VARARGIN)

% Choose default command line output for testversion05
handles.output = hObject;

%initialize AccessMyVNA program
open('AccessMyVNAv0.7\release\AccessMyVNA.exe');
% Update handles structure
handles.din.freq_range=[4 6; 14 16; 24 26; 34 36; 44 46; 54 56];%this stores the accepted frequency ranges for each harmonic
handles.din.avail_harms=[1 3 5 7 9 11];
handles.din.error_count=1;%declar an error log vounter variable that is stored int he handles structure
handles.din.error_log={};%declare an error log variable that is stored in the handles structure
handles.din.prev_cond=zeros(str2double(get(handles.num_datapoints,'string')),1);
handles.din.harmonic=1;
handles.din.n=1;%starting initial index for FG_frequency
handles.din.max_datapts=1e6;
handles.din.FG_frequency=NaN(handles.din.max_datapts,13);
handles.din.FG_freq_shifts=NaN(handles.din.max_datapts,13);
handles.din.chi_sqr_value=NaN(handles.din.max_datapts,13);
%set reference frequency shifts and dissipation shifts
handles.din.ref_freq=[5 15 25 35 45 55].*1e6;%units in Hz
handles.din.ref_diss=[100 100 100 100 100 100];%units in Hz
%inital formating of axes and buttons, etc.
axes(handles.axes7);
plot(handles.axes7,[0,1],[0,0],'-',[0,1],[0,0],'r-','visible','off');%add a legend box for the raw conductance plots
set(gca,'fontsize',6);%set font size of the legend
legend('Conductance','Susceptance','Location','West');%set location of legend box
set(handles.axes7,'visible','off');
set(handles.peak_center,'visible','off');
set(handles.center1,'value',1);
set(handles.primaryaxes1,'fontsize',8);
xlabel(handles.primaryaxes1,'Time (min)','fontsize',10);
ylabel(handles.primaryaxes1,'Frequency (Hz)','fontsize',10);
for dum=1:6%add labels to the conductance curves
    axname=['axes',num2str(dum)];
    set(handles.(axname),'fontsize',4);
    xlabel(handles.(axname),'Freqency (Hz)','fontsize',6);
    ylabel(handles.(axname),'mSiemens (mS)','fontsize',6);
end%for dum=1:6
%add folder paths
addpath('AccessMyVNAv0.7\AccessMyVNA','AccessMyVNAv0.7\release',...
    'AccessMyVNAv0.7\AccessMyVNA\Debug');
guidata(hObject, handles);
%set default reference time
set(handles.reference_time,'string',datestr(clock,'yy:mm:dd:HH:MM:SS:FFF'));

% UIWAIT makes testversion05 wait for user response (see UIRESUME)
% uiwait(handles.primary1);


% --- Outputs from this function are returned to the command line.
function varargout = testversion05_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in start.
function start_Callback(hObject, ~, handles)
tic
harm_tot=find_num_harms(handles);%find total active harmonics
if isempty(harm_tot)
    harm_tot=1;
end%if isempty(harm_tot)
write_settings(handles,harm_tot(1));%this function writes out the settings text file
%update string of the start button based on the toggle state
if get(handles.start,'value')==1
    set(handles.start,'string','Stop Scan','backgroundcolor','r');
else
    set(handles.start,'string','Start Scan','backgroundcolor',[0 0.5 0]);
end%if get(handles.start,'value')==1
if get(handles.start,'value')==0
    return
end%if get(handles.start,'value')==0
counter=1;%counter
%//////////////////////////////////////////////////////////////////////////
%designate output file location and name for output data
if get(handles.filename_txt,'userdata')==0
    fg_values=matfile('fg_values.mat','Writable',true);
    spectra = matfile('raw_spectras.mat','Writable',true);%open matfile and set access to writable
else
    fg_values=matfile([handles.din.output_path,handles.din.output_filename],'Writable',true);
    spectra = matfile([handles.din.output_path,handles.din.output_filename(1:end-4),'_raw_spectras.mat'],'Writable',true);%open matfile and set access to writable
end%if get(handles.filename_txt,'userdata')==0
%//////////////////////////////////////////////////////////////////////////
start_time=datenum(get(handles.reference_time,'string'),'yy:mm:dd:HH:MM:SS:FFF');%gets reference time value and sets it as start time
start_time1=datestr(start_time,'yy:mm:dd:HH:MM:SS:FFF');
start_time2=datevec(start_time1,'yy:mm:dd:HH:MM:SS:FFF');%change reference time into appropriate format
n=handles.din.n;
prev_data=zeros(1,6);%preallocate prev data
while get(handles.start,'value')==1
    disp('-------------------');
    disp('Scan initiated');
    dum=1;
    %check to see if VB has output the next harmonic
    for dum=1:size(harm_tot)        
        disp('...');
        disp(['Scanning harmonic: ', num2str(harm_tot(dum))]);
        %check to see if VB has output the next harmonic
        check=0;
        if size(harm_tot,1)~=1
            while check==0&&get(handles.start,'value')==1
                write_settings(handles,harm_tot(dum));%update the setting txt file
                handles.din.harmonic=harm_tot(dum);
                [freq,conductance,susceptance,handles]=read_scan(handles);%read the data from the output myVNA c++ output file
                if isequal(conductance,handles.din.prev_cond)==0&&size(conductance,1)==str2double(get(handles.num_datapoints,'string'))
                    disp([]);
                    check=1;
                    handles.din.prev_cond=conductance;
                else
                    disp('xxxxx');
                    disp(['Cond diff: ',num2str(sum(handles.din.prev_cond-conductance),10)]);
                    disp('Verify that AccessMyVNA program is actively scanning');
                    check=1;
                    pause;
                end%if sum(handles.din.prev_cond-conductance)~=0&&size(conductance,1)==str2double(get(handles.num_datapoints,'string'))
            end%while check==0&&get(handles.start,'value')==1
        else
            write_settings(handles,harm_tot(dum));%update the setting txt file
            handles.din.harmonic=harm_tot(dum);
            [freq,conductance,susceptance,handles]=read_scan(handles);%read the data from the output myVNA c++ output file
            check=1;
        end%if size(harm_tot,1)~=1
        if check==1
            tic
            try
%             combine_spectra=[freq,conductance,susceptance];
                %only run the following if statement if the user wants to see the it dynamically            
                if get(handles.dynamic_fit,'value')==1%this if statement will run the Lorentzian fitting function
                      [G_fit,B_fit,~,~,combine_spectra,G_parameters,B_parameters]=Lorentzian_dynamic_fit(handles,freq,conductance,susceptance,[freq,conductance,susceptance]);
                else
                    combine_spectra=[freq,conductance,susceptance,zeros(size(freq,1),4)];
                end%if get(handles.dynamic_fit,'value')==1                
            %output harmonic in appropriate axes
                ax1=['axes',num2str((harm_tot(dum)+1)*0.5)];
                axes(handles.(ax1));
            %//////////////////////////////////////////////////////////////
            %Determine variable name in which the spectra information will be stored
            time_now=datestr(clock,'yy:mm:dd:HH:MM:SS:FFF');%Current time
            time_now1=datevec(time_now,'yy:mm:dd:HH:MM:SS:FFF');%Find current time and make it a vector
            Z=time_now1 - start_time2;%Find difference in time
            time_elapsed=Z(1)*525960+Z(2)*43830+Z(3)*1440+Z(4)*60+Z(5)+Z(6)./60;%fix time into MINUTES
            time_elapsed1=strrep(num2str(time_elapsed),'.','dot');%replace decimal with 'dot'        
            if dum==1% makes sure all harmonics are recorded with same timestamp
              timestamp=time_elapsed1;
            end%if dum==1
            if dum==size(harm_tot);
                timestamp_end=time_elapsed;
            end%if dum==size(harm_tot)
            %//////////////////////////////////////////////////////////////
            %write out spectra in specified spectra filename
            spectra.(sprintf(['filename_t_%s_iq_1_ih_',num2str((harm_tot(dum)+1)./2)],timestamp)) = combine_spectra;%renames variable based on harm
            if get(handles.dynamic_fit,'value')==1
                handles.din.FG_frequency(n,1)=str2double(strrep(timestamp,'dot','.'));%timestamp
                handles.din.FG_frequency(n,harm_tot(dum)+1)=G_parameters(1);%frequency at peak of Lorentzian fit
                handles.din.FG_frequency(n,harm_tot(dum)+2)=G_parameters(2);%HMHW of Lorentzian peak
                handles.din.FG_freq_shifts(n,1)=handles.din.FG_frequency(n,1);%timestamp
                handles.din.FG_freq_shifts(n,harm_tot(dum)+1)=G_parameters(1)-handles.din.ref_freq((harm_tot(dum)+1)./2);%calculate delta f
                handles.din.FG_freq_shifts(n,harm_tot(dum)+2)=G_parameters(2)-handles.din.ref_diss((harm_tot(dum)+1)./2);  %calculate delta Gamma
                handles.din.chi_sqr_value(n,1)=str2double(strrep(timestamp,'dot','.'));%Timestamps chi squared value variable
                handles.din.chi_sqr_value(n,harm_tot(dum)+1)=sum(combine_spectra(:,6));%stores chi squared for G
                handles.din.chi_sqr_value(n,harm_tot(dum)+2)=sum(combine_spectra(:,7));%stores chi squared for B         
                if get(handles.radio_chi,'value')==1 %Show chi squared parameter on plots
                    xsq_name=['X',num2str(harm_tot(dum))];
                    set(handles.(xsq_name),'visible','on');
                    set(handles.(xsq_name),'string',['Xsq = ',num2str(handles.din.chi_sqr_value(n,harm_tot(dum)+1))]);
                end              
            end%if get(handles.dynamic_fit,'value')==1
            %//////////////////////////////////////////////////////////////
            toc
            catch
               disp('err')
            end%try
            if get(handles.start,'value')==0
                disp('Scan stopped');
            end%if get(handles.start,'value')==0
            counter=counter+1;
        else
        end%if check==1
        %/////////////////////////////////////////////////////////////////
        %plot the data set
        %this if statement code refreshes the spectra every <user-defined>th iteration of the while loop    
        if mod(counter,str2double(get(handles.refresh_spectra,'string')))==0
            disp(['Plotting harmonic: ', num2str(harm_tot(dum)),' in ',ax1]);
            cla(handles.(ax1));
            p1=plot(handles.(ax1),freq,conductance,'bx-','linewidth',1,'markersize',6);
            hold on;
            if get(handles.show_susceptance,'value')==1
                plot(freq,susceptance,'rx-','linewidth',1,'markersize',6);
            end%if get(handles.show_susceptance,'value')==1
            if get(handles.dynamic_fit,'value')==1
                plot(handles.(ax1),freq,G_fit,'k','linewidth',2);
                if get(handles.show_susceptance,'value')==1
                    plot(freq,susceptance,'rx-');
                    plot(handles.(ax1),freq,B_fit,'k','linewidth',2);
                end%if get(handles.show_susceptance,'value')==1
                plot_primaryaxes1(handles,handles.din.FG_frequency,harm_tot,n);
                n=n+1;
            end%if get(handles.dynamic_fit,'value')==1
            %set(gca,'ylim',set_ylim);
            hold off;
            ylabel(gca,'mSiemans (mS)','fontsize',6);
            xlabel(gca,'Frequency (Hz)','fontsize',6);
            drawnow
        end%if mod(counter,str2double(get(handles.refresh_spectra,'string')))==0
        %//////////////////////////////////////////////////////////////////////
        %this block of code deals with peak tracking
        [peak_detect,loc]=findpeaks(conductance,'sortstr','descend');
        peak_detect=[freq(loc(1)),peak_detect(1)];
        %//////////////////////////////////////////////////////////////////////
    end%for dum=1:size(harm_tot)
    pause(str2double(get(handles.wait_time,'string'))./1000);
end%while get(handles.start,'value')==1
%//////////////////////////////////////////////////////////////////////////
%Write out chi values into spectra file
reference=char(get(handles.reference_time,'string'),get(handles.wait_time,'string')...
    ,get(handles.num_datapoints,'string'),get(handles.record_time_increment,'string'));%records reference time 
fg_values.reference=reference;
if get(handles.dynamic_fit,'value')==1
    fg_values.abs_freq=handles.din.FG_frequency;%save f0 and gamma0 fit data to fg_values.mat
    fg_values.freq_shift=handles.din.FG_freq_shifts;
    fg_values.freq_shift_ref=[handles.din.ref_freq;handles.din.ref_diss];
    fg_values.chi_values=handles.din.chi_sqr_value;
end%if get(handles.dynamic_fit,'value')==1
%//////////////////////////////////////////////////////////////////////////
cla(handles.primaryaxes1);
handles.din.n=n;
guidata(hObject, handles);

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
if get(handles.(harmname),'value')==1
    fprintf(fileID,'%10.12f\r\n',str2double(get(handles.(startname),'string')));%write start frequency of <dum> harmonic
    fprintf(fileID,'%10.12f\r\n',str2double(get(handles.(endname),'string')));%write out end frequency of <dum> harmonic
    fprintf(fileID,'%10.12f\r\n',handles.din.freq_range((harm_num+1)./2,1));%write out lowerbound of frequency range for the harmonic
    fprintf(fileID,'%10.12f\r\n',handles.din.freq_range((harm_num+1)./2,2));%write out upperbound of frequency range for the harmonicc
end%if get(handles.(harmname),'value')==1
fclose(fileID);
%write out the settings.txt
fileID1=fopen('AccessMyVNAv0.7\release\settings.txt','w');
fprintf(fileID1,'%i\r\n',get(handles.maintain_myVNA,'value'));%write the toggle state of the maintain)myVNA radio dial
fprintf(fileID1,'%i\r\n',str2double(get(handles.wait_time,'string')));%writes the wait time between measurements
fprintf(fileID1,'%i\r\n',str2double(get(handles.num_datapoints,'string')));%writes out the number of datapoints to collect between the start and end frequencies
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
        if size(raw,1)==str2double(get(handles.num_datapoints,'string'))*2
            conductance=1e3.*raw(1:str2double(get(handles.num_datapoints,'string')));
            susceptance=1e3.*raw((str2double(get(handles.num_datapoints,'string'))+1):(str2double(get(handles.num_datapoints,'string'))*2));
            freq=[start1:(end1-start1)./str2double(get(handles.num_datapoints,'string')):end1-(end1-start1)/str2double(get(handles.num_datapoints,'string'))]';
            assignin('base','freq',freq);%output values in the "base" or global workspace
            assignin('base','conductance',conductance);
            assignin('base','susceptance',susceptance);
            flag=1;
            if handles.din.error_count>1
                set(handles.status,'string',['Status: Scan successful. Number of errors encountered: ',num2str(handles.din.error_count-1)]);
            end%if handles.din.error>1
        else
            disp(['Size of the raw output file is ',num2str(size(raw,1))])
            set(handles.num_datapoints,'string',size(raw,1)/2);
            disp('ERROR: SCAN WAS NOT COMPLETED');
            handles.din.error_log(handles.din.error_count,1)={[datestr(clock),'  ERROR: SCAN WAS NOT COMPLETED']};
            set(handles.status,'string',['Status: ERROR! Number of errors: ',num2str(handles.din.error_count),'; Attempting to correct problem...']);            
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


% --- Executes on button press in set_settings.
function set_settings_Callback(~, ~, handles)
%find active harmonics
harm_tot=find_num_harms(handles);
for dum=1:size(harm_tot,1)
    write_settings(handles,harm_tot(dum))
end%for dum=1:size(harm_tot,1)



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
if str2num(get(handles.(startname),'string'))<min_range||str2num(get(handles.(startname),'string'))>max_range
    set(handles.status,'string',...
        ['Status: ERROR: The frequency range for harmonic number ' num2str(harm),' needs to be between ',...
        num2str(min_range),' to ',num2str(max_range),' MHz! Ready...']);
    set(handles.(startname),'string',min_range);
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
if str2num(get(handles.(endname),'string'))<min_range||str2num(get(handles.(endname),'string'))>max_range
    set(handles.status,'string',...
        ['Status: ERROR: The frequency range for harmonic number ' num2str(harm),' needs to be between ',...
        num2str(min_range),' to ',num2str(max_range),' MHz! Ready...']);
    set(handles.(endname),'string',max_range);
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
function set_reference_time_Callback(hObject, eventdata, handles)
if get(handles.set_reference_time,'value')==1                        
    set(handles.reference_time,'string',datestr(clock,'yy:mm:dd:HH:MM:SS:FFF'));%automatically sets reference time when button is clicked
end



%Functions to fit a Lorentz curve to the spectra data BEGINS HERE-----------
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
function [G_fit,B_fit,G_chi_sq,B_chi_sq,combine_spectra,G_parameters,B_parameters]=Lorentzian_dynamic_fit(handles,freq,conductance,susceptance,combine_spectra)
                [MaxVal MaxInd]=max(combine_spectra,[],1);%Max of each column
                [peak_detect,index]=findpeaks(conductance,'sortstr','descend');
                Gmax=peak_detect(1);%find peak of curve
                f0=freq(index(1));%finds freq at which Gmax happens
                halfg=Gmax./2;%half of the Gmax
                halfg_freq=freq(find(abs(halfg-conductance)==min(abs((halfg-conductance))),1));
                gamma0=abs(halfg_freq-f0);%Guess for gamma, HMHW of peak
                phi=0;%Assume rotation angle is 0
                offset=0;%Assume offset value is 0
                switch get(handles.fit_mode,'value')
                    case 1%Guess value based on max conductance
                        % % % % 
                        p=[f0 gamma0 phi Gmax offset];                
                            try
                            [G_fit,G_residual,G_parameters]=fit_spectra(p,freq,conductance);
                                                      
                            %chi-squared calculation
                            error=0.003;
                            G_chi_sq=(G_residual.^2)./((error^2)*(str2double(get(handles.num_datapoints,'string'))-1));
                            if get(handles.fit_B_radio,'value')==1
                                [B_fit,B_residual,B_parameters]=fit_spectra_sus(p,freq,susceptance);
                                B_chi_sq=(B_residual.^2)./((error^2)*(str2double(get(handles.num_datapoints,'string'))-1));
                            else
                                B_fit=NaN(size(G_fit,1),size(G_fit,2));
                                B_chi_sq=B_fit;
                                B_parameters=[NaN NaN NaN NaN NaN];
                            end%if get(handles.fit_B_radio,'value')==1
                            combine_spectra=[freq,conductance,susceptance,G_fit,B_fit,G_chi_sq,B_chi_sq];
                            catch
                            end%try
                    case 2  %Guess values based on the Derivative of the Fit
                    case 3%Guess value base on the preqious fit values               
                end%switch 

function [fitted_y,residual,parameters]=fit_spectra(x0,freq_data,y_data,lb,ub)%fit spectra to conductance curve
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
if nargin==3
    lb=[-Inf -Inf 0 -Inf 0];
    ub=[Inf Inf Inf Inf Inf];
end%if nargin==3
options=optimset('display','off','tolfun',1e-10,'tolx',1e-10);
[parameters resnorm residual]=lsqcurvefit(@lfun4c,x0,freq_data,y_data,lb,ub,options);%use lsqcurvefit function to fit the spectra data to a Lorentz curve
fitted_y=lfun4c(parameters,freq_data);


function [fitted_y,residual,parameters]=fit_spectra_sus(x0,freq_data,susceptance_data,lb,ub)%fit spectra to susceptance curve
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
if nargin==3
    lb=[-Inf -Inf 0 -Inf 0];
    ub=[Inf Inf Inf Inf Inf];
end%if nargin==3
options=optimset('display','off','tolfun',1e-10,'tolx',1e-10);
[parameters resnorm residual]=lsqcurvefit(@lfun4s,x0,freq_data,susceptance_data,lb,ub,options);%use lsqcurvefit function to fit the spectra data to a Lorentz curve
fitted_y=lfun4s(parameters,freq_data);


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
F_susceptance= p(4).*((((x.^2).*((2.*p(2)).^2))./(((((p(1)).^2)-(x.^2)).^2)+...
    ((x.^2).*((2.*p(2)).^2)))).*sind(p(3))-((((p(1)).^2-x.^2)).*x.*(2.*p(2)))./...
    (((((p(1)).^2)-(x.^2)).^2)+((x.^2).*((2.*p(2)).^2))).*cosd(p(3)))+p(5);


% --- Executes on selection change in fit_mode.
function fit_mode_Callback(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
function fit_mode_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in dynamic_fit.
function dynamic_fit_Callback(hObject, eventdata, handles)

%%Functions to fit a Lorentz curve to the spectra data ENDS HERE-----------
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


%PEAK CENTERING FUNCTIONS BEGINS HERE//////////////////////////////////////
%//////////////////////////////////////////////////////////////////////////
%//////////////////////////////////////////////////////////////////////////
% --- Executes on button press in peak_centering.
function peak_centering_Callback(hObject, ~, handles)
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
    set(handles.peak_centering,'fontweight','bold','foregroundcolor','r');
    set(handles.status,'string','Status: Peak centering mode. Ready...');
else
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
    flag=1;
    check=1;
    dum=1;
            initial_end=str2double(get(handles.(['end_f',num2str(harm(dum))]),'string'));
            initial_start=str2double(get(handles.(['start_f',num2str(harm(dum))]),'string'));
            freq_range=(initial_end-initial_start).*1e6;%calculate the initial frequency range of the harmonic
            [freq,conductance,susceptance,handles]=read_scan(handles);
            f1=figure('CloseRequestFcn',{@my_closereq,handles,freq});%create a figure with a special custom close request function
            p=axes;
            set(f1,'units','normalized','position',[0.2 0.313 0.5 0.467],'toolbar','figure');%adjust location of the figure
            set(p,'units','normalized','position',[0.1 0.12 0.5 0.8],'fontsize',10);
            tbh=findall(f1,'type','uitoolbar');
            [fit_button,refresh]=my_buttons();  
            pth1=uipushtool(tbh,'cdata',fit_button,'tooltipstring','Apply a Lorentzian fit',...
                'ClickedCallback',{@myL_fit,handles,freq,conductance,susceptance,p,harm});
            pth2=uipushtool(tbh,'cdata',refresh,'tooltipstring','Refresh raw spectra data',...
                'ClickedCallback',{@refresh_button,handles,p});
            span_panel=uipanel('title','     Span     ','fontweight','bold','position',[.63 .12 .35 .8],...
                'fontsize',10,'bordertype','line','titleposition','centertop','shadowcolor','k',...
                'foregroundcolor','b');
            set_span=uicontrol('parent',span_panel,'style','edit',...
                'unit','normalized','position',[.274 0.35 0.45 0.1],...
                'fontweight','bold','fontsize',10,'backgroundcolor',[1 1 1],...
                'string',(str2double(get(handles.(['end_f',num2str(harm(dum))]),'string'))-...
                str2double(get(handles.(['start_f',num2str(harm(dum))]),'string'))).*1e6);
            increase_span_txt=uicontrol('parent',span_panel,'style','text',...
                'string','Increase span','unit','normalized','position',[0.1 0.88 0.35 0.1],...
                'fontweight','bold','fontsize',10);
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
            p1=plot(freq,conductance,'bx-','markersize',6);
            set_ylim=get(p,'ylim');
            hold on;
            plot(freq,susceptance,'rx-','markersize',6);
            set(p,'ylim',set_ylim);
            title(['Harmonic ',num2str(harm(dum))],'fontweight','bold','fontsize',10);
            hold off;
            ylabel(p,'mSiemans (mS)','fontsize',10,'fontweight','bold');
            xlabel(p,['Harmonic ',num2str(harm(dum)),' Frequency (Hz)'],'fontsize',10,'fontweight','bold');
            drawnow
            while get(handles.peak_centering,'value')==1
                axname=['axes',num2str((handles.din.harmonic+1)/2)];
                datacursormode on
                dcm_obj=datacursormode(f1);
                set(dcm_obj,'UpdateFcn',{@myupdatefcn,hObject, handles})
                c_info=getCursorInfo(dcm_obj);
                if get(handles.peak_centering,'value')==0
                   break
                end%if get(handles.view_select,'value')==0   
                zoom on;
                waitfor(handles.peak_centering,'userdata');
                if isempty(get(handles.peak_centering,'userdata'))==0
                    c_info.Position=get(handles.peak_centering,'userdata');
                end%if isempty(get(handles.view_select,'userdata'))=0
                if isfield(c_info,'Position')
                    center=c_info.Position(1);%extract the user defined peak center
                    if sum(freq_range==get(p,'xlim'))~=2
                        freq_range=abs(diff(get(p,'xlim')));%refresh window range
                    end%if flag==1
                    %redefine frequency range
                    new_start=(center-(freq_range)/2).*1e-6;
                    new_end=(center+(freq_range)/2).*1e-6;
                    disp(['Frequency range (MHz): ',num2str(new_start),' to ',num2str(new_end)]);
                    disp(['frequency span: ',num2str(freq_range)]);
                    set(handles.(['start_f',num2str(harm(dum))]),'string',num2str(new_start,10));
                    set(handles.(['end_f',num2str(harm(dum))]),'string',num2str(new_end,10));
                    write_settings(handles,harm(dum));
                    %now output scan
                    txt=text('units','normalized','position',[.1 .9 1],'string','Refreshing...','color','r','edgecolor','r');
                    while check<=length(find_num_harms(handles))
                        pause((str2double(get(handles.wait_time,'string'))/1000)*2.5);
                        [freq,conductance,susceptance,handles]=read_scan(handles);                    
                        check=check+1;
                    end%while check=1
                        delete(txt);
                        check=1;
                        cla(p);
                        p1=plot(freq,conductance,'bx-');
                        set_ylim=get(p,'ylim');
                        hold on;
                        plot(freq,susceptance,'r');
                        set(p,'ylim',set_ylim);
                        hold off;
                        drawnow
                    if get(handles.peak_centering,'value')==1
                        figure(f1);
                        flag=0;
                    end%if get(handles.peak_centering,'value')=1
                    set(pth1,'ClickedCallback',{@myL_fit,handles,freq,conductance,susceptance,p,harm});
                    set(pth2,'ClickedCallback',{@refresh_button,handles,p});
                end%if isfield(c_info,'Position')
            end%        while get(handles.peak_centering,'value')==1
        dummy=1;
        set(handles.peak_centering,'value',1);
        peak_centering_Callback(hObject,dummy,handles);
        set(handles.status,'string','Status: Peak centering successful! Ready...');
catch
end%try

% --- Executes when selected object is changed in peak_center.
function peak_center_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in peak_center 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
flag=0;
status=eventdata.EventName
current_handle=eventdata.NewValue;%get handle of current selected radial dial in peak centering panel
current_harm=get(current_handle,'userdata');
handles.din.harmonic=current_harm;%store current harmonic (from peak centering panel) in handles structure
harm_tot=find_num_harms(handles);%find the total number of active harmonics from the harmonics panel (not the peak centering panel)
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
center_peak_function(handles,current_harm,hObject);%center the peak of the selected harmonic fromthe peak centering panel
%revert active harmonics back to initial state
%first turn off all harmonics
for dum=1:2:11
    harm_name=['harm',num2str(dum)];
    set(handles.(harm_name),'value',0);
end%for dum=1:2:11
%turn back initial active harmonics back on
for dum=1:length(harm_tot)
    harm_name=['harm',num2str(harm_tot(dum))];
    set(handles.(harm_name),'value',1);
end%for dum=1:length(harm_tot)
if flag==1%if the start button was running previously, turn it back on
    set(handles.start,'value',1);
end%flag==1

function output_txt = myupdatefcn(~,event_obj,~, handles)
% This is the function that runs when datacursormode is employed. The
% output output-txt is what appears in the box.

%Determines output box--this is the usual function of datacursor, modified
%to know what the x axis actually is.
pos = get(event_obj,'Position');
output_txt = {['Frequency ',num2str(pos(1),5),' Hz'],...
    ['Y data: ',num2str(pos(2),5)]};
set(handles.peak_centering,'userdata',pos);

%this function that runs when the user exsits out of the
%peak_centering figure window
    function my_closereq(src,evnt,handles,freq)
% User-defined close request function 
% to display a question dialog box 
if isempty(get(handles.peak_centering,'userdata'))
    set(handles.peak_centering,'userdata',[mean(freq),1]);
else
    set(handles.peak_centering,'userdata',[]);
end%if isempty(handles.peak_centering,'userdata')
datacursormode off
delete(gcf)
for dum=1:2:11
    harm_name=['center',num2str(dum)];
    set(handles.(harm_name),'value',0);
end%for dum=1:2:11

%This function that runs when the user clicks on the "Fit"
%button in the figure toolbar of the peak_centering window
    function myL_fit(hObject,eventdata,handles,freq,conductance,susceptance,p,harm_tot)
        combine_spectra=[freq,conductance,susceptance];
        [G_fit,B_fit,G_chi_sq,B_chi_sq,~,~,~]=Lorentzian_dynamic_fit(handles,freq,conductance,susceptance,combine_spectra);
        cla(p);
        plot(p,freq,conductance,'bx-','markersize',6,'linewidth',1);
        get_ylim=get(p,'ylim');
        hold on;
        plot(freq,susceptance,'rx-','markersize',6,'linewidth',1);
        set(p,'ylim',get_ylim);
        plot(freq,G_fit,'k-','linewidth',2);
        plot(freq,B_fit,'k-','linewidth',2);
        ylabel(p,'mSiemans (mS)','fontsize',10);
        xlabel(p,['Harmonic ',num2str(harm_tot),' Frequency (Hz)'],'fontsize',10);
        drawnow;

%this function that runs when the refresh button is pressed
%in the toolbar of the peak_centering figure window (this refreshes the raw
%conductance spectra)
    function refresh_button(hObject,eventdata,handles,p)
        cla(p);
        txt=text('units','normalized','position',[.1 .9 1],'string','Refreshing...','color','r','edgecolor','r');
        pause((str2double(get(handles.wait_time,'string'))/1000)*2);
        [freq,conductance,susceptance,handles]=read_scan(handles);
        plot(p,freq,conductance,'bx-','markersize',6,'linewidth',1);
        get_ylim=get(p,'ylim');
        hold on;
        plot(freq,susceptance,'rx-','markersize',6,'linewidth',1);
        set(p,'ylim',get_ylim);
        drawnow;
        try
            delete(txt);
        catch
        end%try
        
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
        set(set_span,'string',new_end1-new_start1);
        write_settings(handles,harm);
        refresh_button(hObject,eventdata,handles,p);
        
        
            
%PEAK CENTERING FUNCTIONS ENDS HERE////////////////////////////////////////
%//////////////////////////////////////////////////////////////////////////
%//////////////////////////////////////////////////////////////////////////


% --- Executes on button press in cla_raw.
%This function clears all raw spectra
function cla_raw_Callback(hObject, ~, handles)
cla(handles.axes1);
cla(handles.axes2);
cla(handles.axes3);
cla(handles.axes4);
cla(handles.axes5);
cla(handles.axes6);
cla(handles.primaryaxes1);
cla(handles.primaryaxes2);
for dum=1:6
    chi_name=['X',num2str(dum*2-1)];
    set(handles.(chi_name),'string','Xsq = ');
end%for dum=1:6
handles.din.prev_cond=zeros(str2double(get(handles.num_datapoints,'string')),1);
guidata(hObject, handles);

% --- Executes on button press in clear_datapoints.
function clear_datapoints_Callback(hObject, eventdata, handles)
backup=
handles.din.FG_frequency=NaN(handles.din.max_datapts,13);
handles.din.FG_freq_shifts=NaN(handles.din.max_datapts,13);
handles.din.chi_sqr_value=NaN(handles.din.max_datapts,13);
guidata(hObject, handles);

function wait_time_Callback(~, ~, handles)
set(handles.status,'string','Status: WARNING: CHANGING THE TIME B/W MEASUREMNTS CAN CAUSE SYNC PROBLEMS! Ready...');

function num_datapoints_Callback(~, ~, handles)
num_datapoints=str2double(get(handles.num_datapoints,'string'));
round_num_datapoints=round(num_datapoints/100)*100;
set(handles.num_datapoints,'string',round_num_datapoints);
set(handles.status,'string','Status: WARNING: CHANGING THE # OF DATAPOINTS CAN CAUSE SYNC PROBLEMS! Ready...');


% --- Executes on button press in show_susceptance.
function show_susceptance_Callback(hObject, eventdata, handles)


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
    if get(handles.radio_chi,'value')==1
        set(handles.radio_chi,'value',0);
        set(handles.status,'string','Status: Error! The Dynamic Fit option must be selected! Ready...');
        set(handles.dynamic_fit,'value',1);
    else
        set(handles.status,'string','Status: Ready...');
    end% if get(handles.radio_chi,'value')==1
end%if get(handles.dynamic_fit,'value')==1



%this function creates a new figure showing the selected raw conductance
%spectra
function raw_fig_Callback(~, ~, handles)
set(handles.raw_fig,'userdata',[100]);
while get(handles.raw_fig,'value')==1
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
                  [G_fit,B_fit,G_chi_sq,B_chi_sq,combine_spectra,~,~]=Lorentzian_dynamic_fit(handles,freq,conductance,susceptance,combine_spectra);
            end%if get(handles.dynamic_fit,'value')==1   
            f1=figure(dum);
            clf(figure(dum));
            a=axes;
            plot(a,freq,conductance,'bx-','linewidth',1.5,'markersize',8);
            hold on;
            if get(handles.dynamic_fit,'value')==1%this if statement will run the Lorentzian fitting function            
                plot(freq,G_fit,'k','linewidth',2);
                text('units','normalized','position',[.02 .95 1],'string',['Xsq = ',num2str(sum(G_chi_sq))],...
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
    end%for dum=1:6
%     get(handles.raw_fig,'userdata')
%     waitfor(handles.raw_fig,'userdata');
end%while get(handles.raw_fig,'value')==1
set(handles.raw_fig,'fontweight','normal','foregroundcolor','k','userdata',[0]);


% --- Executes on button press in fix_span.
function fix_span_Callback(hObject, eventdata, handles)



% --- Executes on button press in fix_center.
function fix_center_Callback(hObject, eventdata, handles)



%this function saves settings into an output file
function save_settings_Callback(hObject, eventdata, handles)
settings.maintain_myVNA=get(handles.maintain_myVNA,'value');
settings.harm1=get(handles.harm1,'value');
settings.harm3=get(handles.harm3,'value');
settings.harm5=get(handles.harm5,'value');
settings.harm7=get(handles.harm7,'value');
settings.harm9=get(handles.harm9,'value');
settings.harm11=get(handles.harm11,'value');
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
settings.fix_span=get(handles.fix_span,'value');
settings.fix_center=get(handles.fix_center,'value');
settings.refresh_spectra=get(handles.refresh_spectra,'string');
settings.reference_time=get(handles.reference_time,'string');
settings.wait_time=get(handles.wait_time,'string');
settings.num_datapoints=get(handles.num_datapoints,'string');
settings.record_time_increment=get(handles.record_time_increment,'string');
settings.dynamic_fit=get(handles.dynamic_fit,'value');
settings.radio_chi=get(handles.radio_chi,'value');
settings.fit_mode=get(handles.fit_mode,'value');
settings.freq_format=get(handles.freq_format,'value');
settings.output_filename=handles.din.output_filename;
settings.output_path=handles.din.output_path;
save([handles.din.output_path,handles.din.output_filename(1:end-4),'_settings.mat'],'settings');
set(handles.status,'string',['Status: Settings succesfully saved! ',handles.din.output_filename(1:end-4),'_settings.mat']);

function record_time_increment_Callback(hObject, eventdata, handles)
% hObject    handle to record_time_increment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of record_time_increment as text
%        str2double(get(hObject,'String')) returns contents of record_time_increment as a double


%Load settings that are saved
function load_settings_Callback(hObject, eventdata, handles)
try
   variables=open([handles.din.output_path,handles.din.output_filename(1:end-4),'_settings.mat']);
   settings=variables.settings;
   clear('variables');
catch
    try
        [settings_filename,settings_path]=uigetfile('*.mat');
        load([settings_path,settings_filename]);
    catch
        set(handles.status,'string','Status: ERROR! Unable to load settings file. Ready...');
    end%try
end%try
try
    set(handles.maintain_myVNA,'value',settings.maintain_myVNA);
    set(handles.harm1,'value',settings.harm1);
    set(handles.harm3,'value',settings.harm3);
    set(handles.harm5,'value',settings.harm5);
    set(handles.harm7,'value',settings.harm7);
    set(handles.harm9,'value',settings.harm9);
    set(handles.harm11,'value',settings.harm11);
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
    set(handles.fix_span,'value',settings.fix_span);
    set(handles.fix_center,'value',settings.fix_center);
    set(handles.refresh_spectra,'string',settings.refresh_spectra);
    set(handles.reference_time,'string',settings.reference_time);
    set(handles.wait_time,'string',settings.wait_time);
    set(handles.num_datapoints,'string',settings.num_datapoints);
    set(handles.record_time_increment,'string',settings.record_time_increment);
    set(handles.dynamic_fit,'value',settings.dynamic_fit);
    set(handles.radio_chi,'value',settings.radio_chi);
    set(handles.fit_mode,'value',settings.fit_mode);
    set(handles.freq_format,'value',settings.freq_format);
    handles.din.output_path=settings.output_path;
    handles.din.output_filename=settings.output_filename;
    set(handles.filename_txt,'tooltipstring',[handles.din.output_path,handles.din.output_filename]);
    set(handles.status,'string',['Status: Settings, ',settings.output_filename,...
        ', succesfully loaded!']);
catch
    set(handles.status,'string','Status: ERROR! Unable to load settings file. Ready...');
end%try


% --- Executes on selection change in plot1_choice.
function plot1_choice_Callback(hObject, eventdata, handles)
choice=get(handles.plot1_choice,'value');
axes(handles.primaryaxes1);
font_size=12;
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
end%switch choice
    


% --- Executes during object creation, after setting all properties.
function plot1_choice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plot1_choice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%This functions will output the data into a user specified filename and
%path
function save_data_Callback(hObject, ~, handles)
[output_filename,output_path]=uiputfile('*.mat');
full_filename=[output_path,output_filename];
set(handles.filename_txt,'string',[full_filename(1:10),'...',full_filename(end-10:end)],...
    'tooltipstring',full_filename,'userdata',1);%output filename info
handles.din.output_filename=output_filename;
handles.din.output_path=output_path;
guidata(hObject, handles);


% --- Executes on selection change in plot2_choice.
function plot2_choice_Callback(hObject, eventdata, handles)
% hObject    handle to plot2_choice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns plot2_choice contents as cell array
%        contents{get(hObject,'Value')} returns selected item from plot2_choice


% --- Executes during object creation, after setting all properties.
function plot2_choice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plot2_choice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function plot_primaryaxes1(handles,FG_frequency,harm_tot,n)
    tic
axes(handles.primaryaxes1);
active_plot_harmonics=[];
flag=1;
for dum=1:2:11
    plot_name_dial=['plot_',num2str(dum)];
    if get(handles.(plot_name_dial),'value')==1&&sum(harm_tot==dum)==1
        active_plot_harmonics=[active_plot_harmonics,dum];
        flag=flag+1;
    end%if get(handles.(plot_name_dial),'value')==1
end%dum=1:2:11
switch get(handles.plot1_choice,'value')
    case 2%plot frequency shift versus time
        for dum=1:length(active_plot_harmonics)
            F_frequency_shifts=FG_frequency(:,active_plot_harmonics(dum)+1)-handles.din.ref_freq((active_plot_harmonics(dum)+1)./2);
%             G_frequency_shifts= FG_frequency(:,active_plot_harmonics(dum)+2)-handles.din.ref_diss((active_plot_harmonics(dum)+1)./2);
            plot(FG_frequency(1:n,1),F_frequency_shifts(1:n),'bx');hold on;
            if (max(FG_frequency(:,1)))>=max(get(gca,'xlim'))*1.3
                set(gca,'xlim',[FG_frequency(1,1)-1, max(FG_frequency(:,1))*1.2]);
            end% if (max(FG_frequency(:,1)))>=get(gca,'xlim')(1,2)-10
            drawnow
        end%for dum=1:length(active_plot_harmonics)
    case 3%plot frequency shift/harmonic order versus time
        for dum=1:length(active_plot_harmonics)
            F_frequency_shifts=FG_frequency(:,active_plot_harmonics(dum)+1)-handles.din.ref_freq((active_plot_harmonics(dum)+1)./2);
%             G_frequency_shifts= FG_frequency(:,active_plot_harmonics(dum)+2)-handles.din.ref_diss((active_plot_harmonics(dum)+1)./2);
            plot(FG_frequency(1:n,1),F_frequency_shifts(1:n)./active_plot_harmonics(dum),'bx');hold on;
            if (max(FG_frequency(:,1)))>=max(get(gca,'xlim'))*1.3
                set(gca,'xlim',[FG_frequency(1,1)-1, max(FG_frequency(:,1))*1.2]);
            end% if (max(FG_frequency(:,1)))>=get(gca,'xlim')(1,2)-10
            drawnow
        end%for dum=1:length(active_plot_harmonics)        
    case 4     
        for dum=1:length(active_plot_harmonics)
%             F_frequency_shifts=FG_frequency(:,active_plot_harmonics(dum)+1)-handles.din.ref_freq((active_plot_harmonics(dum)+1)./2);
            G_frequency_shifts= FG_frequency(:,active_plot_harmonics(dum)+2)-handles.din.ref_diss((active_plot_harmonics(dum)+1)./2);
            plot(FG_frequency(1:n,1),G_frequency_shifts(1:n),'bx');hold on;
            if (max(FG_frequency(:,1)))>=max(get(gca,'xlim'))*1.3
                set(gca,'xlim',[FG_frequency(1,1)-1, max(FG_frequency(:,1))*1.2]);
            end% if (max(FG_frequency(:,1)))>=get(gca,'xlim')(1,2)-10
            drawnow
        end%for dum=1:length(active_plot_harmonics)        
    case 5
        for dum=1:length(active_plot_harmonics)
%             F_frequency_shifts=FG_frequency(:,active_plot_harmonics(dum)+1)-handles.din.ref_freq((active_plot_harmonics(dum)+1)./2);
            G_frequency_shifts= FG_frequency(:,active_plot_harmonics(dum)+2)-handles.din.ref_diss((active_plot_harmonics(dum)+1)./2);
            plot(FG_frequency(1:n,1),G_frequency_shifts(1:n)./active_plot_harmonics(dum),'bx');hold on;
            if (max(FG_frequency(:,1)))>=max(get(gca,'xlim'))*1.3
                set(gca,'xlim',[FG_frequency(1,1)-1, max(FG_frequency(:,1))*1.2]);
            end% if (max(FG_frequency(:,1)))>=get(gca,'xlim')(1,2)-10
            drawnow
        end%for dum=1:length(active_plot_harmonics)           
end
hold off;
disp('primaryaxes1 updated');
toc


function plot_primaryaxes2(handles,FG_frequency,harm_tot,n)
    tic
axes(handles.primaryaxes1);
active_plot_harmonics=[];
flag=1;
for dum=1:2:11
    plot_name_dial=['plot_',num2str(dum)];
    if get(handles.(plot_name_dial),'value')==1&&sum(harm_tot==dum)==1
        active_plot_harmonics=[active_plot_harmonics,dum];
        flag=flag+1;
    end%if get(handles.(plot_name_dial),'value')==1
end%dum=1:2:11
switch get(handles.plot2_choice,'value')
    case 2%plot frequency shift versus time
        for dum=1:length(active_plot_harmonics)
            F_frequency_shifts=FG_frequency(:,active_plot_harmonics(dum)+1)-handles.din.ref_freq((active_plot_harmonics(dum)+1)./2);
%             G_frequency_shifts= FG_frequency(:,active_plot_harmonics(dum)+2)-handles.din.ref_diss((active_plot_harmonics(dum)+1)./2);
            plot(FG_frequency(1:n,1),F_frequency_shifts(1:n),'bx');hold on;
            if (max(FG_frequency(:,1)))>=max(get(gca,'xlim'))*1.3
                set(gca,'xlim',[FG_frequency(1,1)-1, max(FG_frequency(:,1))*1.2]);
            end% if (max(FG_frequency(:,1)))>=get(gca,'xlim')(1,2)-10
            drawnow
        end%for dum=1:length(active_plot_harmonics)
    case 3%plot frequency shift/harmonic order versus time
        for dum=1:length(active_plot_harmonics)
            F_frequency_shifts=FG_frequency(:,active_plot_harmonics(dum)+1)-handles.din.ref_freq((active_plot_harmonics(dum)+1)./2);
%             G_frequency_shifts= FG_frequency(:,active_plot_harmonics(dum)+2)-handles.din.ref_diss((active_plot_harmonics(dum)+1)./2);
            plot(FG_frequency(1:n,1),F_frequency_shifts(1:n)./active_plot_harmonics(dum),'bx');hold on;
            if (max(FG_frequency(:,1)))>=max(get(gca,'xlim'))*1.3
                set(gca,'xlim',[FG_frequency(1,1)-1, max(FG_frequency(:,1))*1.2]);
            end% if (max(FG_frequency(:,1)))>=get(gca,'xlim')(1,2)-10
            drawnow
        end%for dum=1:length(active_plot_harmonics)        
    case 4     
        for dum=1:length(active_plot_harmonics)
%             F_frequency_shifts=FG_frequency(:,active_plot_harmonics(dum)+1)-handles.din.ref_freq((active_plot_harmonics(dum)+1)./2);
            G_frequency_shifts= FG_frequency(:,active_plot_harmonics(dum)+2)-handles.din.ref_diss((active_plot_harmonics(dum)+1)./2);
            plot(FG_frequency(1:n,1),G_frequency_shifts(1:n),'bx');hold on;
            if (max(FG_frequency(:,1)))>=max(get(gca,'xlim'))*1.3
                set(gca,'xlim',[FG_frequency(1,1)-1, max(FG_frequency(:,1))*1.2]);
            end% if (max(FG_frequency(:,1)))>=get(gca,'xlim')(1,2)-10
            drawnow
        end%for dum=1:length(active_plot_harmonics)        
    case 5
        for dum=1:length(active_plot_harmonics)
%             F_frequency_shifts=FG_frequency(:,active_plot_harmonics(dum)+1)-handles.din.ref_freq((active_plot_harmonics(dum)+1)./2);
            G_frequency_shifts= FG_frequency(:,active_plot_harmonics(dum)+2)-handles.din.ref_diss((active_plot_harmonics(dum)+1)./2);
            plot(FG_frequency(1:n,1),G_frequency_shifts(1:n)./active_plot_harmonics(dum),'bx');hold on;
            if (max(FG_frequency(:,1)))>=max(get(gca,'xlim'))*1.3
                set(gca,'xlim',[FG_frequency(1,1)-1, max(FG_frequency(:,1))*1.2]);
            end% if (max(FG_frequency(:,1)))>=get(gca,'xlim')(1,2)-10
            drawnow
        end%for dum=1:length(active_plot_harmonics)           
end
hold off;
disp('primaryaxes1 updated');
toc


% --- Executes on button press in plot_1st.
function plot_1st_Callback(hObject, eventdata, handles)
% hObject    handle to plot_1st (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plot_1st


% --- Executes on button press in plot_3rd.
function plot_3rd_Callback(hObject, eventdata, handles)
% hObject    handle to plot_3rd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plot_3rd


% --- Executes on button press in plot_5th.
function plot_5th_Callback(hObject, eventdata, handles)
% hObject    handle to plot_5th (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plot_5th


% --- Executes on button press in plot_7th.
function plot_7th_Callback(hObject, eventdata, handles)
% hObject    handle to plot_7th (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plot_7th


% --- Executes on button press in plot_9th.
function plot_9th_Callback(hObject, eventdata, handles)
% hObject    handle to plot_9th (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plot_9th


% --- Executes on button press in plot_11th.
function plot_11th_Callback(hObject, eventdata, handles)
% hObject    handle to plot_11th (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plot_11th

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


% --- Executes on button press in plot2_1.
function plot2_1_Callback(hObject, eventdata, handles)



% --- Executes on button press in plot2_3.
function plot2_3_Callback(hObject, eventdata, handles)



% --- Executes on button press in plot2_5.
function plot2_5_Callback(hObject, eventdata, handles)



% --- Executes on button press in plot2_7.
function plot2_7_Callback(hObject, eventdata, handles)



% --- Executes on button press in plot2_9.
function plot2_9_Callback(hObject, eventdata, handles)



% --- Executes on button press in plot2_11.
function plot2_11_Callback(hObject, eventdata, handles)



% --- Executes on button press in fit_B_radio.
function fit_B_radio_Callback(hObject, eventdata, handles)



