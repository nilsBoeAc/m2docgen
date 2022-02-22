function GenerateFolderStructure(obj)
% generates the specified folder structure for m2docgen documentation
%% Description:
%   This function is part of m2docgen and creates the folder structure. If 
%   the user specified a specific folder structure, then this function will
%   generate that.
%   
%% Syntax:
%   [m2docgen].GenerateFolderStructure;
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

if obj.verbose
    disp("Creating documentation folder structure...")
end

mkdir(obj.outputFolder); % generates the output folder with the html documents
mkdir(fullfile(obj.outputFolder, obj.htmlFolderName)); % folder with css files etc

%% create entire subdirectory structure if required
% follow up functions are speed up and wont error out
if obj.buildSubDir
    for i = 1:length(obj.fileList)
        currPath = fullfile(obj.outputFolder, obj.fileList(i).htmlOutputPath);
        if ~isfolder(currPath)
            mkdir(currPath)
        end
    end
end

end