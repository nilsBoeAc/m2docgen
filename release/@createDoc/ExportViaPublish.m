function ExportViaPublish(obj, inputPath, exportPath)
% function directly exports a file to html with MATLABs editor 'save to'
%% Description:
%   This function is part of m2docgen and converts a file into a html
%   document a matlab build in function. Publish() was not used as it didnt
%   work as expected. 
%   
%% Syntax:
%   [m2docgen].ExportViaPublish(inputPath, exportPath)
%
%% Input:
% required input values
%   inputPath - total path to a file - "string" or 'char'
%   exportPath - save path of html - "string" or 'char'
%
%% Output:
%  no direct output values
%
%% Disclaimer:
%
% Last editor:  Pierre Ollfisch
% Last edit on: 17.04.2021
% Code version: 1.1
% Copyright (c) 2021

%% ToDo / Changelog
% - initial version (17.04.2021 - po)
% - chagned from publish to the liveeditor thing, less control but at least
%   it works (17.04.2021 - PO).

% opts            = struct;
% opts.format     = 'html';
% opts.stylesheet = fullfile(obj.m2docPath, obj.htmlTemplate, "stylesheetForPublish.xsl");
% opts.evalCode   = false;
% opts.catchError = false;
% opts.showCode   = false;
% opts.outputDir  = fileparts(exportPath);
%publish(inputPath, opts);

matlab.internal.liveeditor.openAndConvert(inputPath,char(exportPath));
end