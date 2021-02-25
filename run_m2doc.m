function m2doc = run_m2doc()
% create options struct and run the script to convert m files a html doc
%% Options:
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
clc;clearvars ;close all;

opts = struct(  'delOld',           true, ...
                'mFolder',          ["C:\Users\pubbe\Documents\GitHub\sdbox\TB_Code"], ...
                'outputFolder',     ["C:\Users\pubbe\Documents\GitHub\sdbox\TB_Code\sd_doc"], ...
                'buildSubDir',      false, ...
                'excludeFolder',	["debug" "external_Modules" "geometry"], ...
                'excludeFile',      ["sdp_template"], ...
                'htmlFolderName',   "html", ...
                'htmlMetaFolder',   "ressources", ...
                'startPage',        ["SDBox.html"], ...
                'toc',              [], ...
                'verbose',          true);
             
opts.toc = {"SDBox",    "/",            []; ...
            "SDBoxApp", "@SDBoxApp",    []};

opts.toc{1,3} = {   "sdb_system",   "@sdb_system",   [];
                    "Modules",      "modules",      [];
                    "Excitation",   "excitation",   []};
                
opts.toc{1,3}{1,3} = {"Result Classes" , ["@sdb_FFT" "@sdb_TF"], []};


%% add functions/path of m2doc to matlab path
currScript  = mfilename('fullpath');
m2docFolder = fileparts(currScript);
cd(m2docFolder);
addpath(genpath(m2docFolder));
addpath(genpath(opts.mFolder));

%% create main object
m2doc = createDoc(opts);

%% Generate list of files to convert
m2doc.GenerateFilteredFileList;
% Add toc structure field to file list
m2doc.GenerateTocStructure;
% add relative (html) output path to file list
m2doc.GenerateRelOutputPath;

%% delete old documentation if option is set
if opts.delOld && exist(opts.outputFolder)
    if opts.verbose
        disp("Removing previous documentation...")
    else
        warning('off');
    end
    rmdir(opts.outputFolder, 's'); % also removes subfolders and files
    % please close all programms that currently access the html documents
    % (e.g. browsers, matlab, editors, etc..)
    warning('on');
end

%% copy important style files and images etc to doc folder
if opts.verbose
    disp("Creating documentation folder structure...")
end
mkdir(opts.outputFolder);
mkdir(fullfile(opts.outputFolder, opts.htmlFolderName));
% copy entire folder with all meta files to target directory
copyfile(pwd + "\Templates\Standard_V1", fullfile(opts.outputFolder,opts.htmlMetaFolder));

%% Convert m files to html
% first: generate reference list with all functions
m2doc.GenerateFuncRefList;
% second: loop through all files in m2doc.fileList and convert them
fileList = m2doc.fileList;
for i = 1:length(fileList)
    % assign general variables
    currFileName = [fileList(i).name fileList(i).ext];
    currFileFolder = fileList(i).folder; % absolute folder, not relative
    currFileOutputFolder = fullfile(opts.outputFolder,fileList(i).htmlOutputPath); % absolute html output folder, not relative
    fprintf('Converting file <a href="matlab: open(%s)">%s</a>\n',"'" + ...
        fullfile(currFileFolder, currFileName) + "'", string(currFileName));
    
    % read m file and extract "dummys"
    currMFile = MFile(currFileName, currFileFolder);
    currMFile.parseFile;
    currMFile.checkCrossRef(m2doc.funcRefList);
    
    % use dummys and a template html to generate html file
    myName      = currMFile.name;
    tplFolder   = pwd + "\Templates\Standard_V1";
    outputFolder = currFileOutputFolder;
    styleFolder = "..\" + opts.htmlMetaFolder;
    homePath = opts.startPage;
    myhtml = TemplateHTML(myName,tplFolder,outputFolder,styleFolder,homePath, opts.verbose);
    myhtml.parseStr(currMFile.dummyList);
    myhtml.createHTML;
end

%% build xml file (helptoc.xml)

%% print stats
if m2doc.verbose
    disp("Sucessfully converted " + length(m2doc.fileList) + " script files" ...
        + " to a html documentation!");
end
end