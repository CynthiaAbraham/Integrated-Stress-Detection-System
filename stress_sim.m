classdef stress_sim < matlab.apps.AppBase
% Properties that correspond to app components
properties (Access = public)
UIFigure matlab.ui.Figure
TabGroup matlab.ui.container.TabGroup
Tab matlab.ui.container.Tab
LoadHRVdataButton matlab.ui.control.Button
Tab2 matlab.ui.container.Tab
ImagesemotionButton matlab.ui.control.Button
end

% Callbacks that handle component events
methods (Access = private)
% Button pushed function: LoadHRVdataButton
function LoadHRVdataButtonPushed(app, event)
% Load ECG data
[filename, path] = uigetfile('*.mat', 'Select ECG dataset');
if filename
% Load the ECG signal
loaded_data = load(fullfile(path, filename));
disp('ECG dataset loaded.');
% Convert the structure to a cell array
data_cell = struct2cell(loaded_data);
% Access the first cell element (assuming it contains the ECG data)
ecg_data = data_cell{1};
% Plot the ECG signal
subplot(2,1,1)
plot(ecg_data); % Plot the ECG data
xlabel('Time (ms)');
ylabel('Amplitude (mV)');
title('ECG Data');
% Detect peaks in the ECG signal
[~, locs] = findpeaks(ecg_data);
% Calculate R-R intervals
rr_intervals = diff(locs);
% Display R-R intervals
disp('R-R intervals:');
disp(rr_intervals);
% Set a threshold for stress detection
threshold = 1.5; % Set your desired stress threshold value here
% Detect peaks in the ECG signal above and below the threshold
[~, locs_above] = findpeaks(ecg_data, 'MinPeakHeight', threshold);
[~, locs_below] = findpeaks(-ecg_data, 'MinPeakHeight', -threshold);

% Assess stress based on threshold
if numel(locs_above) > numel(locs_below)
fprintf('Higher stress detected (Peaks above threshold).\n');
else
fprintf('No stress detected (Peaks below threshold).\n');
end
% Calculate RMSSD
differences = diff(rr_intervals);
squared_diff = differences .^ 2;
mean_squared_diff = mean(squared_diff);
rmsdd_value = sqrt(mean_squared_diff);
% Display RMSSD value
fprintf('RMSDD Value: %.4f milliseconds\n', rmsdd_value);
end

end
% Button pushed function: ImagesemotionButton
function ImagesemotionButtonPushed(app, event)
% Load emotion image
[filename, ~] = uigetfile({'.jpg;.png','Image Files (*.jpg, *.png)'},'Select an
image');
if filename
% Extract emotional state from image filename
[~, name, ~] = fileparts(filename);
% Assuming the emotional state is encoded in the filename, parse it
% For example, if the filename is "happy_s.jpg", extract "happy"
split_name = strsplit(name, '_'); % Split filename by underscore
emotional_state = split_name{1}; % Assume emotional state is the first part
% Check if HRV value is less than 20 milliseconds
hrv_value = 20; % Placeholder value, replace with actual HRV value
if hrv_value > 80 && strcmp(emotional_state, 'happy')
disp('No Stress Detected');
elseif hrv_value <= 20 && strcmp(emotional_state, 'sad')
disp('Stress Detected');
else
disp('No Stress Detected');
end
end
end
end
% Component initialization
methods (Access = private)
% Create UIFigure and components
function createComponents(app)
% Create UIFigure and hide until all components are created
app.UIFigure = uifigure('Visible', 'off');
app.UIFigure.Position = [100 100 640 480];
app.UIFigure.Name = 'MATLAB App';
% Create TabGroup

app.TabGroup = uitabgroup(app.UIFigure);
app.TabGroup.Position = [171 210 260 221];
% Create Tab
app.Tab = uitab(app.TabGroup);
app.Tab.Title = 'Tab';
% Create LoadHRVdataButton
app.LoadHRVdataButton = uibutton(app.Tab, 'push');
app.LoadHRVdataButton.ButtonPushedFcn = createCallbackFcn(app,
@LoadHRVdataButtonPushed, true);
app.LoadHRVdataButton.Position = [81 114 100 23];
app.LoadHRVdataButton.Text = 'Load HRV data';
% Create Tab2
app.Tab2 = uitab(app.TabGroup);
app.Tab2.Title = 'Tab2';
% Create ImagesemotionButton
app.ImagesemotionButton = uibutton(app.Tab2, 'push');
app.ImagesemotionButton.ButtonPushedFcn = createCallbackFcn(app,
@ImagesemotionButtonPushed, true);
app.ImagesemotionButton.Position = [81 94 101 23];
app.ImagesemotionButton.Text = 'Images-emotion';
% Show the figure after all components are created
app.UIFigure.Visible = 'on';
end
end
% App creation and deletion
methods (Access = public)
% Construct app
function app = stress_sim
% Create UIFigure and components
createComponents(app)
% Register the app with App Designer
registerApp(app, app.UIFigure)
if nargout == 0
clear app
end
end
% Code that executes before app deletion
function delete(app)
% Delete UIFigure when app is deleted
delete(app.UIFigure)
end
end
end