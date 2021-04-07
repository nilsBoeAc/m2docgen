function parseFile(obj)
% scans the file for text blocks "dummys", part of class MFile 
%% Description:
%   This function reads in a m-file in the form of a vertical string (no
%   newline chars in the string) and searches for certain keywords (see
%   properties knownBlocks and classBlocks). The following text will up
%   until the next double percentage sign "%%" will be stored as dummy.
%   Dummys will later on be used  by TemplateHTML to fill a HTML document.
%   
%% Syntax:
%   [MFile].parseFile;
%
%% Input:
%   no direct inputs
%
%% Output:
%   no direct outputs
%       adds "DUMMY" objects to obj
%
%% Disclaimer:
%
% Author: Pierre Ollfisch
% Copyright (c) 2021

%% ToDo / Changelog:
% - remove string manipulation that adds html div tags, now done in
%   TemplateHTML (po - 07.04.2021)

txt = obj.text;

%% Check for SHORT_DESC (has to be first comment line)
cL = char(txt(2)); cL = strrep(cL,' ','');
if ~(cL(1:2) == "%%")
    line = 2;
    while(1)
        line = line+1;
        if(line > length(txt))
            lastLine = line;
            break;
        end
        cL = char(txt(line));
        cL = strrep(cL,' ','');
        if (contains(upper(cL),"%%"))
            lastLine = line;
            break;
        end
    end
    fil = txt(2:lastLine-1);
    dum = Dummy("{SHORT_DESC}",fil);
    obj.addDummy(dum);
end

%% Search for known Blocks (for regular header)
for i = 1:length(obj.knownBlocks)
    line = 0;
    st_found = false;
    firstLine = -1; lastLine = -1;
    while(1)
        line = line+1;          % current line that is searched for the keyword
        if(line >length(txt))   % break while if end of file is reached
            if(st_found)
                lastLine = line-1;
            end
            break;
        end
        cL = char(txt(line));   % current line
        cL = strrep(cL,' ','');
        if contains(upper(cL),"%%"+obj.knownBlocks(i))
            firstLine = line;
            st_found = true;
        elseif (contains(upper(cL),"%%") && st_found)
            lastLine = line;
            break;
        end
        if isempty(cL)
            % not even a percentage sign is present, header is finished
            % stop the loop
            if st_found
                lastLine = line - 1;
            end
            line = length(txt) +1;
            break;
        end
    end %while
    if(firstLine>0 && lastLine>0)
        fil = txt(firstLine+1:lastLine-1);
        dum = Dummy(obj.knownBlocks(i),fil);
        obj.addDummy(dum);
    end
end %for

%% classdef searches for definitions of methods etc
if obj.type == "class"
    txtNoCom = obj.noComments(txt);     %remove all comments from txt, but keep line count
    [~, fileName] = fileparts(obj.name);
    propertiesList = properties(fileName); % file name and class name MUST MATCH
    methodsList = methods(fileName); % file name and class name MUST MATCH
    % remove unwanted elements from methods block, like self call
    % (constructor) or handle class specific items:
    handleElement = {'addlistener' 'eq' 'findprop' 'gt' 'le' 'lt' 'notify' ...
        'delete' 'findobj' 'ge' 'isvalid' 'listener' 'ne' fileName};
    for i = length(methodsList):-1:1
        currMeth = string(methodsList{i});
        for ii = 1:length(handleElement)
            if currMeth == string(handleElement{ii})
                methodsList(i) = [];
            end
        end
    end
    
    % add all list elements to text dummies
    % methods
    for i = 1:length(methodsList)
        singleMeth = methodsList{i};
        dum = Dummy("METHODS", singleMeth);
        dum.type = "classBlock";
        obj.addDummy(dum);
    end
    % properties
    for i = 1:length(propertiesList)
        singleProp = propertiesList{i};
        dum = Dummy("PROPERTIES", singleProp);
        dum.type = "classBlock";
        obj.addDummy(dum);
    end

    %% find constructor and entirely add as dummy text
    txt = obj.text;
    [~,strCoName] = fileparts(obj.name);
    % onyl works if its defined in the class m-file itself
    startLine = -1;
    endLine = -1;
    % keywords that require an "end" afterwards
    strKeyword = ["if " "try " "while " "for " "parfor " "switch "];
    endCounter = 0;
    for i = 1:length(txtNoCom)
        currLine = lower(txtNoCom(i));
        if contains(currLine, "function") && contains(currLine, strCoName)
            % constructor found, now find the end of it
            startLine = i;
        end
        % increment or decrement endCounter
        if startLine ~= -1
            if contains(currLine, strKeyword) % currLine still does not contain comments
                endCounter = endCounter +1;
                continue;
            end
            currLineNoSp = strrep(currLine, " ", "");
            if currLineNoSp == "end" || currLineNoSp == "end;"
                if endCounter == 0
                    endLine = i;
                    break; %  break out of loop if finished
                else
                    endCounter = endCounter -1;
                end
            end
        end
    end % for i, constructor now defined between startLine and endLine
    if startLine ~= -1 && endLine ~= -1
        strConstructor = txt(startLine:endLine); % includes comments
        dum = Dummy("CONSTRUCTOR",strConstructor);
        dum.type = "constructor";
        obj.addDummy(dum);
    end
end % end if is class
end % end function parseFile