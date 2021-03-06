/**
INSTITUTO TECNOLÓGICO AUTÓNOMO DE MÉXICO
Proyecto 3 De Programación INTELIGENCIA ARTIFICAL
PRIMAVERA 2022
MiniRouter

Lucía Lizardi CU:181036
Alejandro Bermudez CU:181500
Rogelio Torres CU:182346

THOR:
    The
    Heuristic
    Optimal
    Router

Run this command on Terminal with path location in order to let prolog get txt cases file
working_directory(CWD,'path_or_location').

**/

/**
thor.
**/
:-ensure_loaded(stations).

thor:-
    write("Hello, I'm Thor ϟ The Heuristic Optimal Router."),nl,thor1.
thor1:-
    write("I have DC's subway station data. Tell me the beginning of your trip:"),nl,
    read(PointA),
    write("Tell me where you want to go:"),nl,
    read(PointB),
    (station(_,PointA,_,_,_,_),station(_,PointB,_,_,_,_) ->
    getRoute(PointA,PointB,Route);
    write("ERROR."),nl,thor1),
    write("You should follow the next route: "),nl,
    correct(Route,PointA),
    write("Wanna take anothera trip?"),nl,read(Answer),
    (Answer == yes -> thor1;
    write("Bye!ϟ")),!.



 %distPQ(i,i,i,i,o)
 /**
 Se calcula la distancia entre los puntos de Origen (P) y el punto de destino (Q)
 P=(X1,Y1)
 Q=(X2,Y2)
 **/
distPQ(X1, Y1, X2, Y2, Res):-
    X is (X2-X1),
    Y is (Y2-Y1),
    SUM is (X*X) + (Y*Y),
    N is 100*sqrt(SUM),
    round(N, 2, Res).

%dist(i,i,o)
dist(Boston1,Boston2,Dist):-
    station(_,Boston1,CB11,CB12,_,_),   %Estación de origen y sus coordenadaas de origen
    station(_,Boston2,CB21,CB22,_,_),   %Estación final y sus coordenadaas de final
    distPQ(CB11,CB12,CB21,CB22,Dist),!. %Se llama la función de distancia entre dos puntos distPQ con los datos de altitud y latitud de cada estación


normaAux(X1,X2,Est2,Dist):-
    station(_,Est2,Cord1,Cord2,_,_),
    normaEuclidiana(X1,X2,Cord1,Cord2,Dist),!.
/**Aux**/

%getHead(i,o)
/**Regla que regresa la cabeza de una lista**/
getHead([H|_], Head):-
    Head = H.

%getTail(i,o)
/**Regla que regresa la cola de una lista**/
getTail([_|T], Tail):-
    Tail = T.

%pop(i,o)
/**Sacamos el último elemento de una lista**/
pop(List, Last):-
    reverse(List, Rev),
    getHead(Rev, Last).

%round(i,i,o)
/**Se usa para redondear un número**/
round(Num, Digits, Ans):-
    Z is Num * 10^Digits,
    round(Z, ZA),
    Ans is ZA / 10^Digits.

%getValG(i,o)
/**Regresa el valor g(n) ara el algoritmo A*
 que es el peso de cada acción**/
getValG(Node, Ans):-
    getHead(Node, Values),
    getHead(Values, Ans).

%getValH(i,o)
/**Regresa el valor h(n) para el algoritmo A*
h(n)
***/
getValH(Node, Ans):-
    getHead(Node, Head),
    reverse(Head, R),
    getHead(R, Ans).

%stationName(i,o)
/**Reegresa el nombre de la estación de un nodo**/
stationName([_,_,Station,_], Name):-
    Name = Station.
stationName([_,Station,_],Name):-
    Name = Station.

%numStations(i,i,o)
/**Número de estaciones en una línea en el sistema dado (metro) **/
numStations(System, Line, Count):-
    aggregate_all(count, station(System,_,_,_,Line,_), Count).



%addToPriorityQueue(i,i,i,i)
/** Regla que añade elementos a una cola de prioridaades dependiendo de su
valor f(n)=g(n)+h(n) para el funcionamientp del algoritmo A* **/
addToPriorityQueue(Elem, _, [], First):- %Si la lista es vacía
    First = [Elem], !.
addToPriorityQueue(Node, Priority, [Queue|Tail], Ans):-
    getHead(Queue, Weights),
    getHead(Weights, G),
    getLast(Weights, H),
    HeadPriority is G + H,    % Prioridad del primer elemento de la cola
    Priority > HeadPriority,
    addToPriorityQueue(Node, Priority, Tail, Rest),
    append([Queue], Rest, Ans), !.
addToPriorityQueue(Node, _, Queue, Ans):-
    append([Node], Queue, Ans), !.

%dequeuePriorityQueue(i,i,o)
dequeuePriorityQueue([Queue|T], Rest, Elem):-
    Rest = T,
    Elem = Queue.

