function varargout = GCSegTool(varargin)
% GCSEGTOOL MATLAB code for GCSegTool.fig
%      GCSEGTOOL, by itself, creates a new GCSEGTOOL or raises the existing
%      singleton*.
%
%      H = GCSEGTOOL returns the handle to a new GCSEGTOOL or the handle to
%      the existing singleton*.
%
%      GCSEGTOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GCSEGTOOL.M with the given input arguments.
%
%      GCSEGTOOL('Property','Value',...) creates a new GCSEGTOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GCSegTool_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GCSegTool_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GCSegTool

% Last Modified by GUIDE v2.5 10-Jun-2017 08:07:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GCSegTool_OpeningFcn, ...
    'gui_OutputFcn',  @GCSegTool_OutputFcn, ...
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


% --- Executes just before GCSegTool is made visible.
function GCSegTool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GCSegTool (see VARARGIN)
I = imread('default.jpg');
axes(handles.imageAxes);
imshow(I);
I = imread('default.jpg');
axes(handles.segAxes);
imshow(I);

% Choose default command line output for GCSegTool
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GCSegTool wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GCSegTool_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in SelectPushbutton.
function SelectPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SelectPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global im;
[path, Cancel] = imgetfile();
if Cancel
    msgbox(sprintf('Error'),'Error','Error');
    return
end
im = imread(path);
axes(handles.imageAxes);
imshow(im);


% --- Executes on button press in foregroundPushbutton.
function foregroundPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to foregroundPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global fg;
disp('select foreground pixels');
h=imfreehand('Closed',false);
setColor(h,'r');
pos = getPosition(h);
size(pos)
fg=zeros(size(pos));
fg(:,1)= ceil(pos(:,2));
fg(:,2)= ceil(pos(:,1));


% --- Executes on button press in backgroundPushbutton.
function backgroundPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to backgroundPushbutton (see GCBO)
% eventdata  reserved to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global bg;
disp('select background pixels');
h=imfreehand('Closed',false);
setColor(h,'b');
pos = getPosition(h);
size(pos)
bg=zeros(size(pos));
bg(:,1)= ceil(pos(:,2));
bg(:,2)= ceil(pos(:,1));


% --- Executes on button press in segmentPushbutton.
function segmentPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to segmentPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Interactive Graph cuts Segmentation Algorithm
% Towards Medical Image Analysis course
% By Ravindra Gadde, Raghu Yalamanchili

% Interactive Graph cut segmentation using max flow algorithm as described
% in Y. Boykov, M. Jolly, "Interactive Graph Cuts for Optimal Boundary and
% Region Segmentation of Objects in N-D Images", ICCV, 2001.

global im fg bg;
lambda=10^0;% Terminal Constant
K=10; % Large constant
sigma=1;% Similarity variance

c=10^8;% Similarity Constant

m = double(rgb2gray(im));
[height,width] = size(m);

disp('building graph');

N = height*width;

% construct graph
% Calculate weighted graph
E = edges4connected(height,width);
V = c*exp(-abs(m(E(:,1))-m(E(:,2))))./(2*sigma^2);
A = sparse(E(:,1),E(:,2),V,N,N,4*N);
T = calc_weights(m,fg,bg,K,lambda);


%Max flow Algorithm
disp('calculating maximum flow');

[flow,labels] = maxflow(A,T);
labels = reshape(labels,[height width]);
for k=1:3
    for i = 1: height
        for j = 1: width
            if(labels(i,j)==0)
                im_segment(i,j,k)=im(i,j,k);
                
            else
                im_segment(i,j,k)=255;
                
                
            end
        end
    end
end

% imagesc(labels); title('labels');
axes(handles.segAxes);
imshow(uint8(im_segment));


% --- Executes on slider movement.
function lambdaSlider_Callback(hObject, eventdata, handles)
% hObject    handle to lambdaSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global im fg bg;
lambda=10^(50*get(hObject,'Value'));% Terminal Constant
K=10; % Large constant
sigma=1;% Similarity variance

c=10^8;% Similarity Constant

m = double(rgb2gray(im));
[height,width] = size(m);

disp('building graph');

N = height*width;

% construct graph
% Calculate weighted graph
E = edges4connected(height,width);
V = c*exp(-abs(m(E(:,1))-m(E(:,2))))./(2*sigma^2);
A = sparse(E(:,1),E(:,2),V,N,N,4*N);
T = calc_weights(m,fg,bg,K,lambda);


%Max flow Algorithm
disp('calculating maximum flow');

[flow,labels] = maxflow(A,T);
labels = reshape(labels,[height width]);
for k=1:3
    for i = 1: height
        for j = 1: width
            if(labels(i,j)==0)
                im_segment(i,j,k)=im(i,j,k);
                
            else
                im_segment(i,j,k)=255;
                
                
            end
        end
    end
end

% imagesc(labels); title('labels');
axes(handles.segAxes);
imshow(uint8(im_segment));


% --- Executes during object creation, after setting all properties.
function lambdaSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lambdaSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
