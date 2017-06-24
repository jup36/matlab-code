clc; clearvars; close all;
mixed_tone = zeros(1,480001); 
for ii = [2, 4, 6, 8, 16]
    mixed_tone = mixed_tone+ sin(2*pi*ii*1000*(0:1/48000:10));
end

envelop = 1+cos(2*pi*1000/3*(0:1/48000:0.003)-pi);

mixed_click = envelop.*mixed_tone(1:length(envelop));

spike_rate = 20;
interval = exprnd(1/spike_rate, 1, spike_rate*20*60);
spike_time = cumsum(interval);
spike_time_raster = zeros(1, 48000*20*60);
spike_time_raster(round(spike_time*48000)) = 1;

poisson_click = conv(spike_time_raster, mixed_click, 'same');

audiowrite('poisson_click.wav', poisson_click, 48000);