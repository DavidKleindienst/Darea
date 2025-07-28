% unit test for StartAnalysis and makeFigures functions

classdef Testing < matlab.unittest.TestCase
    properties
        hProgress
        datFile = 'tests/Config1.dat';
        outpath = 'tests/output_data.mat';
        figuresOutpath = 'tests/FiguresOutputData';
        analysisName = 'TestAnalysis1';
        figure_settings
        analysis_settings

    end

    methods (TestMethodSetup)
        function setup(testCase)
            testCase.hProgress = uicontrol('Style', 'Text', 'Position', [35 65 580 50], ...
                'FontWeight', 'bold', 'FontSize', 13, 'HorizontalAlignment', 'center');
            
            S = load('tests/TestDataSet/analysis_settings.mat'); % load settings for StartAnalysis
            testCase.analysis_settings = S.settings;

            T = load('tests/TestDataSet/figure_settings.mat'); % load settings for makeFigures
            testCase.figure_settings = T.settings;
        end
    end

methods (TestMethodTeardown)
    function cleanup(testCase)
        delete(gcf); % remove hProgress figure window after tests

        if isfile(testCase.outpath)
            delete(testCase.outpath); % remove analysis output data after tests
        end

        fclose('all'); % Close all open file handles

        if isfolder(testCase.figuresOutpath)
            rmdir(testCase.figuresOutpath, 's'); % remove figures data after tests
        end
    end
end

    methods (Test)
        function testAnalysis(testCase)
            StartAnalysis(testCase.datFile, testCase.analysis_settings, ...
                testCase.hProgress, testCase.outpath, testCase.analysisName); % runs StartAnalysis

            % check if output file was created
            testCase.assertTrue(isfile(testCase.outpath), 'StartAnalysis output file not found.');

            loaded = load(testCase.outpath);
            testCase.assertTrue(isfield(loaded, 'Data'), 'No Data struct in StartAnalysis output.'); % check if Data has been loaded from outpath
            Data = loaded.Data;

            try
                Data = hlp_deserialize(Data);
            catch
                error('Could not deserialize Data.');
            end

            testCase.assertTrue(isfield(testCase.figure_settings, 'SimNames'), ...
                'SimNames field is missing in settings.');

            testCase.assertEqual(Data.nrImages, length(Data.Orig.Images));
            testCase.assertTrue(isfield(Data, 'distfields'), 'distfields missing.');

            % verify the number of images match
            imageFiles = dir('tests/TestDataSet/*.tif');
            imageFiles = imageFiles(~endsWith({imageFiles.name}, '_mod.tif')); % Filter out files ending with '_mod.tif'
            testCase.assertEqual(Data.nrImages, numel(imageFiles), ...
                'Number of images in Data does not match the number of .tif files in TestDataSet.');


            % run makeFigures
            makeFigures(Data, testCase.datFile, testCase.figuresOutpath, ...
                testCase.figure_settings, testCase.hProgress);

            % check folder with figures data was created
            testCase.assertTrue(isfolder(testCase.figuresOutpath), 'Figures output folder not created.');

            % check ImageInfo was created in figuresOutpath
            testCase.assertTrue(isfile(fullfile(testCase.figuresOutpath, 'ImageInfo.csv')), ...
                'ImageInfo.csv not found in figures output.')

            % check Stats_and_Metrics and tSNE plots were created 
            if testCase.figure_settings.makeStatistics
                statsPath = fullfile(testCase.figuresOutpath, 'Stats_and_Metrics');
                testCase.assertTrue(isfolder(statsPath), 'Stats_and_Metrics folder not created.');
            end
            
            if testCase.figure_settings.StatisticsOptions.maketSNE
                tsnePath = fullfile(testCase.figuresOutpath, 'Stats_and_Metrics', 'plots', 'tSNE');
                testCase.assertTrue(isfolder(tsnePath), 'tSNE output folder not created.');
            end
        end
    end
end