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
%   Last editor:  Pierre Ollfisch
%   Last edit on: 07.04.2021
%   Code version: 1.0
%
%   Copyright (c) 2020 Nils Böhnisch, Pierre Ollfisch.
%
%   This file is part of m2docgen.
%
%   m2docgen is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   any later version. Also see the file "License.txt".

%% ToDo / Changelog
% - seperate from main class file (po - 07.04.21)
% - add support for dynamically identified text blocks / dummies (po -
%       27.06.2021)

strTemplate = obj.str;     % entire website template as string
defaultDummy = Dummy("--","--");
typeCase = defaultDummy.typeCases;
keyPlace = 'CONTENT_FROM_M2DOC'; % position in the strTemplate above which the segments must be inserted

for di = 1:length(dummyList) % di = dummy index
    currDummy = dummyList{di};
    key     = currDummy.name;
    filling = currDummy.filling; % acutal text content
    refPath = currDummy.refPath;
    dumType = char(currDummy.type);
    dummyList{di,2} = currDummy.name; % for debugging in the workspace

    switch dumType
        case typeCase(1) %'SHORT_DESCR'
            % step 1: load segment template
            descrTemplPath = which("shortDescr.tpl");
            descrTempl  = obj.loadSegmentTemplate(descrTemplPath);
            % step 2: load dummy into segment
            strBlock    = filSTR(obj, descrTempl, key, filling);
            % step 3: load segment into website template
            strTemplate = addBlock(obj,strTemplate,strBlock,keyPlace);
        case typeCase(2) %"DYNAMIC"
            % step 1: load dummy segment template
            dynaTemplPath = which("dynamicSegment.tpl");
            dynaTempl   = obj.loadSegmentTemplate(dynaTemplPath);
            % step 2: replace dummyname placeholder with real dummy name in dummy segment
            dynaDescrKey = "{DUMMYNAME}";
            headingName = filterName(key); % remove leading percent signs and spaces, remove curly brackets
            namedBlock  = filSTR(obj, dynaTempl, dynaDescrKey, headingName); % replace "{DYNADESCRKEY}" with the descriptive name
            % step 3: insert dummy filling into segment
            dynaFillKey = "{DUMMYFILLING}";
            strBlock    = filSTR(obj, namedBlock, dynaFillKey, filling); % replace "{DYNAFILLKEY}" with the dummy filling
            % step 4: add segment into website template
            keyPlace    = 'CONTENT_FROM_M2DOC'; 
            strTemplate = addBlock(obj,strTemplate,strBlock,keyPlace);
        case typeCase(3) % "FUNCTREF"
            % step 1: check if the segment for function references is
            % already in the website template. if not add it in
            if ~contains(strTemplate, "{TOTAL_CALL}")
                totalCallTPLPath = which("totalCallSegment.tpl");
                totalCallTxt     = obj.loadSegmentTemplate(totalCallTPLPath);
                keyPlace         = 'CONTENT_FROM_M2DOC';
                strTemplate      = addBlock(obj, strTemplate, totalCallTxt, keyPlace);
            end
            % step 2: check if the function reference segment already
            % contains a "name called" subsegment. if not add it in.
            if ~contains(strTemplate, "NAME_CALL")
                % if the website template already contains the name_call
                % tag, then we can directly insert the function snippet.
                % Otherwise, the function call segment must be added first.
                funcTemplatePath = which("nameCallSegment.tpl");
                funcTemplate     = obj.loadSegmentTemplate(funcTemplatePath);
                keyPlace         = '{TOTAL_CALL}';
                strTemplate      = addBlock(obj, strTemplate, funcTemplate, keyPlace);
            end
            % step 3: load the function reference snippet template;
            funcSnippetPath = which("functRefSnip.tpl");
            funcSnippet = obj.loadSegmentTemplate(funcSnippetPath);
            % step 4: fill the snippet with the dummy filling / link
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
            % step 5: place the snippet into the website template within
            % the function reference segment inside the name called segment
            strTemplate = addBlock(obj,strTemplate,strBlock,keyPlace);
        case typeCase(4) % "CLASSBLOCK" 
            % step 1:check if a methods/properties segment is present. if
            % not add it in. Method and Property have a different template
            if upper(currDummy.name) == "{CLASS METHODS}"
                if ~contains(upper(strTemplate), "CLASSMETHODS")
                    methodsSegmentPath  = which("methodsSegments.tpl");
                    methodsSegment      = obj.loadSegmentTemplate(methodsSegmentPath);
                    mainKey = 'CONTENT_FROM_M2DOC'; 
                    strTemplate         = addBlock(obj,strTemplate,methodsSegment,mainKey);
                end
                keyPlace    = "methods above"; 
            else
                if ~contains(upper(strTemplate), "CLASSPROPERTIES") 
                    propSegPath     = which("propertiesSegments.tpl");
                    propSegTpl      = obj.loadSegmentTemplate(propSegPath);
                    mainKey         = 'CONTENT_FROM_M2DOC'; 
                    strTemplate     = addBlock(obj,strTemplate,propSegTpl,mainKey);
                end
                keyPlace    = "properties above";
            end
            % step 2: get snippet template for this content
            classTmplPath = which("classSnip.tpl");
            classTmpl = obj.loadSegmentTemplate(classTmplPath);
            % step 3: insert dummy filling into the snippet
            key  = "{SUB}"; % new key for new block
            strBlock        = filSTR(obj,classTmpl,key,filling);
            % step 4: add the snippet into the website template into the
            % class specific segment.
            strTemplate = addBlock(obj,strTemplate,strBlock,keyPlace);
        case typeCase(5) %"CONSTRUCTOR"
            % Step 1: highlight keywords in the constructor filling
            filling = highlightFunctionKeywords(filling);
            filling = highlightComments(filling);
            % step 2: load segment for constructor
            dynaTemplPath = which("dynamicSegment.tpl");
            dynaTempl = obj.loadSegmentTemplate(dynaTemplPath);
            % step 3: fill segment with dummy filling
            constrTempl = filSTR(obj,dynaTempl,'{DUMMYNAME}', "Constructor");
            constrTempltxt = filSTR(obj,constrTempl,'{DUMMYFILLING}', filling);
            % step 4: insert  segment into website template
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
    "function " "end"]; % spaces are important for identifying single words
