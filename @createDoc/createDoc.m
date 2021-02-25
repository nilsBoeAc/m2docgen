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
      delOld logical; 
      mFolder string;
      outputFolder string;
      buildSubDir logical;
      excludeFolder string;
      excludeFile string;
      htmlMetaFolder string;
      startPage string;
      htmlFolderName string;
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
         obj.verbose        = opts.verbose;
         if obj.verbose
             disp("Sucessfully created m2doc object");
         end
      end
      %% external functions
      GenerateFilteredFileList(obj);
      GenerateTocStructure(obj);
      printToc(obj);
      GenerateRelOutputPath(obj);
   end
end