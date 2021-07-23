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
%
% Last editor:  Pierre Ollfisch
% Last edit on: 22.03.2021
% Code version: 1.0
% Copyright (c) 2021

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