function res = sdm_eigenproblem(M,C,K,varargin)
% Calculates the eigenvalues
% Test
% Test2
%
%% Description:
%
% Purpose:  Calculate the eigenvalues and eigenvectors of a structural dynamics system.
%           A modified version of polyeigs() will be used in combination
%           with eigs().
%
%% Syntax:
%
% res = sdm_eigenproblem(M,C,K)
% res = sdm_eigenproblem(M,C,K,noValues)
%
%% Input:
%   Mandatory:
%       M: [double matrix] Mass Matrix 
%       C: [double matrix] Damping Matrix 
%       K: [double matrix] Stiffness Matrix
%   Hint: Make sure, that M,C,K are of the same size and quadratic!
%   
%   Optional:
%       NoValues: [indteger] number of different eigenvalues to be computed
%           If not specified, all 2*ndof eigevalues and correspponding eigenvectors will be calculated.
%           Different means: conjugate complex are not different
% 
%% Output:
%       res.eigenValues [double complex]: 2*NoValues printed eigenValues
%       res.eigenVectors [double complex x double complex]: ndof x 2+NoValues calculated eigenevectors (each column for one eigenvector)
%
%% References:
%
%   [Ref1]: MATLAB's polyeig() function
%   [Ref2]: MATLAB's eigs() function
%
%
%% Disclaimer:
% Copyright (c) 2021,  FH Aachen, LFT Labor (FB6).
% All rights reserved. 
% 
% Module Version:           1.0
% Last edited on:           25.01.2021
% Last edited by:           Nils Boehnisch

%% ToDo
% - only checked for systems with complex eigenvalues

%% Input Checking
checkNoVal = @(x) (x>0 && x<=length(K));
p = inputParser;
addOptional(p,'noValues',length(K),checkNoVal);
parse(p,varargin{:});
noValues = p.Results.noValues;

%% Calculations

% original code by MATLAB function - polyeig
n = length(K);
p = 2;
np = n*p;

A = eye(np);
A(1:n,1:n) = K;
    
nB = size(A,1);
B = zeros(nB);
B((n+1):(nB+1):end) = 1;
k = 1;
ind = (k-1)*n;
B(1:n, ind+1:ind+n) = - C;

k = 2;
ind = (k-1)*n;
B(1:n, ind+1:ind+n) = - M;

% Use eigs instead of eig
[Q,D] = eigs(A,B,2*noValues,'SM');
eigVals = diag(D);

% Determine normalized eigenvectors (max entry = 1)
Q_abs = abs(Q);
[~,index] = max(Q_abs,[],1); % max by column
eigenvector = zeros(size(Q));
% Make eigenvectors 1-Normal
for i = 1:size(Q,2)
        % normalizing to max 1
        eigenvector(:,i) = 1/Q(index(i),i) .* Q(:,i);
end

% reduce to number of ndof
eigenvector = eigenvector(n+1:end,:);

%% Output assignments
res.eigenValues = eigVals;
res.eigenVectors = eigenvector;
end