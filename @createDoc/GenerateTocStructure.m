function GenerateTocStructure(obj)
% Decide where the converted m-file should be acessible and save to the
% objects file list.
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
%
% Author: Pierre Ollfisch
% Copyright (c) 2021

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
        tocPath         = checkTocPath(obj.toc, relFolderString, []); % check if a custom structure has been defined for this folder
        % Then the tocCell must be checked if the wanted toc path exists. 
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

function newTocPath = checkTocPath(tocCell, folderPath, cellPath)
% this function checks if the relative path defined in folderPath has
% somewhere in tocCell been defined to change its target folder.
% if no Folder of folderPath is defined in the current tocCell layer
% (second column), then cells in the third column will be checked
% (recursively). cellPath is a string array that describes the path through
% the tocCell to the current cell layer. If no custom toc path for any
% folder in folderPath has been defined, then the function returns the
% input folderPath. Else, the modified toc path will be returned.
currCell        = tocCell; % tocCell is different for each toc cell layer
currCellPath    = cellPath;
flagFound       = false;

%% safety check
if size(currCell,2) < 2
    % no custom definitions are present in this cell layer, which means 
    % this recusion can be canceled. 
    newTocPath = folderPath;
    return;
end

%% loop through all folder names in the folderPath
for f = numel(folderPath):-1:1 % loops trough the folders in the path
    searchForFolder = folderPath(f);
    % check if that folderName exists in the current cell layer
    for r = 1:size(currCell,1) % loops through the cell rows
        targetFolderName = currCell{r,1};
        sourceFolderNames = string(currCell{r,2});
        if any(sourceFolderNames == searchForFolder)
            % check if the current folder name has a custom definition in
            % this cell layer
            flagFound = true;
            break;
        end
        if targetFolderName == searchForFolder
            % check if the current folder has been defined as toc heading
            flagFound = true;
            break;
        end
    end
    if flagFound
        % if a custom definition for the searchForFolder has been made:
        break;
    end
end

%% change path from real file path to toc path if flagFound == true
if flagFound
    % check what part of the folderPath must be adapted
    % element f must change name to customFolderName
    newTocPath = folderPath;
    newTocPath(f) = targetFolderName;
    % element f + rest of folderPath must change position to currCellPath
    if isempty(currCellPath) % check root folder.
    else
        newTocPath = [currCellPath, newTocPath(f:end)];
        return;
    end
else
    %% check cell layers deeper if flagFound == false
    for r = 1:size(currCell,1)
        nextCell = currCell{r,3};
        nextCellPath = [currCellPath, currCell{r,1}];
        if isempty(nextCell)
            newTocPath = folderPath; % "branch" is empty, comparison comparePath must evaluate to true
            continue
        end
        newTocPath = checkTocPath(nextCell, folderPath, nextCellPath);
        if ~comparePath(newTocPath, folderPath)
            % newTocPath contains a different path than put into
            % checkTocPath, so there is definetly a changed name/ path
            return;
        end
    end
    % if the code runs through here, then nothing has been foud in this
    % toc cell layer (see "continue")
    if ~comparePath(newTocPath, folderPath)
        % if newTocPath contains a different path than put into
        % checkTocPath, then a custom definition was found and we can
        % cancel this recursion layer
        return;
    end
end

%% fallback if nothing was found
% if the code runs thorugh here, then no special definitions have been made
% for any folders in the folderPath. However, my custom rule says that such
% folders should appear under the first TOC element, not as new elements.
if isempty(cellPath) && comparePath(newTocPath, folderPath)
    newTocPath = [tocCell{1,1}, newTocPath];
end
end % function checkTocPath

function areSame = comparePath(path1, path2)
% small helper function that checks if the string arrays path1 and path2
% are identical
areSame = false;
cmpA = string(fullfile(path1{:}));
cmpB = string(fullfile(path2{:}));
if cmpA == cmpB
    areSame = true;
else
    areSame = false;
end
end % local function comparePath

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