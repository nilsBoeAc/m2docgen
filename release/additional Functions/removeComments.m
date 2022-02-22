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
    %   Last editor: Nils Böhnisch
    %
    %   Copyright (c) 2020 Nils Böhnisch, Pierre Ollfisch.
    %
    %   This file is part of m2docgen.
    %
    %   m2docgen is free software: you can redistribute it and/or modify
    %   it under the terms of the GNU General Public License as published by
    %   the Free Software Foundation, either version 3 of the License, or
    %   any later version. Also see the file "License.txt".
    
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