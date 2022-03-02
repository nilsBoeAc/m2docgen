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

    %% read fileList and sort entries
    name   = string({obj.fileList(:).name});
    toc    = string({obj.fileList(:).toc});
    
    sortIndex = join([toc', name'], '0000', 2);
    [~,idx] = sortrows(lower(sortIndex));
    
    name = name(idx);
    toc  = toc(idx);
    
    
    %% Create Toc XLM with sorted List
    
    toc = cellfun(@(x) strsplit(x, filesep), toc, 'UniformOutput', false);
    
    % We add a dummy entry at the start and end to prevent edge cases
    name = ["", name, ""];
    toc  = [{{}}; toc(:); {{}}];
    for ii = 2:numel(toc)
        
        nCommonLevels = min(numel(toc{ii-1}), numel(toc{ii}));
        firstDifferentLevel = find(~strcmp(toc{ii-1}(1:nCommonLevels), toc{ii}(1:nCommonLevels)), 1);
        if isempty(firstDifferentLevel)
            firstDifferentLevel = nCommonLevels+1;
        end
        
        % close Items down to the point where the change starts
        for jj = numel(toc{ii-1}):-1:firstDifferentLevel
            closeItem(tocFid,jj);
        end

        if ii == numel(toc)
            break;
        end
        
        % open Items ip to the level required
        for jj = firstDifferentLevel:numel(toc{ii})
            openItem(tocFid,jj,toc{ii}{jj} + ".html",toc{ii}{jj});
        end

        % write current Item
        writeItem(tocFid,numel(toc{ii}),name{ii}+".html",name{ii});
 
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
