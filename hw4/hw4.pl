% 1     : '.'
% 11    : 1 or 111
% 111   : '-'
% 111+  : 111
% 0     : separator
% 00    : 0 or 000
% 000   : boundary
% 0000  : 000
% 00000 : 000 or 0000000
% 0000000: space
% 00000+ : space

%Counting the duplicate 0s and 1s, make them tuples
count_dup([], []).
count_dup([Head], [[1, Head]]).
count_dup([Head | Tail], [[Count, Head] | Rest]) :- 
	count_dup(Tail, [[Old, Head] | Rest]), succ(Old, Count), !.
%When hit changing between 0 and 1, renew the count
count_dup([Head | Tail], [[1, Head], [Old, Last] | Rest]) :- 
	count_dup(Tail, [[Old, Last] | Rest]), Head \= Last, !.

%Recursively calling match to match through the whole list
match([], []).
match([[1,1] | Tail], ['.' | Rest]):- match(Tail, Rest).
match([[2,1] | Tail], ['.' | Rest]):- match(Tail, Rest).
match([[2,1] | Tail], ['-' | Rest]):- match(Tail, Rest).
match([[3,1] | Tail], ['-' | Rest]):- match(Tail, Rest).
match([[Value,1] | Tail], ['-' | Rest]):- Value > 3, match(Tail, Rest).
match([[1,0] | Tail], Rest):- match(Tail, Rest).
match([[2,0] | Tail], Rest):- match(Tail, Rest).
match([[2,0] | Tail], ['^' | Rest]):- match(Tail, Rest).
match([[3,0] | Tail], ['^' | Rest]):- match(Tail, Rest).
match([[4,0] | Tail], ['^' | Rest]):- match(Tail, Rest).
match([[5,0] | Tail], ['^' | Rest]):- match(Tail, Rest).
match([[5,0] | Tail], ['#' | Rest]):- match(Tail, Rest).
match([[Value,0] | Tail], ['#' | Rest]):- Value > 5, match(Tail, Rest).

signal_morse([], []).
signal_morse([Head | Tail], Result) :- count_dup([Head | Tail], Tmp), match(Tmp, Result).

%--------------------------------------------------------------------------------------------------------------%
morse(a, [.,-]).           % A
morse(b, [-,.,.,.]).	   % B
morse(c, [-,.,-,.]).	   % C
morse(d, [-,.,.]).	   % D
morse(e, [.]).		   % E
morse('e''', [.,.,-,.,.]). % É (accented E)
morse(f, [.,.,-,.]).	   % F
morse(g, [-,-,.]).	   % G
morse(h, [.,.,.,.]).	   % H
morse(i, [.,.]).	   % I
morse(j, [.,-,-,-]).	   % J
morse(k, [-,.,-]).	   % K or invitation to transmit
morse(l, [.,-,.,.]).	   % L
morse(m, [-,-]).	   % M
morse(n, [-,.]).	   % N
morse(o, [-,-,-]).	   % O
morse(p, [.,-,-,.]).	   % P
morse(q, [-,-,.,-]).	   % Q
morse(r, [.,-,.]).	   % R
morse(s, [.,.,.]).	   % S
morse(t, [-]).	 	   % T
morse(u, [.,.,-]).	   % U
morse(v, [.,.,.,-]).	   % V
morse(w, [.,-,-]).	   % W
morse(x, [-,.,.,-]).	   % X or multiplication sign
morse(y, [-,.,-,-]).	   % Y
morse(z, [-,-,.,.]).	   % Z
morse(0, [-,-,-,-,-]).	   % 0
morse(1, [.,-,-,-,-]).	   % 1
morse(2, [.,.,-,-,-]).	   % 2
morse(3, [.,.,.,-,-]).	   % 3
morse(4, [.,.,.,.,-]).	   % 4
morse(5, [.,.,.,.,.]).	   % 5
morse(6, [-,.,.,.,.]).	   % 6
morse(7, [-,-,.,.,.]).	   % 7
morse(8, [-,-,-,.,.]).	   % 8
morse(9, [-,-,-,-,.]).	   % 9
morse(., [.,-,.,-,.,-]).   % . (period)
morse(',', [-,-,.,.,-,-]). % , (comma)
morse(:, [-,-,-,.,.,.]).   % : (colon or division sign)
morse(?, [.,.,-,-,.,.]).   % ? (question mark)
morse('''',[.,-,-,-,-,.]). % ' (apostrophe)
morse(-, [-,.,.,.,.,-]).   % - (hyphen or dash or subtraction sign)
morse(/, [-,.,.,-,.]).     % / (fraction bar or division sign)
morse('(', [-,.,-,-,.]).   % ( (left-hand bracket or parenthesis)
morse(')', [-,.,-,-,.,-]). % ) (right-hand bracket or parenthesis)
morse('"', [.,-,.,.,-,.]). % " (inverted commas or quotation marks)
morse(=, [-,.,.,.,-]).     % = (double hyphen)
morse(+, [.,-,.,-,.]).     % + (cross or addition sign)
morse(@, [.,-,-,.,-,.]).   % @ (commercial at)

% Error.
morse(error, [.,.,.,.,.,.,.,.]). % error - see below

% Prosigns.
morse(as, [.,-,.,.,.]).          % AS (wait A Second)
morse(ct, [-,.,-,.,-]).          % CT (starting signal, Copy This)
morse(sk, [.,.,.,-,.,-]).        % SK (end of work, Silent Key)
morse(sn, [.,.,.,-,.]).          % SN (understood, Sho' 'Nuff)


morse_to_letters([], []).
morse_to_letters(Code, [Letter]) :- morse(Letter, Code).
%Get the Code segment when hit '^', and ignore '^'
morse_to_letters(Code, [LetterHead|LettersTail]) :- 
	append(CodeHead, [^|CodeTail], Code), morse(LetterHead, CodeHead), morse_to_letters(CodeTail, LettersTail).
%Do the same as '^' when hit '#', but append # inside the result
morse_to_letters(Code, LettersList) :- 
	append(CodeHead, [#|CodeTail], Code), morse(LetterHead, CodeHead), morse_to_letters(CodeTail, LettersTail),
	append([LetterHead], [#|LettersTail], LettersList).

%Get the words before '#'
get(List, []) :- \+member('#', List).
get(List, Words) :- append(_, [Last_Word], List), Last_Word\='#', append(Head, [#|Tail], List), \+member('#', Tail),
	append(Head, ['#'], Words).
get(List, Words) :- append(Head, [Last], List), Last='#', get(Head, Words).

%Remove the words followed with 'error', keep the '#' at the same time
remove([], []).
remove(Letters, Letters) :- \+member(error, Letters).
remove([#|Letters_raw], [#|Letters_result]) :- remove(Letters_raw, Letters_result).
remove([error|Letters_raw], [error|Letters_result]) :- once(remove(Letters_raw, Letters_result)).
remove(Letters, List) :- append(Head,['error'|Tail], Letters), \+ member('error',Head), 
	get(Head,Prev_Words), remove(Tail,Rest_Words), append(Prev_Words,Rest_Words,List). 

signal_message([], []).
signal_message(Binary, Message) :- signal_morse(Binary, Morse), morse_to_letters(Morse, Letters), 
	remove(Letters, Message).

