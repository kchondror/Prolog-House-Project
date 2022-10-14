%������������ - ����� ������������ , �.�.� : 3812
%������� ���������� , �.�.� : 3699




%����� consult �� ������ ��� ������� ��� ��� ��������
:-['houses.pl','requests.pl'].

% � ����� ��������� ��� ������������ .��������� �� ����� ��� ������ ���
% ��� ������ �� �������� ��� ����������.
run :-
   nl,nl,
   write('�����: \n======\n
1 - ����������� ���� ������
2 - ������� ����������� �������
3 - ������� ������� ���� �����������
0 - ������
'),nl,

   write('�������: '),read(Number),
   (   (Number>=0,Number<4)  -> process(Number)
   ;   write('\n������� ���� ������ ������ 0 ��� 3'),nl,nl,run).

% ������� 1�.
% ������ ��� ��� ������ ��� ����������� ����������� ��� ��� �������
% ��� �� ������� ������ �� ���� �����.
process(1) :-
    write('���� ��� �������� �����������:'),nl,nl,
    write('=============================='),nl,nl,

    write('�������� �������'),read(Area),
    write('��������� ������� ������������:'),read(Bedrooms),
    write('�� ������������ ����������; (yes/no)'),read(Pets),
    write('��� ����� ����� ��� ���� �� ������� ������������;'),read(Elev_level),
    write('���� ����� �� ������� ������� ��� ������� �� ���������;'),read(Rent),
    write('���� �� ������ ��� ��� ���������� ��� ������ ��� ����� (��� �������� �����������);'),nl,read(Center),
    write('���� �� ������ ��� ��� ���������� ��� �������� ��� ����� (��� �������� �����������); '),nl,read(Suburb),
    write('���� �� ������ ��� ���� ����������� ������������� ���� ��� �� ��������;'),read(More_Area),
    write('���� �� ������ ��� ���� ����������� �����;'),read(Garden),nl,

    findall(house(Addr,Bdrms,Ar,Cntr,Lvl,Elvtr,Pts,Grd,Rnt),(house(Addr,Bdrms,Ar,Cntr,Lvl,Elvtr,Pts,Grd,Rnt)),L),

    % � ����� CompHouses ���� ��� �� ������ ��� ������� ��� ���������� ��� ������.
    compatible_houses(Area,Bedrooms,Pets,Elev_level,Rent,Center,Suburb,More_Area,Garden,L,CompHouses),

    length(CompHouses,Leng),( Leng==0  -> nl,write('��� ������� ��������� �����!'),nl,nl ;

    % ������� �� ������ ��� ��������� �� BestHouse ��� ��������� � find_best_house.
    print_houses(CompHouses) ,
    find_best_house(CompHouses,BestHouse),
    house(Adress,_,_,_,_,_,_,_,_) = BestHouse,
    write('����������� � ��������� ��� ������������� ���� ���������: '),write(Adress),nl,nl
    ),

    run.


% ������� 2�.
% ��� �� ������ requests.pl ������ ��� ����������� ��� ������� ��� ��
% ������������ ��� ��������� �� ������� ��� 1�� �������� ��� ���
% ���������� ��� ��� �������� ����.
process(2) :-

   findall(request(Name,Area,Bedrooms,Pets,Elevator,Rent,Rent_Center,Rent_Suburb,More_Area,More_Garden),
          (request(Name,Area,Bedrooms,Pets,Elevator,Rent,Rent_Center,Rent_Suburb,More_Area,More_Garden)),
           Requests),

   findall(house(Addr,Bdrms,Ar,Cntr,Lvl,Elvtr,Pts,Grd,Rnt),(house(Addr,Bdrms,Ar,Cntr,Lvl,Elvtr,Pts,Grd,Rnt)),L),
   find_houses(Requests,L),
   print_Process2(Requests),
   run.

% ������� 3�.
% �������� �������� - ������������� ��� ���������� (��� ���� �������)
% ��� �� ���� request.
process(3) :-

   findall(request(Name,Area,Bedrooms,Pets,Elevator,Rent,Rent_Center,Rent_Suburb,More_Area,More_Garden),
          (request(Name,Area,Bedrooms,Pets,Elevator,Rent,Rent_Center,Rent_Suburb,More_Area,More_Garden)),
           Requests),

   findall(house(Addr,Bdrms,Ar,Cntr,Lvl,Elvtr,Pts,Grd,Rnt),(house(Addr,Bdrms,Ar,Cntr,Lvl,Elvtr,Pts,Grd,Rnt)),L),

   loop_houses(L,Requests),
   findall(bidders(X,Y),bidders(X,Y),Bs),

   find_houses(Requests,L),
   findall(house(Addr,Bdrms,Ar,Cntr,Lvl,Elvtr,Pts,Grd,Rnt),best_house(_,house(Addr,Bdrms,Ar,Cntr,Lvl,Elvtr,Pts,Grd,Rnt)),BestHouses),

   find_best_bidders(Bs,[],BestHouses),


   ( current_predicate(final_bidders/2) -> findall(final_bidders(X,Y),final_bidders(X,Y),Final),
     print_final_bidders(Final,Requests),
     abolish(final_bidders/2)
   ; nl,write('������� ��� �� ���������� ������ ����������.')),

   abolish(best_house/2),
   abolish(bidders/2),

   run.

%������� 4�.
%������ ��� �� ���������.
process(0) :- halt(0).

% ------------------------------------------------------------------------

print_final_bidders([],[]).

% ��������� ������ ��� ��� �� ����������� ������ �����.
print_final_bidders([],[H|T]):-
   request(Name,_,_,_,_,_,_,_,_,_)=H,

   write('O ������� '),write(Name),write(' ��� �� ��������� ������ ����������!'),nl,
   print_final_bidders([],T).

% ������� �� ������ ��� ����� �� ������������ final_bidders ���� �����
% ��� ������ Request - House ��� ��� �� requests ��� �������� ���� ����.
% ���� ������� ��� �������� ��� ������ ,������� �� ���������� request ���
% ��� ���� ,���� ���� ���� ��� �� ����������� �� ����� �� ������� ��� ���
% �� ����������� ������ ����������.
print_final_bidders([H|T],Requests):-
   final_bidders(Req,House)=H,
   request(Name,_,_,_,_,_,_,_,_,_)=Req,
   house(Addr,_,_,_,_,_,_,_,_)=House,
   write('O ������� '),write(Name),write(' �� ��������� �� ���������� ���� ���������: '),write(Addr),nl,
   select(Req,Requests,Rest),

   print_final_bidders(T,Rest).


% ������� �� ������ ��� ����� �� ������������ bidders ��� ������
% House - Bidders ���� ��� ���� ���������� ,bidders ����� ��
% ��������� ����������� ��� .�� predicate ���� ,������� ��� ����������
% ��� ��������� �� ���������� ������� ��� ���������� ��� dynamic fact
% final_bidders(����������� - �����) ������ �� ����� ��� ������� ����
% ���� ����� L � ����� ������������ ��� �� ������ ��� ����� ���
% ����������� .�������� � ��������� ��� ���� ���������� �����������
% �������� ��� �� ������������ ��� ����� ���������� (BestHouses).
find_best_bidders([],_,_).
find_best_bidders([H|T],L,BestHouses):-

   bidders(House,Bidders)=H,
   delete_Element(house('','','','','','','','',''),BestHouses,BestHouses2),

   (  (member(House,BestHouses2) ; list_Empty(BestHouses2) ) ->

   max_bidder(Bidders,Max,L,House),
   delete_Element(House,BestHouses2,Rest),
   ( list_Empty(Max) -> List=L ; assert(final_bidders(Max,House)),add_tail(L,Max,List)) ,
   find_best_bidders(T,List,Rest) ;

   add_tail(T,H,Temp),
   find_best_bidders(Temp,L,BestHouses2)

   ).

% ����������� ���������� ��� ����� �� �� ������ ��� ������� ����
% ������ ��� ���������� ���� ���������� ����������� ��� ����
% ������������� ��� fact bidders(���������� - �����������).
loop_houses([],_).
loop_houses([H|T],Requests):-
   house_bidders(H,Requests,Comp_Bidders),
   assert(bidders(H,Comp_Bidders)),
   loop_houses(T,Requests).

% ��� �� ����� ��� ������� ���� ������ (House) ������� ���� ����������
% ����������� ��� ��� ���� ���������� ���� ��� ������ L.
house_bidders(_,[],_).
house_bidders(House,[H|T],L):-

   house_bidders(House,T,Rest),

   request(_,Area,Bedrooms,Pets,Elevator,Rent,Rent_Center,Rent_Suburb,More_Area,More_Garden)=H  ,

   (compatible_house(Area,Bedrooms,Pets,Elevator,Rent,Rent_Center,Rent_Suburb,More_Area,More_Garden,House) -> add_tail(Rest,H,L) ; L=Rest ).


% ������� ��� ���������� ���� ��������� ���������� ��� ��� ���������� ���
% ���������� true ��� �� ���� ����� ������� �� ��� ���������� ���.
% �������� ���������� false.
compatible_house(Area,Bedrooms,Pets,Elev_level,Rent,Center,Suburb,More_Area,Garden,House):-

   house(_,Bdrms,Ar,_,Lvl,Elvtr,Pts,_,Rnt)=House,

   Ar >= Area ,

   Bdrms >= Bedrooms,

   (  Pts=='yes' -> true ; Pts == Pets ),

   (  Elvtr == 'yes' -> true ; Lvl < Elev_level ),


   find_Full_Price(House,request(_,Area,_,_,_,Rent,Center,Suburb,More_Area,Garden),Full_Price),


   Full_Price >= Rnt,
   Rent >= Rnt.

% ���������� ���������� ��� ����� �� ��� �� ������������ ��� �����
% ������� �� ��� ���������� ��� �� ���������� ���� ��������� L.
compatible_houses(_,_,_,_,_,_,_,_,_,[],_).
compatible_houses(Area,Bedrooms,Pets,Elev_level,Rent,Center,Suburb,More_Area,Garden,[H|T],L):-

   compatible_houses(Area,Bedrooms,Pets,Elev_level,Rent,Center,Suburb,More_Area,Garden,T,Rest),

   (   compatible_house(Area,Bedrooms,Pets,Elev_level,Rent,Center,Suburb,More_Area,Garden,H) -> add_tail(Rest,H,L) ; L=Rest ).


% ������� ��� ������ ��� ����� �� ��� �� requests ��� ��� �� ���� ���
% ��������� �� ������� ������ ,���� ��� �� ������������ ���.
print_Process2([]):-abolish(compatibles/2),abolish(best_house/2).
print_Process2([H|T]):-

   compatibles(H,Houses),
   request(Name,_,_,_,_,_,_,_,_,_)=H,
   write('��������� ������������ ��� ��� ������: '),write(Name),nl,write('======================================='),nl,
   length(Houses,Leng),( Leng==0  -> nl,write('��� ������� ��������� �����!'),nl,nl ;

   print_houses(Houses) ,

   best_house(H,BestHouse),
   house(Adress,_,_,_,_,_,_,_,_) = BestHouse,
   write('����������� � ��������� ��� ������������� ���� ���������: '),write(Adress),nl,nl
   ),

   print_Process2(T).

% ��� ���� ������� ��� ������ request.pl ,���������� ������������ ��
% ������������ ��� ����� ������� �� ��� ���������� ����� ��� ���� ���
% ���������� ��� ���� �������� �� ���������� ���� ����� ��� facts
% compatibles/2 , best_house/2 .�� ��������� ��� ��� ������� ������
% ������� ����� ,�� best_house ����������� �� ���� (house('','','','','','','','',''))
find_houses([],_).
find_houses([H|T],L):-

   request(_,Area,Bedrooms,Pets,Elev_level,Rent,Center,Suburb,More_Area,Garden)=H,
   compatible_houses(Area,Bedrooms,Pets,Elev_level,Rent,Center,Suburb,More_Area,Garden,L,CompHouses),
   assert(compatibles(H,CompHouses)),

   length(CompHouses,Length),
   (  Length==0 -> assert(best_house(H,house('','','','','','','','',''))) ;

   find_best_house(CompHouses,BestHouse),
   assert(best_house(H,BestHouse))),


   find_houses(T,L).


% ����� ��� ����� ��� ����������� �� ����� �� ������ �� �������� ��� ��
% ������ ��� �������� ���� ����� Houses ��� �� ���������� ���� ���
% ���������� BestHouse
find_best_house(Houses,BestHouse):-

   find_cheap(Houses,Res1),
   find_biggest_garden(Res1,Res2),
   find_biggest_house(Res2,Res3),
   nth0(0,Res3,BestHouse).


% ������� �� ���������� �� �� ��������� ������� ��� ������ Houses ���
% ������ �������� ��� ���� �� ��� ���� ���� ���� ����� ����, ��
% ���������� ���� ��� ���������� Res.
find_cheap(Houses,Res):-
   min_Rent(Houses,Cheaper),
   house(_,_,_,_,_,_,_,_,Rent)= Cheaper,
   findall(house(Addr,Bdrms,Ar,Cntr,Lvl,Elvtr,Pts,Grd,Rent),(house(Addr,Bdrms,Ar,Cntr,Lvl,Elvtr,Pts,Grd,Rent),
                                                            member(house(Addr,Bdrms,Ar,Cntr,Lvl,Elvtr,Pts,Grd,Rent),Houses)),Res).

% ������� �� ���������� �� ��� ���������� ���� ��� ������ Houses ���
% ������ �������� ��� ���� �� ��� ���� ������ ���� ����� ����, ��
% ���������� ���� ��� ���������� Res.
find_biggest_garden(Houses,Res):-
   max_Garden(Houses,Biggest_Garden),
   house(_,_,_,_,_,_,_,Garden,_)= Biggest_Garden,
   findall(house(Addr,Bdrms,Ar,Cntr,Lvl,Elvtr,Pts,Garden,Rnt),(house(Addr,Bdrms,Ar,Cntr,Lvl,Elvtr,Pts,Garden,Rnt),
                                                            member(house(Addr,Bdrms,Ar,Cntr,Lvl,Elvtr,Pts,Garden,Rnt),Houses)),Res).

% ������� �� ���������� �� �� ����������� ����������� ��� ������ Houses
% ��� ������ �������� ��� ���� �� ��� ���� ������ ���� ����� ����, ��
% ���������� ���� ��� ���������� Res.
find_biggest_house(Houses,Res):-
   max_Area(Houses,Biggest_Area),
   house(_,_,Area,_,_,_,_,_,_)= Biggest_Area,
   findall(house(Addr,Bdrms,Area,Cntr,Lvl,Elvtr,Pts,Grd,Rnt),(house(Addr,Bdrms,Area,Cntr,Lvl,Elvtr,Pts,Grd,Rnt),
                                                            member(house(Addr,Bdrms,Area,Cntr,Lvl,Elvtr,Pts,Grd,Rnt),Houses)),Res).

% ������� ��� ���������� ��� �� ��������� �� ���� �� ������� ���
% ���������.
print_house(House):-
   house(Addrs,Bdrms,Ar,Cntr,Lvl,Elvtr,Pts,Grd,Rnt)= House,
   write('��������� ����� ���� ���������: '),write(Addrs),nl,
   write('�����������: '),write(Bdrms),nl,
   write('�������: '),write(Ar),nl,
   write('������� �����: '),write(Grd),nl,
   write('����� ��� ������ ��� �����: '),write(Cntr),nl,
   write('������������ ����������: '),write(Pts),nl,
   write('������: '),write(Lvl),nl,
   write('������������: '),write(Elvtr),nl,
   write('�������: '),write(Rnt),nl,nl.

% ��������� ��� �� ������ ��� ������ ��� �������.
print_houses([]).
print_houses([H|T]):-
   print_houses(T),
   print_house(H).

% ������� �� ����� �� �� ��������� �������.
min_Rent([M],M).
min_Rent( [H1,H2|T],Max):-
        house(_,_,_,_,_,_,_,_,Rent1)=H1,
        house(_,_,_,_,_,_,_,_,Rent2)=H2,
	Rent1 < Rent2,
	min_Rent([H1|T],Max).
min_Rent( [H1,H2|T],Max):-
        house(_,_,_,_,_,_,_,_,Rent1)=H1,
        house(_,_,_,_,_,_,_,_,Rent2)=H2,
	Rent1 >= Rent2,
	min_Rent([H2|T],Max).

% ������� �� ����� �� ��� ���������� ����.
max_Garden([M],M).
max_Garden( [H1,H2|T],Max):-
        house(_,_,_,_,_,_,_,Garden1,_)=H1,
        house(_,_,_,_,_,_,_,Garden2,_)=H2,
	Garden1 > Garden2,
	max_Garden([H1|T],Max).
max_Garden( [H1,H2|T],Max):-
        house(_,_,_,_,_,_,_,Garden1,_)=H1,
        house(_,_,_,_,_,_,_,Garden2,_)=H2,
	Garden1 =< Garden2,
	max_Garden([H2|T],Max).

% ������� �� ����� �� �� ����������� �����������.
max_Area([M],M).
max_Area( [H1,H2|T],Max):-
        house(_,_,Area1,_,_,_,_,_,_)=H1,
        house(_,_,Area2,_,_,_,_,_,_)=H2,
	Area1 > Area2,
	max_Area([H1|T],Max).
max_Area( [H1,H2|T],Max):-
        house(_,_,Area1,_,_,_,_,_,_)=H1,
        house(_,_,Area2,_,_,_,_,_,_)=H2,
	Area1 =< Area2,
	max_Area([H2|T],Max).


% ������� ��� ���������� ��� ���������� �� ����� �� ����������� �������
% ��� ��� ����� �� ��� ���� �� ����� ��� ������� ���� ���� �����
% L .�� ��� ������ ������� ����������� � ���� �����.
max_bidder([],M,_,_):-M=[].
max_bidder([M],Max,L,_):-(not(member(M,L))-> Max=M ; Max=[]).
max_bidder( [H1,H2|T],Max,L,House):-

   ( member(H1,L),      member(H2,L) ->  max_bidder(T,Max,L,House) ;
   ( member(H1,L) , not(member(H2,L))->  max_bidder([H2|T],Max,L,House)) ;
   ( not(member(H1,L)), member(H2,L) ->  max_bidder([H1|T],Max,L,House)) ;


   find_Full_Price(House,H1,Full_Price1),
   find_Full_Price(House,H2,Full_Price2),

   Full_Price1 > Full_Price2  ,
   max_bidder([H1|T],Max,L,House)).


max_bidder( [H1,H2|T],Max,L,House):-

   ( member(H1,L),      member(H2,L) -> max_bidder(T,Max,L,House) ;
   ( member(H1,L) , not(member(H2,L))-> max_bidder([H2|T],Max,L,House)) ;
   ( not(member(H1,L)), member(H2,L) -> max_bidder([H1|T],Max,L,House)) ;

   find_Full_Price(House,H1,Full_Price1),
   find_Full_Price(House,H2,Full_Price2),

   Full_Price1 =< Full_Price2,
   max_bidder([H2|T],Max,L,House)).



% ������� �� �������� ��� ����� ��� ��� request ��� ���������� ��
% �������� ���� ������� �� ��� ���������� �������� �� �� �������.
find_Full_Price(House,Request,Full_Price):-

   house(_,_,Ar,Cntr,_,_,_,Grd,_)=House,

   request(_,Area,_,_,_,_,Center,Suburb,More_Area,Garden)=Request,

   Total_Area is (Ar-Area)*More_Area,
   (  Grd > 0 -> Total_Garden_Area is Grd*Garden ; Total_Garden_Area is 0),

   (  Cntr=='yes' -> Full_Price is (Total_Area + Total_Garden_Area +Center)
                   ; Full_Price is (Total_Area + Total_Garden_Area + Suburb)).


% ��������� ��������� ��� ��������� ��� ����������� ��� ����� ����
% ������.
add_tail([],X,[X]).
add_tail([H|T],X,[H|L]):-add_tail(T,X,L).

% �� �� ������ ����� ���� ����� ���������� true.
list_Empty([]).


% ��������� ��������� ��� ������� ��� ����������� ��� ��� �����.
delete_Element(_,[],[]).
delete_Element(X,[X|T],T1) :-
	delete_Element(X,T,T1).
delete_Element(X,[H|T],[H|T1]) :-
	delete_Element(X,T,T1).

