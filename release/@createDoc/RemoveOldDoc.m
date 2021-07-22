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
%
% Last editor:  Pierre Ollfisch
% Last edit on: 22.03.2021
% Code version: 1.0
% Copyright (c) 2021

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