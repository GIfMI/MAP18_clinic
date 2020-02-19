function [pathname] = uigetdir_multi(start_path, dialog_title)
    %UIGETDIR_MULTI - Select multiple folders with GUI.
    %
    % Modified from
    % Tiago (2020). uigetfile_n_dir : select multiple files and directories (https://www.mathworks.com/matlabcentral/fileexchange/32555-uigetfile_n_dir-select-multiple-files-and-directories), MATLAB Central File Exchange. Retrieved February 3, 2020.
    %
    % Syntax:  [path_name] =  uigetdir_multi(start_path, dialog_title)
    %
    % Inputs:
    %    start_path: (string) root path for GUI, defaults to pwd if empty
    %    dialog_title: (string) title of the File dialog
    %
    % Outputs:
    %    pathname: array with selected folders
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
    
    import javax.swing.JFileChooser;
    
    if nargin == 0 || isempty(start_path)
        start_path = pwd;
    elseif numel(start_path) == 1
        if start_path == 0 % Allow a null argument.
            start_path = pwd;
        end
    end
    
    jchooser = javaObjectEDT('javax.swing.JFileChooser', start_path);
    jchooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
    jchooser.setMultiSelectionEnabled(true);
    if nargin > 1
        jchooser.setDialogTitle(dialog_title);
    end
    status = jchooser.showOpenDialog([]);
    if status == JFileChooser.APPROVE_OPTION
        jFile = jchooser.getSelectedFiles();
        pathname = arrayfun(@(x) char(x.getPath()), jFile, 'UniformOutput', false);
    elseif status == JFileChooser.CANCEL_OPTION
        pathname = [];
    else
        error('Error occured while picking file.');
    end
end

