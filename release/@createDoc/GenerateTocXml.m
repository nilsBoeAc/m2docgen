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
    %
    % Author: Pierre Ollfisch
    % Copyright (c) 2021
    
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
 
    [toc,idx]   = sort(toc);
    name = name(idx);
    level = level(idx);
    tocSplit = tocSplit(idx);


    currentToc   = tocSplit{1}(1);
    currentLevel = 1;
    fprintf(tocFid,'<tocitem target="%s" image="$toolbox/matlab/icons/book_mat.gif">%s\n',startHTMLPath, currentToc);

    for i = 1:length(toc)
        newItem = false;
        closeItem = false;

        if currentLevel < level(i)
%             currentLevel = currentLevel + 1;
            if currentToc(currentLevel) ~= tocSplit{i}(currentLevel)
                closeItem = true;
            end
            currentLevel = level(i);
%             diffLevel    = level(i) - currentLevel;
            currentToc(end+1) = tocSplit{i}(currentLevel);
            newItem = true;
        elseif currentLevel > level(i)
            fprintf(tocFid,'%s</tocitem>\n',getSpaces(currentLevel));
            currentLevel = currentLevel - 1;
            currentToc(end) = [];
        end
        
        if currentToc(currentLevel) ~= tocSplit{i}(currentLevel)
            fprintf(tocFid,'%s</tocitem>\n',getSpaces(currentLevel));
            newItem = true;
        end

        if newItem
            currentToc(end) = tocSplit{i}(currentLevel);
            htmlpath = tocSplit{i}(currentLevel) + ".html";
            fileName = tocSplit{i}(currentLevel);
            % open new tocitem
            fprintf(tocFid,'%s<tocitem target="%s" image="$toolbox/matlab/icons/book_mat.gif">%s\n',getSpaces(currentLevel),htmlpath, fileName);
        end
 
         % write Item
        tmpFileName = name(i);
        htmlpath  = fullfile(tmpFileName + ".html");
        fileName = tmpFileName;
        fprintf(tocFid,'%s<tocitem target="%s">%s</tocitem>\n',getSpaces(currentLevel+1),htmlpath, fileName);        
    end
    
    for i = currentLevel:-1:1
        fprintf(tocFid,'%s</tocitem>\n',getSpaces(i));
    end

    %% close file
    fprintf(tocFid,'\n</toc>');
    fclose(tocFid);
    disp("Generated the helptoc.xml file!");

end % end

function spaces = getSpaces(level)
    spaces = "";
    for i=2:level
        spaces = spaces + "   ";
    end
end
