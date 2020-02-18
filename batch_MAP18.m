function batch_MAP18(varargin)
    %BATCH_MAP18 - Runs a full MAP18 analysis on selected subject.
    %This function is a wrapper script for the MAP18 (Huppertz) software package.
    %Each subject folder needs to have an MAP folder containing the T1 and FLAIR images and an age folder.
    %
    % Program flow:
    %
    % - The user inputs the parameters. Depending on the input a GUI is shown.
    % - For each subject <subject>, the script runs a full MAP18 analysis
    %
    % Syntax:  batch_MAP18(subject_path, subjects, map18_cfg, test_run)
    %
    % Inputs:
    %    subject_path: root folder with subject folders
    %       with GUI   : root folder for select tool
    %       without GUI: absolute path to root folder of subjects
    %       default    : pwd
    %
    %    subjects: string or cell array with relative paths to subject folders
    %       if empty, a file dialog pops up
    %
    %    map18_cfg: struct with configuration data for the script
    %       if empty, the default provided cfg_MAP18 is run
    %             map18_cfg.subject_path = absolute path to subject folder
    %             map18_cfg.map18.path = absolute path to the MAP18 installation 
	%			      (<PATH to MAP18>\MATLAB-Programs')
    %             map18_cfg.map18.param.norm = normal database (default: 'Gent_PrismaFit_T1')
    %             map18_cfg.map18.test_run = do a test_run (default: false)
    %
    % Outputs:
    %     none
    %
    % Other m-files required: UIGETDIR_MULTI, CELLIFY, CHECK_FIELDS, MAP18
    % Subfunctions: none
    % MAT-files required: none
    %
    % See also: none
    % Author: Pieter Vandemaele
    % Ghent University - Department of Diagnostic Sciences
    % Corneel Heymanslaan 10 | 9000 Ghent | BELGIUM
    % email: pieter.vandemaele@ugent.be
    % Website: http://gifmi.ugent.be
    % January 2020; Last revision: 13-January-2020 
    
	%% Start time logging
    tic
    fprintf('%s\n', repmat('=' , [1,80]));
    fprintf('RUNNING %s \n', mfilename())
    fprintf('%s\n', repmat('=' , [1,80]));
    fprintf('Started at %s\n', datetime);
    fprintf('\n');
   
    run_gui = true;
    
    %% Add path to Matlab path
    [my_path, ~, ~] = fileparts(which(mfilename));
    addpath(genpath(my_path));
    
    %% Check configuration structure
    fprintf('Checking input configuration\n');
    if nargin>=3 && ~isempty(varargin{3})
        map18_cfg = varargin{3};
    else
        try
            map18_cfg = cfg_MAP18;
        catch exception
			fprintf('%s: %s\n', exception.identifier, exception.message);
            error('MAP18:batch_MAP18', sprintf(['There are issues with the configuration file.\n', ...
                'Check if cfg_MAP18 is in the MATLAB path.']));
        end
        
        if ~exist('map18_cfg', 'var')
            error('MAP18:batch_MAP18', sprintf(['There are issues with the configuration file.\n', ...
                'Check if map18_cfg is defined in the cfg_MAP18_kliniek.m file.']));
        end
    end
    
	try
		assert(isstruct(map18_cfg), 'MAP:batch_MAP18', 'map18_cfg is not a struct');
	catch exception
		fprintf('%s: %s\n', exception.identifier, exception.message);
        error('MAP18:batch_MAP18', sprintf(['There are issues with the configuration file.\n', ...
              'Check if cfg_MAP18 is in the MATLAB path.']));	
	end

    %% Check MAP18 and SPM12
    fprintf('Checking MAP18 installation\n');
    try
        check_fields(map18_cfg, {'map18'});
    catch exception
		fprintf('%s: %s\n', exception.identifier, exception.message);
		error('MAP18:batch_MAP18', 'No valid MAP18 installation found, bailing out!');
    end
    
    try
        check_fields(map18_cfg.map18, {'path'});
    catch exception
		fprintf('%s: %s\n', exception.identifier, exception.message);
		error('MAP18:batch_MAP18', 'No valid MAP18 configuration found, bailing out!');
    end
    
    try 
        check_fields(map18_cfg.map18, {'param'});
    catch exception
		%fprintf('%s: %s\n', exception.identifier, exception.message);
		fprintf('	No normal database found, defaults to %s\n', 'Gent_PrismaFit_T1')
        map18_cfg.map18.param.norm = 'Gent_PrismaFit_T1';
    end

    try
        check_fields(map18_cfg.map18.param, {'norm'});
    catch exception
		%fprintf('%s: %s\n', exception.identifier, exception.message);
		fprintf('	No normal database found, defaults to %s\n', 'Gent_PrismaFit_T1')
        map18_cfg.map18.param.norm = 'Gent_PrismaFit_T1';
    end

	% Check MAP18 path
    map18_path = fullfile(map18_cfg.map18.path, 'MAP18_for_SPM12', 'MAP18_Program');
	map18_m = ls(fullfile(map18_path, 'map18.m'));
    
    if isempty(map18_m)
		error('MAP18:batch_MAP18', 'No valid MAP18 installation found in folder %s, bailing out!', map18_path);
    end
    
	% Adding MAP18 to path
    path_cell = regexp(path, pathsep, 'split');
    if ispc  % Windows is not case-sensitive
        on_path = any(strcmpi(map18_path, path_cell));
    else
        on_path = any(strcmp(map18_path, path_cell));
    end
    
    if ~on_path
        addpath(map18_path);
    end
	
	% Check SPM12 path
    spm12_path = fullfile(map18_cfg.map18.path, 'spm12')
	spm12_m = ls(fullfile(spm12_path, 'spm.m'));
    
    if isempty(spm12_m)
		error('MAP18:batch_MAP18', 'No valid SPM12 installation found in folder %s, bailing out!', spm12_path);
    end
    
	% Adding SPM12  to path
    path_cell = regexp(path, pathsep, 'split');
    if ispc  % Windows is not case-sensitive
        on_path = any(strcmpi(spm12_path, path_cell));
    else
        on_path = any(strcmp(spm12_path, path_cell));
    end
    
    if ~on_path
        addpath(spm12_path);
    end
	
    %% Check for test flag
    fprintf('Checking input arguments\n');
    if nargin>=4
        map18_cfg.map18.test_run = logical(varargin{4});
    else
        try
            check_fields(map18_cfg.map18, {'test_run'});
        catch exception
            map18_cfg.map18.test_run = false;
        end
    end
    
    %% Check subjects
    fprintf('Checking subjects\n');
    % Check for subjects
    if nargin>=2 && ~isempty(varargin{2})
        subjects = cellify(varargin{2});
        run_gui = false;
    end
    
    %% Check subject path
    if nargin>=1 && ~isempty(varargin{1})
        map18_cfg.subject_path = varargin{1};
        try
            check_fields(map18_cfg, 'subject_path');
        catch exception
            map18_cfg.subject_path = pwd;
        end
    end
    
    if ~isfolder(map18_cfg.subject_path)
	    error('MAP18:batch_MAP18', 'Subject path %s is not a valid folder, bailing out!', map18_cfg.subject_path);
    end
                
    %% Select subjects
    if run_gui
        fprintf('Select subject folders\n');
        subjects = cellify(uigetdir_multi(map18_cfg.subject_path , 'Select subjects to process'));
    else
        subjects = cellfun(@(x) fullfile(map18_cfg.subject_path, x), subjects, 'uni', 0);
    end
    
	fprintf('\nConfiguration\n');
	fprintf('-------------\n');
	fprintf('%s\n\n', printstruct(map18_cfg));
    
	uiwait(msgbox('Check the configuration settings in the command window!', 'Check configuration'))
	
	fprintf('Start processing subjects\n');
    
    for subject_={subjects{:}}
        subject_path = subject_{1};
        
        [~, subject_name ] = fileparts(subject_path);
        fprintf('Processing subject %s\n', subject_name);
        subject_path = fullfile(subject_path, 'MAP');
        fprintf('\tWorking path: %s\n', subject_path);
        
        age_path = dir(fullfile(subject_path , 'age *'));
        if isempty(age_path)
            error('No age path found in %s, bailing out!', subject_path);
        end
        
        age = split(age_path.name);
        age = age{2};
        age = str2double(age);
        
        if isempty(age)
            error('No valid age found in %s, bailing out!', subject_path);
        end
        
        T1_file = dir(fullfile(subject_path, '*_T1*.nii'));
        if ~isstruct(T1_file)
            error('No T1 file found in %s, bailing out!', subject_path);
        end
        
        T1_file = fullfile(T1_file.folder, T1_file.name);
        
        fprintf('\tProcessing - Subject: %s | age: %.2f\n', subject_name, age);

        if  ~map18_cfg.map18.test_run
            map18(T1_file, ...
                'full', ...
                'Gent_PrismaFit_T1', ...
                'standard', ...
                'medium', ...
                'closed', ...
                'MRIcro', ...
                age, ...
                'none@nowhere');
        end
    end
	
	%% End time logging
    fprintf('\n');
    fprintf('Finished at %s\n', datetime);
    fprintf('Total running time: %.2fs\n', toc)
    fprintf('\n');
end