keywords = [keywords, strrep(keywords," ","(")]; % add keywords with braces
modTxt = inputTxt; % return input by default,  fallback if nothing is modified

% find out if there are any leading spaces in the first row
fL = char(modTxt(1)); % first line char
leadingSpace = 0;
if ~isempty(fL) && numel(fL) > 0
    for i = 1:numel(fL)
        if fL(i) ~= ' '
            leadingSpace = i-1;
            break;
        end
    end
end

% loop throug each row and highlight keywords
rowCount = size(inputTxt, 1);
for r = 1:rowCount
    rowTxt = modTxt(r);
    % remove leading spaces if required
    if leadingSpace > 0 && strlength(rowTxt) > leadingSpace
        rT = rowTxt; % funny matlab bug
        rowTxt = extractAfter(rT, leadingSpace);
        modTxt(r) = rowTxt;
    end
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

function txt = filterName(key)
% this function gets a text line from a m-file and filters out the leading
% percent signs, curly braces and spaces
txt = char(key);
txt = strrep(txt, '{',''); % remove curly brackets
txt = strrep(txt, '}','');
key = txt; % resave key because the break of the loop depends on it to be accurate
% now remove leading spaces and percent signs
cOut = 0; % counts number of loops
charsToDelete = [' ','%'];
while(true)
    cOut = cOut+1;
    currChar = txt(1);
    if any(currChar == charsToDelete) 
        if length(txt) >=2
            txt = txt(2:end);
        else
            txt = '';
        end
    end
    % break condition 1: if alphanumeric letter is found
    if isletter(currChar) || ~isnan(str2double(currChar))
        break;
    end
    % break condition 2: if cOut is greater than letter number of input
    if cOut > strlength(key)
        break;
    end
end

if isempty(txt)
    txt = "(-)";
else
    txt = string(txt); 
end
end % filterName