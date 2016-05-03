clearvars;

miceType = 'PV';
startingDir = ['C:\Users\Lapis\OneDrive\project\workingmemory_interneuron\data\Behavior\', miceType, 'ChR'];
findingFile = [miceType, 'ChR*result*.txt'];
sList = FindFiles(findingFile, 'StartingDirectory', startingDir, 'CheckSubdirs', 0);
inCell = cellfun(@(x) ~isempty(strfind(x, 'random')) | ~isempty(strfind(x, '80mW')), sList);
sList = sList(inCell);

outCell = cellfun(@(x) ~isempty(strfind(x, 'PVChR4')), sList);
sList(outCell) = [];


[~, cellNm] = cellfun(@fileparts, sList, 'UniformOutput', false);
cellNms = cellfun(@(x) strsplit(x, '_'), cellNm, 'UniformOutput', false);

mouseNm = cellfun(@(x) x{1}, cellNms, 'UniformOutput', false);
sessionTime = datetime(cellfun(@(x) [x{2} x{3}], cellNms, 'UniformOutput', false), 'InputFormat', 'yyyyMMddHHmmss');

mList = unique(mouseNm);
nM = length(mList);

results = cell(nM, 1);
ps = ones(nM, 4);
pdiv = ones(nM, 12);
[perf.y perf.n] = deal(zeros(nM, 12));
M = cell(4,1);
for iT = 1:4
    M{iT} = zeros(2, 2, nM);
end

M2 = cell(12,1);
for iT = 1:12
    M2{iT} = zeros(2, 2, nM);
end

for iM = 1:nM
    inS = find(strcmp(mouseNm, mList{iM}));
    nS = length(inS);
    
    result = struct('target', [], 'choice', [], 'correct', [], 'light', []);
    result(2).target = [];
    result(3).target = [];
    result(4).target = [];
    
    for iS = 1:nS
        switch cellNms{inS(iS)}{6}
            case '3s'
                iT = 1;
            case '5s'
                iT = 2;
            case '10s'
                if length(cellNms{inS(iS)}) == 6
                    iT = 3;
                else
                    iT = 4;
                end
            otherwise
                continue;
        end

        sData = importdata(sList{inS(iS)});
        if isempty(sData); continue; end;
        inT = sData(1,:)~=0;
        target = sData(1,inT)';
        choice = sData(2,inT)';
        correct = target==choice;
        light = sData(7,inT)';
        result(iT).target = [result(iT).target; target];
        result(iT).choice = [result(iT).choice; choice];
        result(iT).correct = [result(iT).correct; correct];
        result(iT).light = [result(iT).light; light];
        
        pdiv(iM, iS) = chisq([correct, light]);
        perf.y(iM, iS)  = nanmean(correct(light==1));
        perf.n(iM, iS) = nanmean(correct(light==0));
        
        for iC = 1:2
            for iL = 1:2
                M2{iS}(iC, iL, iM) = sum(correct==(2-iC) & light==(2-iL));
            end
        end
    end
    
    
    
    results{iM} = result;
    
    for iT = 1:4
        ps(iM, iT) = chisq([result(iT).correct, result(iT).light]);
        
        for iC = 1:2
            for iL = 1:2
                M{iT}(iC, iL, iM) = sum(result(iT).correct==(2-iC) & result(iT).light==(2-iL));
            end
        end
    end
end

psrblock = zeros(1,4);
pMH = ones(4,1);
pttblock = zeros(1,4);
for iT = 1:4
    py = perf.y(:,(iT-1)*3+(1:3)); py = py(:)';
    pn = perf.n(:,(iT-1)*3+(1:3)); pn = pn(:)';
    [h, pttblock(iT)] = ttest(py, pn);
    psrblock(iT) = signrank(py, pn);
    pMH(iT) = MantelHaenTest(M{iT});
end

ptt = zeros(1,12);
psr = zeros(1,12);
pMH2 = zeros(1,12);
for iT = 1:12
    [~,ptt(iT)] = ttest(perf.y(:,iT), perf.n(:,iT));
    psr(iT) = signrank(perf.y(:,iT), perf.n(:,iT));
    pMH2(iT) = MantelHaenTest(M2{iT});
end
                    

