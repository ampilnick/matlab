function [fname2Save] = multiFig2Avi(opt)
arguments
    opt.nameDataFilesRootFold (1,:) char {mustBeNonempty, mustBeFinite}
    opt.pattRegexpFnamesDataFile (1,:) char {mustBeNonempty, mustBeFinite}
    opt.nOverFrame (1,1) {mustBeNumeric} = 1
end

addpath('Libs');
tic

opt.nameDataFilesRootFold = 'd:\Meas\FERS\Software\matSoftware\Staircase\runData\hv_55\fitCountIChDetFigTest\';
% opt.pattRegexpFnamesDataFile = '(?<=fitCountIChDet_)\d+(?=.fig$)';
% opt.nameDataFilesRootFold = 'd:\Meas\FERS\Software\matSoftware\Staircase\runData\hvCountPng\';
opt.pattRegexpFnamesDataFile = '(?<=countAllChHv)\d+(?=.png$)';
opt.nOverFrame = 5;

fnameAllData = findFileFolderList('searchOf','files',...
    'searchPath',opt.nameDataFilesRootFold,...
    'fullNameRegexpOrKeptObj',{opt.pattRegexpFnamesDataFile});

fnameVid2Save = cell(1,numel(fnameAllData));

% List of subfolders of the data files
if numel(fnameAllData) > 1
    uniqNameAllDataFold = unique(fileparts(fnameAllData));
else
    uniqNameAllDataFold = unique({fileparts(fnameAllData)});
end

parfor iNameDataFold = 1:numel(uniqNameAllDataFold)
% for iNameDataFold = 1:numel(uniqNameAllDataFold)

    pathF = uniqNameAllDataFold{iNameDataFold};

    % Data files from current subfolder
    fnameDataCurFolder = findFileFolderList('searchOf','files',...
        'searchPath',pathF,...
        'fullNameRegexpOrKeptObj',{opt.pattRegexpFnamesDataFile});

    [~,~,partFnameResult,diffFnameData] = commonSubstringFromStart(fnameDataCurFolder);
    diffFnameData2 = cellfun(@(x) x(1:end-4),diffFnameData, 'UniformOutput',false);
    maxLengthD2 = max(cellfun(@(x) numel(x),diffFnameData2));

    fnameVid2Save{iNameDataFold} = [partFnameResult repmat('x',1,maxLengthD2) '_overFrame' num2str(opt.nOverFrame)];

    objVidWri = VideoWriter(fnameVid2Save{iNameDataFold},'MPEG-4');
    open(objVidWri);

    for iFnameDataCurFolder = 1:numel(fnameDataCurFolder)
        curFrame = imread(fnameDataCurFolder{iFnameDataCurFolder});
        for ii = 1:opt.nOverFrame
            writeVideo(objVidWri, curFrame);
        end
    end
    close(objVidWri);
end

toc