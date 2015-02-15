% Use jobMangerName as global variable, will be set in installer
global jobManagerName;

% A GUI to set releveant directories, Matlab jobmanager and chose a dataset
installer

% NO MODIFICATIONS NECESSARY UNDER THIS LINE USUALLY

% Compile functions needed later using Matlab mex compiler
display('If you get warning or errors here, please try to run mex -setup and choose a compiler supported by Matlab');
% Compile mex watershed and nml parser
if strcmp(computer('arch'), 'glnxa64')
    % Linux mex
    mex CFLAGS="\$CFLAGS -U FORTIFY_SOURCE -std=c99" -largeArrayDims -outdir retina/segmentation/watershedBasedSeg retina/segmentation/watershedBasedSeg/watershed_threeTimes3D.c;
    mex -outdir auxiliaryMethods auxiliaryMethods/parseNml.c;
elseif strcmp(computer('arch'), 'PCWIN64')
    % Windows mex
    mex -largeArrayDims -outdir retina\segmentation\watershedBasedSeg retina\segmentation\watershedBasedSeg\watershed_threeTimes3D.c;
    mex -outdir auxiliaryMethods auxiliaryMethods\parseNml.c;
else
    display('Please set up mex to run with your architecture!')
end

% This requires that matlab is started from the baseDirectory of the github
% repo, better alternative?
codeDirectory = pwd;

% Open relevant scripts for dataset/code version
if strcmp(chosenDataset, 'Retina (ek0563)')
    run(['retina' filesep 'startup.m']);
end
if strcmp(button, 'Cortex (2012_09_28_ex145_07x2)')
    run(['cortex' filesep 'startup.m']);
end