%adyacentStations([i],o)
%adyacentStations([i,i,i],o)
adyacentStations([System, Station, Line], Stations):-
    station(System, Station, _, _, Line, Index),
    L is Index-1,
    R is Index+1,
    numStations(System, Line, Count),
    (L > 0, R =< Count -> station(System,Left,_,_,Line, L),
    station(System,Right,_,_,Line, R),
    Stations = [Left, Right]
    ; (L =:= 0 -> station(System,Right,_,_,Line, R),
    Stations = [Right] ; station(System,Left,_,_,Line, L),
    Stations = [Left])), !.

%getSaneStations(i,o)
getSameStations(Station, Conections):-
    findall([System, Station, Line] ,station(System,Station,_,_,Line,_),Conections).

%getConnections([i],o)
getConnections([_, Sys, Node, Line], Connection):-
    getSameStations(Node, Con),
    delete(Con, [Sys,Node,Line], Connection).

%checkDirections
checkDirection([H|[T]],Start,Goal,Line, Direction):-
    dist(H,Goal, Left),
    dist(T,Goal, Right),
    station(_, Start, _ ,_, Line, Index),
    (Left < Right -> Direction is Index-1 ; Direction is Index+1).
checkDirection([H|[]],Start, _,Line, Dir):- % Si es terminal o inicio de línea
    station(_,Start,_,_,Line,StartOrder),
    station(_,H,_,_,Line,Order),
    Dif is StartOrder-Order,
    (Dif > 0 -> Dir is StartOrder-1 ; Dir is StartOrder+1).

%getDirection
getDirection([Sys, Node, Line], Goal, New):-
    adyacentStations([Sys, Node, Line], Stations),
    checkDirection(Stations, Node, Goal, Line, Dir),
    station(Sys, Next, _ , _, Line, Dir),
    New = [Sys, Next, Line], !.

%getAdyacentStationsCon
getAdyacentStationsCon([], _, Ans):-
    Ans = [].
getAdyacentStationsCon(Connections, Goal, Ans):-
    getHead(Connections, Head),
    getDirection(Head, Goal, Next),
    getTail(Connections, Rest),
    getAdyacentStationsCon(Rest, Goal, Con),
    append([Next], Con, Ans), !.

%nodeValue
nodeValue([Sys|[Node|[Line]]], Goal, Prev, PrevG, List):-
    (norma(Node, Prev, G) -> SumG is G + PrevG ; SumG is PrevG),   % Peso del nodo previo al actual
    norma(Node, Goal, H),   % Valor heurístico
    List = [[SumG,H],Sys, Node, Line].

%weightNodes
weightNodes([], _, _, _, _).
weightNodes(Nodes, Goal, PrevName, PrevG, Weighted):-
    getTail(Nodes, Tail),
    weightNodes(Tail, Goal, PrevName, PrevG, W),
    getHead(Nodes, Head),
    nodeValue(Head, Goal, PrevName, PrevG, NodeVal),
    getHead(NodeVal, Weights),
    getHead(Weights, G),
    getLast(Weights, H),
    F is G + H,
    addToPriorityQueue(NodeVal, F, W, Weighted), !.

%getNextStation
getNextStation([_,_, Prev, _], [_, Sys, Node, Line], Next):-
    station(Sys,Node, _, _, Line, IndexNode),
    station(Sys,Prev, _, _, Line, IndexPrev),
    numStations(Sys, Line, Count),
    (IndexNode =:= 1 -> Direction is 2 ; (IndexNode =:= Count -> Direction is Count-1 ; Direction is IndexNode + (IndexNode - IndexPrev))),
    station(Sys,Name, _, _, Line, Direction),
    Next = [Sys, Name, Line], !.

%getPreviousFirst
getPreviousFirst([Sys, Node, Line], Goal, Next):-
    adyacentStations([Sys, Node, Line], [H|[T]]),
    station(Sys,Node, _, _, Line, IndexNode),
    dist(H,Goal, Left),
    dist(T,Goal, Right),
    (Left < Right -> Direction is IndexNode +1 ; Direction is IndexNode -1),
    station(Sys,Name, _, _, Line, Direction),
    Next = [[0,0],Sys, Name, Line].
getPreviousFirst([Sys, Node, Line], _, Next):-
    Next = [[0,0],Sys, Node, Line].

%getChildNodes
getChildNodes(Prev, Parent, Goal, WeightedChilds):-
    getNextStation(Prev, Parent, Next), % Estación siguiente en la misma línea
    getConnections(Parent, Conections),
    getAdyacentStationsCon(Conections, Goal, AdCon), % Estaciones de transbordo
    append(AdCon, [Next], Childs),
    (Prev \= [] -> getTail(Prev, PTail) ; PTail is " "),
    delete(Childs, PTail, Cons),
    stationName(Prev, PrevName),
    getValG(Prev, PrevG),
    weightNodes(Cons, Goal, PrevName, PrevG , WeightedChilds), !.

