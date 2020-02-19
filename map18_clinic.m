function map18_kliniek
%MAP18_KLINIEK - GUI for dcm2niix and MAP18, tailored to use at UZGent
%Wraps around prepare_map18_kliniek (convert DICOM to NIfTI) and
%batch_map18_kliniek (run MAP18 software).
%
% Syntax:  map18_kliniek()
%
% Other m-files required:
%    prepare_MAP18_kliniek
%    batch_MAP18_kliniek
%
% Subfunctions: none
% MAT-files required: none
%
% See also: none
%
% Author: Pieter Vandemaele
% Ghent University - Department of Diagnostic Sciences
% Corneel Heymanslaan 10 | 9000 Ghent | BELGIUM
% email: pieter.vandemaele@ugent.be
% Website: http://gifmi.ugent.be
% February 2020; Last revision: 19-February-2020

fprintf('%s\n', repmat('=' , [1,80]));
fprintf('RUNNING %s \n', mfilename())
fprintf('%s\n', repmat('=' , [1,80]));
fprintf('Started at %s\n', datetime);
fprintf('\n');

%% Add path to Matlab path
[my_path, ~, ~] = fileparts(which(mfilename));
addpath(genpath(my_path));

%% Read the config m-file
try
    map18_cfg = cfg_MAP18;
catch exception
    error(sprintf(['There are issues with the configuration file.\n', ...
        'Check if cfg_MAP18_kliniek is in the MATLAB path.']));
    return
end

if ~exist('map18_cfg', 'var')
    error(sprintf(['There are issues with the configuration file.\n', ...
        'Check if map18_cfg is defined in the cfg_MAP18.m file.']));
    return
end

%% Calculate GUI parameters
% Calculate parameters for GUI
screen_size = get(0,'ScreenSize');
fig_pos = [500, screen_size(4) - 500, 250 275];

% Create a figure window
fig = uifigure('Name', 'MAP18 UZGent', 'Resize', 'off',...
    'Position', fig_pos);

% Default GUI element dimensions
btn_width = 100;
%btn_height = 22;
btn_margin = 30;
cbx_height = 30;

% Calculate button heights
btn_height = floor((fig_pos(4)- 3*btn_margin - 3*cbx_height)/2);
%btn_height = floor((fig_pos(4)- 3*btn_margin)/2);
btn_width = fig_pos(3)-2*btn_margin;
btn_left = btn_margin;

% Preparation GUI elements
btn_prep_bottom = 2*btn_margin+btn_height+3*cbx_height;
cbx_prep_bottom = btn_prep_bottom - 2*cbx_height;

try
    check_fields(map18_cfg, {'prep'});
catch exception
    flag_delete_files = true;
    flag_flair_wba = true;
end
if isfield (map18_cfg, 'prep')
    
    try check_fields(map18_cfg.prep, {'delete_files'});
        flag_delete_files = map18_cfg.prep.delete_files;
    catch exception
        flag_delete_files = true;
    end
    try check_fields(map18_cfg.prep, {'flair_wba'});
        flag_flair_wba = map18_cfg.prep.flair_wba;
    catch exception
        flag_flair_wba = true;
    end
end

% Batch processing GUI elements
btn_batch_bottom = btn_margin+cbx_height;
cbx_batch_bottom = btn_batch_bottom - 1*cbx_height;
try
    check_fields(map18_cfg, {'map18'});
catch exception
    flag_test_run = false;
end

try check_fields(map18_cfg.map, {'test_run'});
    flag_test_run = map18_cfg.map18.test_run;
catch exception
    flag_test_run = false;
end

%% Build GUI
% PREPARE
cbx_prep_delete_files = uicheckbox(fig, 'Text','Delete files',...
    'Value', flag_delete_files,...
    'Position',[btn_left, cbx_prep_bottom + cbx_height, btn_width, cbx_height]);

cbx_prep_flair_wba = uicheckbox(fig, 'Text','FLAIR whole brain analysis',...
    'Value', flag_flair_wba,...
    'Position',[btn_left, cbx_prep_bottom, btn_width, cbx_height]);

btn_prepare_map18 = uibutton(fig,'push',...
    'Text', 'Prepare data', ...
    'Position',[btn_left, btn_prep_bottom, btn_width, btn_height],...
    'ButtonPushedFcn', @(btn,event) prepare_MAP18('', '', map18_cfg, cbx_prep_delete_files.Value, cbx_prep_flair_wba.Value));

% BATCH PROCESS
cbx_batch_test_run = uicheckbox(fig, 'Text','Test run',...
    'Value', flag_test_run,...
    'Position',[btn_left, cbx_batch_bottom, btn_width, cbx_height]);

btn_batch_map18 = uibutton(fig,'push',...
    'Text', 'Batch analysis', ...
    'Position',[btn_left, btn_batch_bottom, btn_width, btn_height],...
    'ButtonPushedFcn', @(btn,event) batch_MAP18('', '', map18_cfg, cbx_batch_test_run.Value));
end