function GenerateTocStructure(obj)
% Decide where the converted m-file shoudl be acessible and save to the
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
tbroot = tbsplit{end};
if obj.verbose
    obj.printToc;
end

%% loop through file path and assign toc heading
if isempty(obj.toc)
    
else
    for i = 1:numel(fileList)
        folderSplit = strsplit(fileList(i).folder, filesep);
        lastFolder = folderSplit{end};
        if string(lastFolder) == string(tbroot)
            toc(i) = "/";
        else
            tocPath = getTocPath(lastFolder, obj.toc,"");
            % if the output argument localPath cannot be assigned, then
            % recheck your opts.toc second column, especially for missing
            % "@" and "+" in front of folder names. 
            if strlength(tocPath) == 0
                toc(i) = fullfile(obj.toc{1,1},lastFolder);
            else
                toc(i) = tocPath;
            end
        end
    end
end
[fileList.toc] = toc{:};

%% return value to object
obj.fileList = fileList;
if obj.verbose
    disp("Sucessfully assigned toc structure to files!")
end
 
%% update toc cell with new information:
for i = 1:length(toc)
    if (~isempty(toc(i))) && (toc(i) ~= "/") && (toc(i) ~= "\")
        currTocFolder = toc(i);
        tocParts = string(strsplit(currTocFolder, filesep));
        tocParts = tocParts(tocParts ~= ""); %filter out empty strings
        obj.toc = checkToc(tocParts, 1, obj.toc);
    end % if
end

end % end function

%----------local functions----------------
function localPath = getTocPath(searchFolder, tocCell, tocPath)  
% recursive function assign the current .m file a toc path. This works by
% calling this function with a lastFolder keyword (constant), a cell to
% look for the keyword (changes) and the "path" to that cell (changes). If
% the searchFolder cant be found in the second cell column, then the
% function checks if the third column contains cells. If yes, then this
% function is called again, this time with the new cell as tocCell and the
% "chain"/path to the current cell as tocPath. 
    localPath = "";
    localToc = tocCell;
    fn = string(localToc(:,1)); 
    for i = 1:numel(fn) % loop through all toc elements in that cell
        newtocPath = fullfile(tocPath, fn(i));
        tmpFolderNames = localToc{i,2};
        if contains(searchFolder, tmpFolderNames)
            localPath = newtocPath;
            return;
        else
            if ~isempty(localToc{i,3})
                localPath = getTocPath(searchFolder, localToc{i,3}, newtocPath);
                if strlength(localPath) ~= 0 % if result is not empty
                    return;
                end
            end
        end
    end
end

function tocCell = checkToc(tocParts, tocPos, tocCell)
    currToc = tocCell;
    [tocCell, elemPos] = scanTocLayer(currToc,tocParts(tocPos));
    if tocPos == numel(tocParts)
    else
        tocCell{elemPos, 3} = checkToc(tocParts, tocPos +1, currToc{elemPos, 3});
    end
end

function [tocCell, elemPos] = scanTocLayer(tocCell, tocElement)
% this 
	tocList = string(tocCell(:,1));
    locMask = strcmp(tocList, tocElement);
    elemPos = find(locMask);
    if isempty(elemPos)
        elemPos = size(tocCell,1) +1;
        tocCell{elemPos,1} = tocElement;
        tocCell{elemPos,2} = tocElement;
        tocCell{elemPos,3} = {};
    end
end