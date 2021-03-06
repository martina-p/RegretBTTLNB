function [winnings2x2, chosenGame, opponentChoice]=games2x2winnings(gamesdatafilename, cfg, window)

% enable all number keys depending on platform
if ismac
    enabledKeys = RestrictKeysForKbCheck([30:39, 44, 79, 80, 81,82]); % add all number keys and Space
elseif isunix
    disp('Unix');
elseif ispc
    disp('PC');
    enabledKeys = RestrictKeysForKbCheck([37,38,39,40,32,48:57]); % add all number keys and Space PC
end

gamedata = dataset('File', gamesdatafilename, 'ReadVarNames', false, 'Delimiter', ' ');
% convert ASCII file of user choices to usable dataset
load('matching_responsesDATASET');

% Select specific text font, style and size:
screenXpixels=cfg.screenSize.x;
Screen('TextFont', window, 'Courier New');
Screen('TextSize', window, cfg.fontSize);
Screen('TextStyle', window);
Screen('TextColor', window, cfg.textColor);

inputReq1 = 'Digita il numero del gioco come riportato  \n sulla lavagna e poi premi ''Invio'': '; % ITALIAN
fail1='Si prega tastere un numero di gioco \n e premi ''Invio'': '; % ITALIAN
inputReq2 = 'Digita la scelta del tuo avversario \n e premi ''Invio'': '; % ITALIAN
fail2='Si prega tastere 1 o 2 e premi ''Invio'': '; % ITALIAN

[nx, ny1, textRect1]=DrawFormattedText(window, inputReq1, 0, 0, cfg.bgColor); % draws a dummy version of text just to get measurements
[nx, ny2, textRect2]=DrawFormattedText(window, inputReq2, 0, ny1, cfg.bgColor); % draws a dummy version of text just to get measurements
textWidth1 = textRect1(3)-textRect1(1); % figures width of bounding rectangle of text
textWidth2 = textRect2(3)-textRect2(1); % figures width of bounding rectangle of text
textHeight = textRect1(4)-textRect1(2); % for positioning top text
yPos0 = textHeight * 2; % position for reporting text
xPos1 = cfg.screenCenter(1) - textWidth1/2; % sets x position half the text length back from center
xPos2 = cfg.screenCenter(1) - textWidth2/2; % sets x position half the text length back from center
yPos = cfg.screenCenter(2);
yPos2 = yPos + ny1;
Screen('Flip', window)

%% Input chosen game in PTB

% May not work on Windows 7, MS Vista or non-US keyboard mappings
% inputReq1 = 'Tasti il gioco scelto e premi ''Enter'': '; % ITALIAN
% fail1='Si prega tastere un numero di gioco e premi ''Enter'': '; % ITALIAN
% fail1='Please enter a game number.'; % ENGLISH

aOK=0; % initial value for aOK

while aOK ~= 1
    %     (~strcmp(keyName,'space'))
    
    %     Screen('DrawFormattedText', window, inputReq1, xPos1, yPos, cfg.textColor);
    %     Screen('Flip', window, 0, 1);
    %     while true
    %         char = GetChar;
    %
    %         if isempty(char)
    %             string = '';
    %             break;
    %         end
    %
    %         switch (abs(char))
    %             case 8
    %                 % backspace
    %                 if ~isempty(string)
    %                     % Redraw text string, but with textColor == bgColor, so
    %                     % that the old string gets completely erased:
    %                     oldTextColor = Screen('TextColor', window);
    %                     Screen('DrawFormattedText', window, output, xPos1, yPos, cfg.bgColor);
    %                     Screen('TextColor', window, oldTextColor);
    %
    %                     % Remove last character from string:
    %                     string = string(1:length(string)-1);
    %                 end
    %             otherwise
    %                 string = [string, char]; %#ok<AGROW>
    %         end
    %         output = [msg, ' ', string];
    %         Screen('DrawFormattedText', window, output, xPos1, yPos, cfg.textColor);
    %         Screen('Flip', window, 0, 1);
    %     end
    
    
    chosenGame = str2double(GetEchoStringForm(window, inputReq1, xPos1, yPos, cfg.textColor)); % displays string in PTB; allows backspace
    
    % potential alternative
    % number = GetNumber([deviceIndex][, untilTime=inf][, optional KbCheck arguments...])
    % Should repeat as long as while condition satisfied
    
    % chosenGame = input('Enter the randomly selected game: ') % ENGLISH
    % chosenGame = input('Tasti il gioco scelto: ') % ITALIAN
    switch isempty(chosenGame)
        case 1 %deals with both cancel and X presses
            Screen('Flip', window)
            chosenGame = str2double(GetEchoStringForm(window, fail1, xPos1, yPos, cfg.textColor)); % displays string in PTB; allows backspace
            aOK = 0;
        case 0
            if chosenGame < 1 || chosenGame > 48
                Screen('Flip', window)
%                 chosenGame = str2double(GetEchoStringForm(window, fail1, xPos1, yPos, cfg.textColor)); % displays string in PTB; allows backspace
%                 aOK = 0;
                continue
            elseif chosenGame == NaN
                Screen('Flip', window)
                %                  chosenGame = str2double(GetEchoStringForm(window, fail1, xPos1, yPos, cfg.textColor)); % displays string in PTB; allows backspace
                %                  aOK = 0;
                continue
            else
                Screen('Flip', window)
                aOK = 1;
            end
    end
    Screen('Flip', window)
    
