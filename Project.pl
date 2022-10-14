%Κωνσταντίνος - Ηλίας Χονδρορρίζος , Α.Ε.Μ : 3812
%Ανδρέας Ναλμπάντης , Α.Ε.Μ : 3699




%Κάνει consult τα αρχεία των σπιτιών και των αιτήσεων
:-['houses.pl','requests.pl'].

% Η κύρια συνάρτηση του προγράμματος .Εμφανίζει το μενού και ζητάει από
% τον χρήστη να επιλέξει μια λειτουργία.
run :-
   nl,nl,
   write('Μενού: \n======\n
1 - Προτιμήσεις ενός πελάτη
2 - Μαζικές προτιμήσεις πελατών
3 - Επιλογή πελατών μέσω δημοπρασίας
0 - Έξοδος
'),nl,

   write('Επιλογή: '),read(Number),
   (   (Number>=0,Number<4)  -> process(Number)
   ;   write('\nΕπίλεξε έναν αριθμό μεταξύ 0 έως 3'),nl,nl,run).

% Επιλογή 1η.
% Ζητάει από τον χρήστη τις απαραίτητες πληροφορίες και του βρίσκει
% όλα τα συμβατά σπίτια με βάση αυτές.
process(1) :-
    write('Δώσε τις παρακάτω πληροφορίες:'),nl,nl,
    write('=============================='),nl,nl,

    write('Ελάχιστο εμβαδόν'),read(Area),
    write('Ελάχιστος αριθμός υπνοδωματίων:'),read(Bedrooms),
    write('Να επιτρέπονται κατοικίδια; (yes/no)'),read(Pets),
    write('Από ποιον όροφο και πάνω να υπάρχει ανελκυστήρας;'),read(Elev_level),
    write('Ποιο είναι το μέγιστο ενοίκιο που μπορείς να πληρώσεις;'),read(Rent),
    write('Πόσα θα έδινες για ένα διαμέρισμα στο κέντρο της πόλης (στα ελάχιστα τετραγωνικά);'),nl,read(Center),
    write('Πόσα θα έδινες για ένα διαμέρισμα στα προάστια της πόλης (στα ελάχιστα τετραγωνικά); '),nl,read(Suburb),
    write('Πόσα θα έδινες για κάθε τετραγωνικό διαμερίσματος πάνω από το ελάχιστο;'),read(More_Area),
    write('Πόσα θα έδινες για κάθε τετραγωνικό κήπου;'),read(Garden),nl,

    findall(house(Addr,Bdrms,Ar,Cntr,Lvl,Elvtr,Pts,Grd,Rnt),(house(Addr,Bdrms,Ar,Cntr,Lvl,Elvtr,Pts,Grd,Rnt)),L),

    % Η λίστα CompHouses έχει όλα τα σπίτια που πληρούν τις απαιτήσεις του χρήστη.
    compatible_houses(Area,Bedrooms,Pets,Elev_level,Rent,Center,Suburb,More_Area,Garden,L,CompHouses),

    length(CompHouses,Leng),( Leng==0  -> nl,write('Δεν υπάρχει κατάλληλο σπίτι!'),nl,nl ;

    % Τυπώνει τα σπίτια και προτείνει το BestHouse που επέστρεψε η find_best_house.
    print_houses(CompHouses) ,
    find_best_house(CompHouses,BestHouse),
    house(Adress,_,_,_,_,_,_,_,_) = BestHouse,
    write('Προτείνεται η ενοικίαση του διαμερίσματος στην διεύθυνση: '),write(Adress),nl,nl
    ),

    run.


% Επιλογή 2η.
% Από το αρχείο requests.pl αντλεί τις πληροφορίες των χρηστών για τα
% διαμερίσματα και ακολουθεί τα πρότυπα της 1ης επιλογής για τον
% υπολογισμό και την εμφάνιση τους.
process(2) :-

   findall(request(Name,Area,Bedrooms,Pets,Elevator,Rent,Rent_Center,Rent_Suburb,More_Area,More_Garden),
          (request(Name,Area,Bedrooms,Pets,Elevator,Rent,Rent_Center,Rent_Suburb,More_Area,More_Garden)),
           Requests),

   findall(house(Addr,Bdrms,Ar,Cntr,Lvl,Elvtr,Pts,Grd,Rnt),(house(Addr,Bdrms,Ar,Cntr,Lvl,Elvtr,Pts,Grd,Rnt)),L),
   find_houses(Requests,L),
   print_Process2(Requests),
   run.

% Επιλογή 3η.
% Επιλεγεί αυτόματα - ανταγωνιστικά ενα διαμέρισμα (εαν αυτό υπάρχει)
% για το κάθε request.
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
   ; nl,write('Κανένας δεν Θα ενοικιάσει κάποιο διαμερισμα.')),

   abolish(best_house/2),
   abolish(bidders/2),

   run.

