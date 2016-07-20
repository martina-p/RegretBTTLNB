 % Clear the workspace and the screen
% sca;
% close all;
clearvars -except particNum DateTime screens screenNumber window windowRect prop* tex* arrow* enabledKeys;  

% load('regretTasktrialWheels1shot.mat')       % Load the preset wheel probabilites and values TABLE
load('regretTasktrialWheels1shotDataset.mat')       % Load the preset wheel probabilites and values DATASET
regretTasktrialWheels1shot = regretTasktrialWheels1shotDataset; % Needed to equate variable to different filename
% DateTime=datestr(now,'ddmm-HHMM');      % Get date and time for log file



%% Here we call some default settings for setting up Psychtoolbox

% Define black and white and other colors
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
BG=[1 1 1]; % set background color of PNG imports
% NOTE that colors now have to be in the set [0,1], so to get values, just 
% divide old RGB amounts by 255
winColors = [.1333, .5451, .1333]; %ForestGreen
loseColors = [.8039, .2157, 0]; %OrangeRed3
% winColors = black; %black
% loseColors = black; %black
chooseColors = [1, .84, 0]; %Gold

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);
screenCenter = [xCenter, yCenter]; % center coordinatesf


%% Set position info
wheelRadius = (screenXpixels*.13);

% Set positions of graphical elements
leftWheelpos = [screenXpixels*.25-wheelRadius screenYpixels*.5-wheelRadius screenXpixels*.25+wheelRadius screenYpixels*.5+wheelRadius];
rightWheelpos = [screenXpixels*.75-wheelRadius screenYpixels*.5-wheelRadius screenXpixels*.75+wheelRadius screenYpixels*.5+wheelRadius];
leftArrowpos = [screenXpixels*.25-wheelRadius*.25 screenYpixels*.5-wheelRadius*.75 screenXpixels*.25+wheelRadius*.25 screenYpixels*.5+wheelRadius*.75];
rightArrowpos = [screenXpixels*.75-wheelRadius*.25 screenYpixels*.5-wheelRadius*.75 screenXpixels*.75+wheelRadius*.25 screenYpixels*.5+wheelRadius*.75];

% Select specific text font, style and size:
fontSize = round(screenYpixels * 2/60);
    Screen('TextFont', window, 'Courier New');
    Screen('TextSize', window, fontSize);
    Screen('TextStyle', window);
    Screen('TextColor', window, [0, 0, 0]);

    % Set positions of text elements
