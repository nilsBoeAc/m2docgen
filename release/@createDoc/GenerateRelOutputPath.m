function GenerateRelOutputPath(obj)
% function to assign a path to save the converted html file to.
%% Description:
%   This function checks if the flag obj.buildSubDir is set. If no, then
%   all converted html files will be saved to obj.outputPath/html/. If yes,
%   then the toc structure will be mirrored with folderds.
%   
%% Syntax:
%   obj.GenerateRelOutputPath;
%
%% Input:
%   no direct inputs
%       gets obj.fileList
%% Output:
%   no direct outputs
%       saves obj.fileList
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

if obj.buildSubDir % if sub-folders should be used
    tmpPath = {fileList.toc};
    tmpPath = fullfile(obj.htmlFolderName, tmpPath);
    [fileList.htmlOutputPath] = tmpPath{:};
else
    tmpPath = repmat(fullfile(obj.htmlFolderName), 1,length(fileList));
    [fileList.htmlOutputPath] = tmpPath{:};
end

%% return value to object
obj.fileList = fileList;
if obj.verbose
    disp("Sucessfully assigned output paths to the script files!")
end


end