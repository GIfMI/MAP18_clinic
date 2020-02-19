function prepare_MAP18(varargin)
    %PREPARE_MAP18 - Converts DICOM to NIfTI and reorder/rename data for MAP18 processing.
    %This function is a wrapper script for dcm2niix (Chris Rorden) for DICOM to NIfTI conversion.
    %A folder MAP is created in the same root folder as the DICOM images.
    %Also a folder 'age <float>' is created within the MAP folder.
    %
    % Program flow:
    %
    % - The user inputs the parameters. Depending on the input a GUI is shown.
    % - For each subject <subject>, the script
    %   * converts all images in '<subject>/Dicom' to NIfTI
    %   * moves the files to '<subject>/MAP'
    %   * renames MPRAGE images to T1 and FLAIRD3D to FLAIR (depends on seqmap, see below)
    %   * deletes other NIfTI files if flagged
    %   * adds a an incremental counter to the end if the file already
    %     exists
    %   * calculates age of subject at scan date and creates folder '<subject>/age <age>'
    %
    % Syntax:  prepare_MAP18(subject_path, subjects, map18_cfg, delete_files)
    %
    % Inputs:
    %    subject_path: (string) root folder with subject folders
    %       with GUI   : root folder for select tool
    %       without GUI: absolute path to root folder of subjects
    %       default    : pwd
    %
    %    subjects:(string or cell array) with relative paths to subject folders
    %       if empty, a file dialog pops up
    %
    %    map18_cfg: (struct) with configuration for the script
    %       if empty, the default provided cfg_MAP18 is run
    %
    %       === DATA SPECIFIC ===
    %        map18_cfg.subject_path = absolute path to subject folder
    %               if empty, calling script should deal with it
    %
    %       === DICOM CONVERSION SPECIFIC ===
    %       --- DCM2NIIX
    %       map18_cfg.d2n.path = root folder of dcm2niix;
    %       map18_cfg.d2n.exe = 'dcm2niix';
    %       map18_cfg.d2n.options = '-f %n_%t_%3s_%p -v n -o'
    %
    %       --- SEQUENCE MAPPING
    %       map18_cfg.seqmap(i).protocol = '_<protocol_name>'
    %       map18_cfg.seqmap(i).sequence = '_<sequence_name>'
    %       map18_cfg.seqmap(i).contrast = '_<contrast>'
    %    
    %       --- REGEXP FOR MAPPING
    %       map18_cfg.prep.regexp: (string) regular expression used to match files from
    %                              DICOM to NIfTI converter
    %                              depends on  map18_cfg.d2n.options
    %                              must contain one %s for the contrast name
    %                              '([^s].*)(%s)(_WBA)?([a-z])?$'
    %
    %       --- FLAGS FOR CONVERSION/CLEANING
    %       map18_cfg.prep.delete_files: flag to delete unmapped files (default: false)
	%               overriden if provided as an argument     
    %       map18_cfg.prep.flair_wba: flag to run a FLAIR whole brain analysis (default: true)
	%               if true, the suffix _WBA will be added to the FLAIR nii file     
    %               overriden if provided as an argument
	%
    %    delete_files: (logical) flag to delete unmapped files, overrides flag in map18_cfg.prep(default: false)
    %
    %    flair_wba: (logical) flag to run a FLAIR whole brain analyis, overrides flag in map18_cfg.prep(default: true)	
    %           if true, the suffix _WBA will be added to the FLAIR nii file    
    %
    % Outputs:
    %     none
    %
    % Other m-files required: UIGETDIR_MULTI
    % Subfunctions: CHECK_MAPPING_AND_RENAME
    % MAT-files required: none
    %
    % See also: none
    % Author: Pieter Vandemaele
    % Ghent University - Department of Diagnostic Sciences
    % Corneel Heymanslaan 10 | 9000 Ghent | BELGIUM
    % email: pieter.vandemaele@ugent.be
    % Website: http://gifmi.ugent.be
    % January 2020; Last revision: 19-February-2020
    
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
            error('MAP18:prepare_MAP18', sprintf(['There are issues with the configuration file.\n', ...
                'Check if cfg_MAP18 is in the MATLAB path.']));
        end
        
        if ~exist('map18_cfg', 'var')
            error('MAP18:prepare_MAP18', sprintf(['There are issues with the configuration file.\n', ...
                'Check if map18_cfg is defined in the cfg_MAP18_kliniek.m file.']));
        end
    end
    
	try
		assert(isstruct(map18_cfg), 'MAP:prepare_MAP18', 'map18_cfg is not a struct');
	catch exception
		fprintf('%s: %s\n', exception.identifier, exception.message);
        error('MAP18:prepare_MAP18', sprintf(['There are issues with the configuration file.\n', ...
              'Check if cfg_MAP18 is in the MATLAB path.']));	
	end
    
     %% Check preparation
    fprintf('Checking preparation parameters\n');
    try
        check_fields(map18_cfg, {'prep'});
    catch exception
		fprintf('%s: %s\n', exception.identifier, exception.message);
		error('MAP18:prepare_MAP18', 'No valid MAP18 configuration found, bailing out!');
    end
    
    %% Check dcm2niix
    fprintf('Checking dcm2niix installation\n');
    try
        check_fields(map18_cfg, {'d2n'});
    catch exception
		fprintf('%s: %s\n', exception.identifier, exception.message);
		error('MAP18:prepare_MAP18', 'No valid dcm2niix installation found, bailing out!');
    end
    
    try
        check_fields(map18_cfg.d2n, {'path', 'exe'});
    catch exception
		fprintf('%s: %s\n', exception.identifier, exception.message);
		error('MAP18:prepare_MAP18', 'No valid dcm2niix installation found, bailing out!');
    end

    if ~isfield(map18_cfg.d2n, 'options') || isempty(map18_cfg.d2n.options)
        map18_cfg.d2n.options = '-f %n_%t_%3s_%p -v n -o';
    end
    
    [status, ~] = system(fullfile(map18_cfg.d2n.path, map18_cfg.d2n.exe));
    
    if status
 		error('MAP18:prepare_MAP18', 'No valid MAP18 installation found in folder %s, bailing out!', fullfile(map18_cfg.d2n.path, map18_cfg.d2n.exe));
    end
    
    %% Check sequence mapping
    fprintf('Checking sequence mapping\n');
    try
        check_fields(map18_cfg, 'seqmap');
    catch exception
		fprintf('%s: %s\n', exception.identifier, exception.message);
		error('MAP18:prepare_MAP18', 'No valid sequence mapping found in file cfg_MAP18, bailing out!');
    end
    
    if ~isstruct(map18_cfg.seqmap)
 		error('MAP18:prepare_MAP18', 'No valid sequence mapping found in file cfg_MAP18, bailing out!');
    end
    
    for i=1:numel(map18_cfg.seqmap)
        try
            check_fields(map18_cfg.seqmap(i), {'protocol', 'sequence', 'contrast'});
        catch exception
    		fprintf('%s: %s\n', exception.identifier, exception.message);
		    error('MAP18:prepare_MAP18', 'Sequence mapping %i misses a required field, bailing out!', i);
        end
    end
   
    %% Check for regular expression
    try
        check_fields(map18_cfg.prep, {'regexp'});
    catch exception
        error('MAP18:prepare_MAP18', 'A regular regular expression for filename matching is required, bailing out!');
    end
    
    %% Check for delete files flag
    fprintf('Checking input arguments\n');
    if nargin>=4
        map18_cfg.prep.delete_files = logical(varargin{4});
    else
        try
            check_fields(map18_cfg.prep, {'delete_files'});
        catch exception
            map18_cfg.prep.delete_files = false;
        end
    end
    
    %% Check for flair_wba flag
    if nargin>=5
        map18_cfg.prep.flair_wba = logical(varargin{5});
    else
        try
            check_fields(map18_cfg.prep, {'flair_wba'});
        catch exception
            map18_cfg.prep.flair_wba = true;
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
	    error('MAP18:prepare_MAP18', 'Subject path %s is not a valid folder, bailing out!', map18_cfg.subject_path);
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
	fprintf('%s\n', printstruct(map18_cfg));
    
	uiwait(msgbox('Check the configuration settings in the command window!', 'Check configuration'))
    fprintf('Start processing subjects\n');
    map_log = [];
    
    %% LOOPING SUBJECTS
    for subject_={subjects{:}}
        subject_path = subject_{1};
        [~, subject_name ] = fileparts(subject_path);
        fprintf('Processing subject %s\n', subject_name);
        fprintf('\tWorking path: %s\n', subject_path);
        
        fprintf('\tChecking DICOM and MAP paths\n');
        subject_dicom_path = fullfile(subject_path, 'Dicom');
        subject_map18_path = fullfile(subject_path, 'MAP');
        
        % === Check Dicom path
        if ~isfolder(subject_dicom_path)
            error('No Dicom path available at %s, bailing out!', subject_dicom_path);
        end
        
        % === Check MAP path
        if ~isfolder(subject_map18_path)
            status = mkdir(subject_map18_path);
            if ~status
                error('Could not make output path %s, bailing out!', subject_map18_path);
            end
        end
        
        fprintf('\tConvert DICOM to NIFTI\n');
        % === Convert dicom to nifti
        d2n_command = sprintf('%s %s %s %s', fullfile(map18_cfg.d2n.path, map18_cfg.d2n.exe), map18_cfg.d2n.options, subject_map18_path, subject_dicom_path);
        [status, ~] = system(d2n_command);
        
        if status
            error('Conversion to dicom from subject %s failed, bailing out!', subject_name);
        end
        
        fprintf('\tStart mapping\n');
        % === Select files
        all_files = dir(fullfile(subject_map18_path));
        all_files = all_files(~[all_files.isdir]);
        if ~isstruct(all_files)
            error('No NIfTI files found in %s, bailing out!', subject_map18_path);
        end
        
        % === Filtering and Renaming
        mapped = arrayfun(@(f) check_mapping_and_rename(f, map18_cfg.seqmap, map18_cfg.prep), all_files);
        map_log = horzcat(mapped, map_log);
        
        % === Create age folder
        % get a dicom file
        fprintf('\tCalculate age: ');
        dcm_content = dir(fullfile(subject_dicom_path, '**', '*.*'));
        
        dcm_files = dcm_content(~[dcm_content.isdir]);
        idx = arrayfun(@(f) isdicom(fullfile(f.folder, f.name)), dcm_files);
        
        if ~any(idx)
            error('No DICOM files available in folder %s, bailing out!', subject_dicom_path);
        end
        
        idx = find(idx, 1);
        dcminfo = dicominfo(fullfile(dcm_files(idx).folder, dcm_files(idx).name), 'UseDictionaryVR', true);
        
        % extract DOB from dicom
        date_birth = datetime(dcminfo.PatientBirthDate,'InputFormat','yyyyMMdd');
		
        % extract date of scan
        date_scan = datetime(dcminfo.AcquisitionDate,'InputFormat','yyyyMMdd');
        
        % calculate age
        age_at_scan = years(date_scan - date_birth);
        fprintf('%.2f years\n', age_at_scan);
        age_path = sprintf('age %.2f', age_at_scan);
        
        % create folder
        if ~isfolder(fullfile(subject_map18_path, age_path))
            status = mkdir(subject_map18_path, age_path);
            if ~status
                error('Could not make age path %s, bailing out!', fullfile(subject_map18_path, age_path));
            end
        end
    end
    
    if ~any(map_log)
        fprintf('WARNING: no files were mapped, check output folder\n');
    else
        fprintf('Total mapped files: %d\n', numel(find(map_log>0 & map_log<4)));
        fprintf('Total unmapped files: %d\n', numel(find(map_log==0)));
        fprintf('Total deleted files: %d\n', numel(find(map_log==4)));
        % fprintf('Mapped files with suffix only: %d\n', numel(find(map_log==2)));
        % fprintf('Mapped files with counter only: %d\n', numel(find(map_log==3)));
    end
    
    fprintf('\n');
    fprintf('Finished at %s\n', datetime);
    fprintf('Total running time: %.2fs\n', toc)
    fprintf('\n');
