function printToc(obj)
% This debug function prints the obj.toc cell to the command window.
%% Description:
%   The structured cell of obj.toc will be looped through recursively and
%   printed out along the way.
%   
%% Syntax:
%   obj.printToc;
%
%% Disclaimer:
%
% Author: Pierre Ollfisch
% Copyright (c) 2021

if iscell(obj.toc)
    preStr = " ";
    listElements(obj.toc, preStr);
end

end

function listElements(myCell, preStr)
% recursive function.
    fn = string(myCell(:,1)); % fieldnames = toc - names
    for i = 1:numel(fn)
        disp(preStr + fn(i));
        if ~isempty(myCell{i,3})
            newStr = preStr + "   --- ";
            listElements(myCell{i,3}, newStr);
        end
    end
end