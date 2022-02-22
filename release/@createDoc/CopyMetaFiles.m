function CopyMetaFiles(obj)
% copy the meta folder with css files and images to a target directory
%% Description:
%   This function is part of the class @createDoc. It copies the contents
%   of a folder specified by obj.htmlTemplate and pastes them into a new
%   folder specified by obj.htmlMetaFolder.
%   
%% Syntax:
%   obj.CopyMetaFiles;
%
%% Input:
%   no input values required
%
%% Output:
%   no direct output values
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

% copy entire folder with all meta files to target directory
mySource = obj.htmlTemplate;
myTarget = fullfile(obj.outputFolder,obj.htmlMetaFolder);

copyfile(mySource, myTarget);

% remove everything that is related to the creation of the documentation
strExclude = ["info.xml" ".tpl"];
listFolder = dir(myTarget);
for i = length(listFolder):-1:1
    currName = string(listFolder(i).name);
    if contains(currName, strExclude)
        tmpPath = fullfile(myTarget, currName);
        delete(tmpPath);
    end
end

end