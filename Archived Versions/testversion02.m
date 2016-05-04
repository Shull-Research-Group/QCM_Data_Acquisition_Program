function varargout = testversion02(varargin)
% TESTVERSION02 MATLAB code for testversion02.fig
%      TESTVERSION02, by itself, creates a new TESTVERSION02 or raises the existing
%      singleton*.
%
%      H = TESTVERSION02 returns the handle to a new TESTVERSION02 or the handle to
%      the existing singleton*.
%
%      TESTVERSION02('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TESTVERSION02.M with the given input arguments.
%
%      TESTVERSION02('Property','Value',...) creates a new TESTVERSION02 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before testversion02_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to testversion02_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help testversion02

% Last Modified by GUIDE v2.5 21-Jan-2014 00:39:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @testversion02_OpeningFcn, ...
                   'gui_OutputFcn',  @testversion02_OutputFcn, ...
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


% --- Executes just before testversion02 is made visible.
function testversion02_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to testversion02 (see VARARGIN)

% Choose default command line output for testversion02
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
axes(handles.axes4);
plot(handles.axes4,[0,1],[0,0],'-',[0,1],[0,0],'-','visible','off');
legend('Conductance','Susceptance','Location','West');
set(handles.axes4,'visible','off');
xlabel(handles.axes1,'Freqency (Hz)','fontsize',6);
ylabel(handles.axes1,'Siemens (S)','fontsize',6);
xlabel(handles.axes2,'Freqency (Hz)','fontsize',6);
ylabel(handles.axes2,'Siemens (S)','fontsize',6);
xlabel(handles.axes3,'Freqency (Hz)','fontsize',6);
ylabel(handles.axes3,'Siemens (S)','fontsize',6);


% UIWAIT makes testversion02 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = testversion02_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in start.
function start_Callback(hObject, eventdata, handles)
if get(handles.start,'value')==1
    set(handles.start,'string','Stop Scan');
else
    set(handles.start,'string','Start Scan');
end
counter=1;%counter
while get(handles.start,'value')==1
fid1=fopen('myVNAfreq.csv');
fid2=fopen('myVNAdata.csv');
fid3=fopen('myVNAdata2.csv');
freq=cell2mat(textscan(fid1,'%f'));%frequency data
conductance=cell2mat(textscan(fid2,'%f'));%conductance data
susceptance=cell2mat(textscan(fid3,'%f'));%susceptance data
try
    combine_spectra=[freq,conductance,susceptance];
catch
end
%close datafiles
fclose(fid1);
fclose(fid2);
fclose(fid3);
flag=0;
%figure out which harmonic it is based on frequency range
try
if freq(1)<6e6&&freq(1)>4e6
    flag=flag+1;
    ax1=['axes',num2str(flag)];
    axes(handles.(ax1));
elseif freq(1)<16e6&&freq(1)>14e6
    flag=flag+1;
    ax1=['axes',num2str(flag)];
    axes(handles.(ax1));
elseif freq(1)<26e6&&freq(1)>24e6
    flag=flag+1;
    ax1=['axes',num2str(flag)];
    axes(handles.(ax1));
elseif freq(1)<36e6&&freq(1)>34e6
    flag=flag+1;
    ax1=['axes',num2str(flag)];
    axes(handles.(ax1));
elseif freq(1)<46e6&&freq(1)>44e6
    flag=flag+1;
    ax1=['axes',num2str(flag)];  
    axes(handles.(ax1));
elseif freq(1)<56e6&&freq(1)>54e6
    flag=flag+1;
    ax1=['axes',num2str(flag)];  
    axes(handles.(ax1));
end
catch err
end
tic
%plot the data set
try
    if get(handles.radio_update_spectra,'value')==1%update the spectra every 5th iteration
        plot(freq,conductance,freq,susceptance);
        xlabel(handles.(ax1),'Freqency (Hz)','fontsize',6);
        ylabel(handles.(ax1),'Siemens (S)','fontsize',6);
        drawnow
        counter=0;%reset counter
    end%if
catch err
end%try
    
spectra = matfile('spectra.mat','Writable',true);
spectra.combine_spectra = combine_spectra;
toc
counter=counter+1;
end%while


% --- Executes on button press in radio_update_spectra.
function radio_update_spectra_Callback(hObject, eventdata, handles)
% hObject    handle to radio_update_spectra (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radio_update_spectra



function start_f1_Callback(hObject, eventdata, handles)
% hObject    handle to start_f1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of start_f1 as text
%        str2double(get(hObject,'String')) returns contents of start_f1 as a double


% --- Executes during object creation, after setting all properties.
function start_f1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to start_f1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in set_settings.
function set_settings_Callback(hObject, eventdata, handles)
%this series of if statements inside of the loop determines what harmonics will be recorded
if get(handles.harm1,'value')==1
    record_harms(1)=1;
    freq_range(1)=str2double(get(handles.start_f1,'string'));%gets start frequency value
    freq_range(2)=str2double(get(handles.end_f1,'string'));%gets end frequency value
end
if get(handles.harm3,'value')==1
    record_harms(3)=1;
    freq_range(3)=str2double(get(handles.start_f3,'string'));%gets start frequency value
    freq_range(4)=str2double(get(handles.end_f3,'string'));%gets end frequency value    
end
if get(handles.harm5,'value')==1
    record_harms(5)=1;
    freq_range(5)=str2double(get(handles.start_f5,'string'));%gets start frequency value
    freq_range(6)=str2double(get(handles.end_f5,'string'));%gets end frequency value    
end
if get(handles.harm7,'value')==1
    record_harms(7)=1;
    freq_range(7)=str2double(get(handles.start_f7,'string'));%gets start frequency value
    freq_range(8)=str2double(get(handles.end_f7,'string'));%gets end frequency value    
end
if get(handles.harm9,'value')==1
    record_harms(9)=1;
    freq_range(9)=str2double(get(handles.start_f9,'string'));%gets start frequency value
    freq_range(10)=str2double(get(handles.end_f9,'string'));%gets end frequency value        
end
if get(handles.harm11,'value')==1
    record_harms(11)=1;
    freq_range(11)=str2double(get(handles.start_f11,'string'));%gets start frequency value
    freq_range(12)=str2double(get(handles.end_f11,'string'));%gets end frequency value        
end    
num_harms=sum(record_harms);%calculate number of harmonics
record_harms=find(record_harms==1);
%write settings into a text file
fid=fopen('myvna_settings.txt','w');
fprintf(fid,'%i \t %f \t %f \t',[num_harms,freq_range]);
fclose(fid);
%export variables into handles structure
handles.din.record_harms=record_harms;
handles.din.num_harms=num_harms;
%update Status bar
set(handles.status,'string','Status: Settings Saved! Ready...');
keyboard

% --- Executes on button press in harm1.
function harm1_Callback(~,~,handles)
% --- Executes on button press in harm3.
function harm3_Callback(~,~,handles)
% --- Executes on button press in harm5.
function harm5_Callback(~,~,handles)
% --- Executes on button press in harm7.
function harm7_Callback(~,~,handles)
% --- Executes on button press in harm9.
function harm9_Callback(~,~,handles)
% --- Executes on button press in harm11.
function harm11_Callback(~,~,handles)


function end_f1_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function end_f1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function start_f3_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function start_f3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function end_f3_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function end_f3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function start_f5_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function start_f5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function end_f5_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function end_f5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function start_f7_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function start_f7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function end_f7_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function end_f7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function start_f9_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function start_f9_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function end_f9_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function end_f9_CreateFcn(hObject, eventdata, handles)



function start_f11_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function start_f11_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function end_f11_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function end_f11_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function refresh_spectra_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function refresh_spectra_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
