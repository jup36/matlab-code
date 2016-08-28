clc; clearvars; close all;
load('cellTable.mat');

cellNm = {'pv', 'som', 'fs', 'pc'};
trialType = [1, 3, 13, 15];
lineClr = {[1 0 0], [1 0.5 0.5], [0 0 1], [0.5 0.5 1]};

tag.p = T.pLR < 0.01 & T.pSalt < 0.01;
tag.pv = tag.p & T.line=='PV';
tag.som = tag.p & T.line=='SOM';

cellList.pv = T.cellList(tag.pv);
cellList.som = T.cellList(tag.som);
cellList.fs = T.cellList(T.class == 1 & ~(tag.pv & tag.som));
cellList.pc = T.cellList(T.class == 2 & ~(tag.pv & tag.som));

n.pv = length(cellList.pv);
n.som = length(cellList.som);
n.fs = length(cellList.fs);
n.pc = length(cellList.pc);


for iC = 1:n.pv
    load(cellList.pv{iC});
    clf;
    hold on;
    for iType = 1:4
        plot(psthtimeRw, psthconvRw(trialType(iType), :), 'Color', lineClr{iType});
    end
    
    inText = input('Press enter to continue or press e to end');
    if inText == 'e'
        break;
    end
end