end


%% KbWait

chosenTrial = gamedata.Var6 == chosenGame; % find the trial that contains the chosen game
matchedGame = find(matchingresponsesDATASET.column == chosenGame); % get the corresponding game from standard list
matchedTrial = gamedata.Var6 == matchedGame; % get the trial in which player did the matched game
% get the choice from the chosen game
chosenChoice = gamedata.Var5(chosenTrial);
matchedChoice = gamedata.Var5(matchedTrial);

if strcmp(chosenChoice, 'UpArrow') == 1
    numberChoice = 1;
elseif strcmp(chosenChoice, 'DownArrow') == 1
    numberChoice = 2;
else
    disp('Something bad happened with chosenChoice')
end


%% report chosen choice
% LAST TIME, SOMETHING BAD HAPPENED WITH CHOSENCHOICE, SO NUMBER CHOICE
% NEVER PRODUCED

% get the choice from the matched game
% these numbers are flipped because of how the grids match up
if strcmp(matchedChoice, 'UpArrow') == 1
    numberMatch = 2; %
elseif strcmp(matchedChoice, 'DownArrow') == 1
    numberMatch = 1;
else
    disp('Something bad happened with matchedChoice')
end

% report matched choice
% disp(numberMatch)

thisChoiceTex = ['Comunica allo sperimentatore che la tua scelta e'' ', num2str(numberMatch), '.'];

thisChoice = DrawFormattedText(window, thisChoiceTex, 'center', yPos0, cfg.instColA); % Draw betting instructions

%% Input opponent choice
% opponentChoice = input('Enter your selected opponent''s choice and press ''Enter'': ') % ENGLISH
% inputReq2 = 'Tasti la scelta del tuo avversario e premi ''Enter'': '; % ITALIAN
% fail2='Si prega tastere 1 o 2 e premi ''Enter'': '; % ITALIAN

aOK=0; % initial value for aOK

while aOK ~= 1
    opponentChoice = str2double(GetEchoStringForm(window, inputReq2, xPos2, yPos2, cfg.textColor)); % displays string in PTB; allows backspace
    
    % disp({'Enter your selected opponent''s choice.'}, {'And then tell them your reported choice.'})
    % disp({'Tasti la scelta del tuo avversario.'},{'E poi, dica al avversario il tuo scelto.'})
    % % enter opponent's choice for chosen game
    % opponentChoice = user_input;
    
    switch isempty(opponentChoice)
        case 1 %deals with both cancel and X presses
            Screen('Flip', window)
            %             thisChoice; % does it repeat the display? If not, paste that Tex command here
            %             opponentChoice = str2double(GetEchoStringForm(window, fail2, xPos2, yPos2, cfg.textColor)); % displays string in PTB; allows backspace
            aOK = 0;
            continue
        case 0
            if (opponentChoice == 1 || opponentChoice == 2)
                Screen('Flip', window)
                thisChoice; % does it repeat the display? If not, paste that Tex command here
                aOK = 1;
                %             if opponentChoice ~= (1 || 2)
                %                 aOK = 0;
                %                 Screen('Flip', window)
                %                 thisChoice; % does it repeat the display? If not, paste that Tex command here
                %                 opponentChoice = str2double(GetEchoStringForm(window, fail2, xPos2, yPos2, cfg.textColor)); % displays string in PTB; allows backspace
                %             elseif isnan(opponentChoice)
                %                 aOK = 0;
                %                 Screen('Flip', window)
                %                 thisChoice; % does it repeat the display? If not, paste that Tex command here
                %                 opponentChoice = str2double(GetEchoStringForm(window, fail2, xPos2, yPos2, cfg.textColor)); % displays string in PTB; allows backspace
            else
                Screen('Flip', window)
                %                 thisChoice; % does it repeat the display? If not, paste that Tex command here
                %                 opponentChoice = str2double(GetEchoStringForm(window, fail2, xPos2, yPos2, cfg.textColor)); % displays string in PTB; allows backspace
                aOK = 0;
                continue
            end
            
    end
    
   Screen('Flip', window)
    
end

% pairedOutcome = ['r_c' num2str(numberChoice) num2str(opponentChoice)];
% matchingresponsesDATASET.pairedOutcome(chosenTrial)

% compute result based on player's choice and opponent's choise
switch numberChoice
    case 1
        if opponentChoice == 1
            winnings2x2 = matchingresponsesDATASET.r_c11(chosenGame);
        else
            winnings2x2 = matchingresponsesDATASET.r_c12(chosenGame);
        end
    case 2
        if opponentChoice == 1
            winnings2x2 = matchingresponsesDATASET.r_c21(chosenGame);
        else
            winnings2x2 = matchingresponsesDATASET.r_c22(chosenGame);
        end
end


%% report result (payout)
% payout2x2 = ['You won ' num2str(winnings2x2) '.']; %ENGLISH
payout2x2 = ['Hai vinto ' num2str(winnings2x2) '.']; %ITALIAN

DrawFormattedText(window, payout2x2, 'center', 'center'); % Result text

Screen('Flip', window)

WaitSecs(4);

% gamedata.3(chosenGame) = my_choiceVar6
%
% disp(my_choice)
%
% game.4(chosenGame) = matchedGame
%
% game.matchedGame(chosenGame) = winnings2x2



end


