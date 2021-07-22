function redTxt = reduceText(obj,txt)
% reduce txt to only to comments lines
%% Description:
%   text file is recuded to only its comment lines
%   
%% Syntax:
%   obj.reduceText;
%
%% Input:
%   txt - file text: "string" || char
%       Text of the file you want to process
%
%% Output:
%   redTxt - file text: "string"
%       Text of reduced input file text.
%
%% Disclaimer:
%
% Author: Nils Boehnisch
% Copyright (c) 2021


redTxt(1) = txt(1);
cI = 1;
while(1)
    cI = cI+1;
    cL = char(txt(cI));
    cL = strrep(cL,' ','');
    if(~isempty(cL) && cL(1)=="%")
        redTxt(cI,1) = txt(cI);
    else
        break;
    end
end % while
end % reduceText