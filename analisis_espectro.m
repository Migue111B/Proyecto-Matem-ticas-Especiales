%% Análisis del espectro de voz grabada
clear; clc; close all;

% --- CONFIGURACIÓN ---
% Carpeta donde están tus audios
folderPath = fullfile('audio', 'Admin'); % Cambia si tu carpeta tiene otro nombre

% Escoge si quieres analizar audios del Admin o del NoAdmin
tipo = 'prender';  % Cambia a 'NoAdmin' si quieres ver otro

audioPath = fullfile(folderPath, tipo);
audioFiles = dir(fullfile(audioPath, '*.wav'));

if isempty(audioFiles)
    error('No se encontraron audios en la carpeta: %s', audioPath);
end

% --- SELECCIÓN DEL AUDIO ---
fileName = audioFiles(4).name;  % Toma el primer audio
[x, fs] = audioread(fullfile(audioPath, fileName));

disp(['Analizando el archivo: ', fileName]);
disp(['Frecuencia de muestreo: ', num2str(fs), ' Hz']);

% --- GRAFICAR FORMA DE ONDA ---
t = (0:length(x)-1) / fs;

figure('Name','Análisis de Audio','NumberTitle','off');
subplot(2,1,1);
plot(t, x, 'b');
title(['Forma de onda de: ', fileName]);
xlabel('Tiempo (s)');
ylabel('Amplitud');
grid on;

% --- FFT (Transformada de Fourier) ---
N = length(x);
Y = fft(x);
Ymag = abs(Y(1:N/2));             % Magnitud positiva
f = (0:(N/2)-1) * (fs / N);       % Escala de frecuencia en Hz

% Normalizar magnitud
Ymag = Ymag / max(Ymag);

% --- GRAFICAR ESPECTRO ---
subplot(2,1,2);
plot(f, Ymag, 'r');
title('Espectro de Frecuencia de la Voz');
xlabel('Frecuencia (Hz)');
ylabel('Magnitud Normalizada');
grid on;

sgtitle(['Análisis de Espectro - ', tipo]);





% --- Noadmin ---

% --- CONFIGURACIÓN ---
% Carpeta donde están tus audios
folderPath = fullfile('audio'); % Cambia si tu carpeta tiene otro nombre

% Escoge si quieres analizar audios del Admin o del NoAdmin
tipo = 'NoAdmin';  % Cambia a 'NoAdmin' si quieres ver otro

audioPath = fullfile(folderPath, tipo);
audioFiles = dir(fullfile(audioPath, '*.wav'));

if isempty(audioFiles)
    error('No se encontraron audios en la carpeta: %s', audioPath);
end

% --- SELECCIÓN DEL AUDIO ---
fileName = audioFiles(1).name;  % Toma el primer audio
[x, fs] = audioread(fullfile(audioPath, fileName));

disp(['Analizando el archivo: ', fileName]);
disp(['Frecuencia de muestreo: ', num2str(fs), ' Hz']);

% --- GRAFICAR FORMA DE ONDA ---
t = (0:length(x)-1) / fs;

figure('Name','Análisis de Audio','NumberTitle','off');
subplot(2,1,1);
plot(t, x, 'b');
title(['Forma de onda de: ', fileName]);
xlabel('Tiempo (s)');
ylabel('Amplitud');
grid on;

% --- FFT (Transformada de Fourier) ---
N = length(x);
Y = fft(x);
Ymag = abs(Y(1:N/2));             % Magnitud positiva
f = (0:(N/2)-1) * (fs / N);       % Escala de frecuencia en Hz

% Normalizar magnitud
Ymag = Ymag / max(Ymag);

% --- GRAFICAR ESPECTRO ---
subplot(2,1,2);
plot(f, Ymag, 'r');
title('Espectro de Frecuencia de la Voz');
xlabel('Frecuencia (Hz)');
ylabel('Magnitud Normalizada');
grid on;

sgtitle(['Análisis de Espectro - ', tipo]);




% --- pruebas ---


% --- CONFIGURACIÓN ---
% Carpeta donde están tus audios
folderPath = fullfile('audio'); % Cambia si tu carpeta tiene otro nombre

% Escoge si quieres analizar audios del Admin o del NoAdmin
tipo = 'pruebas';  % Cambia a 'NoAdmin' si quieres ver otro

audioPath = fullfile(folderPath, tipo);
audioFiles = dir(fullfile(audioPath, '*.wav'));

if isempty(audioFiles)
    error('No se encontraron audios en la carpeta: %s', audioPath);
end

% --- SELECCIÓN DEL AUDIO ---
fileName = audioFiles(1).name;  % Toma el primer audio
[x, fs] = audioread(fullfile(audioPath, fileName));

disp(['Analizando el archivo: ', fileName]);
disp(['Frecuencia de muestreo: ', num2str(fs), ' Hz']);

% --- GRAFICAR FORMA DE ONDA ---
t = (0:length(x)-1) / fs;

figure('Name','Análisis de Audio','NumberTitle','off');
subplot(2,1,1);
plot(t, x, 'b');
title(['Forma de onda de: ', fileName]);
xlabel('Tiempo (s)');
ylabel('Amplitud');
grid on;

% --- FFT (Transformada de Fourier) ---
N = length(x);
Y = fft(x);
Ymag = abs(Y(1:N/2));             % Magnitud positiva
f = (0:(N/2)-1) * (fs / N);       % Escala de frecuencia en Hz

% Normalizar magnitud
Ymag = Ymag / max(Ymag);

% --- GRAFICAR ESPECTRO ---
subplot(2,1,2);
plot(f, Ymag, 'r');
title('Espectro de Frecuencia de la Voz');
xlabel('Frecuencia (Hz)');
ylabel('Magnitud Normalizada');
grid on;

sgtitle(['Análisis de Espectro - ', tipo]);
