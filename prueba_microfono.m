%% Prueba de micrófono
clc; clear; close all;

fs = 16000;     % Frecuencia de muestreo
duracion = 3;   % Segundos
recObj = audiorecorder(fs,16,1);

disp('Habla durante 3 segundos...');
recordblocking(recObj, duracion);
audioReal = getaudiodata(recObj);

% Mostrar señal capturada
figure;
subplot(2,1,1);
plot(audioReal);
title('Forma de onda capturada');
xlabel('Muestras'); ylabel('Amplitud');

% FFT para ver contenido de frecuencias
subplot(2,1,2);
N = length(audioReal);
Y = abs(fft(audioReal));
Y = Y(1:floor(N/2));
f = linspace(0, fs/2, numel(Y));
plot(f, Y);
title('Espectro de frecuencias');
xlabel('Hz'); ylabel('Magnitud');

disp('Grabación completa');
