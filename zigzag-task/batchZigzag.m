%% run JRC first and do automated sorting
runJrc();

%% run these after doing manual clustering
disp('saveJrc');
saveJrc();

disp('saveEvent');
saveEventZigzag();

disp('savePlot');
OVERWRITE = 1;
savePlotZigzag({}, OVERWRITE);

% for plotting
plotZigag();