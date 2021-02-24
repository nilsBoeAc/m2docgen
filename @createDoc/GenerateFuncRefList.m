function GenerateFuncRefList(obj)
fileList = obj.fileList;
refNames = string({fileList.name});
refHTMLPath = fullfile(string({fileList.htmlOutputPath}),refNames + ".html");
obj.funcRefList = [refNames' refHTMLPath'];
end