%% uninstalling m2docgen Toolbox
%% Description
% The Toolbox will be uninstalled by removing the folder from the matlab search path
% 
% Hint: you can fast uninstall the toolbox by marking this file in the MATLAB
% "Current Folder Browser" and pressing F9. So you do not need to open the
% script.

cd(fileparts(which(mfilename)));
rmpath(genpath('.'));
disp("m2docgen is Uninstalled / Removed!");
% eof;