end

function mapped = check_mapping_and_rename(f, seqmap, prep)
    mapped = 0;

    for i=1:numel(seqmap)
        [~, fname, fext] = fileparts(f.name);
        output_file = f.name;
        
        expr = sprintf(strcat(prep.regexp, '(_\\d)?$'), seqmap(i).contrast);
        tokens = regexp(fname, expr, 'tokens');
        
        % Check if file already matches
        if ~isempty(tokens)
            mapped = 1;
            break
        end
        
        expr = sprintf(strcat(prep.regexp, '$'), seqmap(i).sequence);
        tokens = regexp(fname, expr, 'tokens');
        
        if ~isempty(tokens)
            mapped = 1;
            prefix = tokens{1}{1};
            sequence = tokens{1}{2};
            suffix = tokens{1}{4};
            contrast = seqmap(i).contrast;
            output_file = fname;
            output_file = sprintf('%s%s', prefix, contrast);
            
            if ~isempty(regexp(contrast, 'FLAIR$', 'match', 'once')) && prep.flair_wba
                output_file = sprintf('%s_WBA', output_file);
            end
            
            % build file with suffix
            if ~isempty(suffix)
                output_file = sprintf('%s%s', output_file, suffix);
                mapped = 2;
            end
            
            cnt = 1;
            output_file2 = output_file;
            while true
                if isfile(fullfile(f.folder, [output_file2 , fext]))
                    output_file2 = sprintf('%s_%d', output_file, cnt);
                    cnt = cnt+1;
                else
                    output_file = output_file2;
                    mapped = 3;
                    break;
                end
            end

            fprintf('\t\tMove file %s to %s\n', f.name, [output_file, fext]);
            movefile(fullfile(f.folder, f.name), fullfile(f.folder, [output_file, fext]));
            break
        end
    end
    
    if ~mapped && prep.delete_files
        fprintf('\t\tDeleting %s\n', fullfile(f.folder, f.name))
        mapped = 4;
        delete(fullfile(f.folder, f.name))
    end
end



