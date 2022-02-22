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
%   Last editor : Nils Böhnisch
%   Last edit on: 22.02.2022
%
%   Copyright (c) 2020 Nils Böhnisch, Pierre Ollfisch.
%
%   This file is part of m2docgen.
%
%   m2docgen is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   any later version. Also see the file "License.txt".

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