function ConvertFiles(obj)
% converts the elements from obj.fileList to HTML documents
%% Description:
% This function is part of m2doc and converts all files listed in
% obj.fileList into html documents. 
%   
%% Syntax:
%   obj.ConvertFiles;
%
%% Input:
%   no input values required
%
%% Output:
%   no direct output values
%
%% References:
%   m2html
%
%% Disclaimer:
%
% Last editor:  Pierre Ollfisch
% Last edit on: 23.03.2021
% Code version: 1.0
% Copyright (c) 2021

%% loop through all files in m2doc.fileList and convert them
fileList = obj.fileList;
for i = 1:length(fileList)
    % assign general variables
    currFileName    = [fileList(i).name fileList(i).ext];
    currFileFolder  = fileList(i).folder; % absolute folder, not relative
    currFileOutputFolder = fullfile(obj.outputFolder, ...
                            fileList(i).htmlOutputPath); % absolute html output folder, not relative
    fprintf('Converting file <a href="matlab: open(%s)">%s</a>\n',"'" + ...
        fullfile(currFileFolder, currFileName) + "'", string(currFileName));
    
    % read m file and extract text "dummys"
    currMFile       = MFile(currFileName, currFileFolder);
    currMFile.parseFile; % find text dummys and add them to currMFile obj
    currMFile.checkCrossRef(obj.funcRefList);
    
    % insert text dummys into template html to generate html file
    myName          = currMFile.name;
    tplFolder       = fullfile(pwd,obj.htmlTemplate);
    outputFolder    = currFileOutputFolder;
    styleFolder     = obj.htmlMetaFolder;
    homePath        = obj.startPage;
    myhtml          = TemplateHTML(myName, tplFolder, outputFolder, ...
                        styleFolder,homePath, obj.verbose);
    myhtml.parseStr(currMFile.dummyList); % add dummy blocks to template html document
    myhtml.createHTML; % save string as html file
end % for i
end % function ConvertFiles