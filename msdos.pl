%simplification rules ---------------------------------------------------
sr([a|X],X).
sr([of|X],X).
sr([the|X],X).
sr([is|X],X).
sr([are|X],X).
sr([there|X],X).
sr([any|X],X).
sr([show|X],X).
sr([list|X],X).
sr([for|X],X).
sr([this|X],X).
sr([window|X],X).
sr([what|X],X).
sr([tell|X],X).
sr([me|X],X).
sr([about|X],X).
sr([find|X],X).
sr([program|X],X).
sr([running|X],X).

sr([in|X],[on|X]).
sr([pc|X],[computer|X]).
sr([stop|X],[shutdown|X]).
sr([closedown|X],[shutdown|X]).
sr([diagram|X],[tree|X]).
sr([structure|X],[tree|X]).
sr([back|X],[up|X]).
sr([operating,system|X],[about,system|X]).
sr([named|X],[called|X]).
sr([name|X],[called|X]).
sr([current|X],[all|X]).
sr([programs|X],[tasks|X]).

sr([disk,drive|X],[drive|X]).
sr([disk|X],[drive|X]).
sr([disk,drives|X],[drives|X]).
sr([disks|X],[drives|X]).
sr([X,drive|Y],[drive,X|Y]) :- char_table(X,_,_).

sr([browser|X],[iexplore|X]).
sr([explorer|X],[iexplore|X]).

sr([text,editor|X],[notepad|X]).

sr([defragment|X],[defrag|X]).
sr([clean|X],[defrag|X]).
sr([but|X],[except|X]).
sr([not|X],[except|X]).
sr([but,not|X],[except|X]).

sr([run|X],[start|X]).
sr([open|X],[start|X]).
sr([new|X],[start|X]).

sr([folder|X],[files|X]).
sr([what,files|X],[files|X]).
sr([file|X],[files|X]).

sr([all,files|X],[files|X]).
sr([everything|X],[all,files|X]).
sr([every|X],[all|X]).


%simplify ---------------------------------------------------------------
simplify(List,Result) :-
  sr(List,NewList),
  !,
  simplify(NewList,Result).

simplify([W|Words],[W|NewWords]) :-
  simplify(Words,NewWords).

simplify([],[]).


%translation rules ------------------------------------------------------
tr([computer,called],['cmd /k hostname']).
tr([called,computer],['cmd /k hostname']).

tr([tree,files,on,drive,X],['cmd /k cd / & cd /d ',X,': & tree']).

tr([all,tasks],['cmd /k tasklist']).

tr([search,X,on,drive,Y],['cmd /k cd / & cd /d ',Y,': & dir ',X,' /s /p']).
tr([search,X,files,on,drive,Y],['cmd /k cd / & cd /d ',Y,': & dir ',X,' /s /p']).
tr([search,files,called,X,on,drive,Y],['cmd /k cd / & cd /d ',Y,': & dir ',X,' /s /p']).

tr([defrag,drive,X],['cmd /k defrag ',X,': /U']).
tr([defrag,all,drives],['cmd /k defrag /C /U']).
tr([defrag,all,drives,except,drive,X],['cmd /k defrag ',X,': /E /U']).

tr([start,X],['cmd /k start ',X]).
tr([start,X,called,Y],['cmd /k start ',X,' "',Y,'"']).


tr([quit],[quit]).
tr([files,on,drive,X],['cmd /k dir ',X,':']).
tr([X,files,on,drive,Y],['cmd /k dir ',Y,':*.',X]).
tr([copy,files,from,drive,X,to,drive,Y], ['copy ',X,':*.* ',Y,':']).
tr([files,on,directory,X],['cmd /k dir \\',X]).


%translate --------------------------------------------------------------
translate(Input,Result) :-
   tr(Input,Result),
   !.

translate(_,[]) :-
   write('I do not understand'),
   nl.


%setup command ----------------------------------------------------------
process_commands :-
   repeat,
      write('Command -> '),
      tokenize_line(user,X),
      tokens_words(X,What),
      simplify(What,SimplifiedWords),
      translate(SimplifiedWords,Command),
      pass_to_os(Command),
      Command == [quit],
   !.

%passing commands to the OS ---------------------------------------------
pass_to_os([])     :- !.

pass_to_os([quit]) :- !.

pass_to_os(Command) :-
   concat(Command,String),
   win_exec(String,show).


concat([H|T],Result) :-
   name(H,Hstring),
   concat(T,Tstring),
   append(Hstring,Tstring,Result).

concat([],[]).

append([H|T],L,[H|Rest]) :- append(T,L,Rest).
append([],L,L).