/**
Algortimo
A STAR
**/

%a_star
a_star(Prev, Parent, Goal, Path):-
    stationName(Parent, PName),
    PName \= Goal,
    getChildNodes(Prev, Parent, Goal, Childs),
    getHead(Childs, Succesor),
    a_star(Parent, Succesor, Goal, Closed),
    append([PName], Closed, Path), !.
a_star(_, _, Goal, Path):-
    Path = [Goal].

/**
 * Método que inicializa la búsqueda A* para una estación en particular.
 * **/
 %getPath(i,i,o)
getPath(PointA, PointB, Path):-
    station(Sys, PointA,_,_,Line,_),
    getPreviousFirst([Sys, PointA, Line], PointB, First),
    a_star(First, [[0,0], Sys, PointB, Line], PointB,Path).

/**
 * newCase(input)
 * Agrega un nuevo caso a la memoria de datos.
 * La memoria de datos se guarda en un .txt llamado routeCases.txt
 * Debe estar en la carpeta del proyecto.
 * Recibe un parámetro de entrada que es una lista
 * que contiene una ruta.
 **/
 %newCase(i)
newCase(List) :-
    open('routeCases.txt', append, Stream),
    (write(Stream, List),
    write(Stream,"."),
    nl(Stream),
    !;
    true),
    close(Stream).


 %returnAllCases(o)
returnAllCases(List):-
  setup_call_cleanup(
    open('routeCases.txt', read, In),
    readInfo(In, List),
    close(In)).

%reeadInfo(i,o)
readInfo(In, L):-
  read_term(In, H, []),
    (H == end_of_file ->  L = [];
      L = [H|T],
      readInfo(In,T)).

/**
 * compatibleCase(input,input,output)
 * Regresa una ruta en la cual estén contenidas las dos estaciones
 * i: Estación 1
 * i: Estación 2
 * o: Ruta
**/
%compatibleCase
compatibleCase(Station1,Station2,Case):-
    returnAllCases(CaseList),
    auxCompatibleCase(Station1,Station2,CaseList,Case).

/**
 * auxCompatibleCase(input,input,input,output)
 * Verifica si las estaciones están en un caso
 * input1: Estación 1
 * input2: Estación 2
 * input3: Ruta visitada
 * output: Ruta
**/
%auxCompatibleCase
auxCompatibleCase(_,_,[],[]).
auxCompatibleCase(Station1, Station2,[Current|Tail],Case):-
    (member(Station1,Current),member(Station2,Current) ->
    Case = Current);
    auxCompatibleCase(Station1,Station2,Tail,Case), !.

%adaptCase(i,i,i,o)
adaptCase(Station1,Station2,Caso,Res):-
    findCase(Station1,Station2,Caso,Res1),
    reverse(Res1,Res2),
    findCase(Station1,Station2,Res2,Res3),
    reverse(Res3,Res).

%findCase(i,i,i,o)
findCase(_,_,[],[]):-
    !.
findCase(Station1,_,[Station1|Tail],[Station1|Tail]):-
    !.
findCase(_,Station2,[Station2|Tail],[Station2|Tail]):-
    !.
findCase(Station1,Station2,[_|Tail],Res):-
    findCase(Station1,Station2,Tail,Res).

 %correctOrder
correct([Head|Tail],Origen):-
    (Head == Origen -> print([Head|Tail]);
    reverse([Head|Tail],NewList),print(NewList)).

%print(i):-
print([]):-
    write("You arrived!"),nl,!.
print([H|T]):-
    write(H),nl,
    write("↓"),
    print(T).

%hasElem(i)
hasElem([]):-
    false.
hasElem([_|_]):-
    true.

%getRoute(i,i,o)
getRoute(Origen,Destino,Ruta):-
    compatibleCase(Origen,Destino,Case),
    (hasElem(Case) ->
    adaptCase(Origen,Destino,Case,Ruta),newCase(Ruta);
    getPath(Origen,Destino,Ruta),newCase(Ruta)).

:-dynamic closest/1.

closestStation(Latitud,Longitud,Station):-
    findall(X,station(_,X,_,_,_,_),L),
    closestStation1(Latitud,Longitud,_,100000,L),
    retract(closest(Station)).

closestStation1(_,_,St,_,[]):-
   assert(closest(St)),
   !.


%Si la distancia calculada por la norma es
closestStation1(Latitud,Longitud,_,DistActual,[Start|Rest]):-
    normaAux(Latitud,Longitud,Start,Dist),
    Dist=<DistActual,
    closestStation1(Latitud,Longitud,Start,Dist,Rest).

closestStation1(Latitud,Longitud,StationName,DistActual,[_|Rest]):-
    closestStation1(Latitud,Longitud,StationName,DistActual,Rest),!.



























