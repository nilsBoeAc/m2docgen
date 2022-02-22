function GenerateTocStructure(obj)
%% Description:
%   This function assignes each file a table of contents path. For Example,
%   if a file can be found unter /MyToolbox/Vehicles/Air/plane.m and the
%   obj.toc is structured like "/MyToolbox/Aircraft", then each file in
%   the Vehicles/Air/-subfolder will be assigned the toc path 
%   "/MyToolbox/Aircraft". This works by (ONLY) checking the last folder of
%   the current .m file and cross-referencing it by revursively going
%   through the obj.toc structure, finding the last folder and writing the
%   current toc path to the file list.
%
%% Syntax:
%   obj.GenerateTocStructure
%
%% Input:
%   no direct inputs
%       gets obj.fileList
%
%% Output:
%   no direct outputs
%       saves obj.fileList
%
%% Disclaimer:
%   Last editor : Nils Böhnisch
%   Last edit on: 22.02.2022
%
%   Copyright (c) 2020 Nils Böhnisch, Pierre Ollfisch.
%
%   This file is part of m2docgen.
%
%   m2docgen is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   any later version. Also see the file "License.txt".

%% initialize
fileList = obj.fileList;
toc = "";
tbsplit = strsplit(obj.mFolder, filesep);
tbroot = tbsplit{end}; % toolbox root folder
if obj.verbose
    obj.printToc;
end

%% precondition obj.toc if empty
if isempty(obj.toc)
    % no defined custom toc means 1:1 mapping of real folders and files
    lastFolder = strsplit(obj.mFolder, filesep);
    lastFolder = lastFolder(lastFolder ~= "");
    rootFolder = lastFolder(end);
    obj.toc = {obj.toolboxName, rootFolder , {}};
    % the obj.toc will be scanned, then back filled
end

%% Define output toc path for each file
for i = 1:numel(fileList)
    % find relative folder path of current file
    relFolderPath = fileList(i).relPath;
    % check if file is in root folder
    if string(relFolderPath) == string(filesep) || isempty(relFolderPath)
        tocPath = filesep;
    else
        % relative folder path must be converted into a table of content
        % path. This is difficult because the user can define special
        % toc folders which merge multiple real folders, and also change
        % the names and paths of certain folders. Therefore, the user 
        % inputs must be scanned through -> checkTocPath
        relFolderString = strsplit(string(relFolderPath), filesep);
        relFolderString = relFolderString(relFolderString ~= ""); % relative folder to obj.mFolder
        tocPath         = generateTocPath(obj.toc, relFolderString,[]); % generate the toc path from the file folder path
        % if the generateTocPath function did not find a path to the
        % element, then the element is new / currently undefined. Custom
        % definition: Those elements are added unter the first TOC element!
        origPath        = string(fullfile(relFolderString{:}));
        newPath         = string(fullfile(tocPath{:}));
        if  newPath == origPath
            tocPath = [obj.toc{1,1},tocPath];
        end
        % Then the tocCell must be checked if the toc path exists. 
        % If not, then the missing entrys must be added -> addMissingPathToCell
        obj.toc         = addMissingPathToCell(obj.toc, tocPath); % check if path is currently in the cell
    end
    % if the output argument localPath cannot be assigned, then
    % recheck your opts.toc second column, especially for missing
    % "@" and "+" in front of folder names. 
    if strlength(tocPath(1)) == 0 || tocPath(1) == filesep
        toc(i) = fullfile(obj.toc{1,1});
    else
        toc(i) = fullfile(tocPath{:});
    end
end
[fileList.toc] = toc{:};

%% return value to object
obj.fileList = fileList;
if obj.verbose
    disp("Sucessfully assigned toc structure to files!")
end
end % end function

%% ---------- start of local functions ----------------

function currCell = addMissingPathToCell(tocCell, cellPath)
% This function checks if a given cell path is present in the tocCell. If
% no, then the missing elements and toc cell layers will be added.
% recursive function: A "current toc element" is defined as the first
% element in cellPath (string array). The first column of tocCell is
% checked if the current element is present. If not, it is added. If the
% cellPath contains more folders, than the cell associated with the
% found/added current element is used to call this function again. Cellpath
% is reduced by its leftest/first element.
% custom rule: Folders without a custom toc definition will be added to
% tocCell{1,1]. Subfolders of that folder will remain in that path.
currCell = tocCell;
currTocName = cellPath(1);
%% safety checks
cellRows = size(currCell, 1);
cellColumns = size(currCell, 2);
if cellRows == 0 % empty cell
    % fill currCell with dummy values so that currCell{x,y} doesnt error
    % yes i know its ugly, but my internet is down and i cant google how
    % it works with nicer code...
    currCell = {"RePlAcE!ME?XXX#<>","",{}};
    cellRows = 1;
    cellColumns = 3;