%Επιλογή 4η.
%Έξοδος απο το πρόγραμμα.
process(0) :- halt(0).

% ------------------------------------------------------------------------

print_final_bidders([],[]).

% Εμφανίζει αυτούς που δεν θα ενοικιάσουν κάποιο σπίτι.
print_final_bidders([],[H|T]):-
   request(Name,_,_,_,_,_,_,_,_,_)=H,

   write('O πελάτης '),write(Name),write(' δεν θα νοικιάσει κάποιο διαμέρισμα!'),nl,
   print_final_bidders([],T).

% Δέχεται ως είσοδο μια λίστα με κατηγορήματα final_bidders οπού είναι
% της μορφής Request - House και όλα τα requests που υπάρχουν στην βάση.
% Όταν τυπώνει εάν στοιχείο της λίστας ,αφαιρεί το αντίστοιχο request από
% την βάση ,έτσι ώστε αυτά που θα περισσέψουν να είναι οι πελάτες που δεν
% θα ενοικιάσουν κάποιο διαμέρισμα.
print_final_bidders([H|T],Requests):-
   final_bidders(Req,House)=H,
   request(Name,_,_,_,_,_,_,_,_,_)=Req,
   house(Addr,_,_,_,_,_,_,_,_)=House,
   write('O πελάτης '),write(Name),write(' θα νοικιάσει το διαμέρισμα στην διεύθυνση: '),write(Addr),nl,
   select(Req,Requests,Rest),

   print_final_bidders(T,Rest).


% Δέχεται ως είσοδο μια λίστα με κατηγορήματα bidders της μορφής
% House - Bidders οπού για κάθε διαμέρισμα ,bidders είναι οι
% υποψήφιοι ενοικιαστές του .Το predicate τώρα ,βρίσκει τον ενοικιαστή
% που προσφέρει το μεγαλύτερο ενοίκιο και δημιουργεί ενα dynamic fact
% final_bidders(Ενοικιαστής - σπίτι) εφόσον το σπίτι δεν υπάρχει μέσα
% στην λίστα L η οποία περιλαμβάνει όλα τα σπίτια που έχουν ήδη
% κατοχυρωθεί .Επιπλέον η αναζήτηση για τους καλύτερους ενοικιαστές
% ξεκινάει απο τα διαμερίσματα που είναι προτιμητέα (BestHouses).
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

% Προσπελάζει αναδρομικά την λίστα με τα σπίτια που δέχεται στην
% είσοδο και αποθηκεύει τους υποψήφιους ενοικιαστές του κάθε
% διαμερίσματος στο fact bidders(διαμέρισμα - ενοικιαστές).
loop_houses([],_).
loop_houses([H|T],Requests):-
   house_bidders(H,Requests,Comp_Bidders),
   assert(bidders(H,Comp_Bidders)),
   loop_houses(T,Requests).

% Για το σπίτι που δέχεται στην είσοδο (House) βρίσκει τους υποψήφιους
% ενοικιαστές του και τους επιστρέφει μέσο της λίστας L.
house_bidders(_,[],_).
house_bidders(House,[H|T],L):-

   house_bidders(House,T,Rest),

   request(_,Area,Bedrooms,Pets,Elevator,Rent,Rent_Center,Rent_Suburb,More_Area,More_Garden)=H  ,

   (compatible_house(Area,Bedrooms,Pets,Elevator,Rent,Rent_Center,Rent_Suburb,More_Area,More_Garden,House) -> add_tail(Rest,H,L) ; L=Rest ).


% Δέχεται τις απαιτήσεις ενός υποψήφιου ενοικιαστή και ενα διαμέρισμα και
% επιστρέφει true εάν το αυτό είναι συμβατό με τις απαιτήσεις του.
% Ειδάλλως επιστρέφει false.
compatible_house(Area,Bedrooms,Pets,Elev_level,Rent,Center,Suburb,More_Area,Garden,House):-

   house(_,Bdrms,Ar,_,Lvl,Elvtr,Pts,_,Rnt)=House,

   Ar >= Area ,

   Bdrms >= Bedrooms,

   (  Pts=='yes' -> true ; Pts == Pets ),

   (  Elvtr == 'yes' -> true ; Lvl < Elev_level ),


   find_Full_Price(House,request(_,Area,_,_,_,Rent,Center,Suburb,More_Area,Garden),Full_Price),


   Full_Price >= Rnt,
   Rent >= Rnt.

