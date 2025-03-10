(************************************************************************************************************************

Ce programme sert à générer à faire des manipulations sur des arbres binaires de recherche, puis à générer un code tikz
au format qtree qui représente l'arbre obtenu.

************************************************************************************************************************)


type abr = Vide | Arbre of (int * abr * abr)


(*Effectue la découpe de [arbre] selon le pivot [k] : renvoie deux arbres de valeurs < et >= à [k]*)
let rec decoupe arbre k =
  match  arbre with
  | Vide -> (Vide, Vide)
  | Arbre (r, g, d) ->
    (
      if r=k then (g,d)
      else if r<k then let (d1,d2) = decoupe d k in ((Arbre (r, g, d1)), d2)
      else let (g1,g2) = decoupe g k in (g1, (Arbre (r, g2, d)))
    )

(*Ajoute [x] à la racine d'[arbre] tout en gardant la structure d'ABR*)
let ajout_racine arbre x =
  let (g,d) = decoupe arbre x in
  Arbre (x, g, d)

(*Ajoute [x] aux feuilles d'[arbre] tout en gardant la structure d'ABR*)
let rec ajout_feuille arbre x = match arbre with
  Vide -> Arbre(x, Vide, Vide)
  |Arbre (r, g, d) when r>x -> Arbre(r, ajout_feuille g x, d)
  |Arbre (r, g, d) when r=x -> arbre
  |Arbre (r, g, d)          -> Arbre(r, g, ajout_feuille d x)

(*Ajoute tous les élements de [l] à la racine de [arbre]*)
let ajout_racine_liste arbre l =
  List.fold_left ajout_racine arbre l

(*Ajoute tous les élements de [l] aux feuilles de [arbre]*)
let ajout_feuille_liste arbre l =
  List.fold_left ajout_feuille arbre l

(*Affiche l'arbre au format tikz-qtree pour une utilisation LaTeX*)
let affiche_qtree arbre = 
  let rec aux arbre = match arbre with
    Vide -> print_string " $\\bullet$ " (*L'arbre vide est représenté par un point*)
    |Arbre (r, Vide, Vide) ->
      (print_string ("[.") ;
      print_int r ;
      print_string(" ") ;
      print_string " ]")
    |Arbre (r, g, Vide) ->
      (   print_string ("[.") ;
      print_int r ;
      print_string(" ") ;
      aux g ;
      print_string(" $\\bullet$ ") ;
      print_string " ]")
    |Arbre (r, Vide, d) ->
      (print_string ("[.") ;
      print_int r ;
      print_string(" $\\bullet$ ") ;
      print_string(" ") ;
      aux d ; 
      print_string " ]") 
    |Arbre (r, g, d) ->
      (   print_string ("[.") ;
      print_int r ;
      print_string(" ") ;
      aux g ;
      print_string(" ") ;
      aux d ; 
      print_string " ]") 
    in
      print_string "\\Tree " ; aux arbre ; print_newline()


(*Génère une liste de listes représentant le groupe symétrique à [n] éléments*)
let permutations n =
  (*Ajoute [x] à la [k]ième position de la liste [l]*)
  let ajout_k l x k =
    let rec aux l acc = if acc=0 then (x::l)
    else match l with
      []-> failwith "liste trop courte"
      |t::q-> t::(aux q (acc-1))
    in
      aux l k
  in
  (*Renvoie la liste des [ajout_k l x k] pour tout k allant de 0 à [n]-1*)
  let ajout_tout_k l x n =
    let res = ref [] in
    for k=0 to (n-1) do 
      res := (ajout_k l x k)::(!res)
    done;
    !res
  in
  (*Effectue [ajout_tout_k] pour chaque élément de l*)
  let rec ajout_partout l x n = match l with
    []->[]
    |t::q-> (ajout_tout_k t x n)@(ajout_partout q x n)
  in
  (*Fonction auxilliaire récursive qui renvoie Sn*)
  let rec aux n =
    if n=0 then [[]]
    else let l = aux (n-1) in (ajout_partout l n n)
  in
    List.rev (aux n) (*Pour avoir un ordre plus cohérent*)



(*Exemple : générer les ABR3, sur 12 colones*)

let () =
  let n = 4 in
  let colonne = 8 in
  let l = ref (permutations n) in
  let compteur = ref 0 in
  while !l <> [] do
    match (!l) with
      []->failwith "ERREUR"
      |t::q->
        (
          print_string ("\\begin{scope}[shift={(");
          print_int (4*((!compteur) mod colonne));
          print_string (",");
          print_int (-6*((!compteur)/colonne));
          print_string(")}]");
          affiche_qtree (ajout_racine_liste Vide t);
          print_string ("\\end{scope}");
          print_newline();
          l:=q;

          incr compteur;
        )
  done