end
if cellColumns < 3
    % fill thrid row with empty cells to avoid errors when currCell{x,3}
    currCell(:,3) = repmat({}, cellRows, 1);
end

%% check if the toc name is present in the current toc cell layer
flagFound = false;
for r = 1:cellRows
    compName = string(currCell{r,1});
    if compName == currTocName
        flagFound = true;
        break;
    end
end

%% add missing elements
if ~flagFound
    % add missing element
    if currCell{1,1} == "RePlAcE!ME?XXX#<>"
        cellRows = cellRows -1;
    end
    currCell{cellRows+1, 1} = currTocName;
    currCell{cellRows+1, 3} = {};
    r = cellRows+1;
end

%% call function again with next toc cell layer
if numel(cellPath) > 1
    % go one cell layer deeper
    nextCell = currCell{r,3};
    cellPath = cellPath(2:end);
    currCell{r,3} = addMissingPathToCell(nextCell, cellPath);
else
    % result cell was already defined at the beginning of this function
end
end % local function checkuserTocInput

%% ------------------ -Neuer Ansatz-------------------
function tocPath = generateTocPath(tocCell, filePath, tracedPath)
% this function is used to convert the path of a file into a 'table of
% content' path. It is done be checking the last element of a given path,
% aka the "last folder" in a path, and checks if that folder was defined in
% the tocCell. The TocCell defines the toc structure. If the folder name is
% not defined within the tocCell, then the the function returns the input
% file path. if that happens and the file path contains more parent
% folders, then the next folder is searched for in the tocCell.
% now 100% less recursion in this local function.

tocPath = filePath; % fallback if nothing is found in this function
tracedPath = [];
numFolder = numel(tocPath);
l = numFolder;
debugC = 0;
while l > 0
    debugC = debugC +1; % debug counter to check if the loop is exited
    if debugC > 35
        error("m2docgen: The function that generates the left nagivation menu " ...
            + "has failed! Check if your toc structure has loops. If not," ...
            + "open the function GenerateTocStructure in '@createDoc'!");
    end
    lastFolder = tocPath(l);
    tracedPath = [lastFolder,tracedPath];
    listTocPaths = listAllPaths(tocCell, lastFolder,[]); % converts folder path to toc path
    if isempty(listTocPaths)
        % nothing was found, check next parent folder
    else
        % find out which path is the shortest stored in listTocPath
        colMin = 999;
        targetRow = 1;
        for r=1:size(listTocPaths,1)
            currRow = listTocPaths{r,:};
            currRow = currRow(~cellfun(@isempty,currRow));
            colNum = size(currRow, 2);
            if colMin > colNum
                colMin = colNum;
                targetRow = r;
            end
        end
        shortPath = listTocPaths(targetRow,:);
        shortPath = shortPath(~cellfun(@isempty, shortPath));
        lfPath = string(shortPath); % toc path associated with the current "last folder"
        tracedPath(1) = lfPath(end); % foldername migth have changed to a toc name
        if numel(lfPath) >1
            tocPath = [lfPath(1:end-1), tracedPath];
        else
            tocPath = tracedPath; % potential name change was already addressed a few lines above
        end
        % reset l, because the number of toc elements can increase...
        oldNumFolder = numFolder;
        numFolder = numel(tocPath);
        l = numFolder -(oldNumFolder -l); 
    end
    l = l-1; % decrement folder length counter
end %while
end % function generateToc

function pathList = listAllPaths(tocCell, folderName, tocPath)
% checks if a folder name is defined somewehre in the toccell by going
% through recursively each cell and their subccells and their subcells...
currCell = tocCell;
rowNum = size(currCell,1);
colNum = size(currCell,2);
% safety check if empty cell
if rowNum == 0 || colNum < 2
    pathList = {};
    return;
end

% find elements named folderName in this cell
pathList = {};
for r = 1:rowNum
    sourceNames = string(currCell{r,2});
    targetName = string(currCell{r,1});
    if any(folderName == sourceNames) || any(folderName == targetName)
        currPath = [tocPath, targetName];
        pathList = [pathList; num2cell(currPath)];
    end
end
% serach for elements named folderName in subcells
for r = 1:rowNum
    nextCell = currCell{r,3};
    nextPath = [tocPath, currCell{r,1}];
    cellList = listAllPaths(nextCell, folderName, nextPath);
    % add cellList to the end of pathList
    % pathList = [pathList; cellList]; doesnt work because matlab hates me
    rowNum = size(cellList,1);
    oldEnd = size(pathList,1);
    if rowNum > 0
        for j = 1:rowNum
            currRow = cellList(j,:);
            currRow = currRow(~cellfun(@isempty, currRow));
            colNum = size(currRow,2);
            pathList(oldEnd + j,1:colNum) = currRow(:);
        end
    end
    %pathList = [pathList; cellList];
end
end