function varargout = addNew(varargin)
% addNew MATLAB code for addNew.fig
%      addNew, by itself, creates a new addNew or raises the existing
%      singleton*.
%
%      H = addNew returns the handle to a new addNew or the handle to
%      the existing singleton*.
%
%      addNew('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in addNew.M with the given input arguments.
%
%      addNew('Property','Value',...) creates a new addNew or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before addNew_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to addNew_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help addNew

% Last Modified by GUIDE v2.5 01-Apr-2017 11:57:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @addNew_OpeningFcn, ...
                   'gui_OutputFcn',  @addNew_OutputFcn, ...
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


% --- Executes just before addNew is made visible.
function addNew_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to addNew (see VARARGIN)

% Choose default command line output for addNew
handles.output = hObject;

if length(varargin)==1
    load('backupConfiguration.mat', 'backuplist');
    index = varargin{1}; 
    set(handles.name, 'String', backuplist{index,1});
        
    directionIndex = find(strcmp(cellstr(get(handles.direction, 'String')), backuplist{index,2}));
    set(handles.direction, 'Value', directionIndex);
        
    operationIndex = find(strcmp(cellstr(get(handles.operation, 'String')), backuplist{index,3}));
    set(handles.operation, 'Value', operationIndex);
        
    set(handles.sourcePath, 'String', backuplist{index,4});
    set(handles.targetPath, 'String', backuplist{index,5});
    set(handles.extension, 'String', backuplist{index,6});
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes addNew wait for user response (see UIRESUME)
% uiwait(handles.addNew);


% --- Outputs from this function are returned to the command line.
function varargout = addNew_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function name_Callback(hObject, eventdata, handles)
% hObject    handle to name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of name as text
%        str2double(get(hObject,'String')) returns contents of name as a double


% --- Executes during object creation, after setting all properties.
function name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in direction.
function direction_Callback(hObject, eventdata, handles)
% hObject    handle to direction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns direction contents as cell array
%        contents{get(hObject,'Value')} returns selected item from direction


% --- Executes during object creation, after setting all properties.
function direction_CreateFcn(hObject, eventdata, handles)
% hObject    handle to direction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in operation.
function operation_Callback(hObject, eventdata, handles)
% hObject    handle to operation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns operation contents as cell array
%        contents{get(hObject,'Value')} returns selected item from operation


% --- Executes during object creation, after setting all properties.
function operation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to operation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in browseSource.
function browseSource_Callback(hObject, eventdata, handles)
% hObject    handle to browseSource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load('backupConfiguration.mat', 'startingSourceFolder');
sourcePath = uigetdir(startingSourceFolder, 'Choose source folder');
set(handles.sourcePath, 'String', sourcePath);

% --- Executes on button press in browseTarget.
function browseTarget_Callback(hObject, eventdata, handles)
% hObject    handle to browseTarget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load('backupConfiguration.mat', 'startingTargetFolder');
targetPath = uigetdir(startingTargetFolder, 'Choose target folder.');
set(handles.targetPath, 'String', targetPath);

% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load('backupConfiguration.mat', 'backuplist');
name = get(handles.name, 'String');
directionTemp = cellstr(get(handles.direction, 'String'));
direction = directionTemp{get(handles.direction, 'Value')};
operationTemp = cellstr(get(handles.operation, 'String'));
operation = operationTemp{get(handles.operation, 'Value')};
sourcePath = get(handles.sourcePath, 'String');
targetPath = get(handles.targetPath, 'String');
extension = get(handles.extension, 'String');
    
backupTemp = {name, direction, operation, sourcePath, targetPath, extension};
if any(cellfun(@isempty, backupTemp)); msgbox('Empty field exists.');
else
    if ~isempty(backuplist) && any(strcmp(backuplist(:,1), name))
        duplicatedRow = strcmp(backuplist(:,1),name);
        button = questdlg('Overwrite duplicated name?', 'Name duplication', 'Yes', 'No', 'No');
        
        if strcmp(button, 'Yes')
            backuplist(duplicatedRow,:) = backupTemp;
            backupHandle = findall(0, 'tag', 'table'); 
            set(backupHandle, 'Data', backuplist);
            save('backupConfiguration.mat', 'backuplist', '-append');
            close(addNew);
        end
    else
        backuplist = [backuplist; backupTemp];
        backupHandle = findall(0, 'tag', 'table'); 
        set(backupHandle, 'Data', backuplist);
        save('backupConfiguration.mat', 'backuplist', '-append');
        close(addNew);
    end
end


% --- Executes on button press in cancle.
function cancle_Callback(hObject, eventdata, handles)
% hObject    handle to cancle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(addNew);



function extension_Callback(hObject, eventdata, handles)
% hObject    handle to extension (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of extension as text
%        str2double(get(hObject,'String')) returns contents of extension as a double


% --- Executes during object creation, after setting all properties.
function extension_CreateFcn(hObject, eventdata, handles)
% hObject    handle to extension (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
