function RemoveOldDoc(obj)
% delete target folder and all its content
%% Description:
%   This function deletes the folder specified by obj.outputFolder and all
%   its contents, regardless if its a subfolder or files. This function is
%   part of the class @createDoc.
%   
%% Syntax:
%   [createDoc].RemoveOldDoc
%
%% Input:
%   no input values required
%
%% Output:
%   no direct output values
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

%% delete old documentation if option is set
if obj.verbose
    disp("Removing previous documentation...")
else
    warning('off');
end
rmdir(obj.outputFolder, 's'); % also removes subfolders and files
% please close all programms that currently access the html documents
% (e.g. browsers, matlab, editors, etc..)
warning('on');

end