classdef createDoc < handle
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
      end
      %% external functions
      GenerateFilteredFileList(obj);
      GenerateTocStructure(obj);
      printToc(obj);
      GenerateRelOutputPath(obj);
   end
end