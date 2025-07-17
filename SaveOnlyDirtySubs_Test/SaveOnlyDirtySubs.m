clear all
close all
clc

function SaveOnlyDirtySubs('FileToBeControlled')

    modelName = 'FileToBeControlled';
    load_system(modelName);
    
    allSubsystems = find_system(modelName, 'BlockType', 'SubSystem');
    
    referencedModels = {};
    blockPaths = {};
    depth = [];   
    Saved = {};
    seq_end = [];
    dirty_idx = [];
    
    for i = 1:length(allSubsystems)
        refFile = get_param(allSubsystems{i}, 'ReferencedSubsystem');
    
        if ~isempty(refFile)
            referencedModels{end+1} = refFile;
            blockPaths{end+1} = allSubsystems{i}; 
            parts = strsplit(allSubsystems{i}, '/');
            depth(end+1) = length(parts) - 1;
        end
    
    end
    
    new_subs_seq = find(depth == 2);
    
    for k = 1:length(new_subs_seq)
        if k < length(new_subs_seq)
            seq_end(k) = new_subs_seq(k+1) - 1;
        else
            seq_end(k) = length(depth);
        end
    end
    
    
    for k = 1:length(new_subs_seq)
        seq_idx = new_subs_seq(k):seq_end(k);
        
        dirty_idx = []; 
        
        for j = seq_idx
            refModel = referencedModels{j};
            if strcmp(get_param(refModel, 'Dirty'), 'on')
                dirty_idx(end+1) = j;
            end
        end
        
        if ~isempty(dirty_idx)
    
            [~, minIdx] = min(depth(dirty_idx));
            idxToSave = dirty_idx(minIdx);
            save_system(referencedModels{idxToSave}, 'SaveDirtyReferencedModels', 'on');
            Saved{end+1} = referencedModels{idxToSave};
    
        end
    end
    
    fprintf('\n--- Save Summary ---\n');
    
    if ~isempty(Saved)
        fprintf('Saved (%d): %s\n', length(Saved), strjoin(Saved, ', '));
    else
        fprintf('No file saved.\n');
    end

end