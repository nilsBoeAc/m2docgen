function parseDummysIntoTemplate(obj,dummyList)
% reads in a html template and replaces designated parts with the dummys
% from MFile.parse.
%% Description:
%   This function first reads in a specific html template as vertical
%   string. The template contains keywords, which are markers where the
%   dummys must be inserted. The function loops through all dummys and
%   inserts its "filling" to the designated markers. For certain keywords
%   some html markup is applied. The modified template is then saved in the 
%   obj.str property.
%   
%% Syntax:
%   [TemplateHTML].parseStr
%
%% Input:
%   dummyList - list of text dummys : cell vector
%       vertical cell vector containing all dummy objects from MFile.parse
%
%% Output:
%   no output values
%
%% Disclaimer:
%
% Last editor:  Pierre Ollfisch
% Last edit on: 07.04.2021
% Code version: 1.0
% Copyright (c) 2021

%% ToDo / Changelog
% - seperate from main class file (po - 07.04.21)

strTemplate = obj.str;     % string template
for di = 1:length(dummyList) % di = dummy index
    currDummy = dummyList{di};
    key     = currDummy.name;
    filling = currDummy.filling; % acutal text content
    refPath = currDummy.refPath;
    dumType = char(currDummy.type);
    dummyList{di,2} = currDummy.name; % for debugging in the workspace

    switch dumType
        case char('functRef')
            strTemplate = filSTR(obj,strTemplate,key,"");
            strTemplate = filSTR(obj,strTemplate,"{TOTAL_CALL}","");

            % get Block for adding List
            strBlock = getTPL(obj,currDummy.type);
            if(key == "{NAME_CALL}")
                keyPlace = 'functRef above';
            else
                key = "{NAME_CALL}";
                keyPlace = 'functReRef above';
            end

            strBlock = filSTR(obj,strBlock,key,filling);
            if(strcmp(refPath,"NA"))
                strBlock = filSTR(obj,strBlock,"{REF_CALL}",filling+".html");
            else
                strBlock = filSTR(obj,strBlock,"{REF_CALL}",refPath);
            end

            strTemplate = addBlock(obj,strTemplate,strBlock,keyPlace);
        case char("classBlock")
            % remove curly bracket text (PROPERTIES / METHODS)
            %   from html document
            strTemplate = filSTR(obj,strTemplate,key,"");
            % get snippet template for this content
            strBlock    = getTPL(obj,currDummy.type);
            key         = "{SUB}"; % new key for new block
            strBlock        = filSTR(obj,strBlock,key,filling);
            if currDummy.name == "{METHODS}"
                keyPlace    = "methods above";
            else
                keyPlace    = "properties above";
            end
            strTemplate = addBlock(obj,strTemplate,strBlock,keyPlace);
        otherwise
            % check if constructor block is present
            if contains(lower(currDummy.name), "constructor")
                % add colorful html markups (divs) to certain elements
                filling = highlightFunctionKeywords(filling);
                filling = highlightComments(filling);
            end
            % add dummy text at key marker to template string
            strTemplate = filSTR(obj,strTemplate,key,filling);
            
    end
end
obj.str = strTemplate;
end % function parseStr
 
%% ------------------  start of local functions ---------------------

function txt = highlightComments(txt)
% insert div tags into the text for some markup action
% search for comments and mark them up with color div
strDivStart = '<div class="comment">';
strDivEnd = '</div>';
for l = 1:length(txt) % l= line
    if contains(txt(l), "%")
        txtLine = char(txt(l));
        idx = strfind(txtLine, "%");
        % split string at first % and insert div tag
        if idx(1) == 1
            newTxt = [strDivStart, txtLine, strDivEnd];
        else
            newTxt = [txtLine(1:idx(1)-1), strDivStart, ...
                txtLine(idx(1):end), strDivEnd];
        end
        txt(l) = newTxt;
    end
end % for l
end % function highlightComments

function modTxt = highlightFunctionKeywords(inputTxt)
% markup keywords
keywords = ["if " "try " "while " "for " "parfor " "switch " ...
    "function " "end"];
modTxt = inputTxt; % return input by default,  fallback if nothing is modified

% loop throug each row and highlight keywords
rowCount = size(inputTxt, 1);
for r = 1:rowCount
    rowTxt = modTxt(r);
    if contains(rowTxt, keywords)
        % now find all keywords that actually are present
        for i = 1:length(keywords)
            currKey = keywords(i);
            idx = strfind(rowTxt, currKey);
            if ~isempty(idx) % if idx is not empty then the currKey is present in the rowTxt
                % save end index of keyword in row char
                if contains(currKey, " ")
                    idEnd = idx(1) + length(char(currKey))-2;
                else
                    idEnd = idx(1) + length(char(currKey))-1;
                end
                % check if keyword is only content of the rowTxt
                lineNoSp = strrep(rowTxt, " ", ""); % line without spaces
                ccK = char(currKey);
                wcChar1 = [ccK, " *"];
                wcChar2 = ["* ", ccK, " *"];
                keyStartsRow = regexp(lineNoSp, regexptranslate('wildcard',wcChar1));
                keyInRow  = regexp(lineNoSp, regexptranslate('wildcard',wcChar2));
                if lineNoSp == currKey || ~isempty(keyStartsRow) || ~isempty(keyInRow)
                    % continue the function, but do not skip this keyword
                    % keyword is either the only content of the row, the
                    % start of the row or in the middle of the row txt.
                else
                    % skip this keyword as it is part of a word in rowTxt
                    continue;
                end
                %% splice row text and insert markup divs
                rowChar = char(rowTxt);
                if idx == 1
                    preTxt = "";
                else
                    preTxt = string(rowChar(1:idx-1));
                end
                startD = "<div class='functionKeyword'>";
                endDiv = "</div>";
                if idEnd == length(rowChar)
                    aftTxt = "";
                else
                    aftTxt = string(rowChar(idEnd+1:end));
                end
                %% splice back together with div markup
                modTxt(r) = preTxt + startD + ...
                    string(rowChar(idx(1):idEnd)) +endDiv + aftTxt;
            end
        end
    end
end % for r rowcount

    
end % function highlightFunctionKeywords