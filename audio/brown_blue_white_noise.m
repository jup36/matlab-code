clc; clearvars; close all;

Fs = 48000;
duration = 20*60; % second

[bWhite, aWhite] = butter(12, 2000/(Fs/2), 'high');
white = filter(bWhite, aWhite, rand(1, Fs*duration)*2 - 1);
white = white / 5;

cutFrequencyBrown = 10000;
[bBrown, aBrown] = butter(70, cutFrequencyBrown/(Fs/2));
brown = filter(bBrown, aBrown, white);


cutFrequencyBlue = 11000; 
[bBlue, aBlue] = butter(70, cutFrequencyBlue/(Fs/2), 'high');
blue = filter(bBlue, aBlue, white);


audiowrite('white_noise.wav', white, Fs);
audiowrite('brown_noise.wav', brown, Fs);
audiowrite('blue_noise.wav', blue, Fs);

periodogram(white, rectwin(length(white)), length(white), Fs);
periodogram(brown, rectwin(length(brown)), length(brown), Fs);
periodogram(blue, rectwin(length(blue)), length(blue), Fs);