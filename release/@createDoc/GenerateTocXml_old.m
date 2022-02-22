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
    [tocFid, debugMsg] = fopen(tocFile,'wt');
    
    %% write standard beginning of file
    fprintf(tocFid,'<?xml version=''1.0'' encoding=''utf-8'' ?>\n');
    fprintf(tocFid,'<!-- $Date: %s $ -->\n\n', datestr(now,31));
    fprintf(tocFid,'<toc version="2.0">\n\n');
    %% write toc struture of toolbox into file
    startHTMLPath = findStartPage(obj);
    writeTocRec(tocFid, obj.fileList, obj.toc, "", "",startHTMLPath);
    
    %% close file
    fprintf(tocFid,'\n</toc>');
    fclose(tocFid);
    disp("Generated the helptoc.xml file!")
end % end function GenerateTocXml
% ---------------- start local functions ---------------

function writeTocRec(tocFid, fileList, tocCell, preTxt, tocPath, startHTMLPath)
    % tocFid = file id from fopen to the helptoc.xml file
    currTocCell = tocCell;
    currPreTxt  = preTxt; % preTxt are the spaces before a line in the xml document
    % index i:  toc element from currToc
    % index ii: file element from fileList
    for i = 1:size(currTocCell,1)
        % loop through the currrent elements in the toc cell
        % add files to that element if available
        currTocElement  = currTocCell{i,1};
        currTocPath     = fullfile(tocPath, currTocElement);
        if (tocPath == "") && (preTxt == "") && (i == 1)
            % case only for the very first element
            pathToHtml = startHTMLPath;
        else
            pathToHtml = getHeadingHTMLPath(currTocElement);
        end
        % write current element to file
        tocName         = currTocElement; % Text that will appear in the toc
        % fprintf(%s spaces  %s relative-path-to-html-file  %s displayed name)
        fprintf(tocFid,['%s<tocitem target="%s" ', ... 
            'image="$toolbox/matlab/icons/book_mat.gif">%s\n'], ...
            currPreTxt, pathToHtml, tocName); 
        
        % if available, do the loop on subelements of that toc ("subfolders")
        if ~isempty(currTocCell{i,3}) && iscell(currTocCell{i,3})
            newPreTxt = currPreTxt + "    ";
            writeTocRec(tocFid, fileList, currTocCell{i,3}, newPreTxt, currTocPath, startHTMLPath);
        end
        
        % loop throoug file list and add all files that belong to that toc
        for ii = 1:size(fileList,1)
            tmpFileToc  = fileList(ii).toc;
            tmpFileName = fileList(ii).name;
            % special flag if the file should be put in the root toc directory
            rootFlag = false;
            if tmpFileToc == "/" || tmpFileToc == "\"
                if tocPath == ""
                    rootFlag = true;
                end
            end
            if tmpFileToc == currTocPath || rootFlag
                % fprintf(%s spaces  %s path_to_html_file  %s displayed name);
                preSpaces = preTxt + "    ";
                htmlpath  = fullfile(fileList(ii).htmlOutputPath, tmpFileName + ".html");
                fileName = tmpFileName;
                fprintf(tocFid,'%s<tocitem target="%s">%s</tocitem>\n', ...
					    preSpaces, htmlpath, fileName);
            end
        end
        
        % close current toc element
        fprintf(tocFid,'%s</tocitem>\n', currPreTxt);
    end % end for i
end % end local function writeTocRec

function htmlPath = getHeadingHTMLPath(myName)
    % by default it should display a html file with the same name
    htmlPath = myName + ".html";
end % end function getHeadingPath

function htmlPath = findStartPage(obj)
    startPage = string(obj.startPage);
    if startPage == ""
        htmlPath = obj.toolboxName + ".html";
    else
        htmlPath = startPage;
    end
end