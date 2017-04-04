function varargout = backup(varargin)
% BACKUP MATLAB code for backup.fig
%      BACKUP, by itself, creates a new BACKUP or raises the existing
%      singleton*.
%
%      H = BACKUP returns the handle to a new BACKUP or the handle to
%      the existing singleton*.
%
%      BACKUP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BACKUP.M with the given input arguments.
%
%      BACKUP('Property','Value',...) creates a new BACKUP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before backup_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to backup_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help backup

% Last Modified by GUIDE v2.5 01-Apr-2017 11:47:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @backup_OpeningFcn, ...
                   'gui_OutputFcn',  @backup_OutputFcn, ...
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


% --- Executes just before backup is made visible.
function backup_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to backup (see VARARGIN)

% Choose default command line output for backup
handles.output = hObject;

handles.selectedName=0;

handles.configfile = fullfile(fileparts(mfilename('fullpath')),'backupConfiguration.mat');


if exist(handles.configfile)==2
    load(handles.configfile);
    if exist('backuplist','var')==0; backuplist = {}; end;
    if exist('startingSourceFolder','var')==0; startingSourceFolder = pwd; end;
    if exist('startingTargetFolder','var')==0; startingTargetFolder = pwd; end;
    save(handles.configfile, 'backuplist', 'startingSourceFolder', 'startingTargetFolder');
else
    backuplist = {};
    startingSourceFolder = pwd;
    startingTargetFolder = pwd;
    save(handles.configfile, 'backuplist', 'startingSourceFolder', 'startingTargetFolder');
end
set(handles.table, 'Data', backuplist);
set(handles.startingSource, 'String', startingSourceFolder);
set(handles.startingTarget, 'String', startingTargetFolder);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes backup wait for user response (see UIRESUME)
% uiwait(handles.backup);


% --- Outputs from this function are returned to the command line.
function varargout = backup_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in addNew.
function addNew_Callback(hObject, eventdata, handles)
% hObject    handle to addNew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
addNew;


% --- Executes on button press in run.
function run_Callback(hObject, eventdata, handles)
% hObject    handle to run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
backuplist = get(handles.table, 'Data');
runBackup(backuplist);

% --- Executes on button press in modify.
function modify_Callback(hObject, eventdata, handles)
% hObject    handle to modify (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
addNew(handles.selectedName);

% --- Executes on button press in close.
function close_Callback(hObject, eventdata, handles)
% hObject    handle to close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
backuplist = get(handles.table, 'Data');
startingSourceFolder = get(handles.startingSource, 'String');
startingTargetFolder = get(handles.startingTarget, 'String');
save(handles.configfile, 'backuplist', 'startingSourceFolder', 'startingTargetFolder');
close(backup);


% --- Executes on button press in browseStartingSource.
function browseStartingSource_Callback(hObject, eventdata, handles)
% hObject    handle to browseStartingSource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
startingSourceFolder = get(handles.startingSource, 'String');
startingSourceFolder = uigetdir(startingSourceFolder, 'Choose starting source folder');
set(handles.startingSource, 'String', startingSourceFolder);
save(handles.configfile, 'startingSourceFolder', '-append');

% --- Executes on button press in browseStartingTarget.
function browseStartingTarget_Callback(hObject, eventdata, handles)
% hObject    handle to browseStartingTarget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
startingTargetFolder = get(handles.startingTarget, 'String');
startingTargetFolder = uigetdir(startingTargetFolder, 'Choose starting source folder');
set(handles.startingTarget, 'String', startingTargetFolder);
save(handles.configfile, 'startingTargetFolder', '-append');

% --- Executes on button press in delete.
function delete_Callback(hObject, eventdata, handles)
% hObject    handle to delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.selectedName==0; msgbox('No selected data.');
else
    backuplist = get(handles.table, 'Data');
    backuplist(handles.selectedName, :) = [];
    set(handles.table, 'Data', backuplist);
    save(handles.configfile, 'backuplist', '-append');
end

% --- Executes when selected cell(s) is changed in table.
function table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(eventdata.Indices)
    handles.selectedName = eventdata.Indices(1);
    guidata(hObject, handles);
end
