function GenerateFuncRefList(obj)
% Makes an array of all function names (without excension) and assignes an
% html file.
%% Description:
%   Each html file can link to other function documents, but only if the
%   other function names are known. This function generates a list of known
%   functions and assignes the according html document.
%   
%% Syntax:
%   obj.GenerateFuncRefList;
%
%% Input:
%   no direct inputs
%       uses obj.fileList
%% Output:
%   no direct outputs
%       saves obj.funcRefList;
%
%% Disclaimer:
%
% Author: Pierre Ollfisch
% Copyright (c) 2021

fileList = obj.fileList;
refNames = string({fileList.name});
refHTMLPath = fullfile("..",string({fileList.htmlOutputPath}),refNames + ".html");

%% return value to object
obj.funcRefList = [refNames' refHTMLPath'];
if obj.verbose
    disp("Sucessfully created the function reference list!")
end
end