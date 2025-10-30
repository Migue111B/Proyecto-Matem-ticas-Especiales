recObj = audiorecorder(16000, 16, 1); % fs=16000 Hz, 16 bits, mono

disp('Empieza a grabar...');
recordblocking(recObj, 2); % graba 2 segundos
disp('Grabación terminada.');

audioData = getaudiodata(recObj);

% Guardar en archivo .wav
audiowrite('audio/pruebas/prueba3.wav', audioData, 16000);
