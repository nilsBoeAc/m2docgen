function m2docgen = m2docgen(opts)
% main function that controlls m2docgen. m2docgen converts foders and sub-
% folders into custom matlab documentation by converting m-files into HTML.
%% Description:
%   m2docgen must be called from a script or function that provides a specific
%   option structure. Read the "run_m2docgen_example.m" script or the header
%   of the class "createDoc". At first, m2docgen adds itself and the target 
%   folder to the matlab path. It creates a list of all m-files and
%   assignes them an output path and table of content path (see constructor 
%   of "createDoc"). After preparing the pysical target path, the m-files
%   are converted. Lastly, the xml files controlling the MATLAB
%   documentation and the table of content structure are created. If
%   possible, a search database is added to find keywords in the default
%   matlab documentation search bar.
%   
%% Syntax:
%   obj = m2docgen(opts);
%
%% Input:
%   opts - option structure: structure
%       Read the "example_run_m2docgen.m" script or the header of the class
%       "createDoc".
%
%% Output:
%   m2docgen object
%
%% References:
%   m2html
%
%% Disclaimer:
%   Last editor:  Pierre Ollfisch
%
%   Copyright (c) 2020 Nils Böhnisch, Pierre Ollfisch.
%
%   This file is part of m2docgen.
%
%   m2docgen is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   any later version. Also see the file "License.txt".

%% ToDo / Changelog
% - call this function with options structure instead of a single self
%   contained function (po - 16.03.2021)
% - changed name from m2doc to m2docgen (po - 23.07.2021)

clearvars -except opts;close all; fclose('all');

%% add functions/path of m2docgen to matlab path
thisScript  = mfilename('fullpath');
m2docFolder = fileparts(thisScript);
opts.m2docPath = m2docFolder;
addpath(genpath(m2docFolder));
addpath(genpath(opts.mFolder));

%% create main object
m2docgen       = createDoc(opts);

%% manage physical file and file structure
% delete contents of folder if required
if opts.delOld && exist(opts.outputFolder)
    m2docgen.RemoveOldDoc;
end
% create folder structure as specified in opts.buildSubDir
m2docgen.GenerateFolderStructure;
% copy important files, e.g. css and images
m2docgen.CopyMetaFiles;

%% Convert m files to html
m2docgen.ConvertFiles;

%% build xml file that defines the left menue in the doc (helptoc.xml)
m2docgen.GenerateTocXml;

%% build info.xml file
m2docgen.GenerateInfoXml;

%% try to build the search extension 
m2docgen.GenerateSearchDatabase; 

%% add output folder and subfolders to matlab path
% only then the matlab documentation will find the info.xml and display the
% custom documentation inside the MATLAB documentation
addpath(genpath(opts.outputFolder));

%% print stats
if m2docgen.verbose
    disp("Sucessfully converted " + length(m2docgen.fileList) + " script files" ...
        + " to a html documentation!");
end
end