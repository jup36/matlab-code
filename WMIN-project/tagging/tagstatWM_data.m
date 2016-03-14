clearvars;
% Variable nspv, nssom, and wssom will be used.
load('C:\Users\Lapis\OneDrive\project\workingmemory_interneuron\data\celllist_neuron.mat');

% stats_pv = tagstatWM(pv);
% stats_som = tagstatWM(som);
% stats_fs = tagstatWM(fs);
% stats_pc = tagstatWM(pc);
% stats_nongrouped = tagstatWM(nongrouped);
% 
% save('tagstatWM', 'stats_pv', 'stats_som', 'stats_fs', 'stats_pc', 'stats_nongrouped');

stats_nspv = tagstatWM(nspv);
stats_wspv = tagstatWM(wspv);
stats_nssom = tagstatWM(nssom);
stats_wssom = tagstatWM(wssom);

save('tagstatWM', 'stats_nspv', 'stats_wspv', 'stats_nssom', 'stats_wssom', '-append');