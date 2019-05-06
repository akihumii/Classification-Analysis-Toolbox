
fclose(s);

hand = bionicHand('COM47');

a = '1';

while(1)
    if ( a == '9')
        a = '1';
    else
        a = a + 1;
    end
    writeToHand(a);
    pause(1);
end