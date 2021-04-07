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
%% Properties:
%   toolboxName - string : "Name_of_the_toolbox"
%       Distinct name that will be shown in the documentation
%   delOld - boolean: true
%       If documentation folder opts.outputFolder already exist, delete it 
%       first.
%   mFolder - string array : ["absolute_path_to_scripts"]
%       The folder specified in this variable (and subfolders) will be 
%       searched for .m and .mlx files to convert to html. Multiple folders
%       are possible. 
%   outputFolder - string array : ["absolute_path_to_output_folder"]
%       The folder specified in this variable will contain a subfolder with 
%       the converted html files, as well as the toc xml file. 
%   buildSubDir - boolean : false
%       If false, then the converted html files will be saved without
%       structure directly into the outputFolder. If true, html files will
%       be saved in a subfolders mirroring the TOC. 
%   excludeFolder - string array : ["folder_names_to_exclude"]
%       If the path of an m file contains these words, they will be ignored
%       and not be converted to html.
%   excludeFile - string array : ["file_name_to_exclude"]
%       If the file name contains one of these words, they will be ignored
%       and not converted to html.
%   htmlFolderName - string: "name_of_output_html_folder"
%       Within the opts.outputFolder will be a subfolder which contains the
%       converted html files. This variable is the name of that folder.
%   htmlMetaFolder - string : ["relative_folder_name"]
%       This folder will contain the css-files and images of the html files
%       and will be a subfolder of opts.outputFolder.
%   htmlTemplate - string:  ["relative_folder_name"]
%       Define the folder containing the html template files that will
%       define the structure and look of the exported documents. The path
%       must be relative to m2docs tempalte folder.
%   startpage - string array: ["name_of_landing_page_html_file_name"]
%       The very first toc-element will be displayed when opening the html
%       documentation, but is not a regular function/class m-file. Create
%       this landing page by manaully creating an m/mlx-file with this name
%       that contains the desired contents. It will be converted and used
%       accodingly.
%   toc - cell: 
%       The html documentation requires an xml file (helptoc.xml) that
%       structures the documentation. If this variable is empty, then the
%       original folder structure from opts.mFolder will be used.
%       Alternatively, a custom structure can be defined:
%       First cell column:  Names displayed in toc
%       Second cell column: Folder of origin
%       Third cell column:  cell that can define a substructure
%       Example: opts.toc = {"MyToolbox", "/", {}};
%           - All files from the root directory will be inside "MyToolbox"
%       opts.toc{1,3} = {"Vehicles", ["cars" "rockets"], {}};
%           - All files whose last folder is either "cars" or "rocket" will
%           be found under a new sub-toc element instead of the root dir:
%           Mytoolbox->Vehicles
%   verbose - boolean: false
%       If true, then more intermediate steps will be documented in the
%       command window.
%
%% References:
%   m2html
%
%% Disclaimer:
%
% Author: Pierre Ollfisch
% Copyright (c) 2021

%% ToDo / Changelog
% - use constructor to build the important file list (po - 15.03.2021)

properties (Access = public)
    % from initial call
    toolboxName     string;
    delOld          logical; 
    mFolder         string;
    outputFolder    string;
    buildSubDir     logical;
    excludeFolder   string;
    excludeFile     string;
    htmlMetaFolder  string;
    startPage       string;
    htmlFolderName  string;
    htmlTemplate    string;
    toc             cell;
    verbose         logical;
    % from GenerateFileList():
    fileList        struct;
    % from GenerateFuncRefList():
    funcRefList     string;
end

methods (Access = public)
    %% Constructor
     function obj = createDoc(opts)
        % set properties accorting to inputs and create filtered file list
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
        obj.htmlTemplate   = fullfile("Templates", opts.htmlTemplate);
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