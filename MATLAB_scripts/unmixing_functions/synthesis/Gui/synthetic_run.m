function varargout = synthetic_run(varargin)
% SYNTHETIC_RUN M-file for synthetic_run.fig
%
%    Copyright 2010 Grupo Inteligencia Computacional, Universidad del País Vasco / Euskal Herriko Unibertsitatea (UPV/EHU)
%
%    Website: http://www.ehu.es/ccwintco
%
%    This file is part of the HYperspectral Data Retrieval and Analysis tools (HYDRA) program.
%
%    HYDRA is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    HYDRA is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%    You should have received a copy of the GNU General Public License
%    along with HYDRA.  If not, see <http://www.gnu.org/licenses/>.
%
% Graphics user interface for the hyperspectral synthesis tool

% Last Modified by GUIDE v2.5 04-Nov-2010 18:03:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @synthetic_run_OpeningFcn, ...
                   'gui_OutputFcn',  @synthetic_run_OutputFcn, ...
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


% --- Executes just before synthetic_run is made visible.
function synthetic_run_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to synthetic_run (see VARARGIN)
global endmembers;
global selectedEndmembers;
endmembers = load('endmembers.mat');
selectedEndmembers = zeros(0,224);
loadEndmembersList(handles.listbox2,'224','A');
plotEndmembers(handles.axesEndmembers,zeros(1,224));

% Choose default command line output for synthetic_run
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes synthetic_run wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = synthetic_run_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%     CALLBACKS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.text4,'string',get(hObject,'Value'));

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.text5,'string',get(hObject,'Value'));


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.text6,'string',get(hObject,'Value'));


% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider4_Callback(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.text10,'string',get(hObject,'Value'));


% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider5_Callback(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.text11,'string',get(hObject,'Value'));


% --- Executes during object creation, after setting all properties.
function slider5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double
value = str2double(get(hObject,'String'));
if isnan(value) || value < 1
    set(hObject,'string',10);
else
    set(hObject,'string',floor(value));
end

% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double
value = str2double(get(hObject,'String'));
if isnan(value) || value < 1
    set(hObject,'string',64);
else
    set(hObject,'string',floor(value));
end


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double
value = str2double(get(hObject,'String'));
if isnan(value) || value < 1
    set(hObject,'string',64);
else
    set(hObject,'string',floor(value));
end


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double
value = str2double(get(hObject,'String'));
if isnan(value) || value < 1
    set(hObject,'string',3);
else
    set(hObject,'string',floor(value));
end


% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4
global selectedEndmembers;
actualBands = size(selectedEndmembers,2);
contents = get(hObject,'String');
if ~strcmp(contents{get(hObject,'Value')},num2str(actualBands))
    selectedEndmembers = zeros(0,str2double(contents{get(hObject,'Value')}));
    set(handles.text31,'string',0);
    plotEndmembers(handles.axesEndmembers,zeros(1,str2double(contents{get(hObject,'Value')})));
    contents2 = get(handles.popupmenu5,'String');
    loadEndmembersList(handles.listbox2,contents{get(hObject,'Value')},contents2{get(handles.popupmenu5,'Value')});
end

% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu5.
function popupmenu5_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu5
contents = get(hObject,'String');
contents2 = get(handles.popupmenu4,'String');
loadEndmembersList(handles.listbox2,contents2{get(handles.popupmenu4,'Value')},contents{get(hObject,'Value')});


% --- Executes during object creation, after setting all properties.
function popupmenu5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2
bands = get(handles.popupmenu4,'String');
dataset = get(handles.popupmenu5,'String');
e = getEndmember(get(hObject,'Value'),bands{get(handles.popupmenu4,'Value')},dataset{get(handles.popupmenu5,'Value')});
plotEndmembers(handles.axesEndmembers,e);

% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnAdd.
function btnAdd_Callback(hObject, eventdata, handles)
% hObject    handle to btnAdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
bands = get(handles.popupmenu4,'String');
dataset = get(handles.popupmenu5,'String');
e = getEndmember(get(handles.listbox2,'Value'),bands{get(handles.popupmenu4,'Value')},dataset{get(handles.popupmenu5,'Value')});
if sum(e) > 0
    addEndmember(e,handles.text31);
    plotEndmembers(handles.axesEndmembers,e);
end


% --- Executes on button press in btnClear.
function btnClear_Callback(hObject, eventdata, handles)
% hObject    handle to btnClear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clearEndmembers(handles);

