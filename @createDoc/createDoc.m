classdef createDoc < handle
% This is the main class that controlls the export of .m files to an html
% documentation of a toolbox. 
%% Description:
%   Here comes a description. The Code-Word ist "Description" starting with
%   two %%. The Block ends when the next comment-Block starts (next two %%)
%   Each Block does contain a "Code-Word". Those will be stored in a dummy
%   object. 
%   
%% Syntax:
%   obj = createDoc(opts)
%       read about the opts structure in the run_m2doc.m file.
%
%% References:
%   m2html
%
%% Disclaimer:
%
% Author: Pierre Ollfisch
% Copyright (c) 2021

properties (Access = public)
    % from initial call
    toolboxName string;
    delOld logical; 
    mFolder string;
    outputFolder string;
    buildSubDir logical;
    excludeFolder string;
    excludeFile string;
    htmlMetaFolder string;
    startPage string;
    htmlFolderName string;
    htmlTemplate string;
    toc cell;
    verbose logical;
    % from GenerateFileList()
    fileList struct;
    % from GenerateFuncRefList()
    funcRefList string;
end

methods (Access = public)
    %% Constructor
     function obj = createDoc(opts)
        %% set option properties according to input structure
        obj.delOld         = opts.delOld;
        obj.mFolder        = opts.mFolder;
        obj.outputFolder   = opts.outputFolder;
        obj.buildSubDir    = opts.buildSubDir;
        obj.excludeFile    = opts.excludeFile;
        obj.excludeFolder  = opts.excludeFolder;
        obj.htmlMetaFolder = opts.htmlMetaFolder;
        obj.startPage      = opts.startPage;
        obj.toc            = opts.toc;
        obj.htmlFolderName = opts.htmlFolderName;
        obj.htmlTemplate   = opts.htmlTemplate;
        obj.verbose        = opts.verbose;
        obj.toolboxName    = opts.toolboxName;
        if obj.verbose
            disp("Sucessfully created m2doc object");
        end

        % Generate list of files to convert
        obj.GenerateFilteredFileList;
        % Add toc structure field to file list
        obj.GenerateTocStructure;
        % add relative (html) output path to file list
        obj.GenerateRelOutputPath;
        
        % generate reference list with all function names
        obj.GenerateFuncRefList;
        
    end % constructor
    
    %% functions defined externally
    CopyMetaFiles(obj);
    GenerateFilteredFileList(obj);
    GenerateTocStructure(obj);
    printToc(obj);
    GenerateRelOutputPath(obj);
    GenerateTocXml(obj);
    GenerateInfoXml(obj);
    RemoveOldDoc(obj);
    GenerateFolderStructure(obj);
    GenerateFuncRefList(obj);
    ConvertFiles(obj);

end % methods
end % classdef