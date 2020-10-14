% Problems:
%     Find out what x does


Fs       = 44100;       % Sampling Freq (44.1K is chosen to cover the entire human hearing range)
A        = 110;         % The A string of a guitar is normally tuned to 110 Hz
Eoffset  = -5;          % Change in freq wrt A 
Doffset  = 5;
Goffset  = 10;
Boffset  = 14;
E2offset = 19;
F = linspace(1/Fs, 1000, 2^12); % Creating vector for sampling 
x = zeros(Fs*4, 1);             % Generate 4 seconds of zeros to be used to generate the guitar notes
fret = [0 0 2 2 2 0;    % A_Major
        0 3 2 0 1 0;    % C_Major
        0 0 0 2 3 2;    % D_Major
        0 2 2 1 0 0;    % E_Major
        0 0 3 2 1 1;    % F_Major
        3 2 0 0 0 3];   % G_Major
    
while true
    i = input('Enter a chord to play(1-6) (Enter 0 to exit): '); 
    if(i == 0)
        break
    end
    
%     Initalise the delays for each note based on the frets and the string offsets.
    delay = [round(Fs/(A*2^((fret(i,1)+Eoffset)/12))),
    round(Fs/(A*2^(fret(i,2)/12))),
    round(Fs/(A*2^((fret(i,3)+Doffset)/12))), 
    round(Fs/(A*2^((fret(i,4)+Goffset)/12))), 
    round(Fs/(A*2^((fret(i,5)+Boffset)/12))), 
    round(Fs/(A*2^((fret(i,6)+E2offset)/12)))];

    b = cell(length(delay),1);              %Creates a NxM array of "double size" 
    a = cell(length(delay),1);
    H = zeros(length(delay),4096);          %Creates a NxM array of zeros
    note = zeros(length(x),length(delay));
    
    for indx = 1:length(delay)
     % Build a cell array of numerator and denominator coefficients.
        b{indx} = firls(42, [0 1/delay(indx) 2/delay(indx) 1], [0 0 1 1]).'; % Approximate string harmonics
        a{indx} = [1 zeros(1, delay(indx)) -0.5 -0.5].';    % FIND IT OUTTTT (it is somthing related to Frequency Domain Shaping)

     % Populate the states with random numbers and filter the input zeros.
     zi = rand(max(length(b{indx}),length(a{indx}))-1,1);

     %Create a 4 second note.
     note(:, indx) = filter(b{indx}, a{indx}, x, zi); 

    % Make sure that each note is centered on zero.
     note(:, indx) = note(:, indx)-mean(note(:, indx));

%      [H(indx,:),W] = freqz(b{indx}, a{indx}, F, Fs);
    end
    
    combinedNote = sum(note,2);
    combinedNote = combinedNote/max(abs(combinedNote));
    subplot(1,2,1)
    plot(combinedNote)
    set(gca, 'FontName','Lexend Deca','FontSize', 13, 'FontWeight', 'bold');
    title("Abcd");
    subplot(1,2,2)
    set(gca, 'FontName','Lexend Deca','FontSize', 13, 'FontWeight', 'bold');
    stem(combinedNote)
    title("Efgh");
    hplayer = audioplayer(combinedNote, Fs); 
    play(hplayer)
    pause(0.5)
end