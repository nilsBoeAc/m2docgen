classdef Dummy < handle
% text dummys that contain important information 
%% Description:
%   Objects of this class are used to store information about a m-file.
%   While parsing an m-file in the function MFile.parse
%   
%% Syntax:
%   dm = dummy(name, filling);
%
%% Input:
% required input values;
%   name - Heading of the dummy: "string"
%       This is the heading where the dummy should be placed within the
%       template, for example a dm.name = "DESCRIPTION" will be placed
%       under the description heading of the HTML template.
%   filling - text content: "string"
%       This is the content that should appear in the html document. Make
%       sure to not use newline characters in the string, but to use a
%       vertical string.
%
%% Properties:
%   name    - see inputs
%   filling - see inputs
%   type    - classification of the dummy: string
%   refPath - reference path that should be placed into a placeholder that
%             is currently within the filling (content) of the dummy. see
%             generation of function reference list.
%   type    - must be one of the following:
%             "SHORT_DESCR","DYNAMIC","FUNCTREF","CLASSBLOCK","CONSTRUCTOR"
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
    
    %% Properties
    properties
        name    string;
        filling string;
        type    string;
        refPath string = "NA";
    end
    properties(Constant)
        typeCases string = ["SHORT_DESCR","DYNAMIC","FUNCTREF",...
            "CLASSBLOCK","CONSTRUCTOR"];
    end
    
    %% methods
    methods
        %% Dummy Constructor
        function obj = Dummy(name,filling)
            obj.name = name;
            if(isempty(filling))
                filling = "";
            end
            obj.filling = filling;
        end
        
        %% additional functions
        function set.type(obj,ty)
            % check if the type is listed in the typeCase property
            if any(contains(obj.typeCases, ty))
                obj.type = ty;
            else
                error("Error while setting the type property of the dummy " ...
                    + obj.name + ". Please specify a valid type");
            end
        end
        
        function set.name(obj,name)
            % autotype braces around input string if missing
            tmp = char(name);
            if(~contains(tmp,'{'))
                %disp("In Dummy: [Name] does not contain '{'. Will be added!");
                name = "{"+name;
            end
            if(~contains(tmp,'}'))
                %disp("In Dummy: [Name] does not contain '}'. Will be added!");
                name = name+"}";
            end
            obj.name = name;
        end
        
        function set.refPath(obj,rp)
            % autocorrect .html if extension is missing from input string
            if(~contains(rp,".html"))
                rp = rp+".html";
            end
            obj.refPath = rp;
        end
        
        function set.filling(obj,fil)
            % by default remove all % in the 'filling' text block
            % exception: constructor blocks
            exceptions = ["{constructor}","{class properties}","{class methods}"];
            currName = lower(obj.name);
            if any(contains(currName, exceptions))
                % do not remove anything
            else
               for i = 1:length(fil)
                    lineChar = char(fil(i));
                    idx = find(lineChar == '%');
                    if ~isempty(idx)
                        if size(idx,2) > 1
                            if idx(2) == 2
                                lineChar(2) = [];
                            end
                        end
                        if idx(1) == 1
                            lineChar(1) = [];
                        end
                        fil(i) = lineChar;
                    end
                end 
            end
            obj.filling = fil;           
            
        end
    end
end