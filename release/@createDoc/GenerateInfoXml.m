function GenerateInfoXml(obj)
% generates the info.xml file which controlls the documentation
%% Description:
%   A template for the xml file, which controlls the addition of the custom
%   documentation to the MATLAB DOCUMENTATION, is loaded, modified and
%   saved. 
%   
%% Syntax:
%   obj.GenerateInfoXml;
%
%% Input:
%   no direct inputs
%       requires obj.toolboxName, obj.outputFolder
%   
%% Output:
%   saves the info.xml file into the folder specified by obj.mFolder 
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

%% ToDo / Changelog
% - into xml now stored in the documentation folder.

%% get template text and prepare xml file
templateTxt = getTemplate(obj);
%templateTxt = strrep(templateTxt, newline, ""); % otherwise there will be two newlines...
% template contains target markers with %s, which can directly be addressed 
% by sprintf or fprintf. 
path2info       = fullfile(obj.mFolder, "info.xml");
infoID          = fopen(path2info,'wt');

%% modify template and save file
% find out relative path from mFolder to output Folder
toolboxName     = obj.toolboxName;
strInFolder     = strsplit(string(obj.mFolder), filesep);
strInFolder     = strInFolder(strInFolder ~= "");
mFolder         = strInFolder(end);
strOutFolder    = strsplit(string(obj.outputFolder), filesep);
strOutFolder    = strOutFolder(strOutFolder ~= "");
idx             = find(strOutFolder == mFolder);
helpTocPath     = strOutFolder(idx+1:end);
helpTocStr      = fullfile(helpTocPath{:});
% the search database index function doesnt like backslashs in the info.xml
if contains(helpTocStr, filesep)
    helpTocStr = strrep(helpTocStr,filesep, "/");
end
% write info.xml and replace the placeholders with the correct information
templateTxt = strrep(templateTxt,"{TOOLBOXNAME}",toolboxName);
templateTxt = strrep(templateTxt,"{TOOLBOXLOCATION}",helpTocStr);
fprintf(infoID, templateTxt); % toolboxName, helpTocStr);

%% close file
fclose(infoID);
disp("Generated the info.xml file!")
end

function strTemplate = getTemplate(obj)
% extra function because i needed to change this frequently to find the
% correct one for this case...
infoTemplate    = fullfile(obj.htmlTemplate,"info.xml");
strTemplate     = fileread(infoTemplate);
end