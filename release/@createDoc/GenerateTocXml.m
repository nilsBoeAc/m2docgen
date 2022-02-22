function GenerateTocXml(obj)
    % this function generates the helptoc.xml file that controls the displayed
    % table of contents in the matlab documentation of the toolbox.
    %% Description:
    %   This function loads a template of an xml file which controlls the table
    %   of content structure of the custom MATLAB toolbox documentation. The
    %   structure will follow the one given by the cell structure obj.toc
    %   
    %% Syntax:
    %   obj.GenerateTocXml
    %
    %% Input:
    %   no direct inputs
    %       requires obj.outputFolder
    %       requires obj.fileList
    %       requires obj.toc
    %
    %% Output:
    %   saves helptoc.xml to the folder specified by obj.outputFolder
    %
    %% References:
    %   m2html - lines 654 - 690 - used as inspiration
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
    
    %% generate file to write toc to
    tocFile = fullfile(obj.outputFolder,"helptoc.xml");
    tocFid = fopen(tocFile,'wt');
    
    %% write standard beginning of file
    fprintf(tocFid,'<?xml version=''1.0'' encoding=''utf-8'' ?>\n');
    fprintf(tocFid,'<!-- $Date: %s $ -->\n\n', datestr(now,31));
    fprintf(tocFid,'<toc version="2.0">\n\n');

    %% write toc struture of toolbox into file
    startPage = string(obj.startPage);
    if startPage == ""
        startHTMLPath = obj.toolboxName + ".html";
    else
        startHTMLPath = startPage;
    end

    %% read fileList and Sort
    name = repmat("",length(obj.fileList),1);
    toc  = repmat("",length(obj.fileList),1);
    level = zeros(length(obj.fileList),1);
    tocSplit = cell(length(obj.fileList),1);

    for i = 1:length(obj.fileList)
        name(i,1) = string(obj.fileList(i).name);
        toc(i,1)  = string(obj.fileList(i).toc);
        tmp = strsplit(toc(i),filesep);
        level(i,1) = length(tmp);
        tocSplit{i,1} = tmp;
    end

    tocLevelsWN = repmat("",length(level),max(level)+1);
    tocLevels = repmat("",length(level),max(level));
    for i = 1:length(tocSplit)
      lgt = length(tocSplit{i});
      tocLevelsWN(i,1:lgt+1) = [tocSplit{i},"0000"+name(i)];
      tocLevels(i,1:lgt)     =  tocSplit{i};
    end
 
    [~,idx] = sortrows(lower(tocLevelsWN));
    tocLevels = tocLevels(idx,:);
    name = name(idx);
    level = level(idx);

    %% Create Toc XLM with sorted List
    currentToc   = tocLevels(1,1);
    fprintf(tocFid,'<tocitem target="%s" image="$toolbox/matlab/icons/book_mat.gif">%s\n',startHTMLPath, currentToc);

    currentToc   = tocLevels(1,:);
    currentLevel = level(1);
    for i = 1:length(tocLevels)
        compareLV = currentToc == tocLevels(i,:);
        idx = find(compareLV(1:level(i))==0,1);

        % close Items down to the point where the change starts
        for j = currentLevel:-1:idx
            closeItem(tocFid,currentLevel);
            currentLevel = currentLevel - 1;
        end

        % open Items ip to the level required
        for j = idx:level(i)
            currentLevel = currentLevel + 1;
            openItem(tocFid,currentLevel,tocLevels(i,currentLevel) + ".html",tocLevels(i,currentLevel));
        end

        % write current Item
        currentToc = tocLevels(i,:);
        currentLevel = level(i);
        writeItem(tocFid,currentLevel,name(i)+".html",name(i));
 
    end
    
    % close remaining opem items
    for i = currentLevel:-1:1
        fprintf(tocFid,'%s</tocitem>\n',getSpaces(i));
    end

    %% close file
    fprintf(tocFid,'\n</toc>');
    fclose(tocFid);
    disp("Generated the helptoc.xml file!");

end % end

function openItem(tocFid,currentLevel,htmlpath,fileName)
    fprintf(tocFid,'%s<tocitem target="%s" image="$toolbox/matlab/icons/book_mat.gif">%s\n',getSpaces(currentLevel),htmlpath, fileName);
end

function closeItem(tocFid,currentLevel)
    fprintf(tocFid,'%s</tocitem>\n',getSpaces(currentLevel));
end

function writeItem(tocFid,currentLevel,htmlpath,fileName)
    fprintf(tocFid,'%s<tocitem target="%s">%s</tocitem>\n',getSpaces(currentLevel+1),htmlpath, fileName);
end

function spaces = getSpaces(level)
    spaces = "";
    for i=2:level
        spaces = spaces + "   ";
    end
end
