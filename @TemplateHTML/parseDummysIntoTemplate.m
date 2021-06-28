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
% - add support for dynamically identified text blocks / dummies (po -
%       27.06.2021)

strTemplate = obj.str;     % entire website template as string
keyPlace = 'CONTENT_FROM_M2DOC'; % position in the strTemplate above which the segments must be inserted

for di = 1:length(dummyList) % di = dummy index
    currDummy = dummyList{di};
    key     = currDummy.name;
    filling = currDummy.filling; % acutal text content
    refPath = currDummy.refPath;
    dumType = char(currDummy.type);
    dummyList{di,2} = currDummy.name; % for debugging in the workspace

    switch dumType
        case 'SHORT_DESCR'
            descrTemplPath = which("shortDescr.tpl");
            descrTempl = obj.loadSegmentTemplate(descrTemplPath);
            strBlock = filSTR(obj, descrTempl, key, filling);
            strTemplate = addBlock(obj,strTemplate,strBlock,keyPlace);
        case "DYNAMIC"
            dynaTemplPath = which("dynamicSegment.tpl");
            dynaTempl = obj.loadSegmentTemplate(dynaTemplPath);
            dynaDescrKey = "{DUMMYNAME}";
            headingName = strrep(strrep(strrep(key,"{",""),"}",""),":",""); % remove }:{ from headings
            namedBlock = filSTR(obj, dynaTempl, dynaDescrKey, headingName); % replace "{DYNADESCRKEY}" with the descriptive name
            dynaFillKey = "{DUMMYFILLING}";
            strBlock = filSTR(obj, namedBlock, dynaFillKey, filling); % replace "{DYNAFILLKEY}" with the dummy filling
            keyPlace = 'CONTENT_FROM_M2DOC'; 
            strTemplate = addBlock(obj,strTemplate,strBlock,keyPlace);
        case char('functRef')
            % insert Total call segment, insert name call segment, then
            % insert the functionRef block into the name call segment
            if ~contains(strTemplate, "{TOTAL_CALL}")
                % if the website template already contains the name_call
                % tag, then we can directly insert the function snippet.
                % Otherwise, the function call segment must be added first.
                totalCallTPLPath = which("totalCallSegment.tpl");
                totalCallTxt = obj.loadSegmentTemplate(totalCallTPLPath);
                keyPlace = 'CONTENT_FROM_M2DOC';
                strTemplate = addBlock(obj, strTemplate, totalCallTxt, keyPlace);
            end
            if ~contains(strTemplate, "{NAME_CALL}")
                % if the website template already contains the name_call
                % tag, then we can directly insert the function snippet.
                % Otherwise, the function call segment must be added first.
                funcTemplatePath = which("nameCallSegment.tpl");
                funcTemplate = obj.loadSegmentTemplate(funcTemplatePath);
                keyPlace = '{TOTAL_CALL}';
                strTemplate = addBlock(obj, strTemplate, funcTemplate, keyPlace);
            end
            % 
            funcSnippetPath = which("functRef.tpl");
            funcSnippet = obj.loadSegmentTemplate(funcSnippetPath);
            if(key == "{NAME_CALL}")
                keyPlace = 'functRef above';
            else
                key = "{NAME_CALL}";
                keyPlace = 'functReRef above';
            end
            strBlock = filSTR(obj,funcSnippet,key,filling);
            if(strcmp(refPath,"NA"))
                strBlock = filSTR(obj,strBlock,"{REF_CALL}",filling+".html");
            else
                strBlock = filSTR(obj,strBlock,"{REF_CALL}",refPath);
            end
            strTemplate = addBlock(obj,strTemplate,strBlock,keyPlace);
        case char("classBlock")
            % check if a methods/properties segment is present
            if currDummy.name == "{METHODS}"
                if ~contains(strTemplate, "METHODS")
                    methodsSegmentPath = which("methodsSegments.tpl");
                    methodsSegment = obj.loadSegmentTemplate(methodsSegmentPath);
                    mainKey = 'CONTENT_FROM_M2DOC'; 
                    strTemplate = addBlock(obj,strTemplate,methodsSegment,mainKey);
                end
                keyPlace    = "methods above"; 
            else
                if ~contains(strTemplate, "CLASSPROPERTIES")
                    propSegPath = which("propertiesSegments.tpl");
                    propSegTpl = obj.loadSegmentTemplate(propSegPath);
                    mainKey = 'CONTENT_FROM_M2DOC'; 
                    strTemplate = addBlock(obj,strTemplate,propSegTpl,mainKey);
                end
                keyPlace    = "properties above";
            end
            % get snippet template for this content
            classTmplPath = which("classBlock.tpl");
            classTmpl = obj.loadSegmentTemplate(classTmplPath);
            key  = "{SUB}"; % new key for new block
            strBlock        = filSTR(obj,classTmpl,key,filling);
            strTemplate = addBlock(obj,strTemplate,strBlock,keyPlace);
        case "constructor"
            % highlight keywords in the constructor filling
            filling = highlightFunctionKeywords(filling);
            filling = highlightComments(filling);
            % add segment for constructor
            dynaTemplPath = which("dynamicSegment.tpl");
            dynaTempl = obj.loadSegmentTemplate(dynaTemplPath);
            constrTempl = filSTR(obj,dynaTempl,'{DUMMYNAME}', "CONSTRUCTOR");
            constrTempltxt = filSTR(obj,constrTempl,'{DUMMYFILLING}', filling);
            % insert filled template into website
            keyPlace = 'CONTENT_FROM_M2DOC';
            strTemplate = addBlock(obj,strTemplate,constrTempltxt,keyPlace);
        otherwise
            % check if constructor block is present
            error("Unknown Dummy types are not supported");
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