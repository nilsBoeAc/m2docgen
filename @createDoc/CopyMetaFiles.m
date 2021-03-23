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
%
% Last editor:  Pierre Ollfisch
% Last edit on: 22.03.2021
% Code version: 1.0
% Copyright (c) 2021

% copy entire folder with all meta files to target directory
mySource = fullfile(pwd, obj.htmlTemplate);
myTarget = fullfile(obj.outputFolder,obj.htmlMetaFolder);

copyfile(mySource, myTarget);
end