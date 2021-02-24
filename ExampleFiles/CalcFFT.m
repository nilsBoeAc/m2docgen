function CalcFFT(sys, signal, customName, varargin)
% Function: [sdb_system].CalcFFT
% 
%
%% Description:
% Purpose: This function gathers information about a signal and then
% returns a fourier transformed signal in form of a sdb_FFT object.
% 
%% Syntax:
%
% [sdb_system].CalcFFT(signal, customName);
% [sdb_system].CalcFFT(_, Name, Value);
%
%% Input
% Mandatory:
%       'signal' - signal vector or matrix: [double matix]
%           The discretised signal on which the FFT should be performed on.
%           Can also be a ndof x num_ts matrix, for e.g.:
%           sd.timeDomainSol.displacement.
%       'customName' - descripting string: 'string or char'
%           Describe the FFT with at least 3 characters. This identifier
%           will be used by the SDBoxApp to display it.
%
% Name - Value - Pairs:
%   'samplingFreq' - real sampling frequency : [double]
%       This parameter specifies the original sampling frequency of the
%       signal. By default, the sdb_systems sampling frequency will be used
%   'resamplingFreq' - sampling frequency: [double]
%       frequency which the original signal should be downsampled to
%   'samplingDur':  - real duration of signal: [double]
%       signal duration. By default: (num_ts-1) * samplingFreq
%   'resamplingDur' - arbitrary duration : [double]
%       specify a shorter duration than the original signals duration
%   'lowPassFreq': - cut off frequency for low pass filter: [double]
%       Filters the input signal so that higher frequencies than the 
%       specified one are removed. Value in Hz, not rad/s.
%
%% References:
%   [Ref1] Nils ist King
%   [Ref2] SDBox ist geil
%
%% Disclaimer:
% Copyright (c) 2020,  FH Aachen, LFT Labor (FB6).
% All rights reserved. 
% 
% Module Version:   1.2
% Last edited on:   21.01.2021
% Last edited by:   Pierre Ollfisch

%% ToDo
% - rewrite to modular layout (done - PO 14.01.2021)

%% input parsing
p = inputParser;
addRequired(p,'signal');
addRequired(p,'customName');
addOptional(p,'samplingFreq',sys.setup.samplingFreq);
addOptional(p,'resamplingFreq',0);
addOptional(p,'samplingDur',sys.setup.t_duration);
addOptional(p,'resamplingDur',0);
addOptional(p,'lowPassFreq',0); % if zero, no lowpass is applied [Hz]
parse(p,signal, customName, varargin{:});

%% safety functions
if isempty(signal)
    disp("Please specify a signal to perform the FFT-transformation to");
    return;
end

%% assign variables
para.samplingFreq = p.Results.samplingFreq;
para.num_ts = size(signal,1);
para.resamplingFreq = p.Results.resamplingFreq;
para.samplingDur = p.Results.samplingDur;
para.resamplingDur = p.Results.resamplingDur;
para.lowPassFreq = p.Results.lowPassFreq;

%% calculate result
FFTStruct = sdm_FFT(customName, signal, para);

%% assigning structure to object 

FFTObj = sdb_FFT(customName, FFTStruct.f, FFTStruct.rawFFT,...
    FFTStruct.amp, FFTStruct.ampD, FFTStruct.powD, FFTStruct.phase);

%% assigning object to sys [sdb_system object]
newEnd = size(sys.fftSol,1)+1;
sys.fftSol{newEnd,1} = customName;
sys.fftSol{newEnd,2} = FFTObj;
sys.checkSol.fftSol = 1;
disp("   --- Sucessfully calculated FFT of signal " + customName);

end

