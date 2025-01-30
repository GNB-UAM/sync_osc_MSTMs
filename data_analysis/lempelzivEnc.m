function [output outCodeBook NumRep NumRepBin]=lempelzivEnc(Inputdata,codeBook)
    % disp('Start of Lempel-Ziv encoder');
    buffer='';
    output='';
    searchIndex = 0;
    codeBookLength = [];
    for i=1:length(codeBook)
        codeBookLength(i) = length(codeBook{i});
    end
%     str = sprintf('Total input length is %d',length(Inputdata));
%     disp(str);
    prevPos = -1;
    for i=1:length(Inputdata),
        c = Inputdata(i);
        searchIndex = 0;
%         if mod(i,10240) == 0
%             time1 = clock;
%             str = sprintf('%s - Completed length is %d KBit',datestr(now),i/1024);
%             disp(str);
%         end
        % =================
        %codeWord = strcat(buffer,c);
        codeWord = [buffer c];
        codeLength = length(codeWord);
        for j=1:length(codeBook),
            if codeBookLength(j) == codeLength
                if codeBook{j} == (codeWord)
                   searchIndex = j; 
                   break;
                end
            end
        end
        % =================
        if searchIndex~= 0
            buffer = codeWord;
            prevPos = searchIndex;
        else
            startIndex = length(codeBook)+1;
            codeBook{startIndex} = codeWord;
            codeBookLength(startIndex) = length(codeWord);
            %output = strcat(output,num2str( prevPos),',');
            output = [output num2str( prevPos) ','];
           buffer = '';
        end
    end
    outCodeBook = codeBook;
    %% Information about calculation
%     disp('Lempev ziv encoder is completed.');
%     str = sprintf('Total length of code book is %d',length(codeBook));
%     disp(str);
    %% ======================================================
    %%% Calculation of output binary sequence
    %%%======================================================
    NumRep = [];
    NumRepBin = [];
    wordLength = ceil(log2(length(codeBook)-2));
    
    for i=3:length(codeBook),
%         if mod(i,3000) == 0
%             str = sprintf('Current CodeBook binary representation is %d',i);
%             disp(str);
%         end
        strTofind = '';
        strToFindRight = '';
        if codeBookLength(i) == 1
            strTofind = codeBook{i};
        else
            strTofind = codeBook{i}(1:codeBookLength(i)-1);
            strToFindRight = codeBook{i}(codeBookLength(i):codeBookLength(i));
        end
        firstPosition = 0;
        secondPosition = 0;
        for j=1:i,
            if length(strTofind) == codeBookLength(j)
                if strTofind ==  codeBook{j}
                    firstPosition = j;
                end
            end
            if length(strToFindRight) == codeBookLength(j)
                if strToFindRight ==  codeBook{j}
                    secondPosition = j;
                end
            end
            if firstPosition ~= 0 && secondPosition ~=0
                break;
            end
        end
        %% binary and decimal representation of output 
        %NumRep{length(NumRep) + 1 } = strcat(num2str(firstPosition),',',num2str(secondPosition));
        %NumRepBin{length(NumRepBin) + 1 } = strcat( num2str(dec2bin(firstPosition,wordLength)),',',codeBook{secondPosition});
        NumRep{length(NumRep) + 1 } = [num2str(firstPosition) ',' num2str(secondPosition)];
        NumRepBin{length(NumRepBin) + 1 } = [ num2str(dec2bin(firstPosition,wordLength)) ',' codeBook{secondPosition}];

    end
end