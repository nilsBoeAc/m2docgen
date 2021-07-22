function m2doc = m2doc(opts)
% main function that controlls m2doc. m2doc converts a foder and subfolders
% into a custom matlab documentation by converting m-files into HTML files.
%% Description:
%   m2doc must be called from a script or function that provides a specific
%   option structure. Read the "run_m2doc_example.m" script or the header
%   of the class "createDoc". At first, m2doc adds itself and the target 
%   folder to the matlab path. It creates a list of all m-files and
%   assignes them an output path and table of content path (see constructor 
%   of "createDoc"). After preparing the pysical target path, the m-files
%   are converted. Lastly, the xml files controlling the MATLAB
%   documentation and the table of content structure are created. If
%   possible, a search database is added to find keywords in the default
%   matlab documentation search bar.
%   
%% Syntax:
%   obj = m2doc(opts);
%
%% Input:
%   opts - option structure: structure
%       Read the "example_run_m2doc.m" script or the header of the class
%       "createDoc".
%
%% Output:
%   m2doc object
%
%% References:
%   m2html
%
%% Disclaimer:
%
% Last editor:  Pierre Ollfisch
% Last edit on: 07.04.2021
% Code version: 1.3
% Copyright (c) 2021

%% ToDo / Changelog
% - call this function with options structure instead of a single self
%   contained function (po - 16.03.2021)

clearvars -except opts;close all; fclose('all');

%% add functions/path of m2doc to matlab path
thisScript  = mfilename('fullpath');
m2docFolder = fileparts(thisScript);
opts.m2docPath = m2docFolder;
addpath(genpath(m2docFolder));
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

%% add output folder and subfolders to matlab path
% only then the matlab documentation will find the info.xml and display the
% custom documentation inside the MATLAB documentation
addpath(genpath(opts.outputFolder));

%% print stats
if m2doc.verbose
    disp("Sucessfully converted " + length(m2doc.fileList) + " script files" ...
        + " to a html documentation!");
end
end