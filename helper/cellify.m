function obj_cell = cellify(obj)
    %CELLIFY - Turns everything to a cell.
    %Cells stay cells, char arrays are just wrapped in a cell.
    %Multidimensional arrays are turned in cell arrays with same number of
    %elements. Empty input returns an empty cell.
    %
    % Syntax:  obj_cell = cellify(obj)
    %
    % Inputs:
    %    obj: anything
    %
    % Outputs:
    %     obj_cell: cell or cell array
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
    
    if iscell(obj)
        obj_cell = obj;
    elseif isempty(obj)
        obj_cell = {};
    elseif ischar(obj)
        obj_cell = {obj};
    elseif numel(obj)>1
        for i=1:ndims(obj)
            dims{i}=ones(1, size(obj, i));
        end
        obj_cell = mat2cell(obj, dims{:});
    else
        obj_cell = {obj};
    end
end