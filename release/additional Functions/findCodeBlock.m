function codeBlock = findCodeBlock(text,functionName)
  % function that finds a certain CodeBlock
  %
  %% Input
  %   text          [string]  - Code
  %   functionName  [string]  - Name of function
  %
  %% Output
  %   codeBlock     [string]  - found CodeBlock in text
  %
  %% Disclaimer
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
  txt = text;
  txtNoCom  = removeComments(txt);
  strCoName = functionName;

  startLine = -1;
  endLine = -1;

  % keywords that require an "end" afterwards
  strKeyword = ["if " "try " "while " "for " "parfor " "switch "]; % spaces are to determine single word
  strKeyword = [strKeyword, strrep(strKeyword," ", "(")];
  endCounter = 0;
  for i = 1:length(txtNoCom)
      currLine = lower(txtNoCom(i));
      if contains(currLine, "function") && contains(currLine, lower(strCoName))
          % constructor found, now find the end of it
          startLine = i;
      end
      % increment or decrement endCounter
      if startLine ~= -1
          if contains(currLine, strKeyword) && ~contains(currLine,"elseif") % currLine still does not contain comments
              endCounter = endCounter +1;
              continue;
          end
          currLineNoSp = strrep(currLine, " ", "");
          if currLineNoSp == "end" || currLineNoSp == "end;"
              if endCounter == 0
                  endLine = i;
                  break; %  break out of loop if finished
              else
                  endCounter = endCounter -1;
              end
          end
      end
  end % for i, constructor now defined between startLine and endLine

  codeBlock = [];
  if startLine ~= -1 && endLine ~= -1
    codeBlock = txt(startLine:endLine);    
  end

end %eof