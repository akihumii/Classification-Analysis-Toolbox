classdef KlustaMatlab < Files
    %KLUSTAMATLAB Class to handle files for klusta
    % Author: TSAI Chne-Wuen
    % Email: eletsai@nus.edu.sg
    
    %% Public Properties
    properties
        fileType = "intan"
        data
        timeIndex
        samplingFreq
        outputPath
        
        partialDataRange = [30,50] % seconds, input 0 in first position to indicate 1, input 0 in 2nd position to use unitl the end
        
        lowpassFreq = 500
        LFPlowpassFreq = 0
        LFPhighpassFreq = 300
                
        thresholdStrongStdFactor = 4.5
        thresholdWeakStdFactor = 2
        % how to cluster
        % SNR and other parameters
        % inter-channel analysis / correlation
    end
    
    %% Hidden Porperties
    properties (Hidden = true)
        intanConversion = 0.195  % unit times this number = microvolts
        signData = -1  % invert the data
    end
    
    %% Public Methods
    methods
        function self = KlustaMatlab(varargin)
            self.varIntoStruct(varargin{:});
        end
        
        function runKlusta(self)
            self.readData();
            self.selectPartialData();
            self.data = self.signData*self.data;  % invert data so that action potential is positive
            self.getKlustaData();
            self.getKlustaPrm();
            self.getKlustaPrb();
        end
        
        function readData(self)
            switch self.fileType
                case 'intan'
                    self.getFiles('dialogTitle', 'Select raw recording files...');
                    [self.data, self.timeIndex, self.samplingFreq] = readIntan(self.fullfilename);
                    self.data = self.data / 0.195;  % convert from microvolts to unit
                otherwise
                    error('Invalid KlustaMatlab fileType...')
            end
            self.outputPath = fullfile(self.path,self.filenameShort);
        end
        
        function selectPartialData(self)
            self.partialDataRange = round(self.partialDataRange*self.samplingFreq);
            lengthData = size(self.data,2);
            if self.partialDataRange(1) == 0
                self.partialDataRange(1) = 1;
            else
            end
            if self.partialDataRange(2) == 0
                self.partialDataRange(2) = lengthData;
            end
            self.partialDataRange(self.partialDataRange > lengthData) = lengthData;
            if diff(self.partialDataRange) > 0
                self.data = self.data(:,self.partialDataRange(1):self.partialDataRange(2));
                self.timeIndex = self.timeIndex(self.partialDataRange(1):self.partialDataRange(2));
            else
                error('Starting time is larger than end time in PartialDataRange...')
            end
        end
        
        function getKlustaData(self)
            if ~isfolder(self.outputPath)
                mkdir(self.outputPath);
            end
            fullfilenameDat = fullfile(self.outputPath, sprintf('%s.dat',self.filenameShort));
            fid = fopen(fullfilenameDat, 'w');
            fwrite(fid, self.data(:)', 'int16');
            fclose(fid);
            fprintf('Saved %s...\n', fullfilenameDat)
        end
        
        function getKlustaPrm(self)
            fullfilenamePrm = fullfile(self.outputPath, sprintf('%s.prm',self.filenameShort));
            fid = fopen(fullfilenamePrm, 'w');
            fprintf(fid,['\n',...
                         'experiment_name = ''%s''\n',...  %self.outputFilename
                         'prb_file = ''%s''\n\n',...  % join({self.filenameShort, ".prb"],'')
                         'traces = dict(\n',...
                         '\traw_data_files=[experiment_name + ''.dat''],\n',...
                         '\tvoltage_gain=10.,\n',...
                         '\tsample_rate=%d,\n',...  % self.samplingFreq
                         '\tn_channels=%d,\n',...  % size(self.data,1)
                         '\tdtype=''int16'',\n',...
                         ')\n\n',...
                         'spikedetekt = dict(\n',...
                         '\tfilter_low=%d.,  # Low pass frequency (Hz)\n',...  % self.lowpassFreq
                         '\tfilter_high_factor=0.95 * .5,\n',...
                         '\tfilter_butter_order=3,  # Order of Butterworth filter.\n\n',...
                         '\tfilter_lfp_low=%d,  # LFP filter low-pass frequency\n',...  % self.LFPlowpassFreq
                         '\tfilter_lfp_high=%d,  # LFP filter high-pass frequency\n\n',...  % self.LFPhighpassFreq
                         '\tchunk_size_seconds=1,\n',...
                         '\tchunk_overlap_seconds=.015,\n\n',...
                         '\tn_excerpts=50,\n',...
                         '\texcerpt_size_seconds=1,\n',...
                         '\tthreshold_strong_std_factor=%0.10f,\n',...  % self.thresholdStrongStdFactor
                         '\tthreshold_weak_std_factor=%0.10f,\n',...  % self.thresholdWeakStdFactor
                         '\tdetect_spikes=''negative'',\n\n',...
                         '\tconnected_component_join_size=1,\n\n',...
                         '\textract_s_before=16,\n',...
                         '\textract_s_after=16,\n\n',...
                         '\tn_features_per_channel=3,  # Number of features per channel.\n',...
                         '\tpca_n_waveforms_max=10000,\n',...
                         ')\n\n',...
                         'klustakwik2 = dict(\n',...
                         '\tnum_starting_clusters=100,\n',...
                         ')'],...
                     self.filenameShort,...
                     join([self.filenameShort, ".prb"],''),...
                     self.samplingFreq,...
                     size(self.data,1),...
                     self.lowpassFreq,...
                     self.LFPlowpassFreq,...
                     self.LFPhighpassFreq,...
                     self.thresholdStrongStdFactor,...
                     self.thresholdWeakStdFactor);
            fclose(fid);
            fprintf('Saved %s...\n', fullfilenamePrm)
        end
        
        function getKlustaPrb(self)
            fullfilenamePrb = fullfile(self.outputPath, sprintf('%s.prb',self.filenameShort));
            fid = fopen(fullfilenamePrb, 'w');
            numChannel = size(self.data,1);
            
            fprintf(fid,[...
                         'channel_groups = {\n',...
                         '\t# Shank index.\n',...
                         '\t0:\n',...
                         '\t\t{\n',...
                         '\t\t\t# List of channels to keep for spike detection.\n',...
                         '\t\t\t''channels'': list(range(%d)),\n\n',...  % numChannel
                         '\t\t\t# Adjacency graph. Dead channels will be automatically discarded\n',...
                         '\t\t\t# by considering the corresponding subgraph.\n',...
                         '\t\t\t''graph'': [\n',...
                         '%s',...  % channel adjacency
                         '\t\t\t],\n\n',...
                         '\t\t\t# 2D positions of the channels, only for visualization purposes\n',...
                         '\t\t\t# in KlustaViewa. The unit doesn''t matter.\n',...
                         '\t\t\t''geometry'': {\n',...
                         '%s',...  % channel geometry
                         '\t\t\t}\n',...
                         '\t}\n',...
                         '}'],...
                         numChannel,...
                         compose("\t\t\t\t(%d,%d),\n",[0:numChannel-2]',[1:numChannel-1]'),...
                         join(compose("\t\t\t\t%d: (%d,%d),\n",[numChannel-1:-1:0]',[0:numChannel-1]',10*[0:numChannel-1]'),''));
            fclose(fid);
            fprintf('Saved %s...\n', fullfilenamePrb);
        end
    end
end