% --- Executes on button press in btnRun.
function btnRun_Callback(hObject, eventdata, handles)
% hObject    handle to btnRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global selectedEndmembers;
if size(selectedEndmembers,1) > 0
    % abundances
    ab = 'legendre';
    params(1) = floor(get(handles.slider1,'Value')*10) + 1;
    params(2) = floor(get(handles.slider2,'Value')*params(1)*10) + 1;
    params(3) = floor(get(handles.slider3,'Value')*100) + 1;
    if get(handles.radiobutton2,'Value')
        ab = 'gaussian';
        params(1) = get(handles.popupmenu1,'Value');
        if params(1) == 1
            params(2) = floor(get(handles.slider4,'Value')*500) + 1;
            params(3) = 0;
        elseif params(1) == 2
            params(2) = get(handles.slider4,'Value');
            params(3) = get(handles.slider5,'Value')*2;
        elseif params(1) == 3
            params(2) = get(handles.slider4,'Value')*5;
            params(3) = get(handles.slider5,'Value')*5;
        elseif params(1) == 4
            params(2) = floor(get(handles.slider4,'Value')*50) + 1;
            params(3) = get(handles.slider5,'Value')*5;
        end
    end
    % images
    num_images = str2double(get(handles.edit8,'String'));
    lines = str2double(get(handles.edit9,'String'));
    samples = str2double(get(handles.edit10,'String'));
    num_endmembers = str2double(get(handles.edit14,'String'));
    repeat = false;
    proceed = true;
    if get(handles.checkbox1,'Value')
        repeat = true;
    elseif size(selectedEndmembers,1) < num_endmembers
        repeat = true;
        button = questdlg('You didnt select the "Repeat endmembers" checkbox but there are not enough endmembers to sampling without repetition. if you continue repetition will be selected.','Sampling with repetitions','Ok','Cancel','modal');
        switch button
            case 'Yes'
            case 'Ok'
            otherwise
                proceed = false;
        end
    end
    if proceed
        set(handles.btnRun,'Enable','off');
        set(handles.btnReset,'Enable','off');
        run(ab,params,num_images,lines,samples,num_endmembers,repeat,selectedEndmembers);
        warndlg('Synthetic image creation completed.','Finish','modal');
        set(handles.btnRun,'Enable','on');
        set(handles.btnReset,'Enable','on');
    end
else
    errordlg('You must select some endmembers before creating the synthetic images','Error','modal');
end

