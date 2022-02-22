function createHTML(obj)
% saves the obj.str as html file
%% Description:
%   Some high-level markers in the obj.str are replaced by things like file
%   name, current date etc. Afterwards, unused keyword markers are removed
%   from the obj.str. Lastly, the obj.str is saved as html document in
%   obj.outFolder. 
%   
%% Syntax:
%   obj.createHTML;
%
%% Input:
%   no input values required
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
% - seperate from main class file (po - 07.04.2021)

finalStr = obj.str; % html document in txt form
outname = fullfile(obj.outFolder, obj.name + ".html"); % complete html path
currDate = date;
finalStr = filSTR(obj,finalStr,"{NAME}",obj.name);
finalStr = filSTR(obj,finalStr,"{DATE}",string(currDate));
finalStr = filSTR(obj,finalStr,"{YEAR}",string(currDate(end-3:end)));
finalStr = filSTR(obj,finalStr,"{HOME_HTML}",obj.homePath);
finalStr = filSTR(obj,finalStr,"{STYLE_FOLDER}",obj.styleFolder);
obj.str = finalStr;

% write HTML
fil = fopen(outname,'w');
fprintf(fil,"\n%s",obj.str);
fclose(fil); 
end % createHTML