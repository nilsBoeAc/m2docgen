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
%
% Author: Pierre Ollfisch
% Copyright (c) 2021

htmlfolder = obj.outputFolder;

try
    builddocsearchdb(htmlfolder);
    disp("Building the search database was sucessful");
catch
    disp("Building the search database failed!")
end
end