% Δημιουργεί αναδρομικά μια λίστα με όλα τα διαμερίσματα που είναι
% συμβατά με τις απαιτήσεις και τα επιστρέφει στην μεταβλητή L.
compatible_houses(_,_,_,_,_,_,_,_,_,[],_).
compatible_houses(Area,Bedrooms,Pets,Elev_level,Rent,Center,Suburb,More_Area,Garden,[H|T],L):-

   compatible_houses(Area,Bedrooms,Pets,Elev_level,Rent,Center,Suburb,More_Area,Garden,T,Rest),

   (   compatible_house(Area,Bedrooms,Pets,Elev_level,Rent,Center,Suburb,More_Area,Garden,H) -> add_tail(Rest,H,L) ; L=Rest ).


% Παίρνει σαν είσοδο μια λίστα με όλα τα requests και για το κάθε ενα
% εμφανίζει τα συμβατά σπίτια ,αλλά και το προτεινόμενο του.
print_Process2([]):-abolish(compatibles/2),abolish(best_house/2).
print_Process2([H|T]):-

   compatibles(H,Houses),
   request(Name,_,_,_,_,_,_,_,_,_)=H,
   write('Κατάλληλα διαμερίσματα για τον πελάτη: '),write(Name),nl,write('======================================='),nl,
   length(Houses,Leng),( Leng==0  -> nl,write('Δεν υπάρχει κατάλληλο σπίτι!'),nl,nl ;

   print_houses(Houses) ,

   best_house(H,BestHouse),
   house(Adress,_,_,_,_,_,_,_,_) = BestHouse,
   write('Προτείνεται η ενοικίαση του διαμερίσματος στην διεύθυνση: '),write(Adress),nl,nl
   ),

   print_Process2(T).

% Για κάθε εγγραφή στο αρχείο request.pl ,υπολογίζει επαναληπτικά τα
% διαμερίσματα που είναι συμβατά με τις απαιτήσεις καθώς και αυτό που
% προτείνετε και στην συνέχεια τα αποθηκεύει στην μνήμη σαν facts
% compatibles/2 , best_house/2 .Σε περίπτωση που δεν υπάρχει κάποιο
% συμβατό σπίτι ,ως best_house αποθηκεύετε το κενό (house('','','','','','','','',''))
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


% Καλεί μια σειρά από συναρτήσεις με σκοπό να βρεθεί το καλύτερο από τα
% σπίτια που υπάρχουν στην λίστα Houses και να επιστραφεί μέσω της
% μεταβλητής BestHouse
find_best_house(Houses,BestHouse):-

   find_cheap(Houses,Res1),
   find_biggest_garden(Res1,Res2),
   find_biggest_house(Res2,Res3),
   nth0(0,Res3,BestHouse).


% Βρίσκει το διαμέρισμα με το φθηνότερο ενοίκιο της λίστας Houses και
% εφόσον υπάρχουν και αλλά με την ιδιά τιμή στην λίστα αυτή, τα
% επιστρέφει μέσω της μεταβλητής Res.
find_cheap(Houses,Res):-
   min_Rent(Houses,Cheaper),
   house(_,_,_,_,_,_,_,_,Rent)= Cheaper,
   findall(house(Addr,Bdrms,Ar,Cntr,Lvl,Elvtr,Pts,Grd,Rent),(house(Addr,Bdrms,Ar,Cntr,Lvl,Elvtr,Pts,Grd,Rent),
                                                            member(house(Addr,Bdrms,Ar,Cntr,Lvl,Elvtr,Pts,Grd,Rent),Houses)),Res).

