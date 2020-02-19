function [chk, msg] = check_fields(struct_var, fields)
    %CHECK_FIELDS - Checks the presence of one or more fields in a structure.
    %This functions wraps around the isfield function.
    %An error is thrown when non-string input or non-present fields are found.
    %
    % Syntax:  [chk, msg] =  check_fields(struct_var, fields)
    %
    % Inputs:
    %    struct_var: a structure
    %    fields: string or cell array of strings containing field names to test.
    %
    % Outputs:
    %    To enable the output, comment out the lines with 'error'
    %    chk: (bool) true if all fields are found, false otherwise
    %    msg: (char) error message
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
    
    struct_var_name = inputname(1);
    
    chk = false;

    fields = cellify(fields);
    
    % Test structure
    if ~isstruct(struct_var)
        msg = sprintf('MAP18:check_fields: The first input is not a structure, please check.');
        error('MAP18:check_fields', 'The first input is not a structure, please check.');
    end
    
    % Test on non-string elements
    tf = cellfun(@ ischar, fields);
    if ~all(tf)
        msg = sprintf('MAP18:check_fields: The fields array contains a non-string variable, please check.');
        error('MAP18:check_fields', 'The fields array contains a non-string variable, please check.');
    end
        
    % Test on presence of field
    tf = isfield(struct_var, fields);
    if ~all(tf)
        idx = find(tf==0, 1);
        msg = sprintf('MAP18:check_fields: The structure %s does not contain the required field %s, please check.', struct_var_name, fields{idx});
        error('MAP18:check_fields', 'The structure %s does not contain the required field %s, please check.', struct_var_name, fields{idx});
    end
    
    chk = true;
end