function GenerateTocStructure(obj)
%% initialize
fileList = obj.fileList;
toc = "";
tbsplit = strsplit(obj.mFolder, filesep);
tbroot = tbsplit{end};

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
obj.fileList = fileList;
end % end function

%----------local functions----------------
function localPath = getTocPath(searchFolder, tocCell, tocPath)  
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