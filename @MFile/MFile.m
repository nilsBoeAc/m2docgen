classdef MFile < handle
    % MFile
    
    %% Properties
    properties
        name string; % Name of File
        path string; % Full Path of File
        text string;  % text of File

        knownBlocks = ["DESCRIPTION","SYNTAX","INPUT","OUTPUT", ...
                        "REFERENCES","DISCLAIMER"]; % for functions
                    
        classBlocks = ["METHODS"]; % in addition for classes, "PROPERTIES" is already done by other script
        
        dummyList   ={}; %List with dummies
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
            
            % Reduced Text to header
            obj.text = string(dat{1});
        end
    end
    
    %% Get / Set Functions
    methods
        function set.path(obj,p)
            tmp = char(p);
            if(tmp(end)~="\")
                p = p+"\";
            end
            obj.path = p;
        end
        
        function t = get.type(obj)
            lineOne = lower(obj.text(1));
            if contains(lineOne,'function')
                t = "function";
            elseif contains(lineOne,'classdef')
                t = "class";
            else
                t = "script";
            end
        end
        redTxt = reduceText(obj,txt)
        redTxt = noComments(obj, txt)
    end
    
    %% further Method
    methods
        parseFile(obj)
        checkCrossRef(obj,fctlist)
        getConstructor(obj);
        
        function addDummy(obj,dum)
            obj.dummyList{end+1,1} = dum;
        end
        
    end % end methods
end % end classdef