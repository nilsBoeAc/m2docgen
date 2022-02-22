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