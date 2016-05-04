function varargout = testversion04(varargin)
% TESTVERSION04 MATLAB code for testversion04.fig
%      TESTVERSION04, by itself, creates a new TESTVERSION04 or raises the existing
%      singleton*.
%
%      H = TESTVERSION04 returns the handle to a new TESTVERSION04 or the handle to
%      the existing singleton*.
%
%      TESTVERSION04('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TESTVERSION04.M with the given input arguments.
%
%      TESTVERSION04('Property','Value',...) creates a new TESTVERSION04 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before testversion04_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to testversion04_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help testversion04

% Last Modified by GUIDE v2.5 11-Mar-2014 10:51:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @testversion04_OpeningFcn, ...
                   'gui_OutputFcn',  @testversion04_OutputFcn, ...
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


% --- Executes just before testversion04 is made visible.
function testversion04_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to testversion04 (see VARARGIN)

% Choose default command line output for testversion04
handles.output = hObject;

% Update handles structure
handles.din.freq_range=[4 6; 14 16; 24 26; 34 36; 44 46; 54 56];%this stores the accepted frequency ranges for each harmonic
handles.din.avail_harms=[1 3 5 7 9 11];
handles.din.error_count=1;%declar an error log vounter variable that is stored int he handles structure
handles.din.error_log={};%declare an error log variable that is stored in the handles structure
handles.din.prev_cond=zeros(str2double(get(handles.num_datapoints,'string')),1);
handles.din.harmonic=1;
axes(handles.axes7);
plot(handles.axes7,[0,1],[0,0],'-',[0,1],[0,0],'r-','visible','off');%add a legend box for the raw conductance plots
set(gca,'fontsize',6);%set font size of the legend
legend('Conductance','Susceptance','Location','West');%set location of legend box
set(handles.axes7,'visible','off');
set(handles.peak_center,'visible','off');
set(handles.center1,'value',1);
for dum=1:6%add labels to the conductance curves
    axname=['axes',num2str(dum)];
    set(handles.(axname),'fontsize',4);
    xlabel(handles.(axname),'Freqency (Hz)','fontsize',6);
    ylabel(handles.(axname),'mSiemens (mS)','fontsize',6);
end%for dum=1:6
%add folder paths
addpath('AccessMyVNAv0.7/AccessMyVNA','AccessMyVNAv0.7/AccessMyVNA/Release',...
    'AccessMyVNAv0.7/AccessMyVNA/Debug');
guidata(hObject, handles);
%set default reference time
set(handles.reference_time,'string',datestr(clock,'yy:mm:dd:HH:MM:SS:FFF'));

% UIWAIT makes testversion04 wait for user response (see UIRESUME)
% uiwait(handles.primary1);


% --- Outputs from this function are returned to the command line.
function varargout = testversion04_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in start.
function start_Callback(hObject, eventdata, handles)
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
counter=1;%counter
spectra = matfile('spectra1.mat','Writable',true);%open matfile and set access to writable
spectra_data=matfile('spectra_data.mat','Writable',true);
start_time=datenum(get(handles.reference_time,'string'),'yy:mm:dd:HH:MM:SS:FFF');%gets reference time value and sets it as start time
start_time1=datestr(start_time,'yy:mm:dd:HH:MM:SS:FFF');
start_time2=datevec(start_time1,'yy:mm:dd:HH:MM:SS:FFF');%change reference time into appropriate format
%x=NaN(str2double(get(handles.num_datapoints,'string')),13);%preallocated matrix for f0 and gamma0 data
x=zeros(100000,13);
chi_values=zeros(100000,13);
n=1;
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
                fileID_state=fopen('state_vna.txt');
                state=cell2mat(textscan(fileID_state,'%f'));
                fclose(fileID_state);
                handles.din.harmonic=harm_tot(dum);
                [freq,conductance,susceptance,handles]=read_scan(handles);%read the data from the output myVNA c++ output file
                if isequal(conductance,handles.din.prev_cond)==0&&size(conductance,1)==str2double(get(handles.num_datapoints,'string'))
                    disp([]);
                    check=1;
                    handles.din.prev_cond=conductance;
                else
                    disp('xxxxx');
                    disp(['Cond diff: ',num2str(sum(handles.din.prev_cond-conductance),10)]);
                    keyboard
                end%if sum(handles.din.prev_cond-conductance)~=0&&size(conductance,1)==str2double(get(handles.num_datapoints,'string'))
            end%while check==0&&get(handles.start,'value')==1
        else
            write_settings(handles,harm_tot(dum));%update the setting txt file
            fileID_state=fopen('state_vna.txt');
            state=cell2mat(textscan(fileID_state,'%f'));
            fclose(fileID_state);
            handles.din.harmonic=harm_tot(dum);
            [freq,conductance,susceptance,handles]=read_scan(handles);%read the data from the output myVNA c++ output file
            check=1;
        end%if size(harm_tot,1)~=1
        if check==1
            tic
            try
            combine_spectra=[freq,conductance,susceptance];
                %only run the following if statement if the user wants to see the it dynamically            
                if get(handles.dynamic_fit,'value')==1%this if statement will run the Lorentzian fitting function
                      [G_fit,B_fit,G_chi_sq,B_chi_sq,combine_spectra,halfg,halfg_freq]=Lorentzian_dynamic_fit(handles,freq,conductance,susceptance,combine_spectra);
                end%if get(handles.dynamic_fit,'value')==1                
            %output harmonic in appropriate axes
                ax1=['axes',num2str((harm_tot(dum)+1)*0.5)];
                axes(handles.(ax1));
            %plot the data set
            %this if statement code refreshes the spectra every <user-defined>th iteration of the while loop    
            if mod(counter,str2double(get(handles.refresh_spectra,'string')))==0
                disp(['Plotting harmonic: ', num2str(harm_tot(dum)),' in ',ax1]);
                p1=plot(handles.(ax1),freq,conductance,'bx-');
                hold on;
                if get(handles.show_susceptance,'value')==1
                    plot(freq,susceptance,'rx-');
                end%if get(handles.show_susceptance,'value')==1
                if get(handles.dynamic_fit,'value')==1
                    plot(handles.(ax1),freq,G_fit,'k','linewidth',2);
                    if get(handles.show_susceptance,'value')==1
                        plot(freq,susceptance,'rx-');
                        plot(handles.(ax1),freq,B_fit,'k','linewidth',2);
                    end%if get(handles.show_susceptance,'value')==1
                end%if get(handles.dynamic_fit,'value')==1
                %set(gca,'ylim',set_ylim);
                hold off;
                ylabel(gca,'mSiemans (mS)','fontsize',6);
                xlabel(gca,'Frequency (Hz)','fontsize',6);
                drawnow
            end%if mod(counter,str2double(get(handles.refresh_spectra,'string')))==0
            %Determine variable name in which the spectra information will be stored
            time_now=datestr(clock,'yy:mm:dd:HH:MM:SS:FFF');%Current time
            time_now1=datevec(time_now,'yy:mm:dd:HH:MM:SS:FFF');%Find current time and make it a vector
            Z=time_now1 - start_time2;%Find difference in time
            time_elapsed=Z(1)*525960+Z(2)*43830+Z(3)*1440+Z(4)*60+Z(5)+Z(6)./60;%fix time into minutes
            time_elapsed1=strrep(num2str(time_elapsed),'.','dot');%replace decimal with 'dot'        
            if dum==1% makes sure all harmonics are recorded with same timestamp
              timestamp=time_elapsed1;
            end%if dum==1
            if dum==size(harm_tot);
                timestamp_end=time_elapsed;
            end%if dum==size(harm_tot)
            %write out spectra in specified spectra filename
            spectra.(sprintf(['filename_t_%s_iq_1_ih_',num2str((harm_tot(dum)+1)./2)],timestamp)) = combine_spectra;%renames variable based on harm
            if get(handles.dynamic_fit,'value')==1
                [MaxVal MaxInd]=max(combine_spectra,[],1);%Max of each column
                Gmax_fit=MaxVal(4);%Maximum value of conductance
                f0_fit=combine_spectra(MaxInd(4),1);%finds freq at which Gmax happens
                halfg_fit=Gmax_fit./2;%half of the Gmax
                halfg_freq_fit=combine_spectra(find(abs(halfg-combine_spectra(:,4))==min(abs((halfg-combine_spectra(:,4))))),1);
                gamma0_fit=abs(halfg_freq-combine_spectra(MaxInd(4),1)).*2;%Twice the difference from halfg and peak freq
                x(n,1)=str2double(strrep(timestamp,'dot','.'));
                x(n,harm_tot(dum)+1)=f0_fit;
                x(n,harm_tot(dum)+2)=gamma0_fit;                
                chi_values(n,1)=str2double(strrep(timestamp,'dot','.'));%Timestamps chi value variable
                chi_values(n,harm_tot(dum)+1)=sum(combine_spectra(:,6));%stores chi squared for G
                chi_values(n,harm_tot(dum)+2)=sum(combine_spectra(:,7));%stores chi squared for B         
                if get(handles.radio_chi,'value')==1 %Show chi squared parameter on plots
                    xsq_name=['X',num2str(harm_tot(dum))];
                    set(handles.(xsq_name),'visible','on');
                    set(handles.(xsq_name),'string',['Xsq = ',num2str(chi_values(n-1,harm_tot(dum)+1)./1e3)]);
                end
                
            end%if get(handles.dynamic_fit,'value')==1             
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
    end%for dum=1:size(harm_tot)
    if get(handles.dynamic_fit,'value')==1
        %x(n,1)=.5*(str2double(strrep(timestamp,'dot','.'))+str2double(strrep(timestamp_end,'dot','.')));
        n=n+1;
    end%if get (handles.dynamic_fit,'value')==1
end%while get(handles.start,'value')==1
reference=char(get(handles.reference_time,'string'),get(handles.wait_time,'string')...
    ,get(handles.num_datapoints,'string'),get(handles.record_time_increment,'string'));%records reference time 
spectra_data.reference=reference;
if get(handles.dynamic_fit,'value')==1
        X=sum(x');
        Y=sum(chi_values');
        rows_of_zeros=find(X==0);
        rows_of_zeroes1=find(Y==0);
        x(rows_of_zeros,:)=[];
        chi_values(rows_of_zeroes1,:)=[];
        spectra_data.data=x;%save f0 and gamma0 fit data to spectra_data.mat
        spectra_data.chi_values=chi_values;
end
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
write_settings(handles,harm_num);

function write_settings(handles,harm_num)
% This if statement writes out the setting.txt file
if harm_num<11
    filename=['AccessMyVNAv0.7\AccessMyVNA\settings0',num2str(harm_num),'.txt'];
else
    filename=['AccessMyVNAv0.7\AccessMyVNA\settings',num2str(harm_num),'.txt'];
end%if harm_num<11
fileID=fopen(filename,'w');%write settings value into the settings.txt file
harmname=['harm',num2str(harm_num)];
startname=['start_f',num2str(harm_num)];
endname=['end_f',num2str(harm_num)];
if get(handles.(harmname),'value')==1
    fprintf(fileID,'%10.12f\r\n',str2double(get(handles.(startname),'string')));%write start frequency of <dum> harmonic
    fprintf(fileID,'%10.12f\r\n',str2double(get(handles.(endname),'string')));%write out end frequency of <dum> harmonic
end%if get(handles.(harmname),'value')==1
fclose(fileID);
fileID1=fopen('AccessMyVNAv0.7\AccessMyVNA\settings.txt','w');
fprintf(fileID1,'%i\r\n',get(handles.maintain_myVNA,'value'));%write the toggle state of the start button
fprintf(fileID1,'%i\r\n',str2double(get(handles.wait_time,'string')));%writes the wait time between measurements
fprintf(fileID1,'%i\r\n',str2double(get(handles.num_datapoints,'string')));
numberofharms=size(find_num_harms(handles),1);
fprintf(fileID1,'%i\r\n',numberofharms);%write number of harmonics
fprintf(fileID1,'%i\r\n',find_num_harms(handles));%write number of harmonics
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
        disp(['rawdatafile: ',rawfile]);
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

                
% --- Executes on button press in radio_update_spectra.
function radio_update_spectra_Callback(hObject, eventdata, handles)



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
write_settings(handles,1);
% --- Executes during object creation, after setting all properties.
function start_f1_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function end_f1_Callback(~, ~, handles)
check_freq_range(1, handles.din.freq_range(1,1), handles.din.freq_range(1,2), handles);
% --- Executes during object creation, after setting all properties.
function end_f1_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%THIRD HARMONIC
function start_f3_Callback(~, ~, handles)
check_freq_range(3, handles.din.freq_range(2,1), handles.din.freq_range(2,2), handles);
% write_settings(handles,3);
% --- Executes during object creation, after setting all properties.
function start_f3_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function end_f3_Callback(~, ~, handles)
check_freq_range(3, handles.din.freq_range(2,1), handles.din.freq_range(2,2), handles);
% --- Executes during object creation, after setting all properties.
function end_f3_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%5TH HARMONIC
function start_f5_Callback(~, ~, handles)
check_freq_range(5, handles.din.freq_range(3,1), handles.din.freq_range(3,2), handles);
% write_settings(handles,5);
% --- Executes during object creation, after setting all properties.
function start_f5_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function end_f5_Callback(~, ~, handles)
check_freq_range(5, handles.din.freq_range(3,1), handles.din.freq_range(3,2), handles);
% --- Executes during object creation, after setting all properties.
function end_f5_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%7TH HARMONIC
function start_f7_Callback(~, ~, handles)
check_freq_range(7, handles.din.freq_range(4,1), handles.din.freq_range(4,2), handles);
% write_settings(handles,7);
% --- Executes during object creation, after setting all properties.
function start_f7_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function end_f7_Callback(~, ~, handles)
check_freq_range(7, handles.din.freq_range(4,1), handles.din.freq_range(4,2), handles);
% --- Executes during object creation, after setting all properties.
function end_f7_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%9TH HARMONIC
function start_f9_Callback(~, ~, handles)
check_freq_range(9, handles.din.freq_range(5,1), handles.din.freq_range(5,2), handles);
% write_settings(handles,9);
% --- Executes during object creation, after setting all properties.
function start_f9_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function end_f9_Callback(~, ~, handles)
check_freq_range(9, handles.din.freq_range(5,1), handles.din.freq_range(5,2), handles);
% --- Executes during object creation, after setting all properties.
function end_f9_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%11TH HARMONIC
function start_f11_Callback(~, ~, handles)
check_freq_range(11, handles.din.freq_range(6,1), handles.din.freq_range(6,2), handles);
% write_settings(handles,11);
% --- Executes during object creation, after setting all properties.
function start_f11_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function end_f11_Callback(~, ~, handles)
check_freq_range(1, handles.din.freq_range(6,1), handles.din.freq_range(6,2), handles);
% --- Executes during object creation, after setting all properties.
function end_f11_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

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
function [G_fit,B_fit,G_chi_sq,B_chi_sq,combine_spectra,halfg,halfg_freq]=Lorentzian_dynamic_fit(handles,freq,conductance,susceptance,combine_spectra)
                [MaxVal MaxInd]=max(combine_spectra,[],1);%Max of each column
                Gmax=MaxVal(2);%Maximum value of conductance
                f0=combine_spectra(MaxInd(2),1);%finds freq at which Gmax happens
                halfg=Gmax./2;%half of the Gmax
                halfg_freq=combine_spectra(find(abs(halfg-combine_spectra(:,2))==min(abs((halfg-combine_spectra(:,2))))),1);
                gamma0=abs(halfg_freq-combine_spectra(MaxInd(2),1)).*2;%Twice the difference from halfg and peak freq
                phi=0;%Assume rotation angle is 0
                Goff=0;%Assume offset value is 0
                Boff=0;%Assume offset value is 0

                switch get(handles.fit_mode,'value')
                    case 1%Guess value based on max conductance
                        % % % % 
                        p=[f0 gamma0 phi Gmax Goff Boff];                
                            try
                            G_fit=fit_spectra(p,freq,conductance);
                            B_fit=fit_spectra_sus(p,freq,susceptance);                            
                            %chi-squared calculation
                            G_chi_sq=((G_fit-conductance).^2)./(G_fit);
                            B_chi_sq=((B_fit-susceptance).^2)./(B_fit);

                            combine_spectra=[freq,conductance,susceptance,G_fit,B_fit,G_chi_sq,B_chi_sq];
                            catch
                            end%try
                    case 2  %Guess values based on the Derivative of the Fit

                    case 3%Guess value base on the preqious fit values
                        if prev_data(1,6)==0
                            p=[f0 gamma0 phi Gmax Goff Boff];
                            try
                            G_fit=fit_spectra(p,freq,conductance);
                            B_fit=fit_spectra_sus(p,freq,susceptance);                            
                            %chi-squared calculation
                            G_chi_sq=((G_fit-combine_spectra(:,2)).^2)./(G_fit);
                            B_chi_sq=((B_fit-combine_spectra(:,3)).^2)./(B_fit);
                            combine_spectra=[freq,conductance,susceptance,G_fit,B_fit,G_chi_sq,B_chi_sq];
                            catch
                                f0_fit=combine_spectra(find(max(G_fit)),1)
                                halfg_fit=G_fit./2;%half of the G_fit
                                halfg_fit_freq=combine_spectra(find(abs(halfg_fit-G_fit)==min(abs((halfg_fit-G_fit)))),1);
                                gamma0_fit=abs(halfg_freq-combine_spectra(MaxInd(2),1)).*2;%Twice the difference from halfg and peak freq                                    
                            end%try                               
                            prev_data=[f0_fit gamma0_fit phi max(G_fit) Goff Boff];
                        else
                            p=prev_data;
                            try
                            G_fit=fit_spectra(p,freq,conductance);
                            B_fit=fit_spectra_sus(p,freq,susceptance);                            
                            %chi-squared calculation
                            G_chi_sq=((G_fit-combine_spectra(:,2)).^2)./(G_fit);
                            B_chi_sq=((B_fit-combine_spectra(:,3)).^2)./(B_fit);
                            combine_spectra=[freq,conductance,susceptance,G_fit,B_fit,G_chi_sq,B_chi_sq];
                            catch
                                f0_fit=combine_spectra(find(max(G_fit)),1);
                                halfg_fit=G_fit./2;%half of the G_fit
                                halfg_fit_freq=combine_spectra(find(abs(halfg_fit-G_fit)==min(abs((halfg_fit-G_fit)))),1);
                                gamma0_fit=abs(halfg_freq-combine_spectra(MaxInd(2),1)).*2;%Twice the difference from halfg and peak freq                                          
                            end%try
                            prev_data=[f0_fit gamma0_fit phi max(G_fit) Goff Boff];                                
                        end%if
                end%switch 

function [fitted_y]=fit_spectra(x0,freq_data,y_data,lb,ub)%fit spectra to conductance curve
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
    lb=[-Inf -Inf -Inf -Inf -Inf -Inf];
    ub=[Inf Inf Inf Inf Inf Inf];
end%if nargin==3
% lfun4ca=@(p,x)p(4).*((((x.^2).*((2.*p(2)).^2))/(((((p(1)).^2)-(x.^2)).^2)+...
%     ((x.^2).*((2.*p(2)).^2)))).*cosd(p(3))-((((p(1)).^2-x.^2)).*x.*(2.*p(2)))/...
%     (((((p(1)).^2)-(x.^2)).^2)+((x.^2).*((2.*p(2)).^2))).*sind(p(3)))+p(5);
options=optimset('display','off');
[parameters resnorm residual]=lsqcurvefit(@lfun4c,x0,freq_data,y_data,lb,ub,options);%use lsqcurvefit function to fit the spectra data to a Lorentz curve
fitted_y=lfun4c(parameters,freq_data);


function [fitted_y]=fit_spectra_sus(x0,freq_data,susceptance_data,lb,ub)%fit spectra to susceptance curve
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
    lb=[-Inf -Inf -Inf -Inf -Inf -Inf];
    ub=[Inf Inf Inf Inf Inf Inf];
end%if nargin==3
% lfun4ca=@(p,x)p(4).*((((x.^2).*((2.*p(2)).^2))/(((((p(1)).^2)-(x.^2)).^2)+...
%     ((x.^2).*((2.*p(2)).^2)))).*cosd(p(3))-((((p(1)).^2-x.^2)).*x.*(2.*p(2)))/...
%     (((((p(1)).^2)-(x.^2)).^2)+((x.^2).*((2.*p(2)).^2))).*sind(p(3)))+p(5);
options=optimset('display','off');
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
%p(3): phi phse angle difference
%p(4): Gmax maximum conductance
%p(6): Offset value
F_susceptance= p(4).*((((x.^2).*((2.*p(2)).^2))./(((((p(1)).^2)-(x.^2)).^2)+...
    ((x.^2).*((2.*p(2)).^2)))).*sind(p(3))-((((p(1)).^2-x.^2)).*x.*(2.*p(2)))./...
    (((((p(1)).^2)-(x.^2)).^2)+((x.^2).*((2.*p(2)).^2))).*cosd(p(3)))+p(6);


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

function peak_centering(handles)

%PEAK CENTERING FUNCTIONS BEGINS HERE//////////////////////////////////////
%//////////////////////////////////////////////////////////////////////////
%//////////////////////////////////////////////////////////////////////////
function output_txt = myupdatefcn(~,event_obj,~, handles)
% This is the function that runs when datacursormode is employed. The
% output output-txt is what appears in the box.

%Determines output box--this is the usual function of datacursor, modified
%to know what the x axis actually is.
pos = get(event_obj,'Position');
output_txt = {['Frequency ',num2str(pos(1),5),' Hz'],...
    ['Y data: ',num2str(pos(2),5)]};
set(handles.peak_centering,'userdata',pos);

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

function my_closereq(src,evnt,handles)
% User-defined close request function 
% to display a question dialog box 
temp=gcf;
list_of_fig=get(0,'children');%get all figure handles
for dum=1:length(list_of_fig)%go through all open figures in matlab
 fig_name=get(list_of_fig(dum),'name');%extract the name of the figure
 if strcmp(fig_name(1:end-2),'testversion')%find the figure that matches with the testversion.fig file
     obj1=get(list_of_fig(dum),'children');%extract all objects from the figure
     for dum1=1:length(obj1)%check each objects in the figure
         try
             obj1_name=get(obj1(dum1),'Tag');%extract out the tag property of the object
             if strcmp(obj1_name,'uipanel2')%find the right object, in this case it i uipanel2
                 obj2=get(obj1(dum1),'children')%get all the objects inside of this panel
                 for dum2=1:length(obj2)
                     try
                         obj2_name=get(obj2(dum2),'Tag');%extract out the tag property of the objects within uipanel2
                         if strcmp(obj2_name,'peak_centering')%find the peak_centering object and change the properties of the object
                             if isempty(get(obj2(dum2),'userdata'))
                                 selection = errordlg('Please choose the center point of the peak.');
                             else
                                 set(obj2(dum2),'value',0,'userdata',[]);
                                 datacursormode off
                                 delete(gcf)
                             end%if isempty(get(handles.peak_centering,'userdata'))
                         end%if strcmp(obj2_name,'peak_centering')
                     catch
                     end%try
                 end%for dum2=1:length(obj2)
             end%if strcmp(obj1_name,'Tag')
             if strcmp(obj1_name,'uipanel1')
                 obj2=get(obj1(dum1),'children')%get all the objects inside of this panel
                  for dum2=1:length(obj2)
                     try
                         obj2_name=get(obj2(dum2),'Tag');%extract out the tag property of the objects within uipanel1
                         if strcmp(obj2_name,'peak_center')%find the peak_center object and change the properties of the object
                             set(obj2(dum2),'visible','off');
                         elseif strcmp(obj2_name,'harm1')
                             set(obj2(dum2),'visible','on');
                         elseif strcmp(obj2_name,'harm3')
                            set(obj2(dum2),'visible','on');
                         elseif strcmp(obj2_name,'harm5')
                            set(obj2(dum2),'visible','on');
                         elseif strcmp(obj2_name,'harm7')
                            set(obj2(dum2),'visible','on');
                         elseif strcmp(obj2_name,'harm9')
                            set(obj2(dum2),'visible','on');
                         elseif strcmp(obj2_name,'harm11')
                            set(obj2(dum2),'visible','on');
                         elseif strcmp(obj2_name,'harmonics_text')
                             set(obj2(dum2),'visible','on');
                         end%%find the peak_center object and change the properties of the object
                     catch
                     end%try
                 end%for dum2=1:length(obj2)
             end%if strcmp(obj1_name,'uipanel1')
         catch
         end%try
     end% for dum1=1:length(obj1)
 end% if stcmp(fig_name(1:end-2),'testversion')
end%for dum=1:length(list_of_fig)

function center_peak_function(handles,harm_tot,hObject)
flag=1;
    for dum=1:length(harm_tot)%turn on datacursor mode for the active harmonics
        initial_end=str2double(get(handles.(['end_f',num2str(harm_tot(dum))]),'string'));
        initial_start=str2double(get(handles.(['start_f',num2str(harm_tot(dum))]),'string'));
        freq_range=(initial_end-initial_start).*1e6%calculate the initial frequency range of the harmonic
        [freq,conductance,susceptance,handles]=read_scan(handles);
        f1=figure('CloseRequestFcn',@my_closereq);%create a figure with a special custom close request function
        set(f1,'units','normalized','position',[0.621 0.313 0.35 0.467]);%adjust location of the figure
        p1=plot(freq,conductance,'bx-','markersize',6);
        set_ylim=get(gca,'ylim');
        hold on;
        plot(freq,susceptance,'rx-','markersize',6);
        set(gca,'ylim',set_ylim);
        title(['Harmonic ',num2str(harm_tot(dum))],'fontweight','bold');
        hold off;
        ylabel(gca,'Siemans (S)','fontsize',10);
        xlabel(gca,['Harmonic ',num2str(harm_tot(dum)),' Frequency (Hz)'],'fontsize',10);
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
                if flag==1
                    freq_range=diff(get(gca,'xlim'));%refresh window range
                end%if flag==1
                %redefine frequency range
                new_start=(center-(freq_range)/2).*1e-6
                new_end=(center+(freq_range)/2).*1e-6
                set(handles.(['start_f',num2str(harm_tot(dum))]),'string',num2str(new_start,10));
                set(handles.(['end_f',num2str(harm_tot(dum))]),'string',num2str(new_end,10));
                write_settings(handles,harm_tot(dum));
                %now output scan
                [freq,conductance,susceptance,handles]=read_scan(handles);
                axes(handles.(axname));
                p1=plot(freq,conductance,'bx-');
                set_ylim=get(gca,'ylim');
                hold on;
                plot(freq,susceptance,'r');
                set(gca,'ylim',set_ylim);
                hold off;
                ylabel(gca,'Siemans (S)','fontsize',6);
                xlabel(gca,'Frequency (Hz)','fontsize',6);
                drawnow
                if get(handles.peak_centering,'value')==1
                    figure(f1);
                    flag=0;
                end%if get(handles.peak_centering,'value')=1
            end%if isfield(c_info,'Position')
        end%        while get(handles.peak_centering,'value')==1
    end%    for dum=1:length(harm_tot)
    dummy=1;
    set(handles.peak_centering,'value',1);
    peak_centering_Callback(hObject,dummy,handles);
    set(handles.status,'string','Status: Peak centering successful! Ready...');

% --- Executes when selected object is changed in peak_center.
function peak_center_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in peak_center 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
status=eventdata.EventName
current_handle=eventdata.NewValue;%get handle of current selected radial dial
current_harm=get(current_handle,'userdata');
handles.din.harmonic=current_harm;%store current harmonic in handles structure
center_peak_function(handles,current_harm,hObject);
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
for dum=1:6
    chi_name=['X',num2str(dum*2-1)];
    set(handles.(chi_name),'string','Xsq = ');
end%for dum=1:6
handles.din.prev_cond=zeros(str2double(get(handles.num_datapoints,'string')),1);
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
                  [G_fit,B_fit,G_chi_sq,B_chi_sq,combine_spectra,halfg,halfg_freq]=Lorentzian_dynamic_fit(handles,freq,conductance,susceptance,combine_spectra);
            end%if get(handles.dynamic_fit,'value')==1   
            f1=figure(dum);
            clf(figure(dum));
            a=axes;
            plot(a,freq,conductance,'bx-','linewidth',1.5,'markersize',8);
            hold on;
            if get(handles.dynamic_fit,'value')==1%this if statement will run the Lorentzian fitting function            
                plot(freq,G_fit,'k','linewidth',2);
                text('units','normalized','position',[.02 .95 1],'string',['Xsq = ',num2str(sum(combine_spectra(:,6))./1e3)],...
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
    get(handles.raw_fig,'userdata')
    waitfor(handles.raw_fig,'userdata');
end%while get(handles.raw_fig,'value')==1
set(handles.raw_fig,'fontweight','normal','foregroundcolor','k','userdata',[0]);


% --- Executes on button press in fix_span.
function fix_span_Callback(hObject, eventdata, handles)
% hObject    handle to fix_span (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fix_span


% --- Executes on button press in fix_center.
function fix_center_Callback(hObject, eventdata, handles)
% hObject    handle to fix_center (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fix_center


% --- Executes on button press in save_settings.
function save_settings_Callback(hObject, eventdata, handles)
% hObject    handle to save_settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function record_time_increment_Callback(hObject, eventdata, handles)
% hObject    handle to record_time_increment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of record_time_increment as text
%        str2double(get(hObject,'String')) returns contents of record_time_increment as a double


% --- Executes on button press in load_settings.
function load_settings_Callback(hObject, eventdata, handles)
% hObject    handle to load_settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in freq_format.
function freq_format_Callback(hObject, eventdata, handles)
% hObject    handle to freq_format (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns freq_format contents as cell array
%        contents{get(hObject,'Value')} returns selected item from freq_format


% --- Executes during object creation, after setting all properties.
function freq_format_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freq_format (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in plot1_choice.
function plot1_choice_Callback(hObject, eventdata, handles)
% hObject    handle to plot1_choice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns plot1_choice contents as cell array
%        contents{get(hObject,'Value')} returns selected item from plot1_choice


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
