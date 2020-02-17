function out_var = get_var_name(in_var)
    %GET_VAR_NAME - Wrapper function to get the string representation of a variable.
    %Can only be done using a function call.
    %
    % Syntax:  out_var =  get_var_name(in_var)
    %
    % Inputs:
    %    in_var: anything
    %
    % Outputs:
    %    out_var: (string) string representation of the input.
    %        if in_var is string, out_var returns in_var
    %        if in_var is empty, out_var is an empty char
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
    % January 2020; Last revision: 14-January-2020
    
    if ischar(in_var)
        out_var = in_var;
    elseif isempty(in_var)
        out_var = '';
    else
        out_var = inputname(1);
    end
end