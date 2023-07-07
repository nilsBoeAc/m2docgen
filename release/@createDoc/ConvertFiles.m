function ConvertFiles(obj)
    % converts the elements from obj.fileList to HTML documents
    %% Description:
    % This function is part of m2docgen and converts all files listed in
    % obj.fileList into html documents. 
    %   
    %% Syntax:
    %   obj.ConvertFiles;
    %
    %% Input:
    %   no input values required
    %
    %% Output:
    %   no direct output values
    %
    %% References:
    %   m2html
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
    
    %% loop through all files in m2docgen.fileList and convert them
    i = 0;
    while(i<=length(obj.fileList)-1)
        i = i+1;
        % assign general variables
        currFileName    = [obj.fileList(i).name obj.fileList(i).ext];
        currFileFolder  = obj.fileList(i).folder; % absolute folder, not relative
        currFileOutputFolder = fullfile(obj.outputFolder, ...
                                obj.fileList(i).htmlOutputPath); % absolute html output folder, not relative
        fprintf('Converting file <a href="matlab: open(%s)">%s</a>\n',"'" + ...
            fullfile(currFileFolder, currFileName) + "'", string(currFileName));
        
        % check if this is a matlab live file
        totalSourcePath = fullfile(currFileFolder, currFileName);
        totalTargetPath = fullfile(currFileOutputFolder, obj.fileList(i).name + ".html");
        if obj.fileList(i).ext == ".mlx"
            obj.ExportViaPublish(totalSourcePath, totalTargetPath)
            continue;
        end
        % read m file and extract text "dummys"
        currMFile       = MFile(currFileName, currFileFolder);
        currMFile.parseFile; % find text dummys and add them to currMFile obj
        currMFile.checkCrossRef(obj.funcRefList);
    
        % insert text dummys into template html to generate html file
        myName          = currMFile.name;
        tplFolder       = obj.htmlTemplate; % template folder of the help site
        outputFolder    = currFileOutputFolder;
        styleFolder     = obj.htmlMetaFolder; % folder with the 
        homePath        = obj.startPage;
        myhtml          = TemplateHTML(myName, tplFolder, outputFolder, ...
                            styleFolder,homePath, obj.verbose);
        myhtml.parseDummysIntoTemplate(currMFile.dummyList); % add dummy blocks to template html document
        myhtml.createHTML; % save string as html file

        % check if file contains "insideFunctions"
        % if true, then store code in text file and add this function to
        % the overall fileList variable
        if ~isempty(currMFile.insideFunctions)
            % check if file as already an own folder on toc
            % if not -> change the toc
            if ~contains(obj.fileList(i).toc,"@")
                  newToc = fullfile(obj.fileList(i).toc,"@"+obj.fileList(i).name);
                  obj.fileList(i).toc = char(newToc);
                  obj.fileList(i).relPath = char(fullfile(obj.fileList(i).relPath,"@"+obj.fileList(i).name+filesep));
            end

            for n = 1:length(currMFile.insideFunctions)
                % write code in temporary txt file
                targetPath = fullfile(currFileOutputFolder,currMFile.insideFunctions(n).name+".txt");
                fid = fopen(targetPath,'wt');
                for j=1:length(currMFile.insideFunctions(n).text)
                    currentText = replace(currMFile.insideFunctions(n).text(j),"%","%%");
                    fprintf(fid, "%s", currentText);
                    fprintf(fid,"\n");
                end
                fclose(fid);
                
                newfile.name    = char(currMFile.insideFunctions(n).name);
                newfile.folder  = char(currFileOutputFolder);
                newfile.ext     = '.txt';
                newfile.relPath = obj.fileList(i).relPath;
                newfile.toc     = obj.fileList(i).toc;
                newfile.htmlOutputPath = obj.fileList(i).htmlOutputPath;
                k = i+n-1;
                obj.fileList = [obj.fileList(1:k);newfile;obj.fileList(k+1:end)];
            end
        end % if
    end % for i

end % function ConvertFiles