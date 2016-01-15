function tagstatWM_data

clearvars;
% Variable nspv, nssom, and wssom will be used.
load('D:\Cloud\project\workingmemory_interneuron\data\celllist_20150527.mat');

stats_pv = tagstatWM(nspv);
stats_nssom = tagstatWM(nssom);
stats_wssom = tagstatWM(wssom);

save('tagstatWM');