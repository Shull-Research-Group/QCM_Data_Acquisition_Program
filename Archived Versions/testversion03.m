function varargout = testversion03(varargin)
% TESTVERSION03 MATLAB code for testversion03.fig
%      TESTVERSION03, by itself, creates a new TESTVERSION03 or raises the existing
%      singleton*.
%
%      H = TESTVERSION03 returns the handle to a new TESTVERSION03 or the handle to
%      the existing singleton*.
%
%      TESTVERSION03('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TESTVERSION03.M with the given input arguments.
%
%      TESTVERSION03('Property','Value',...) creates a new TESTVERSION03 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before testversion03_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to testversion03_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help testversion03

% Last Modified by GUIDE v2.5 13-Feb-2014 20:34:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @testversion03_OpeningFcn, ...
                   'gui_OutputFcn',  @testversion03_OutputFcn, ...
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


% --- Executes just before testversion03 is made visible.
function testversion03_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to testversion03 (see VARARGIN)

% Choose default command line output for testversion03
handles.output = hObject;

% Update handles structure
handles.din.freq_range=[4 6; 14 16; 24 26; 34 36; 44 46; 54 56];%this stores the accepted frequency ranges for each harmonic
handles.din.avail_harms=[1 3 5 7 9 11];
handles.din.error_count=1;
handles.din.error_log={};
axes(handles.axes7);
plot(handles.axes7,[0,1],[0,0],'-',[0,1],[0,0],'r-','visible','off');
set(gca,'fontsize',6);
legend('Conductance','Susceptance','Location','West');
set(handles.axes7,'visible','off');
for dum=1:6
    axname=['axes',num2str(dum)];
    set(handles.(axname),'fontsize',4);
    xlabel(handles.(axname),'Freqency (Hz)','fontsize',6);
    ylabel(handles.(axname),'Siemens (S)','fontsize',6);
end%for dum=1:6
guidata(hObject, handles);
%set default reference time
set(handles.reference_time,'string',datestr(clock,'yy:mm:dd:HH:MM:SS:FFF'));

% UIWAIT makes testversion03 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = testversion03_OutputFcn(hObject, eventdata, handles) 
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
write_settings(handles,harm_tot(1));%this function writes out the settings text file
%update string of the start button based on the toggle state
if get(handles.start,'value')==1
    set(handles.start,'string','Stop Scan');
else
    set(handles.start,'string','Start Scan');
end%if get(handles.start,'value')==1
counter=1;%counter
spectra = matfile('spectra1.mat','Writable',true);%open matfile and set access to writable
spectra_data=matfile('spectra_data.mat','Writable',true);
start_time=datenum(get(handles.reference_time,'string'),'yy:mm:dd:HH:MM:SS:FFF');%gets reference time value and sets it as start time
start_time1=datestr(start_time,'yy:mm:dd:HH:MM:SS:FFF');
start_time2=datevec(start_time1,'yy:mm:dd:HH:MM:SS:FFF');%change reference time into appropriate format
x=NaN(200,13);%preallocated matrix for f0 and gamma0 data
n=1;
prev_data=zeros(1,6);%preallocate prev data
while get(handles.start,'value')==1
    for dum=1:size(harm_tot)
        try
            [freq,conductance,susceptance,handles]=read_scan(handles);
            combine_spectra=[freq,conductance,susceptance];
                %only run the following if statement if the user wants to see the it dynamically            
                if get(handles.dynamic_fit,'value')==1
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
                                G_fit=fit_spectra(p,freq,conductance)
                                B_fit=fit_spectra_sus(p,freq,susceptance);                            
                                %chi-squared calculation
                                G_chi_sq=((G_fit-combine_spectra(:,2)).^2)./(G_fit)
                                B_chi_sq=((B_fit-combine_spectra(:,3)).^2)./(B_fit)
                                combine_spectra=[freq,conductance,susceptance,G_fit,B_fit,G_chi_sq,B_chi_sq];
                                catch
                                end%try
                        case 2  %Guess values based on the Derivative of the Fit

                        case 3%Guess value base on the preqious fit values
                            if prev_data(1,6)==0
                                p=[f0 gamma0 phi Gmax Goff Boff];
                                try
                                G_fit=fit_spectra(p,freq,conductance)
                                B_fit=fit_spectra_sus(p,freq,susceptance);                            
                                %chi-squared calculation
                                G_chi_sq=((G_fit-combine_spectra(:,2)).^2)./(G_fit)
                                B_chi_sq=((B_fit-combine_spectra(:,3)).^2)./(B_fit)
                                combine_spectra=[freq,conductance,susceptance,G_fit,B_fit,G_chi_sq,B_chi_sq];
                                catch
                                    f0_fit=combine_spectra(find(max(G_fit)),1)
                                    halfg_fit=G_fit./2;%half of the G_fit
                                    halfg_fit_freq=combine_spectra(find(abs(halfg_fit-G_fit)==min(abs((halfg_fit-G_fit)))),1);
                                    gamma0_fit=abs(halfg_freq-combine_spectra(MaxInd(2),1)).*2;%Twice the difference from halfg and peak freq                                    
                                end%try                               
                                prev_data=[f0_fit gamma0_fit phi max(G_fit) Goff Boff];
                            else
                                p=prev_data
                                try
                                G_fit=fit_spectra(p,freq,conductance)
                                B_fit=fit_spectra_sus(p,freq,susceptance);                            
                                %chi-squared calculation
                                G_chi_sq=((G_fit-combine_spectra(:,2)).^2)./(G_fit)
                                B_chi_sq=((B_fit-combine_spectra(:,3)).^2)./(B_fit)
                                combine_spectra=[freq,conductance,susceptance,G_fit,B_fit,G_chi_sq,B_chi_sq];
                                catch
                                    f0_fit=combine_spectra(find(max(G_fit)),1)
                                    halfg_fit=G_fit./2;%half of the G_fit
                                    halfg_fit_freq=combine_spectra(find(abs(halfg_fit-G_fit)==min(abs((halfg_fit-G_fit)))),1);
                                    gamma0_fit=abs(halfg_freq-combine_spectra(MaxInd(2),1)).*2;%Twice the difference from halfg and peak freq                                          
                                end%try
                                prev_data=[f0_fit gamma0_fit phi max(G_fit) Goff Boff];                                
                            end%if
                    end%switch                       
                end%if get(handles.dynamic_fit,'value')==1                
            flag=0;
            %output harmonic in appropriate axes
                flag=flag+1;
                ax1=['axes',num2str(dum)];
                axes(handles.(ax1));
            %plot the data set
            %this if statement code refreshes the spectra every
            %<user-defined>th iteration of the while loop    
            if mod(counter,str2double(get(handles.refresh_spectra,'string')))==0
                p1=plot(freq,conductance,'bx-');
                set_ylim=get(gca,'ylim');
                hold on;
                plot(freq,susceptance,'rx-');
                if get(handles.dynamic_fit,'value')==1
                    plot(freq,G_fit,'k','linewidth',2);
                    plot(freq,B_fit,'k','linewidth',2);
                end
                %set(gca,'ylim',set_ylim);
                hold off;
                ylabel(gca,'Siemans (S)','fontsize',6);
                xlabel(gca,'Frequency (Hz)','fontsize',6);
                drawnow
            end
            %Determine variable name in which the spectra information will be
            %stored
              time_now=datestr(clock,'yy:mm:dd:HH:MM:SS:FFF');%Current time
              time_now1=datevec(time_now,'yy:mm:dd:HH:MM:SS:FFF');%Find current time and make it a vector
              Z=time_now1 - start_time2;%Find difference in time
              time_elapsed=Z(1)*525960+Z(2)*43830+Z(3)*1440+Z(4)*60+Z(5)+Z(6)./60;%fix time into minutes
              time_elapsed1=strrep(num2str(time_elapsed),'.','dot');%replace decimal with 'dot'        
              if dum==1% makes sure all harmonics are recorded with same timestamp
                  timestamp=time_elapsed1;
              end%if
            %write out spectra in specified spectra filename
              spectra.(sprintf(['filename_t_%s_iq_1_ih_',num2str((harm_tot(dum)+1)./2)],timestamp)) = combine_spectra;%renames variable based on harm

                    [MaxVal MaxInd]=max(combine_spectra,[],1);%Max of each column
                    Gmax_fit=MaxVal(4);%Maximum value of conductance
                    f0_fit=combine_spectra(MaxInd(4),1);%finds freq at which Gmax happens
                    halfg_fit=Gmax_fit./2;%half of the Gmax
                    halfg_freq_fit=combine_spectra(find(abs(halfg-combine_spectra(:,4))==min(abs((halfg-combine_spectra(:,4))))),1);
                    gamma0_fit=abs(halfg_freq-combine_spectra(MaxInd(4),1)).*2;%Twice the difference from halfg and peak freq

               x(n,1)=str2double(strrep(timestamp,'dot','.'));
               x(n,harm_tot(dum)+1)=f0_fit;
               x(n,harm_tot(dum)+2)=gamma0_fit;
              spectra_data.data=x;%save f0 and gamma0 fit data to spectra_data.mat
              write_settings(handles,harm_tot(dum));%update the setting txt file
        catch
        end%try
        counter=counter+1;
        toc
        pause(0.5);
    end%for dum=1:1:harm_tot
    n=n+1;
end%while
guidata(hObject, handles);


function harm_tot=find_num_harms(handles)
harm_tot=[];
for dum=1:1:6
    harmname=['harm',num2str(handles.din.avail_harms(dum))];
    if get(handles.(harmname),'value')==1
        harm_tot=[harm_tot;handles.din.avail_harms(dum)];
    end%if get(handles.(harmname),'value')==1
end%for dum=1:1:6

function write_settings(handles,harm_num)
% This if statement writes out the setting.txt file
fileID=fopen('settings.txt','w');%write settings value into the settings.txt file
fprintf(fileID,'%8.6f\r\n',get(handles.start,'value'));%write the toggle state of the start button
harmname=['harm',num2str(harm_num)];
startname=['start_f',num2str(harm_num)];
endname=['end_f',num2str(harm_num)];
if get(handles.(harmname),'value')==1
    fprintf(fileID,'%10.12f\r\n',str2double(get(handles.(startname),'string')));%write start frequency of <dum> harmonic
    fprintf(fileID,'%10.12f\r\n',str2double(get(handles.(endname),'string')));%write out end frequency of <dum> harmonic
end%if get(handles.(harmname),'value')==1

%this function obtains the scan data taken from the VB C++ program
function [freq,conductance,susceptance,handles]=read_scan(handles)
        %csvread(0 function may or may not be faster....
        try
            clear('fid1','fid2','fid3');
            fid1=fopen('myVNAfreq.csv');%open up frequency range output from the AccessMyVNA program
            fid2=fopen('myVNAdata.csv');%open up conductance values from the AccessMyVNA program
            fid3=fopen('myVNAdata2.csv');%open up susceptance values from the AcessMyVNA program
            freq=cell2mat(textscan(fid1,'%f'));%frequency data
            conductance=cell2mat(textscan(fid2,'%f'));%conductance data
            susceptance=cell2mat(textscan(fid3,'%f'));%susceptance data
            fclose(fid1);fclose(fid2);fclose(fid3);%close datafiles     
        catch
            disp('ERROR: INVALID FILE IDENTIFIER. USE FOPEN TO GENERATE A VALID FILE IDENTIFIER');
            handles.din.error_log(handles.din.error_count)=[datestr(clock),'  ERROR: INVALID FILE IDENTIFIER. USE FOPEN TO GENERATE A VALID FILE IDENTIFIER'];
            handles.din.error_count-handles.din.error_count+1;
            assignin('base','fid1',fid1);
            assignin('base','fid2',fid2);
            assignin('base','fid3',fid3);
        end%try
%         harm_start_name=['start_f',num2str((harm_tot(dum)+1)./2)];
%         harm_end_name=['end_f',num2str((harm_tot(dum)+1)./2)];
%         set(handles.(harm_start_name),'string',num2str(min(freq)*1e-6));
%         set(handles.(harm_end_name),'string',num2str(max(freq)*1e-6));
        %If either the freq, conductance, or susceptance array is than 200
        %elements, run this if statement. This if statement only fixes the
        %issue when one of the elements cannot be read as a double (since there
        %are other extraneous char in the element. This if statement forces
        %MATLAB to read that element(s) as NaN.
        if length(freq)<200 || length(conductance)<200 || length(susceptance)<200
            fileID1=fopen('myVNAfreq.csv');%reopen data files
            fileID2=fopen('myVNAdata.csv');
            fileID3=fopen('myVNAdata2.csv');
            A=textscan(fileID1,'%s','treatasempty',{'NA','na'});%replace unrecognized double elements as NaN
            B=textscan(fileID2,'%s','treatasempty',{'NA','na'});
            C=textscan(fileID3,'%s','treatasempty',{'NA','na'});
            fclose(fileID1);fclose(fileID2);fclose(fileID3);%close datafiles
            freq=zeros(200,1);%preallocate arrays to speed up for loop
            conductance=zeros(200,1);
            susceptance=zeros(200,1);
            for dum=1:200%extract data into the freq, conductance, and susceptance arrays
                try
                    freq(dum,1)=str2double(A{1}{dum});
                    conductance(dum,1)=str2double(B{1}{dum});
                    susceptance(dum,1)=str2double(C{1}{dum});
                catch
                end%try
            end%for dum=1:200
        end%if length(freq) || length(conductance) || length(susceptance)
        assignin('base','freq',freq);%output values in the "base" or global workspace
        assignin('base','conductance',conductance);
        assignin('base','susceptance',susceptance);

% --- Executes on button press in radio_update_spectra.
function radio_update_spectra_Callback(hObject, eventdata, handles)



% --- Executes on button press in set_settings.
function set_settings_Callback(~, ~, handles)
% set(handles.start,'value',0);
harm_tot=find_num_harms(handles);
harm_num=harm_tot(1);
fileID=fopen('settings.txt','w');%write settings value into the settings.txt file
fprintf(fileID,'%8.6f\r\n',get(handles.start,'value'));%write the toggle state of the start button
harmname=['harm',num2str(harm_num)];
startname=['start_f',num2str(harm_num)];
endname=['end_f',num2str(harm_num)];
if get(handles.(harmname),'value')==1
    fprintf(fileID,'%10.12f\r\n',str2double(get(handles.(startname),'string')));%write start frequency of <dum> harmonic
    fprintf(fileID,'%10.12f\r\n',str2double(get(handles.(endname),'string')));%write out end frequency of <dum> harmonic
end%if get(handles.(harmname),'value')==1
% set(handles.start,'value',1);



% --- Executes on button press in harm1.
function harm1_Callback(~,~,handles)
% write_settings(handles,1);
% --- Executes on button press in harm3.
function harm3_Callback(~,~,handles)
% write_settings(handles,3);
% --- Executes on button press in harm5.
function harm5_Callback(~,~,handles)
% write_settings(handles,5);
% --- Executes on button press in harm7.
function harm7_Callback(~,~,handles)
% write_settings(handles,7);
% --- Executes on button press in harm9.
function harm9_Callback(~,~,handles)
% write_settings(handles,9);
% --- Executes on button press in harm11.
function harm11_Callback(~,~,handles)
% write_settings(handles,11);


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
    lb=[-Inf -Inf -Inf -Inf -Inf];
    ub=[Inf Inf Inf Inf Inf];
end%if nargin==3
% lfun4ca=@(p,x)p(4).*((((x.^2).*((2.*p(2)).^2))/(((((p(1)).^2)-(x.^2)).^2)+...
%     ((x.^2).*((2.*p(2)).^2)))).*cosd(p(3))-((((p(1)).^2-x.^2)).*x.*(2.*p(2)))/...
%     (((((p(1)).^2)-(x.^2)).^2)+((x.^2).*((2.*p(2)).^2))).*sind(p(3)))+p(5);

[parameters resnorm residual]=lsqcurvefit(@lfun4c,x0,freq_data,y_data);%use lsqcurvefit function to fit the spectra data to a Lorentz curve
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
    lb=[-Inf -Inf -Inf -Inf -Inf];
    ub=[Inf Inf Inf Inf Inf];
end%if nargin==3
% lfun4ca=@(p,x)p(4).*((((x.^2).*((2.*p(2)).^2))/(((((p(1)).^2)-(x.^2)).^2)+...
%     ((x.^2).*((2.*p(2)).^2)))).*cosd(p(3))-((((p(1)).^2-x.^2)).*x.*(2.*p(2)))/...
%     (((((p(1)).^2)-(x.^2)).^2)+((x.^2).*((2.*p(2)).^2))).*sind(p(3)))+p(5);
[parameters resnorm residual]=lsqcurvefit(@lfun4s,x0,freq_data,susceptance_data);%use lsqcurvefit function to fit the spectra data to a Lorentz curve
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


function peak_centering(handles)


function output_txt = myupdatefcn(~,event_obj,~, handles)
% This is the function that runs when datacursormode is employed. The
% output output-txt is what appears in the box.

%Determines output box--this is the usual function of datacursor, modified
%to know what the x axis actually is.
pos = get(event_obj,'Position');
output_txt = {['Frequency ',num2str(pos(1),5),' min.'],...
    ['Y data: ',num2str(pos(2),5)]};
set(handles.peak_centering,'userdata',pos);


% --- Executes on button press in peak_centering.
function peak_centering_Callback(hObject, eventdata, handles)
set(handles.peak_centering,'userdata',[]);
if get(handles.peak_centering,'value')==1
    harm_tot=find_num_harms(handles);%get ytotal number of harmonics
    for dum=1:length(harm_tot)%turn on datacursor mode for the active harmonics
        initial_end=str2double(get(handles.(['end_f',num2str(harm_tot(dum))]),'string'));
        initial_start=str2double(get(handles.(['start_f',num2str(harm_tot(dum))]),'string'));
        freq_range=initial_end-initial_start;%calculate the initial frequency range of the harmonic
        [freq,conductance,susceptance,handles]=read_scan(handles);
        figure(dum);
        p1=plot(freq,conductance,'bx-');
        set_ylim=get(gca,'ylim');
        hold on;
        plot(freq,susceptance,'r');
        set(gca,'ylim',set_ylim);
        hold off;
        ylabel(gca,'Siemans (S)','fontsize',6);
        xlabel(gca,'Frequency (Hz)','fontsize',6);
        drawnow
        while get(handles.peak_centering,'value')==1
            axname=['axes',num2str(dum)];
            datacursormode on
            dcm_obj=datacursormode(figure(dum));
            set(dcm_obj,'UpdateFcn',{@myupdatefcn,hObject, handles})
            c_info=getCursorInfo(dcm_obj);
            if get(handles.peak_centering,'value')==0
               break
            end%if get(handles.view_select,'value')==0    
            waitfor(handles.peak_centering,'userdata');
            if isempty(get(handles.peak_centering,'userdata'))==0
                c_info.Position=get(handles.peak_centering,'userdata');
            end%if isempty(get(handles.view_select,'userdata'))=0
            if isfield(c_info,'Position')
                center=c_info.Position(1);%extract the user defined peak center
                %redefine frequency range
                new_start=center-(freq_range)/2;
                new_end=center+(freq_range)/2;
                set(handles.(['start_f',num2str(harm_tot(dum))]),'string',new_start);
                set(handles.(['end_f',num2str(harm_tot(dum))]),'string',new_end);
                write_settings(handles,harm_tot(dum));
                %now output scan
                [freq,conductance,susceptance,handles]=read_scan(handles);
                axes(handles.(['axes',num2str(dum)]));
                p1=plot(freq,conductance,'bx-');
                set_ylim=get(gca,'ylim');
                hold on;
                plot(freq,susceptance,'r');
                set(gca,'ylim',set_ylim);
                hold off;
                ylabel(gca,'Siemans (S)','fontsize',6);
                xlabel(gca,'Frequency (Hz)','fontsize',6);
                drawnow
            end%if isfield(c_info,'Position')
        end%        while get(handles.peak_centering,'value')==1
    end%    for dum=1:length(harm_tot)
else
    set(handles.peak_centering,'userdata',[]);
end%if get(handles.peak_centering,'value')==1
datacursormode off
guidata(hObject, handles);
