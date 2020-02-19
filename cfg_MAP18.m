function map18_cfg = cfg_MAP18()
    %cfg_MAP18 - Configuration file for the MAP18_CLINIC package.
    %This file is used set parameters for conversion and analysis which are
    %specific to your current setup.
    %Some parameters are required, others optional.
    %
    % Syntax:  batch_MAP18(subject_path, subjects, map18_cfg, test_run)
    %
    % Inputs:
    %    none
    %
    % Outputs:
    %    map18_cfg: struct with configuration parameters
    %
    %    === DATA SPECIFIC ===
    %    map18_cfg.subject_path = absolute path to subject folder
    %           if empty, calling script should deal with it
    %
    %    === MAP18 SPECIFIC ===
    %    --- MAP18 LOCATION
    %    map18_cfg.map18.path = absolute path to the MAP18 installation 
	%	     (<PATH to MAP18>\MATLAB-Programs')
    %
    %    --- MAP18 PARAMETERS
    %    map18_cfg.map18.param.norm = normal database (default: 'Gent_PrismaFit_T1')
    %
    %    --- BATCH TEST
    %    map18_cfg.map18.test_run = flag to do a test_run (default: false)
    %
    %    === DICOM CONVERSION SPECIFIC ===
    %    --- DCM2NIIX
    %    map18_cfg.d2n.path = root folder of dcm2niix;
    %    map18_cfg.d2n.exe = 'dcm2niix';
    %    map18_cfg.d2n.options = '-f %n_%t_%3s_%p -v n -o'
    %
    %    --- SEQUENCE MAPPING
    %    map18_cfg.seqmap(i).protocol = '_<protocol_name>'
    %    map18_cfg.seqmap(i).sequence = '_<sequence_name>'
    %    map18_cfg.seqmap(i).contrast = '_<contrast>'
    %    
    %    --- REGEXP FOR MAPPING
    %    map18_cfg.prep.regexp: (string) regular expression used to match files from
    %                           DICOM to NIfTI converter
    %                           depends on map18_cfg.d2n.options
    %                           must contain one %s for the contrast name
    %                           '([^s].*)(%s)(_WBA)?([a-z])?$'
    %
    %    --- FLAGS FOR CONVERSION/CLEANING
    %	 map18_cfg.prep.delete_files: flag to delete unmapped files (default: false)
    %
    %	 map18_cfg.prep.flair_wba: flag to run a FLAIR whole brain analysis (default: true)
	%           if true, the suffix _WBA will be added to the FLAIR nii file     
    %
    % Other m-files required: none
    % Subfunctions: none
    % MAT-files required: none
    %
    % See also: none
    % Author: Pieter Vandemaele
    % Ghent University - Department of Diagnostic Sciences
    % Corneel Heymanslaan 10 | 9000 Ghent | BELGIUM
    % email: pieter.vandemaele@ugent.be
    % Website: http://gifmi.ugent.be
    % January 2020; Last revision: 19-February-2020     
    
    % === DATA SPECIFIC ===
    map18_cfg.subject_path = 'D:\Projects\MAP18_clinic\Patienten_test\';
    
    % === MAP18 SPECIFIC ===
    % --- MAP18 LOCATION
    map18_cfg.map18.path = 'D:\Software\MAP18\MATLAB-Programs';
    
    % --- MAP18 PARAMETERS
    map18_cfg.map18.param.norm = 'Gent_PrismaFit_T1';
    
    % --- BATCH TEST
    map18_cfg.map18.test_run = false;    
    
    % === DICOM CONVERSION SPECIFIC ===
    % --- DCM2NIIX
    map18_cfg.d2n.path = 'D:\Software\dcm2nii';
    map18_cfg.d2n.exe = 'dcm2niix';
    map18_cfg.d2n.options = '-f %n_%t_%3s_%p -v n -o';
    
    % --- SEQUENCE MAPPING
    map18_cfg.seqmap(1).protocol = '_tfl3d1_16ns';
    map18_cfg.seqmap(1).sequence = '_t1_mprage_sag_p2_iso';
    map18_cfg.seqmap(1).contrast = '_T1';
    
    map18_cfg.seqmap(2).protocol = '_spcir_278ns';
    map18_cfg.seqmap(2).sequence = '_FLAIR3D_sag';
    map18_cfg.seqmap(2).contrast = '_FLAIR';
    
    map18_cfg.seqmap(3).protocol = '_tfl3d1_16ns';
    map18_cfg.seqmap(3).sequence = '_T1_mprage';
    map18_cfg.seqmap(3).contrast = '_T1';

    % --- REGEXP FOR MAPPING
    map18_cfg.prep.regexp = '([^s].*)(%s)(_WBA)?([a-z])?';
    
    % --- FLAGS FOR CONVERSION/CLEANING
    map18_cfg.prep.delete_files = false;
    map18_cfg.prep.flair_wba = true;
