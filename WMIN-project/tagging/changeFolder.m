function changeFolder
load('C:\Users\Lapis\OneDrive\project\workingmemory_interneuron\data\celllist_20150527.mat');

pc = cDir(pc);
pc_pvmice = cDir(pc_pvmice);
pc_sommice = cDir(pc_sommice);

fs = cDir(fs);
fs_pvmice = cDir(fs_pvmice);
fs_sommice = cDir(fs_sommice);

pv = cDir(pv);
nspv = cDir(nspv);
wspv = cDir(wspv);

som = cDir(som);
nssom = cDir(nssom);
wssom = cDir(wssom);

nongrouped = cDir(nongrouped);

save('C:\Users\Lapis\OneDrive\project\workingmemory_interneuron\data\celllist_neuron.mat', ...
    'pc', 'pc_pvmice', 'pc_sommice', ...
    'fs', 'fs_pvmice', 'fs_sommice', ...
    'pv', 'nspv', 'wspv', ...
    'som', 'nssom', 'wssom', ...
    'nongrouped');
end

function mFile = cDir(mFile)
predir = 'D:\\Cloud\\project\\workingmemory_interneuron\\data\\';
curdir = 'C:\\Users\\Lapis\\OneDrive\\project\\workingmemory_interneuron\\data\\';
mFile = regexprep(mFile,predir,curdir);
end