% --- Executes on button press in btnReset.
function btnReset_Callback(hObject, eventdata, handles)
% hObject    handle to btnReset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clear(handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%     BUSINESS LOGIC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Clear abundances panel
function clearAbundances(h)
set(h.radiobutton1,'value',1);
set(h.slider1,'value',0.5);
set(h.text4,'string',0.5);
set(h.slider2,'value',0.5);
set(h.text5,'string',0.5);
set(h.slider3,'value',0.5);
set(h.text6,'string',0.5);
set(h.popupmenu1,'value',1);
set(h.slider4,'value',0.5);
set(h.text10,'string',0.5);
set(h.slider5,'value',0.5);
set(h.text11,'string',0.5);

% Clear images panel
function clearImages(h)
set(h.edit8,'string',10);
set(h.edit9,'string',64);
set(h.edit10,'string',64);

% Clear endmembers panel
function clearEndmembers(h)
set(h.popupmenu4,'value',1);
set(h.popupmenu5,'value',1);
global selectedEndmembers;
selectedEndmembers = zeros(0,224);
set(h.text31,'string',0);
contents = get(h.popupmenu4,'String');
contents2 = get(h.popupmenu5,'String');
loadEndmembersList(h.listbox2,contents{get(h.popupmenu4,'value')},contents2{get(h.popupmenu5,'value')});
plotEndmembers(h.axesEndmembers,zeros(1,224));

% Clear All
function clear(h)
clearAbundances(h);
clearImages(h);
clearEndmembers(h);

% Load endmembers list and plot first one
function loadEndmembersList(h_list,bands,dataset)
global endmembers;
list = [];
switch [dataset bands]
    case 'A480'
        for i=1:size(endmembers.A480,2)
            list = [list '|' endmembers.A480(i).name];
        end
    case 'A2151'
        for i=1:size(endmembers.A2151,2)
            list = [list '|' endmembers.A2151(i).name];
        end
    case 'A3325'
        for i=1:size(endmembers.A3325,2)
            list = [list '|' endmembers.A3325(i).name];
        end
    case 'C480'
        for i=1:size(endmembers.C480,2)
            list = [list '|' endmembers.C480(i).name];
        end
    case 'L480'
        for i=1:size(endmembers.L480,2)
            list = [list '|' endmembers.L480(i).name];
        end
    case 'L2151'
        for i=1:size(endmembers.L2151,2)
            list = [list '|' endmembers.L2151(i).name];
        end
    case 'M480'
        for i=1:size(endmembers.M480,2)
            list = [list '|' endmembers.M480(i).name];
        end
    case 'M2151'
        for i=1:size(endmembers.M2151,2)
            list = [list '|' endmembers.M2151(i).name];
        end
    case 'M3325'
        for i=1:size(endmembers.M3325,2)
            list = [list '|' endmembers.M3325(i).name];
        end
    case 'M4280'
        for i=1:size(endmembers.M4280,2)
            list = [list '|' endmembers.M4280(i).name];
        end
    case 'S480'
        for i=1:size(endmembers.S480,2)
            list = [list '|' endmembers.S480(i).name];
        end
    case 'S2151'
        for i=1:size(endmembers.S2151,2)
            list = [list '|' endmembers.S2151(i).name];
        end
    case 'S3325'
        for i=1:size(endmembers.S3325,2)
            list = [list '|' endmembers.S3325(i).name];
        end
    case 'S4280'
        for i=1:size(endmembers.S4280,2)
            list = [list '|' endmembers.S4280(i).name];
        end
    case 'V224'
        for i=1:size(endmembers.V224,2)
            list = [list '|' endmembers.V224(i).name];
        end
    case 'V480'
        for i=1:size(endmembers.V480,2)
            list = [list '|' endmembers.V480(i).name];
        end
    case 'V2151'
        for i=1:size(endmembers.V2151,2)
            list = [list '|' endmembers.V2151(i).name];
        end
end
set(h_list,'String',list);

% Plot the selected endmembers and the lighted endmember on the list
function plotEndmembers(h_plot,endmember)
axes(h_plot);
cla;
global selectedEndmembers;
for i=1:size(selectedEndmembers,1)
    plot(selectedEndmembers(i,:),'b-');
    hold on;
end
plot(endmember,'r-');
ylim([0.0 1.0]);

% Add the selected endmember
function addEndmember(endmember,h_num)
k = str2double(get(h_num,'String'));
global selectedEndmembers;
selectedEndmembers(k+1,:) = endmember;
set(h_num,'String',k+1);

% Get the endmember
function [endmember] = getEndmember(index_v,bands,dataset)
endmember = zeros(1,str2double(bands));
index = index_v - 1;
global endmembers;
if index > 0    
    switch [dataset bands]
        case 'A480'
            endmember = endmembers.A480(index).reflectance;
        case 'A2151'
            endmember = endmembers.A2151(index).reflectance;
        case 'A3325'
            endmember = endmembers.A3325(index).reflectance;
        case 'C480'
            endmember = endmembers.C480(index).reflectance;
        case 'L480'
            endmember = endmembers.L480(index).reflectance;
        case 'L2151'
            endmember = endmembers.L2151(index).reflectance;
        case 'M480'
            endmember = endmembers.M480(index).reflectance;
        case 'M2151'
            endmember = endmembers.M2151(index).reflectance;
        case 'M3325'
            endmember = endmembers.M3325(index).reflectance;
        case 'M4280'
            endmember = endmembers.M4280(index).reflectance;
        case 'S480'
            endmember = endmembers.S480(index).reflectance;
        case 'S2151'
            endmember = endmembers.S2151(index).reflectance;
        case 'S3325'
            endmember = endmembers.S3325(index).reflectance;
        case 'S4280'
            endmember = endmembers.S4280(index).reflectance;
        case 'V224'
            endmember = endmembers.V224(index).reflectance;
        case 'V480'
            endmember = endmembers.V480(index).reflectance;
        case 'V2151'
            endmember = endmembers.V2151(index).reflectance;
    end
end

% Run
function run(ab_type,params,num_images,lines,samples,num_endmembers,repeat,selectedEndmembers)
button = questdlg([num2str(num_images) ' hyperspectral synthetic image(s) of size ' num2str(lines) ' by ' num2str(samples) ' are going to be created, by randomly selecting ' num2str(num_endmembers) ' endmembers from a set of ' num2str(size(selectedEndmembers,1)) ' spectral signatures. The resulting hyperspectral image(s) will have ' num2str(size(selectedEndmembers,2)) ' bands.'],'Run','Ok','Cancel','Ok');
num_bands = size(selectedEndmembers,2);
k = 1;
for i=1:num_images
    % endmembers
    endmembers = zeros(num_endmembers,num_bands);
    if repeat
        s = 1 + floor(3.*rand(num_endmembers,1));
        endmembers = selectedEndmembers(s,:);
    else
        % Select random non-previously selected endmember
        s = ones(1,size(selectedEndmembers,1));
        for j=1:num_endmembers
            while true
                z = floor(rand()*size(selectedEndmembers,1) + 1);
                if s(z)
                    s(z) = 0;
                    endmembers(j,:) = selectedEndmembers(z,:);
                    break;
                end
            end
        end
    end
    % abundancies
    abundancies = zeros(lines,samples,num_endmembers);
    switch ab_type
        case 'legendre'
            abundancies = getAbundanciesSampleLegendre(num_endmembers,max(lines,samples),params(1),params(2),params(3));
        case 'gaussian'
            abundancies = getAbundanciesSampleGaussianFields(num_endmembers,lines,samples,params(1),params(2),params(3));
    end
    % hyperspectral image
    syntheticImage = getHyperspectralSyntheticImage(endmembers,abundancies);
    while true
        filename = ['hyper-' num2str(k) '.mat'];
        k = k+1;
        file = dir(filename);
        if size(file,1) == 0
            save(filename,'syntheticImage','endmembers','abundancies');
            break;
        end
    end
end
