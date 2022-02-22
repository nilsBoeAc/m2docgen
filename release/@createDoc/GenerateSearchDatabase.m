function GenerateSearchDatabase(obj)
% Function that will try to generate the search database
%
%% Description:
% This function will try to build the search database based on the html
% output folder. If not possible because *reason*, then the try-catch will
% prevent the script from crashing.
%
%% Inputs:
%   no direct inputs
%       uses obj.fileList;
%
%% Outputs:
%   no direct outputs
%       saves database to new subfolder of html output folder
%
%% Syntax:
%   obj.GenerateSearchDatabase;
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

htmlfolder = obj.outputFolder;
warning('off');
rmpath(genpath(htmlfolder));
rmpath(genpath(obj.mFolder));
addpath(genpath(obj.mFolder));
addpath(genpath(htmlfolder));
% removing and adding everything from the matlab path ensures that the
% thing works everytime on the first try. If not, move one folder above the
% toolbox you want to convert, remove it from the path, and add it again.
% Only then will the info.xml file be parsed
warning('on');

try
    builddocsearchdb(htmlfolder);
    disp("Building the search database was successful");
catch ME
    disp("Building the search database failed! Please try again!")
    %rethrow(ME); % for debugging
end
end