function GenerateRelOutputPath(obj)
fileList = obj.fileList;

if obj.buildSubDir % if sub-folders should be used
    tmpPath = {fileList.toc};
    tmpPath = fullfile(obj.htmlFolderName, tmpPath);
    [fileList.htmlOutputPath] = tmpPath{:};
else
    tmpPath = repmat(fullfile(obj.htmlFolderName), 1,length(fileList));
    [fileList.htmlOutputPath] = tmpPath{:};
end
obj.fileList = fileList;
end