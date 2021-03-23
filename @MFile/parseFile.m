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
    obj.getConstructor;         % TODO build html page for constructor
    % loop through all keywords and find those in the txtNoCom:
    for i = 1:length(obj.classBlocks)
        currKeyword = obj.classBlocks(i);
        [firstLine, lastLine] = findBlocks(txtNoCom, currKeyword);
        % up till here the firstLine contains all beginnings of *keyword*
        % the text must be extracted for each found text block, if found
        if(any(firstLine)>0 && any(lastLine)>0)
            % loop through all found entries and merge
            for j = 1:numel(firstLine)
                % look for defnition of access etc..
                currHead    = txtNoCom(firstLine(j));
                currDescr = strrep(lower(currHead), lower(currKeyword),"");
                if currDescr ~= lower(currHead)
                    % remove braces and empty spaces
                    currDescr = strrep(currDescr," ", "");
                    currDescr = strrep(currDescr,"(", "");
                    currDescr = strrep(currDescr,")", "");
                else
                    % no special definition was found
                    currDescr = "no attributes defined";
                end
                currDescr = ['<b>',char(currDescr),'</b>']; % make it bold. TODO: make it a div
                % collect text block
                tmpTxt     = txt(firstLine(j)+1:lastLine(j)-1); % code with comments
                tmpTxtNoC  = txtNoCom(firstLine(j)+1:lastLine(j)-1); % code without comments
                
                % modify text according to keyword
                switch lower(currKeyword)
                    case "methods"
                        currTxt     = scanFunctionText(tmpTxt, tmpTxtNoC);
                        currTxt     = [currDescr; currTxt];
                    case "properties"
                         currTxt     = [currDescr; tmpTxt];
                    otherwise
                         currTxt     = [currDescr; tmpTxt];
                end
                
                % assemble everything into a dummy
                dum = Dummy(currKeyword, currTxt);
                % add dummy to obj
                dum.type = "classBlock";
                obj.addDummy(dum);
            end % end for j
        end % end if
    end % end for (class extras)
end % end if is class
end % end function parseFile

%------------ start of local functions-----------------------

function [firstLine, lastLine] = findBlocks(txt, keyword)
% find beginnings and endings of *keyword* blocks
% use txt without comments for best results
line = 0;
cE = 1; % count number of elements
st_found = false;
while(1)
    line = line +1;
    % break criterium
    if line > length(txt)
        break;
    end
    cL = char(txt(line));
    cL = strrep(cL,' ','');
    % search for the strings
    if contains(upper(cL), keyword)
        st_found = true;
        firstLine(cE) = line;
    elseif upper(cL) == "END" && st_found
        lastLine(cE) = line;
        st_found = false;
        cE = cE +1;
    end
end % end while
% check if the result vars have been set / keywords were found
if exist('firstLine') && exist('lastLine')
else
    firstLine = 0;
    lastLine = 0;
end % if
end % local function findBlocks

function newTxt = scanFunctionText(txt, txtNC)
% text of codeblock : txt
% txt w/o comments: txtNC
newTxt = txt;
% cTxt   = 2;
% 
% i = 1; % counter for line of code
% while i<=length(txt)
%     if contains(lower(txtNC(i)), "function")
%         % if function block is found, then add that to the newTxt list
%         fncCall      = erase(txt(i), "function"); % only add function call
%         newTxt(cTxt) = erase(fncCall, ";");
%         cTxt = cTxt +1;
%     elseif contains(lower(txtNC(i)),");")
%         tmp = regexp(lower(txtNC(i)),"\w*);",'match');
%     end
%     i=i+1;
% end

end