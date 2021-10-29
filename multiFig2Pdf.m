function [fname2Save] = multiFig2Pdf(opt)
arguments
    opt.nameDataFilesRootFold (1,:) char {mustBeNonempty, mustBeFinite}
    opt.pattRegexpFnamesDataFile (1,:) char {mustBeNonempty, mustBeFinite}
end

addpath('Libs');

import mlreportgen.report.*
import mlreportgen.dom.*

% opt.nameDataFilesRootFold = 'd:\Meas\FERS\Software\matSoftware\Staircase\runData\';
opt.nameDataFilesRootFold = 'd:\Meas\FERS\Software\matSoftware\Staircase\runData\hv_55\fitCountIChDetFigTest\';
opt.pattRegexpFnamesDataFile = '(?<=fitCountIChDet_)\d+(?=.fig$)';

coefFontSizereduct = .6;

fnameAllData = findFileFolderList('searchOf','files',...
    'searchPath',opt.nameDataFilesRootFold,...
    'fullNameRegexpOrKeptObj',{opt.pattRegexpFnamesDataFile});

% List of subfolders of the data files
if numel(fnameAllData) > 1
    uniqNameAllDataFold = unique(fileparts(fnameAllData));
else
    uniqNameAllDataFold = unique({fileparts(fnameAllData)});
end

tic
for iNameDataFold = 1:numel(uniqNameAllDataFold)

    pathF = uniqNameAllDataFold{iNameDataFold};

    % Data files from current subfolder
    fnameDataCurFolder = findFileFolderList('searchOf','files',...
        'searchPath',pathF,...
        'fullNameRegexpOrKeptObj',{opt.pattRegexpFnamesDataFile});

    [commonPathRoot, ~, ~, diffSubstringEnd] = commonSubstringFromStart(fnameDataCurFolder);
    [~, ~, ~, diffSubstringEnd2] = commonSubstringFromStart(reverse(diffSubstringEnd));
    iChan = str2double(reverse(diffSubstringEnd2));

    [~,~,commonFNameStart,diffFNameEnd] = commonSubstringFromStart(fnameDataCurFolder);
    [~,~,commonFNameEnd,dd] = commonSubstringFromStart(reverse(diffFNameEnd));
    commonFNameEnd = reverse(commonFNameEnd);
    xSubstitutionDiffFNames = repmat('x',1,max(cellfun(@(x) numel(x), dd)));
    fname2Save = [commonFNameStart xSubstitutionDiffFNames commonFNameEnd];

    [~,iSortIChan] = sort(iChan);

    tic
    report = Report(fname2Save,'pdf');
    pageMargins = PageMargins();
    pageMargins.Left = "0.1in";
    pageMargins.Right = "0.1in";
    pageMargins.Top = "0.5in";
    pageMargins.Bottom = "0.5in";
    report.Layout.PageMargins = pageMargins;

    titlePage = TitlePage();
    titlePage.Title = fname2Save(numel(commonPathRoot)+1:end); % 'Plots set';
    titlePage.Subtitle = ['Plots set from the folder: ' commonPathRoot];
    titlePage.Author = '';
    titlePage.Publisher = '';
    append(report,titlePage);

    tableOfContents = TableOfContents();
    tableOfContents.Title = Text('Table of Contents');
    tableOfContents.NumberOfLevels = 2;
    append(report,tableOfContents);
    append(report,PageBreak);

    chapter = Chapter('Channels');

    for iFileData = iSortIChan

        append(chapter,Section(['Ch_' num2str(iChan(iFileData))]));

        fig = Figure(openfig(fnameAllData{iFileData}));

        hTextBox = findall(gcf,'Type','TextBox');
        if ~isempty(hTextBox)
            hTextBox.FontSize = round(coefFontSizereduct * hTextBox.FontSize);
        end
        hText = findall(gcf,'Type','text');
        [hText.FontSize] = deal(coefFontSizereduct * hText(1).FontSize);
        hLegend = findall(gcf,'Type','Legend');
        [hLegend.FontSize] = deal(coefFontSizereduct * hLegend(1).FontSize);
        fig.Scaling = "custom";
        fig.Height = "3.7in";
        fig.Width = "8in";

        append(chapter,fig);
    end

    append(report,chapter);
    close all

    close(report);
    rptview(report);
end
toc
end