% Βρίσκει το διαμέρισμα με τον μεγαλύτερο κήπο της λίστας Houses και
% εφόσον υπάρχουν και αλλά με την ιδιά έκταση στην λίστα αυτή, τα
% επιστρέφει μέσω της μεταβλητής Res.
find_biggest_garden(Houses,Res):-
   max_Garden(Houses,Biggest_Garden),
   house(_,_,_,_,_,_,_,Garden,_)= Biggest_Garden,
   findall(house(Addr,Bdrms,Ar,Cntr,Lvl,Elvtr,Pts,Garden,Rnt),(house(Addr,Bdrms,Ar,Cntr,Lvl,Elvtr,Pts,Garden,Rnt),
                                                            member(house(Addr,Bdrms,Ar,Cntr,Lvl,Elvtr,Pts,Garden,Rnt),Houses)),Res).

% Βρίσκει το διαμέρισμα με τα περισσότερα τετραγωνικά της λίστας Houses
% και εφόσον υπάρχουν και αλλά με την ιδιά έκταση στην λίστα αυτή, τα
% επιστρέφει μέσω της μεταβλητής Res.
find_biggest_house(Houses,Res):-
   max_Area(Houses,Biggest_Area),
   house(_,_,Area,_,_,_,_,_,_)= Biggest_Area,
   findall(house(Addr,Bdrms,Area,Cntr,Lvl,Elvtr,Pts,Grd,Rnt),(house(Addr,Bdrms,Area,Cntr,Lvl,Elvtr,Pts,Grd,Rnt),
                                                            member(house(Addr,Bdrms,Area,Cntr,Lvl,Elvtr,Pts,Grd,Rnt),Houses)),Res).

% Δέχεται εάν διαμέρισμα και το εμφανίζει με βάση τα πρότυπα της
% εκφώνησης.
print_house(House):-
   house(Addrs,Bdrms,Ar,Cntr,Lvl,Elvtr,Pts,Grd,Rnt)= House,
   write('Κατάλληλο σπίτι στην διεύθυνση: '),write(Addrs),nl,
   write('Υπνοδωμάτια: '),write(Bdrms),nl,
   write('Εμβαδόν: '),write(Ar),nl,
   write('Εμβαδόν κήπου: '),write(Grd),nl,
   write('Είναι στο κέντρο της πόλης: '),write(Cntr),nl,
   write('Επιτρέπονται κατοικίδια: '),write(Pts),nl,
   write('Όροφος: '),write(Lvl),nl,
   write('Ανελκυστήρας: '),write(Elvtr),nl,
   write('Ενοίκιο: '),write(Rnt),nl,nl.

% Εμφανίζει όλα τα σπίτια της λίστας που δέχεται.
print_houses([]).
print_houses([H|T]):-
   print_houses(T),
   print_house(H).

% Βρίσκει το σπίτι με το μικρότερο ενοίκιο.
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

% Βρίσκει το σπίτι με τον μεγαλύτερο κήπο.
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

% Βρίσκει το σπίτι με τα περισσότερα τετραγωνικά.
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


% Βρίσκει τον ενοικιαστή που προτίθεται να δώσει τα περισσότερα χρήματα
% για ενα σπίτι αν και μονο αν αυτός δεν υπάρχει μέσα στην λίστα
% L .Αν δεν βρεθεί κάποιος επιστρέφετε η κενή λίστα.
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



% Παίρνει ως ορίσματα ενα σπίτι και ενα request και υπολογίζει το
% συνολικό ποσό σύμφωνα με τις απαιτήσεις σχετικές με το ενοίκιο.
find_Full_Price(House,Request,Full_Price):-

   house(_,_,Ar,Cntr,_,_,_,Grd,_)=House,

   request(_,Area,_,_,_,_,Center,Suburb,More_Area,Garden)=Request,

   Total_Area is (Ar-Area)*More_Area,
   (  Grd > 0 -> Total_Garden_Area is Grd*Garden ; Total_Garden_Area is 0),

   (  Cntr=='yes' -> Full_Price is (Total_Area + Total_Garden_Area +Center)
                   ; Full_Price is (Total_Area + Total_Garden_Area + Suburb)).


% Βοηθητική συνάρτηση που προσθέτει ενα αντικείμενο στο τέλος μιας
% λίστας.
add_tail([],X,[X]).
add_tail([H|T],X,[H|L]):-add_tail(T,X,L).

% Αν το όρισμα είναι κενή λίστα επιστρέφει true.
list_Empty([]).


% Βοηθητική συνάρτηση που αφαιρεί ένα αντικείμενο από μια λίστα.
delete_Element(_,[],[]).
delete_Element(X,[X|T],T1) :-
	delete_Element(X,T,T1).
delete_Element(X,[H|T],[H|T1]) :-
	delete_Element(X,T,T1).

