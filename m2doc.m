function m2doc = m2doc(varargin)
% create options struct and run the script to convert m files a html doc
%% Options:
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
%       must be relative to the m2doc folder.
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
clc;clearvars -except varargin;close all; fclose('all');

%% add functions/path of m2doc to matlab path
thisScript  = mfilename('fullpath');
m2docFolder = fileparts(thisScript);
cd(m2docFolder);
addpath(genpath(m2docFolder));

%% load options
% check if they were given when calling this function
p = inputParser();
p.StructExpand = false;
p.addOptional("opts", struct)
p.parse(varargin{:})
opts = p.Results.opts;
if isempty(fieldnames(opts))
    warning("Please specify an option structure when calling m2doc." ...
        + "An example can be found in getOptions.m");
else
    if numel(fieldnames(opts)) == 1
        opts = opts.opts; % catch if loaded from mat-file with load
    end
end
addpath(genpath(opts.mFolder));

%% create main object
m2doc       = createDoc(opts);

%% manage physical file and file structure
% delete contents of folder if required
if opts.delOld && exist(opts.outputFolder)
    m2doc.RemoveOldDoc;
end
% create folder structure as specified in opts.buildSubDir
m2doc.GenerateFolderStructure;
% copy important files, e.g. css and images
m2doc.CopyMetaFiles;

%% Convert m files to html
m2doc.ConvertFiles;

%% build xml file that defines the left menue in the doc (helptoc.xml)
m2doc.GenerateTocXml;

%% build info.xml file
m2doc.GenerateInfoXml;

%% try to build the search extension 
m2doc.GenerateSearchDatabase; 

%% print stats
if m2doc.verbose
    disp("Sucessfully converted " + length(m2doc.fileList) + " script files" ...
        + " to a html documentation!");
end
end