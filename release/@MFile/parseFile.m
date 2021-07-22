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
% - added autodetection of text blocks (po - 27.06.2021)

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
        if (contains(upper(cL),"%%")) && ~contains(upper(cL),"'%%") && ~contains(upper(cL),'"%%')
            lastLine = line;
            break;
        end
    end
    fil = txt(2:lastLine-1);
    dum = Dummy("{SHORT_DESC}",fil);
    dum.type = "SHORT_DESCR";
    obj.addDummy(dum);
end

%% Search for text Blocks (for regular header)
line = 1;
st_found = false;
firstLine = -1; lastLine = -1;
newBlockName = "";
oldBlockName = "";
j = 1; % counter variable for number of element in obj.foundBlocks
while(1)
    line = line+1;          % current line that is searched for the keyword, skip "function XXX" line
    if(line >length(txt))   % break while if end of file is reached
        if(st_found)
            lastLine = line-1;
        end
        break;
    end
    cL = char(txt(line));   % current line
    cLwS = strrep(cL,' ',''); % current line without spaces
    cLwSU = upper(cLwS); % current line without spaces, all uppercase
    if contains(cLwSU,'%%')
        if all(cLwSU(1:2) == '%') && length(cLwSU)>2
            oldBlockName = newBlockName; % last block name
            %newBlockName = cLwSU(3:end); % current block name
            newBlockName = cL; % save entire line as block name, will be filtered in TemplateHTML.parseDummysIntoTemplate
            obj.foundBlocks(j) = newBlockName; % store for debugging purposes
            j=j+1;
            if st_found
                % entire text block is detected, add dummy
                lastLine = line;
                fil = txt(firstLine+1:lastLine-1); % entire text block
                dum = Dummy(oldBlockName,fil);
                dum.type = "DYNAMIC";
                obj.addDummy(dum);
                % reset first line
                firstLine = line;
            else
                st_found = true;
                firstLine = line;
            end
        end
    elseif isempty(cLwSU) || cLwSU(1)~='%' % in case of code or empty line break the while loop
        if st_found
            % check if st_found is true; if yes add last dummy
            lastLine = line;
            fil = txt(firstLine+1:lastLine-1); % entire text block
            dum = Dummy(newBlockName,fil);
            dum.type = "DYNAMIC";
            obj.addDummy(dum);
        end
        line = length(txt) +1;
        break;
    end
end %while


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
        dum = Dummy("Class Methods", singleMeth);
        dum.type = "CLASSBLOCK";
        obj.addDummy(dum);
    end
    % properties
    for i = 1:length(propertiesList)
        singleProp = propertiesList{i};
        dum = Dummy("Class Properties", singleProp);
        dum.type = "CLASSBLOCK";
        obj.addDummy(dum);
    end

    %% find constructor and add as dummy text (entirely)
    txt = obj.text;
    [~,strCoName] = fileparts(obj.name);
    % onyl works if its defined in the class m-file itself
    startLine = -1;
    endLine = -1;
    % keywords that require an "end" afterwards
    strKeyword = ["if " "try " "while " "for " "parfor " "switch "]; % spaces are to determine single word
    strKeyword = [strKeyword, strrep(strKeyword," ", "(")];
    endCounter = 0;
    for i = 1:length(txtNoCom)
        currLine = lower(txtNoCom(i));
        if contains(currLine, "function") && contains(currLine, lower(strCoName))
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
        dum = Dummy("Constructor",strConstructor);
        dum.type = "CONSTRUCTOR";
        obj.addDummy(dum);
    end
end % end if is class
end % end function parseFile