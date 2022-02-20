function txtNoCom = removeComments(txt)
    % function that removes matlab comments from text, but keeps line count
    %
    %% Description:
    %   text file is recuded to only its code text, comments are removed. if a
    %   line consist only of comments, then the text in that line is deleted,
    %   but the line is kept (blank). 
    %   
    %% Syntax:
    %   txtNoCom = RemoveComments(txt);
    %
    %% Input:
    %   txt - file text: "string" || char
    %       Text of the file you want to process
    %
    %% Output:
    %   txtNoCom - file text: "string"
    %       Text of reduced input file text.
    %
    %% Disclaimer:
    % Author: Nils Böhnisch
    % Copyright (c) 2022
    
    %% Code
    for i = 1:length(txt)
        idxP = strfind(txt(i), "%"); %index percent
        if isempty(idxP)
            txtNoCom(i) = txt(i);
        else
            newTxt = split(txt(i), "%");
            txtNoCom(i) = newTxt(1);
        end
    end % end for i
    
end % eof