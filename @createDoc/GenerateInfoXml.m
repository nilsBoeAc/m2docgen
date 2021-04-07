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
%
% Author: Pierre Ollfisch
% Copyright (c) 2021

%% get template text and prepare xml file
templateTxt = getTemplate(obj);
templateTxt = strrep(templateTxt, newline, ""); % otherwise there will be two newlines...
% template contains two "%s" which can directly be addressed by sprintf or
% fprintf. 
path2info   = fullfile(obj.mFolder, "info.xml");
infoID      = fopen(path2info,'wt');

%% modify template and save file
toolboxName = obj.toolboxName;
myPathParts = strsplit(obj.outputFolder, filesep);
helptocPath = myPathParts{end};
% write info.xml and replace %s in template with custom variables
fprintf(infoID, templateTxt, toolboxName, helptocPath);

%% close file
fclose(infoID);
disp("Generated the info.xml file!")
end

function strTemplate = getTemplate(obj)
% extra function because i needed to change this frequently to find the
% correct one for this case...
infoTemplate    = fullfile(".",obj.htmlTemplate,"info.xml");
strTemplate     = fileread(infoTemplate);
end