topTextYpos = screenYpixels * 2/40; % Screen Y positions of top/instruction text
botTextYpos = screenYpixels * 35/40; % Screen Y positions of bottom/result text
leftwheelLeftEuroXpos = screenXpixels*.035;
leftwheelRightEuroXpos = screenXpixels*.40;
rightwheelLeftEuroXpos = screenXpixels*.52;
rightwheelRightEuroXpos = screenXpixels*.91;
leftwheelLeftTextYpos = screenYpixels*.38;
leftwheelRightTextYpos = screenYpixels*.43;
rightwheelLeftTextYpos = screenYpixels*.38;
rightwheelRightTextYpos = screenYpixels*.43;
% old positioning (now done using nx output of DrawFormattedText
% leftwheelLeftTextXpos = screenXpixels*.035;
% leftwheelRightTextXpos = screenXpixels*.40;
% rightwheelLeftTextXpos = screenXpixels*.52;
% rightwheelRightTextXpos = screenXpixels*.91;
% leftwheelLeftEuroXpos = screenXpixels*.035 - fontSize*.7;
% leftwheelRightEuroXpos = screenXpixels*.40 - fontSize*.7;
% rightwheelLeftEuroXpos = screenXpixels*.52 - fontSize*.7;
% rightwheelRightEuroXpos = screenXpixels*.91 - fontSize*.7;
[leftwheelLeftTextXpos, yPos, textRect] = DrawFormattedText(window, hex2dec('20ac'), leftwheelLeftEuroXpos, leftwheelRightTextYpos, white); % euro symbol
[leftwheelRightTextXpos, yPos] = DrawFormattedText(window, '-', leftwheelRightEuroXpos, leftwheelLeftTextYpos, white); % euro symbol
[rightwheelLeftTextXpos, yPos] = DrawFormattedText(window, hex2dec('20ac'), rightwheelLeftEuroXpos, rightwheelRightTextYpos, white); % euro symbol
[rightwheelRightTextXpos, yPos] = DrawFormattedText(window, '-', rightwheelRightEuroXpos, rightwheelLeftTextYpos, white); % euro symbol
textHalfHeight=(textRect(2)-textRect(4))/2;
rightText = rightwheelRightTextYpos - textHalfHeight;

% Rect positions/dimensions based on wheel positions/dimensions
rectWidth = screenXpixels*.3; % based on wheelRadius = (screenXpixels*.13);
rectHeight = screenYpixels*.45;
baseRect = [0 0 rectWidth rectHeight];
rectYpos = screenYpixels*.5;
leftRectXpos = screenXpixels*.25;
rightRectXpos = screenXpixels*.75;
leftRect = CenterRectOnPointd(baseRect, leftRectXpos, rectYpos);
rightRect = CenterRectOnPointd(baseRect, rightRectXpos, rectYpos);
lineWeight = round(screenYpixels*.01);

% temporary; will be modified to make these vary depending on choice
% Not sure anymore that this is needed
locChoice = leftWheelpos;  
locNonChoice = rightWheelpos; 
arrowChoice = leftArrowpos;
arrowNonChoice = rightArrowpos;

% Display text
topInstructText = ['Choose which wheel to play.'];
    
% Set some variables
NUMROUNDS = 1;

% Determines type of outcome - reversed so that even numbers represented by
% "2" condition

particPosition=str2num(particNum); % turn particNum into a position number usable in determining if even or odd

if mod(particPosition,2) == 0
  condition = 2; %Even numbers: satisfaction & relief
else
  condition = 1; %Odd numbers: regret & disappointment
end

% Generate random percentages in a uniform distribution within certain desired range on the interval [a, b] with r = a + (b-a).*rand(100,1).

switch condition % could probably tidy this up so it gets selected for down below in the same if statement as the selection (maybe a big switch involving 2 factors or set conditions at beginning)
    case 1    % make it so selection loses, other wins (arrow has to make it past losing portion to win)
        wlp2r1 = .60 + (.85-.60).*rand(1); % randomized range .60-.85 for losing arrow
        wrp2r1 = 1.1 + (1.3-1.1).*rand(1); % randomized range 1.1-1.3 for winning arrow
        wlp2r2 = 1.1 + (1.3-1.1).*rand(1); % randomized range 1.1-1.3 for winning arrow
        wrp2r2 = .60 + (.85-.60).*rand(1); % randomized range .60-.85 for losing arrow
        % Generate pseudo-random outcomes with determined win/loss results
        lotteryOutcome1shot = [wlp2r1*regretTasktrialWheels1shot.wlp2 wrp2r1*regretTasktrialWheels1shot.wrp2; ...
            wlp2r2*regretTasktrialWheels1shot.wlp2 wrp2r2*regretTasktrialWheels1shot.wrp2]; % Creates array of outcomes for both wheels for either left choice (:,1) or right choice (:,2)

    case 2    % make it so selection wins, other loses (arrow has to make it past losing portion to win)
        wlp2r1 = 1.1 + (1.3-1.1).*rand(1); % randomized range 1.1-1.3 for winning arrow
        wrp2r1 = .60 + (.85-.60).*rand(1); % randomized range .60-.85 for losing arrow
        wlp2r2 = .60 + (.85-.60).*rand(1); % randomized range .60-.85 for losing arrow
        wrp2r2 = 1.1 + (1.3-1.1).*rand(1); % randomized range 1.1-1.3 for winning arrow
        % Generate pseudo-random outcomes with determined win/loss results
        lotteryOutcome1shot = [wlp2r1*regretTasktrialWheels1shot.wlp2 wrp2r1*regretTasktrialWheels1shot.wrp2; ...
            wlp2r2*regretTasktrialWheels1shot.wlp2 wrp2r2*regretTasktrialWheels1shot.wrp2]; % Creates array of outcomes for both wheels for either left choice (:,1) or right choice (:,2)

end



%% back to original
% Maximum priority level
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% We will set the rotations angles to increase by 1 degree on every frame
degPerFrame = 10;

arrow=imread(fullfile('arrow.png'), 'BackgroundColor',BG); %load image of arrow
texArrow = Screen('MakeTexture', window, arrow); % Draw arrow to the offscreen window
prop25=imread(fullfile('propCircle25-75.png'), 'BackgroundColor',BG); %load image of circle
prop33=imread(fullfile('propCircle33-66.png'), 'BackgroundColor',BG ); %load image of circle
prop50=imread(fullfile('propCircle50-50.png'), 'BackgroundColor',BG); %load image of circle
prop66=imread(fullfile('propCircle66-33.png'), 'BackgroundColor',BG); %load image of circle
prop75=imread(fullfile('propCircle75-25.png'), 'BackgroundColor',BG); %load image of circle
texProb25 = Screen('MakeTexture', window, prop25); % Draw circle to the offscreen window
texProb33 = Screen('MakeTexture', window, prop33); % Draw circle to the offscreen window
texProb50 = Screen('MakeTexture', window, prop50); % Draw circle to the offscreen window
texProb66 = Screen('MakeTexture', window, prop66); % Draw circle to the offscreen window
texProb75 = Screen('MakeTexture', window, prop75); % Draw circle to the offscreen window

% Sync us and get a time stamp
vbl = Screen('Flip', window);
waitframes = 1;

%% Screen 0 - Instructions
% Instruct text positions
instruct1TextYpos = screenYpixels * 2/42; 
instruct2TextYpos = screenYpixels * 4/42; 
instruct3TextYpos = screenYpixels * 6/42; 
instruct4TextYpos = screenYpixels * 8/42; 
instruct5TextYpos = screenYpixels * 10/42; 
instruct6TextYpos = screenYpixels * 12/42; 
instruct7TextYpos = screenYpixels * 14/42; 
instruct8TextYpos = screenYpixels * 16/42; 
instruct9TextYpos = screenYpixels * 18/42; 
instruct10TextYpos = screenYpixels * 20/42; 
instruct11TextYpos = screenYpixels * 22/42; 
instruct12TextYpos = screenYpixels * 24/42; 
instruct13TextYpos = screenYpixels * 26/42; 
instruct14TextYpos = screenYpixels * 28/42; 
instruct15TextYpos = screenYpixels * 30/42; 
instruct16TextYpos = screenYpixels * 32/42; 
instruct17TextYpos = screenYpixels * 34/42; 
instruct18TextYpos = screenYpixels * 36/42; 
instruct19TextYpos = screenYpixels * 38/42; 
instructbotTextYpos = screenYpixels * 40/42; 

% Instruction text
instructText0 = ['Please wait to be told to continue.'];

instructText11 = ['Now you will play the important'];
instructText12 = ['lottery wheel game.'];
instructText13 = ['You will spin one wheel, and the outcome'];
instructText14 = ['of this game alone can change your winnings.'];
% instructText15 = [''];
instructText16 = ['As before, choose which wheel to play'];
instructText17 = ['by pressing the left arrow key or the'];
instructText18 = ['right arrow key.'];
% instructText19 = [''];

% Instruction text colors
instructCola = [0, 0.4078, 0.5451]; %DeepSkyBlue4
instructColb = [0.8039, 0.5843, 0.0471]; %DarkGoldenRod3

keyName=''; % empty initial value

% RestrictKeysForKbCheck([37,39,32,49]); % limit recognized presses to left and right arrows PC
% RestrictKeysForKbCheck([30, 44, 79, 80]); % limit recognized presses to 1!, space, left and right arrows MAC

while(~strcmp(keyName,'1!')) % continues until the 1 button is pressed
    
    DrawFormattedText(window, instructText11, 'center', instruct2TextYpos, instructCola); % Draw betting instructions
    DrawFormattedText(window, instructText12, 'center', instruct3TextYpos, instructCola); % Draw betting instructions
    DrawFormattedText(window, instructText13, 'center', instruct4TextYpos, instructCola); % Draw betting instructions
    DrawFormattedText(window, instructText14, 'center', instruct5TextYpos, instructCola); % Draw betting instructions
%     DrawFormattedText(window, instructText15, 'center', instruct5TextYpos, instructCola); % Draw betting instructions
    DrawFormattedText(window, instructText16, 'center', instruct8TextYpos, instructColb); % Draw betting instructions
    DrawFormattedText(window, instructText17, 'center', instruct9TextYpos, instructColb); % Draw betting instructions
    DrawFormattedText(window, instructText18, 'center', instruct10TextYpos, instructColb); % Draw betting instructions
%     DrawFormattedText(window, instructText29, 'center', instruct19TextYpos, instructCola); % Draw betting instructions
    DrawFormattedText(window, instructText0, 'center', instruct19TextYpos, black); % Draw betting instructions
    Screen('Flip', window); % Flip to the screen

    [keyTime, keyCode]=KbWait([],2);
    keyName=KbName(keyCode);

end

WaitSecs(.25);


%% Begin trial loop

for i=1:NUMROUNDS

%% Screen 1

keyName=''; % empty initial value

% Screen('TextFont', window, 'Arial');
% Set win/lose values based on trial round
winL = [num2str(regretTasktrialWheels1shot.wlv1(i))];
loseL = [num2str(abs(regretTasktrialWheels1shot.wlv2(i)))];
winR = [num2str(regretTasktrialWheels1shot.wrv1(i))];
loseR = [num2str(abs(regretTasktrialWheels1shot.wrv2(i)))];
% Screen('TextFont', window, 'Courier New');

wheelL = [];
wheelR = [];

probL = num2str(regretTasktrialWheels1shot.wlp1(i));
probR = num2str(regretTasktrialWheels1shot.wrp1(i));

switch probL
    case {'0.25'}
    wheelL=texProb25;
    case {'0.33'}
    wheelL=texProb3';
    case {'0.5'}
    wheelL=texProb50;
    case {'0.66'}
    wheelL=texProb66;
    case {'0.75'}
    wheelL=texProb75;
end

  
switch probR
    case {'0.25'}
    wheelR=texProb25;
    case {'0.33'}
    wheelR=texProb33;
    case {'0.5'}
    wheelR=texProb50;
    case {'0.66'}
    wheelR=texProb66;
    case {'0.75'}
    wheelR=texProb75;
end      
        
% wheelL = texProb66
% wheelR = texProb50 

% I think the simplest workaround is to print the ? symbol in a separate string and print it next to the amount string.
% The string with the ? symbol should look something like this:
%        DrawFormattedText(window,hex2dec('20ac'),'center',500,winColors);
% 
% where hex2dec('20ac') of course is a way of writing the ?
% and you "just" need to adjust the 'center' and 500 and green to the needed x, y, and colour
% 
    angChoice=0;
    angNonChoice=0;
    
    DrawFormattedText(window, topInstructText, 'center', topTextYpos, black); % Instruction text
   
    % Show lottery choices
    Screen('DrawTexture', window, wheelL, [0 0 550 550], locChoice); % Draw probability circle
    Screen('DrawTexture', window, texArrow, [0 0 96 960], arrowChoice, angChoice);
    [leftwheelLeftTextXpos, yPos, textRect] = DrawFormattedText(window, hex2dec('20ac'), leftwheelLeftEuroXpos, leftwheelLeftTextYpos, winColors); % euro symbol
    DrawFormattedText(window, winL, leftwheelLeftTextXpos, leftwheelLeftTextYpos, winColors); % win amount 
    [leftwheelRightTextXpos, yPos] = DrawFormattedText(window, '- ', leftwheelRightEuroXpos, rightText, loseColors); % euro symbol
    [leftwheelRightTextXpos, yPos] = DrawFormattedText(window, hex2dec('20ac'), leftwheelRightTextXpos, leftwheelRightTextYpos, loseColors); % euro symbol
    DrawFormattedText(window, loseL, leftwheelRightTextXpos, leftwheelRightTextYpos, loseColors); % loss amount
    % non-choice wheel & arrow
     
    Screen('DrawTexture', window, wheelR, [0 0 550 550], locNonChoice); % Draw probability circle
    Screen('DrawTexture', window, texArrow, [0 0 96 960], arrowNonChoice, angNonChoice);
    [rightwheelLeftTextXpos, yPos] = DrawFormattedText(window, hex2dec('20ac'), rightwheelLeftEuroXpos, rightwheelLeftTextYpos, winColors); % euro symbol
    DrawFormattedText(window, winR, rightwheelLeftTextXpos, rightwheelLeftTextYpos, winColors); % win amount
    [rightwheelRightTextXpos, yPos] = DrawFormattedText(window, '- ', rightwheelRightEuroXpos, rightText, loseColors); % euro symbol
    [rightwheelRightTextXpos, yPos] = DrawFormattedText(window, hex2dec('20ac'), rightwheelRightTextXpos,rightwheelRightTextYpos, loseColors); % euro symbol
    DrawFormattedText(window, loseR, rightwheelRightTextXpos, rightwheelRightTextYpos, loseColors); % loss amount
    Screen('Flip', window)
 
wofTrialStartTime(i) = GetSecs; % trial time start

% RestrictKeysForKbCheck([79, 80]); % limit recognized presses to left and right arrows MAC
% RestrictKeysForKbCheck([37,39]); % limit recognized presses to left and right arrows PC
[keyTime, keyCode]=KbWait([],2); % Wait for a key to be pushed and released
keyName=KbName(keyCode); % get the name of which key was pressed

    if strcmp(keyName,'LeftArrow') % If left arrow pressed, set the rectangle to the left side
        rectPos = leftRect;
        wof1shotChoice(i) = 1;   % and note the choice for the log file
    elseif strcmp(keyName,'RightArrow')
        rectPos = rightRect;
        wof1shotChoice(i) = 2;
    end
    
wofTrialEndTime(i) = GetSecs; % trial time end

% RestrictKeysForKbCheck([]); % re-recognize all key presses

%% show choice rect over wheels
    Screen('DrawTexture', window, wheelL, [0 0 550 550], locChoice); % Draw probability circle
    Screen('DrawTexture', window, texArrow, [0 0 96 960], arrowChoice, angChoice);
    [leftwheelLeftTextXpos, yPos] = DrawFormattedText(window, hex2dec('20ac'), leftwheelLeftEuroXpos, leftwheelLeftTextYpos, winColors); % euro symbol
    DrawFormattedText(window, winL, leftwheelLeftTextXpos, leftwheelLeftTextYpos, winColors); % win amount 
    [leftwheelRightTextXpos, yPos] = DrawFormattedText(window, '- ', leftwheelRightEuroXpos, rightText, loseColors); % euro symbol
    [leftwheelRightTextXpos, yPos] = DrawFormattedText(window, hex2dec('20ac'), leftwheelRightEuroXpos, leftwheelRightTextYpos, loseColors); % euro symbol
    DrawFormattedText(window, loseL, leftwheelRightTextXpos, leftwheelRightTextYpos, loseColors); % loss amount
    % non-choice wheel & arrow
    
    Screen('DrawTexture', window, wheelR, [0 0 550 550], locNonChoice); % Draw probability circle
    Screen('DrawTexture', window, texArrow, [0 0 96 960], arrowNonChoice, angNonChoice);
    [rightwheelLeftTextXpos, yPos] = DrawFormattedText(window, hex2dec('20ac'), rightwheelLeftEuroXpos, rightwheelLeftTextYpos, winColors); % euro symbol
    DrawFormattedText(window, winR, rightwheelLeftTextXpos, leftwheelLeftTextYpos, winColors); % win amount
    [rightwheelRightTextXpos, yPos] = DrawFormattedText(window, '- ', rightwheelRightEuroXpos, rightText, loseColors); % euro symbol
    [rightwheelRightTextXpos, yPos] = DrawFormattedText(window, hex2dec('20ac'), rightwheelRightEuroXpos, rightwheelRightTextYpos, loseColors); % euro symbol
    DrawFormattedText(window, loseR, rightwheelRightTextXpos, leftwheelRightTextYpos, loseColors); % loss amount
        Screen('FrameRect', window, chooseColors, rectPos, lineWeight); % Draw the choice rect to the screen
        Screen('Flip', window)
    
 WaitSecs(1);   

%% Determine results and log
 
% Determine whether the selection resulted in win or loss
if wof1shotChoice(i) == 1    % Participant chose wheel 1
    j=1;
% Set positions for each wheel type
arrowAngleL=360*lotteryOutcome1shot(j,1); % reflects final position of arrow
arrowAngleR=360*lotteryOutcome1shot(j,2);
    
    if arrowAngleL > 360*regretTasktrialWheels1shot.wlp2(i);   % If endpoint of arrow is greater than loss zone, win
    winAmount(i) = regretTasktrialWheels1shot.wlv1(i);
    wof1shotEarnings(i) = winAmount(i);  % set earngings for log file
    botResultText = ['Hai vinto ' num2str(winAmount(i)) ' euro.'];  % Set feedback text to winning message
    botTextColor = winColors;
    else   % If endpoint of arrow is less than loss zone, loss
    lossAmount(i) = regretTasktrialWheels1shot.wlv2(i);
    wof1shotEarnings(i) = lossAmount(i);  % set losses for log file
    botResultText = ['Hai perso ' num2str(-lossAmount(i)) ' euro.'];  % Set feedback text to losing message
    botTextColor = loseColors;
    end

elseif wof1shotChoice(i) == 2    % Participant chose wheel 2
    j=2;
% Set positions for each wheel type
arrowAngleL=360*lotteryOutcome1shot(j,1); % reflects final position of arrow
arrowAngleR=360*lotteryOutcome1shot(j,2);

    if arrowAngleR > 360*regretTasktrialWheels1shot.wrp2(i);   % If endpoint of arrow is greater than loss zone, win
    winAmount(i) = regretTasktrialWheels1shot.wrv1(i);
    wof1shotEarnings(i) = winAmount(i);  % set earngings for log file
    botResultText = ['Hai vinto ' num2str(winAmount(i)) ' euro.'];  % Set feedback text to winning message
    botTextColor = winColors;
    else   % If endpoint of arrow is less than loss zone, loss
    lossAmount(i) = regretTasktrialWheels1shot.wrv2(i);
    wof1shotEarnings(i) = lossAmount(i);  % set losses for log file
    botResultText = ['Hai perso ' num2str(-lossAmount(i)) ' euro.'];  % Set feedback text to losing message
    botTextColor = loseColors;
    end

end
%% Screen 3 - Animation loop

%     lotteryOutcome = 0.33;      %%!! this is the outcome of the lottery's probability roll, a number between 0 and 1
    time.start = GetSecs;
    angChoice=0;
    angNonChoice=0;
%  && angNonChoice < (4*360 + 360*lotteryOutcome(i,2))
while( (angChoice < (4*360 + 360*lotteryOutcome1shot(j,1))) || (angNonChoice < (4*360 + 360*lotteryOutcome1shot(j,2))) ) %% 4*360 means the arrow will spin 4 full rounds before stopping at the outcome
    if(angChoice < (4*360 + 360*lotteryOutcome1shot(j,1)))
        angChoice=angChoice+degPerFrame;
    end
    if(angNonChoice < (4*360 + 360*lotteryOutcome1shot(j,2)))
        angNonChoice=angNonChoice+degPerFrame;
    end
% Left wheel & arrow
    Screen('DrawTexture', window, wheelL, [0 0 550 550], locChoice); % Draw probability circle
    Screen('DrawTexture', window, texArrow, [0 0 96 960], arrowChoice, angChoice);
    [leftwheelLeftTextXpos, yPos] = DrawFormattedText(window, hex2dec('20ac'), leftwheelLeftEuroXpos, leftwheelLeftTextYpos, winColors); % euro symbol
    DrawFormattedText(window, winL, leftwheelLeftTextXpos, leftwheelLeftTextYpos, winColors); % win amount 
    [leftwheelRightTextXpos, yPos] = DrawFormattedText(window, '- ', leftwheelRightEuroXpos, rightText, loseColors); % euro symbol
    [leftwheelRightTextXpos, yPos] = DrawFormattedText(window, hex2dec('20ac'), leftwheelRightEuroXpos, leftwheelRightTextYpos, loseColors); % euro symbol
    DrawFormattedText(window, loseL, leftwheelRightTextXpos, leftwheelRightTextYpos, loseColors); % loss amount

% Right wheel & arrow    
    Screen('DrawTexture', window, wheelR, [0 0 550 550], locNonChoice); % Draw probability circle
    Screen('DrawTexture', window, texArrow, [0 0 96 960], arrowNonChoice, angNonChoice);
    [rightwheelLeftTextXpos, yPos] = DrawFormattedText(window, hex2dec('20ac'), rightwheelLeftEuroXpos, rightwheelLeftTextYpos, winColors); % euro symbol
    DrawFormattedText(window, winR, rightwheelLeftTextXpos, leftwheelLeftTextYpos, winColors); % win amount
    [rightwheelRightTextXpos, yPos] = DrawFormattedText(window, '- ', rightwheelRightEuroXpos, rightText, loseColors); % euro symbol
    [rightwheelRightTextXpos, yPos] = DrawFormattedText(window, hex2dec('20ac'), rightwheelRightEuroXpos, rightwheelRightTextYpos, loseColors); % euro symbol
    DrawFormattedText(window, loseR, rightwheelRightTextXpos, leftwheelRightTextYpos, loseColors); % loss amount
        Screen('FrameRect', window, chooseColors, rectPos, lineWeight); % Draw the choice rect to the screen
        vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
end

%% Screen 4 - Result

% Hold on last arrow position and give result text
    angLeftArrow=(4*360 + 360*lotteryOutcome1shot(j,1)); % final left arrow position
    angRightArrow=(4*360 + 360*lotteryOutcome1shot(j,2)); % final right arrow position
% Left wheel & arrow
    Screen('DrawTexture', window, wheelL, [0 0 550 550], locChoice); % Draw probability circle
    Screen('DrawTexture', window, texArrow, [0 0 96 960], arrowChoice, angLeftArrow);
    [leftwheelLeftTextXpos, yPos] = DrawFormattedText(window, hex2dec('20ac'), leftwheelLeftEuroXpos, leftwheelLeftTextYpos, winColors); % euro symbol
    DrawFormattedText(window, winL, leftwheelLeftTextXpos, leftwheelLeftTextYpos, winColors); % win amount 
    [leftwheelRightTextXpos, yPos] = DrawFormattedText(window, '- ', leftwheelRightEuroXpos, rightText, loseColors); % euro symbol
    [leftwheelRightTextXpos, yPos] = DrawFormattedText(window, hex2dec('20ac'), leftwheelRightEuroXpos, leftwheelRightTextYpos, loseColors); % euro symbol
    DrawFormattedText(window, loseL, leftwheelRightTextXpos, leftwheelRightTextYpos, loseColors); % loss amount
% Right wheel & arrow        
    Screen('DrawTexture', window, wheelR, [0 0 550 550], locNonChoice); % Draw probability circle
    Screen('DrawTexture', window, texArrow, [0 0 96 960], arrowNonChoice, angRightArrow);
    [rightwheelLeftTextXpos, yPos] = DrawFormattedText(window, hex2dec('20ac'), rightwheelLeftEuroXpos, rightwheelLeftTextYpos, winColors); % euro symbol
    DrawFormattedText(window, winR, rightwheelLeftTextXpos, leftwheelLeftTextYpos, winColors); % win amount
    [rightwheelRightTextXpos, yPos] = DrawFormattedText(window, '- ', rightwheelRightEuroXpos, rightText, loseColors); % euro symbol
    [rightwheelRightTextXpos, yPos] = DrawFormattedText(window, hex2dec('20ac'), rightwheelRightEuroXpos, rightwheelRightTextYpos, loseColors); % euro symbol
    DrawFormattedText(window, loseR, rightwheelRightTextXpos, leftwheelRightTextYpos, loseColors); % loss amount
        Screen('FrameRect', window, chooseColors, rectPos, lineWeight); % Draw the choice rect to the screen
        DrawFormattedText(window, botResultText, 'center', botTextYpos, botTextColor); % Result text
    Screen('Flip', window)

WaitSecs(5); 
%% Screen 5 - Emotional rating

currentRound = i;

[currRatingSelection, wof1shotRatingDuration] = likert_slider(window, windowRect, enabledKeys);
 
wof1shotemotionalRating = currRatingSelection;

end
%% End-of-block calculations and create log file
for i=1:NUMROUNDS
        wof1shotChoiceDuration(i) = wofTrialEndTime(i)-wofTrialStartTime(i);
end

totalEarnings = sum(wof1shotEarnings);

% Write logfile
save([num2str(particNum) '-' DateTime '_2oneshot-subj'], 'regretTasktrialWheels1shotDataset', 'wof1shotChoice', 'wof1shotEarnings', 'wof1shotChoiceDuration', 'wof1shotemotionalRating', 'wof1shotRatingDuration');

%% Screen 6 - Wait screen
message = 'Si prega di attendere un attimo.';
DrawFormattedText(window, message, 'center', 'center', instructCola); % Draw wait message
Screen('Flip', window);

WaitSecs(10);

% RestrictKeysForKbCheck([]); % re-recognize all key presses
    
% Clear the screen
% sca;