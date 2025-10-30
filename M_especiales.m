%% Proyecto Final - Matemáticas Especiales
% Reconocimiento de hablante (Admin vs NoAdmin)
% y comandos (prender, apagar, servo)
% Basado en MFCC → Transformada de Fourier + análisis espectral
% Autor: Miguel Angel Botero

clc; clear; close all;
disp("Proyecto Final - Matemáticas Especiales");

disp("Reconocimiento de hablante (Admin vs NoAdmin)");

disp("Basado en MFCC → Transformada de Fourier + análisis espectral");

%% 1. Configuración de carpetas 
carpetaBase   = fullfile("audio");
carpetaAdmin  = fullfile(carpetaBase,"Admin");   
carpetaNoAdmin= fullfile(carpetaBase,"NoAdmin");
carpetaPruebas= fullfile(carpetaBase,"pruebas");
fsDeseado     = 16000;

%% 2. Crear base de datos para el sistema
adsAdmin   = audioDatastore(carpetaAdmin, 'IncludeSubfolders',true, ...
    'FileExtensions',{'.wav'}, 'LabelSource','foldernames');
adsNoAdmin = audioDatastore(carpetaNoAdmin, 'IncludeSubfolders',true, ...
    'FileExtensions',{'.wav'}, 'LabelSource','foldernames');

%% 3. Configurar extractor de MFCC
afe = audioFeatureExtractor("SampleRate", fsDeseado, "mfcc", true);

%% 4. Extraer características de Admin
X_admin = [];
Y_admin = [];
reset(adsAdmin);
while hasdata(adsAdmin)
    [audioIn, info] = read(adsAdmin);
    if size(audioIn,2)>1, audioIn = mean(audioIn,2); end
    if info.SampleRate ~= fsDeseado
        audioIn = resample(audioIn, fsDeseado, info.SampleRate);
    end
    coeffs = mfcc(audioIn, fsDeseado);
    featMean = mean(coeffs,1);
    X_admin = [X_admin; featMean];
    Y_admin = [Y_admin; string("Admin")]; 
end

%% 5. Extraer características de NoAdmin
X_noadmin = [];
Y_noadmin = [];
reset(adsNoAdmin);
while hasdata(adsNoAdmin)
    [audioIn, info] = read(adsNoAdmin);
    if size(audioIn,2)>1, audioIn = mean(audioIn,2); end
    if info.SampleRate ~= fsDeseado
        audioIn = resample(audioIn, fsDeseado, info.SampleRate);
    end
    coeffs = mfcc(audioIn, fsDeseado);
    featMean = mean(coeffs,1);
    X_noadmin = [X_noadmin; featMean];
    Y_noadmin = [Y_noadmin; string("NoAdmin")]; 
end

%% 6. Entrenamiento de modelo
X_hablante = [X_admin; X_noadmin];
Y_hablante = [Y_admin; Y_noadmin];

modeloHablante = fitcknn(X_hablante, Y_hablante, "NumNeighbors",3);
disp("Modelo de hablante entrenado (Admin o NoAdmin)");

%% 7. Entrenamiento de modelo de palabras (solo Admin)
X_palabra = [];
Y_palabra = [];

subfolders = dir(carpetaAdmin);
for i = 1:length(subfolders)
    if subfolders(i).isdir && ~startsWith(subfolders(i).name,".")
        carpetaSub = fullfile(carpetaAdmin, subfolders(i).name);
        adsTemp = audioDatastore(carpetaSub,'FileExtensions',{'.wav'});
        while hasdata(adsTemp)
            [audioIn, info] = read(adsTemp);
            if size(audioIn,2)>1, audioIn = mean(audioIn,2); end
            if info.SampleRate ~= fsDeseado
                audioIn = resample(audioIn, fsDeseado, info.SampleRate);
            end
            coeffs = mfcc(audioIn, fsDeseado);
            featMean = mean(coeffs,1);
            X_palabra = [X_palabra; featMean];
            Y_palabra = [Y_palabra; string(subfolders(i).name)];
        end
    end
end

modeloPalabra = fitcknn(X_palabra, Y_palabra, "NumNeighbors",3);
disp("Modelo de palabras entrenado (prender, apagar)");

%% 8. Pruebas con audios "pruebas"
adsPruebas = audioDatastore(carpetaPruebas, 'FileExtensions',{'.wav'});

disp("Iniciando pruebas con audios de 'pruebas'...");
reset(adsPruebas);

while hasdata(adsPruebas)
    [audioPrueba, infoPrueba] = read(adsPruebas);
    if size(audioPrueba,2)>1, audioPrueba = mean(audioPrueba,2); end
    if infoPrueba.SampleRate ~= fsDeseado
        audioPrueba = resample(audioPrueba, fsDeseado, infoPrueba.SampleRate);
    end

    % Extraer características
    coeffs = mfcc(audioPrueba, fsDeseado);
    featMean = mean(coeffs,1);

    % --- Paso 1: Clasificar hablante (Admin o NoAdmin) ---
    [predHablante, scoreH] = predict(modeloHablante, featMean);
    predHablante = string(predHablante);
    seguridadH = max(scoreH) * 100; % porcentaje de seguridad

    % Mostrar en consola
    fprintf("\n Hablante detectado: %s (Confianza: %.2f%%)\n", ...
        predHablante, seguridadH);

    if predHablante == "Admin" && seguridadH > 60  % umbral mínimo del 60%
        % --- Paso 2: Clasificar palabra ---
        [predPalabra, scoreP] = predict(modeloPalabra, featMean);
        predPalabra = string(predPalabra);
        seguridadP = max(scoreP) * 100;

        fprintf("Comando reconocido: '%s' (Confianza: %.2f%%)\n", ...
            predPalabra, seguridadP);

        % --- Mostrar gráficas ---
        figure;
        subplot(2,1,1);
        plot(audioPrueba);
        title(sprintf("Forma de onda - %s (%.1f%%)", predPalabra, seguridadP));
        xlabel("Muestras"); ylabel("Amplitud");

        subplot(2,1,2);
        N = length(audioPrueba);
        f = (0:N-1)*(fsDeseado/N);
        Y = abs(fft(audioPrueba));
        plot(f(1:N/2), Y(1:N/2));
        title("Espectro de Frecuencias (FFT)");
        xlabel("Frecuencia (Hz)"); ylabel("Magnitud");

    else
        fprintf("Acceso denegado. Seguridad: %.2f%%\n", seguridadH);
    end
