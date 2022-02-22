function GenerateFuncRefList(obj)
% Makes an array of all function names (without excension) and assignes an
% html file.
%% Description:
%   Each html file can link to other function documents, but only if the
%   other function names are known. This function generates a list of known
%   functions and assignes the according html document.
%   
%% Syntax:
%   obj.GenerateFuncRefList;
%
%% Input:
%   no direct inputs
%       uses obj.fileList
%% Output:
%   no direct outputs
%       saves obj.funcRefList;
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

fileList = obj.fileList;
refNames = string({fileList.name});
refHTMLPath = fullfile(string({fileList.htmlOutputPath}),refNames + ".html");

%% return value to object
obj.funcRefList = [refNames' refHTMLPath'];
if obj.verbose
    disp("Sucessfully created the function reference list!")
end
end