classdef MFile < handle
% class that finds important comments in a specified m-file and reads out 
% the following text block into dummy objects.
%% Description:
%   This class is used to read out important text from a header of an
%   m-file. If specific keywords are found, e.g. "Description", then the
%   text up to the next two percentage signs is read into a Dummy class
%   object. 
%   
%% Syntax:
%   mf = MFile(name,path);
%
%% Input:
%   name - m-file name:     "string"
%       file name, including the extension
%   path - path to m-file:  "string"
%       path to folder that contains the m-file
%
%% Properties:
%   name - see inputs
%   path - see inputs
%   text - m-file text: "string"
%       string does not contain newline chars,  but is a vertical string
%   knownBlocks - keywords for functions: "string array"
%       keywords that should be looked out for in a function m-file.
%   classBlocks - keywords for classes: "string array"
%       keywords that are looked for additionally to knownBlocks in a class
%       m-file.
%   dummyList - list of all dummys: cell (vertical);
%
%% Disclaimer:
%   Last editor : Nils Böhnisch  
%   Last edit on: 22.02.2022
%   Code version: 2.0
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
% - remove HTML markup from this class and put into TEMPLATEHTML

    %% Properties
    properties
        name string; % Name of File
        path string; % Full Path of File
        text string; % text of File
        
        foundBlocks string = [string]; % stores the found text blocks marked with '%%'

%         knownBlocks = ["DESCRIPTION","SYNTAX","INPUT","OUTPUT", ...
%                         "REFERENCES","DISCLAIMER"]; % for functions
             % depreceated, use foundblocks
        classBlocks = ["METHODS", "PROPERTIES"]; % CONSTRUCTOR?
        
        dummyList   = {}; %List with dummies
        insideFunctions struct;
    end
    
    properties (Dependent)
        type string; % type of File{function,script,class} dep. on text
    end
    
    %% methods
    methods
        function obj = MFile(name,path)
            %MFile Constructor
            obj.name = name;
            obj.path = path;
            
            % open file and store text
            fil = fopen(obj.path+name,'r','n','UTF-8');
            dat = textscan(fil,'%s','delimiter','\n','TextType',"string");
            fclose(fil);
            obj.text = string(dat{1});
            %obj.text = textread(obj.path+name, '%s', 'delimiter', '\n', 'whitespace', '');
            
        end % Constructor

        function set.path(obj,p)
            % set a filesep at the end
            tmp = char(p);
            if(tmp(end)~=filesep)
                p = p+filesep;
            end
            obj.path = p;
        end % function set.path
        
        function t = get.type(obj)
            lineOne = lower(obj.text(1));
            if contains(lineOne,'function')
                t = "function";
            elseif contains(lineOne,'classdef')
                t = "class";
            else
                t = "script";
            end
        end % function get.type
        
        function addDummy(obj,dum)
            % addDummy to List
            obj.dummyList{end+1,1} = dum;
        end % function addDummy

    end % methods (interla)
    
    %% external defined functions
    methods
        parseFile(obj)
        checkCrossRef(obj,fctlist)
        redTxt = reduceText(obj,txt)
    end % methods (external)
end % end classdef