end

disp("Fin de pruebas.");


% %% 9. Reconocimiento en tiempo real (ajustado al micrófono real)
% disp('Reconocimiento en tiempo real...');
% fs = fsDeseado;
% duracion = 2;
% recObj = audiorecorder(fs,16,1);
% 
% % --- Crear carpeta 'audios' si no existe ---
% carpetaGrabaciones = fullfile(carpetaBase, "audios");
% if ~exist(carpetaGrabaciones, "dir")
%     mkdir(carpetaGrabaciones);
% end
% 
% while true
%     disp('Presiona ENTER y habla (3 segundos)...');
%     pause;
%     recordblocking(recObj, duracion);
%     audioReal = getaudiodata(recObj);
% 
%     % --- Guardar audio grabado en carpeta 'audios' ---
%     nombreArchivo = sprintf("grabacion_%s.wav", datestr(now, "yyyymmdd_HHMMSS"));
%     rutaArchivo = fullfile(carpetaGrabaciones, nombreArchivo);
%     audiowrite(rutaArchivo, audioReal, fs);
%     fprintf("Audio guardado en: %s\n", rutaArchivo);
% 
%     % --- Normalización y centrado ---
%     audioReal = audioReal - mean(audioReal);
%     audioReal = audioReal / max(abs(audioReal) + eps);
% 
%     % --- Detección de voz (VAD manual simple) ---
%     energia = movmean(audioReal.^2, 512);
%     umbral = 0.1 * max(energia);
%     idxVoz = find(energia > umbral);
% 
%     if isempty(idxVoz)
%         disp("No se detectó voz. Intenta de nuevo.");
%         continue;
%     end
% 
%     % --- Recorte automático a la parte hablada ---
%     inicio = max(1, idxVoz(1) - 800);
%     fin = min(length(audioReal), idxVoz(end) + 800);
%     audioReal = audioReal(inicio:fin);
% 
%     % --- Suavizado ---
%     audioReal = audioReal .* hamming(length(audioReal));
% 
%     % --- Características (MFCC) ---
%     feat = mean(mfcc(audioReal, fs), 1);
% 
%     % --- Clasificación de hablante ---
%     [predHablante, scoreH] = predict(modeloHablante, feat);
%     predHablante = string(predHablante);
%     confianzaH = max(scoreH) * 100;
%     fprintf("\n Hablante: %s (%.2f%% de confianza)\n", predHablante, confianzaH);
% 
%     % --- Si es Admin, detectar comando ---
%     if predHablante == "Admin" && confianzaH > 55
%         [predPalabra, scoreP] = predict(modeloPalabra, feat);
%         predPalabra = string(predPalabra);
%         confianzaP = max(scoreP) * 100;
%         fprintf("Comando reconocido: %s (%.2f%% de confianza)\n", predPalabra, confianzaP);
% 
%         % LED Virtual
%         figure(1); clf; axis off;
%         switch lower(predPalabra)
%             case "prender"
%                 rectangle('Position',[0 0 1 1],'Curvature',[1 1],'FaceColor','y');
%                 text(0.3,0.5,'ENCENDIDO','FontSize',14,'Color','k');
%             case "apagar"
%                 rectangle('Position',[0 0 1 1],'Curvature',[1 1],'FaceColor',[0.2 0.2 0.2]);
%                 text(0.35,0.5,'APAGADO','FontSize',14,'Color','w');
%         end
% 
%     else
%         fprintf("No autorizado. (%.2f%% de confianza)\n", confianzaH);
%         figure(1); clf; axis off;
%         rectangle('Position',[0 0 1 1],'Curvature',[1 1],'FaceColor','r');
%         text(0.3,0.5,'NO ADMIN','FontSize',14,'Color','w');
%     end
% 
%     % --- Mostrar forma de onda y espectro ---
%     figure(2); clf;
%     subplot(2,1,1);
%     plot(audioReal);
%     title('Forma de onda recortada');
%     xlabel('Muestras'); ylabel('Amplitud');
% 
%     subplot(2,1,2);
%     N = length(audioReal);
%     Y = abs(fft(audioReal));
%     Y = Y(1:floor(N/2));
%     f = linspace(0, fs/2, numel(Y));
%     plot(f, Y);
%     title('Espectro de Frecuencias (FFT)');
%     xlabel('Hz'); ylabel('Magnitud');
% 
%     % --- Repetir o salir ---
%     cont = input('\n¿Deseas hacer otra prueba? (s/n): ','s');
%     if lower(cont) ~= 's'
%         disp('Fin del reconocimiento en tiempo real.');
%         break;
%     end
% end
