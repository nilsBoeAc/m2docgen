function parseFile(obj)
% scans the file for text blocks "dummys"
%% Description:
%   Here comes a description. The Code-Word ist "Description" starting with
%   two %%. The Block ends when the next comment-Block starts (next two %%)
%   Each Block does contain a "Code-Word". Those will be stored in a dummy
%   object. 
%   
%% Syntax:
%   obj.parseFile;
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
% - make style changes to css divs instead of html, e.g. bold attributes:
%   switch from <b> to <div class="attInfo"> or something like that

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
        cL = char(txt(line));
        cL = strrep(cL,' ','');
        if contains(upper(cL),"%%"+obj.knownBlocks(i))
            firstLine = line;
            st_found = true;
        elseif (contains(upper(cL),"%%") && st_found)
            lastLine = line;
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
    propertiesList = properties(fileName);
    methodsList = methods(fileName);
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
            txt(i) = highlightKeywords(txt(i));
            if contains(currLine, strKeyword) 
                endCounter = endCounter +1;
            end
            if currLine == "end"
                if endCounter == 0
                    endLine = i;
                    break; %  break out of loop if finished
                else
                    endCounter = endCounter -1;
                end
            end
        end

    end % for i
    if startLine ~= -1 && endLine ~= -1
        strConstructor = txt(startLine:endLine); % includes comments
        dum = Dummy("CONSTRUCTOR",strConstructor);
        dum.type = "constructor";
        obj.addDummy(dum);
    end
end % end if is class
end % end function parseFile

%% ------------ start of local functions --------------

function modTxt = highlightKeywords(inputTxt, identLvl)
    % insert spaces for indentation
    modTxt = string(inputTxt);
    if nargin ==1
        identLvl = 0;
    else
        indent = strjoin(repmat(" ", 1, identLvl));
        modTxt = indent + inputTxt;
    end
    
    % markup keywords
    keywords = ["if " "try " "while " "for " "parfor " "switch " ...
        "function " "end"];
    if contains(modTxt, keywords)
        for i = 1:length(keywords)
            currKey = keywords(i);
            idx = strfind(modTxt, currKey);
            if ~isempty(idx)
                idEnd = idx(1) + length(char(currKey))-1;
%                 if contains(currKey, " ")
%                     idEnd = idEnd -1;
%                 end
                modChar = char(modTxt);
                if idx == 1
                    preTxt = "";
                else
                    preTxt = string(modChar(1:idx));
                end
                startD = "<div class='functionKeyword'>";
                endDiv = "</div>";
                if idEnd == length(modChar)
                    aftTxt = "";
                else
                    aftTxt = string(modChar(idEnd:end));
                end
                modTxt = preTxt + startD + ...
                    string(modChar(idx(1):idEnd)) +endDiv + aftTxt;
            end
        end
    end
end