function networks = getTrainedNetworks()
%% Returns names of all deepLearning networks in network_folder

network_folder='deepLearning/checkpoints';
    function bool=allNecessaryFilesExist(network_name)
        bool=true;
        necessary_files={'.ckpt.data-00000-of-00001',...
                        '.ckpt.index', ...
                        '.ckpt.meta', ...
                        '.info'};
        
        for i=1:numel(necessary_files)
            ext=necessary_files{i};
            if ~isfile(fullfile(network_folder, [network_name ext]))
                bool=false;
                return;
            end
        end
                        
    end

networks=dir(network_folder);
networks={networks.name};
networks=networks(contains(networks,'.ckpt.'));
networks=unique(cellfun(@(C)extractBefore(C,'.'),networks,'UniformOutput',false));
%Remove networks for which not all files exist
networks=networks(cell2mat(cellfun(@allNecessaryFilesExist, networks, 'UniformOutput', false)));

end

