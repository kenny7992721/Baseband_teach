function blkStruct = slblocks
%SLBLOCKS Defines the block library for Real-Time Workshop

%   Copyright 1994-2003 The MathWorks, Inc.
%   $Revision: 1.9.2.2 $
%   $Date: 2004/04/15 00:25:09 $

% Name of the subsystem which will show up in the
% Simulink Blocksets and Toolboxes subsystem.
blkStruct.Name = 'SMIMS Engine';

% The function that will be called when
% the user double-clicks on this icon.
blkStruct.OpenFcn = 'smims';

blkStruct.MaskInitialization = '';

% The argument to be set as the Mask Display for the subsystem.
% You may comment this line out if no specific mask is desired.
blkStruct.MaskDisplay = '';

% Define the library list for the Simulink Library browser.
% Return the name of the library model and the name for it
Browser(1).Library = 'smims';
Browser(1).Name    = 'SMIMS Verilink';
Browser(1).IsFlat  = 0;

blkStruct.Browser = Browser;
% End of slblocks
