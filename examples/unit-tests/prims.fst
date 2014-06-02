(*
   Copyright 2008-2014 Nikhil Swamy and Microsoft Research

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*)
module Prims

kind Unop  = Type => Type           (* simple kind abbreviation *)
kind Binop = Type => Type => Type   
type l_not : Unop  (* prefix unary '~' *)
type l_and : Binop (* infix binary '/\' *)
type l_or  : Binop (* infix binary '\/' *)
type l_iff : Binop (* infix binary '<==>' *)
type l_imp : Binop (* infix binary '==>' *)
type Forall : #'a:Type => ('a => Type) => Type
type Exists : #'a:Type => ('a => Type) => Type
type ForallTyp : (Type => Type) => Type
type ExistsTyp : (Type => Type) => Type
type True : Type
type False : Type
type EqTyp : Type => Type => Type                    (* infix binary '==' *)
type Eq2 : #'a:Type => #'b:Type => 'a => 'b => Type  (* infix binary '==' *)
type TypeOf : #'a:Type => 'a => Type
type KindOf : Type => Type
type XOR = fun ('P:Type) ('Q:Type) => ('P \/ 'Q) /\ ~('P /\ 'Q)
type ITE = fun ('P:Type) ('Q:Type) ('R:Type) => ('P ==> 'Q) /\ (~'P ==> 'R) (* if/then/else in concrete syntax at the level of types/formulae *)

monad_lattice { (* The definition of the PURE effect is fixed; no user should ever change this *)
  PURE::
             terminating
             kind Pre = Type
             kind Post ('a:Type) = 'a => Type
             kind WP ('a:Type) = Post 'a => Pre
             type return   ('a:Type) (x:'a) ('p:Post 'a) = 'p x
             type bind_wp  ('a:Type) ('b:Type) ('wp1:WP 'a) ('wlp1:WP 'a) ('wp2: 'a => WP 'b) ('wlp2:'a => WP 'b) ('p:Post 'b) = 'wp1 (fun a => 'wp2 a 'p)
             type bind_wlp ('a:Type) ('b:Type) ('wp1:WP 'a) ('wlp1:WP 'a) ('wp2: 'a => WP 'b) ('wlp2:'a => WP 'b) ('p:Post 'b) = 'wlp1 (fun a => 'wlp2 a 'p)
             type ite_wlp ('a:Type) ('guard:Type) ('wlp1:WP 'a) ('wlp2:WP 'a) ('post:Post 'a) = 
                 (forall (a:'a). 'post a \/ (if 'guard 
                                             then 'wlp1 (fun a1 => a=!=a1)
                                             else 'wlp2 (fun a2 => a=!=a2)))
             type ite_wp  ('a:Type) ('guard:Type) ('wp1:WP 'a) ('wlp1:WP 'a) ('wp2:WP 'a) ('wlp2:WP 'a) ('post:Post 'a) = 
                 //ite_wlp 'a 'guard 'wlp1 'wlp2 'post 
                 (forall (a:'a). 'post a \/ (if 'guard 
                                             then 'wlp1 (fun a1 => a=!=a1)
                                             else 'wlp2 (fun a2 => a=!=a2)))
                 /\ 'wp1 (fun a => True)
                 /\ 'wp2 (fun a => True)
             type imp_wp ('a:Type) ('wp1:WP 'a) ('wp2:'WP 'a) = forall ('p:Post 'a). 'wp1 'p ==> 'wp2 'p
             type close_wp ('a:Type) ('b:Type) ('wp:'b => 'WP 'a) ('p:Post 'a) = forall (b:'b). 'wp b p
             with Total ('a:Type) ('pre:Pre) ('post:Post 'a) =
                 PURE 'a 
                   (fun ('p:Post 'a) => 'pre /\ (forall a. 'pre /\ 'post a ==> 'p a)) (* WP *)
                   (fun ('p:Post 'a) => forall a. 'pre /\ 'post a ==> 'p a)           (* WLP *)
             and Tot ('a:Type) =
                 Total 'a True (fun a => True)
}
type assert_pure ('a:Type) ('P:Type) : Pure.WP 'a = fun ('post:WP.Post 'a) => 'P /\ 'P ==> (forall (x:'a). 'post x)
type assume_pure ('a:Type) ('P:Type) : Pure.WP 'a = fun ('post:WP.Post 'a) => 'P ==> (forall (x:'a). 'post x)

type bool
type b2t (b:bool) = b==true
type unit
assume Unit_id: forall (x:unit). x==()
type int
type char
type byte
type uint16
type int32 = int
type int64
type float
type double = float
type string
type array : Type => Type
type ref : Type => Type
type LBL : string => Type => Type
type bytes
type exn

logic data type option 'a =
  | None : option 'a
  | Some : v:'a -> option 'a

type heap
logic val SelHeap : 'a:Type -> heap -> ref 'a -> 'a
logic val UpdHeap : 'a:Type -> heap -> ref 'a -> 'a -> heap    
logic val EmpHeap : heap
logic val InHeap  : 'a:Type -> heap -> ref 'a -> bool
assume SelUpd1: forall ('a:Type) (h:heap) (x:ref 'a) (v:'a).{:pattern (SelHeap (UpdHeap h x v) x)} SelHeap (UpdHeap h x v) x == x
assume SelUpd2: forall ('a:Type) ('b:Type) (h:heap) (x:ref 'a) (y:ref 'b) (v:'b).{:pattern (SelHeap (UpdHeap h y v) x)} y=!=x ==> SelHeap (UpdHeap h y v) x == SelHeap h x
assume InHeap1:  forall ('a:Type) (h:heap) (x:ref 'a) (v:'a).{:pattern (InHeap (UpdHeap h x v) x)} InHeap (UpdHeap h x v) x == true
assume InHeap2:  forall ('a:Type) ('b:Type) (h:heap) (x:ref 'a) (y:ref 'b) (v:'b).{:pattern (InHeap (UpdHeap h y v) x)} y=!=x ==> InHeap (UpdHeap h y v) x == InHeap h x

type refset
logic val EmptySet : refset
logic val Singleton : ref 'a -> refset
logic val Union : refset -> refset -> refset
logic val Intersection : refset -> refset -> refset
type InSet : #'a:Type => ref 'a => refset => Type
type SetEqual : refset => refset => Type
assume InEmptySet:     forall a. ~(InSet a EmptySet)
assume InSingleton:    forall a. InSet a (Singleton a)
assume InSingletonInv: forall a b. InSet a (Singleton b) <==> a==b
assume InUnion:        forall s1 s2 a. InSet a (Union s1 s2) <==> (InSet a s1 \/ InSet a s1)
assume InUnionL:       forall s1 s2 a. InSet a s1 ==> InSet a (Union s1 s2)
assume InUnionR:       forall s1 s2 a. InSet a s2 ==> InSet a (Union s1 s2)
assume UnionIdemL:     forall s1 s2. Union (Union s1 s2) s2 == Union s1 s2
assume UnionIdemR:     forall s1 s2. Union s1 (Union s1 s2) == Union s1 s2
assume InInter:        forall s1 s2 a. InSet a (Intersection s1 s2) <==> (InSet a s1 /\ InSet a s2)
assume InterIdemL:     forall s1 s2. Intersection (Intersection s1 s2) s2 == Intersection s1 s2
assume InterdemR:      forall s1 s2. Intersection s1 (Intersection s1 s2) == Intersection s1 s2
assume SetEqualDef:    forall s1 s2. SetEqual s1 s2 <==> (forall a. InSet a s1 <==> InSet a s2)
assume SeqEqualExt:    forall s1 s2. SetEqual s1 s2 ==> s1==s2 
logic data type refs = 
  | AllRefs : refs
  | SomeRefs : v:refset -> refs

let modifies (r:refs) = r 

type Modifies (mods:refs) (h:heap) (h':heap) =
    (if b2t (is_AllRefs mods)
     then True
     else forall 'b (x:ref 'b). (b2t (InHeap h x) /\ ~(InSet x (SomeRefs.v mods))) ==> (b2t (InHeap h' x) /\ SelHeap h x==SelHeap h' x))

logic data type result : Type => Type =
  | V : 'a:Type -> v:'a -> result 'a
  | E : 'a:Type -> e:exn -> result 'a
  | Err : 'a:Type -> msg:string -> result 'a

val retype : result 'a -> PURE.Tot (result 'b)
let retype 'a 'b r = match r with 
  | V _ -> Err "impos"
  | Err m -> Err m
  | E e -> E e 

monad_lattice {
  STATE::
             kind Pre     = heap => Type
             kind Post ('a:Type) = 'a => heap => Type
             kind WP ('a:Type) = Post 'a => Pre
             type return   ('a:Type) (x:'a) ('p:Post 'a) = 'p x
             type bind_wp  ('a:Type) ('b:Type) ('wp1:WP 'a) ('wlp1:WP 'a) ('wp2:'a => WP 'b) ('wlp2:'a => WP 'b) ('p:Post 'b) (h0:heap) = 'wp1 (fun a => 'wp2 a 'p) h0
             type bind_wlp ('a:Type) ('b:Type) ('wp1:WP 'a) ('wlp1:WP 'a) ('wp2:'a => WP 'b) ('wlp2:'a => WP 'b) ('p:Post 'b) (h0:heap) = 'wlp1 (fun a => 'wlp2 a 'p) h0
             type ite_wlp  ('a:Type) ('guard:Type) ('wlp1:WP 'a) ('wlp2:WP 'a) ('post:Post 'a) (h0:heap) = 
                 (forall (a:'a) (h:heap). 'post a h \/ (if 'guard 
                                                        then 'wlp1 (fun a1 h1 => a=!=a1 /\ h=!=h1) h0
                                                        else 'wlp2 (fun a2 h2 => a=!=a2 /\ h=!=h2) h0))
             type ite_wp ('a:Type) ('guard:Type) ('wp1:WP 'a) ('wlp1:WP 'a) ('wp2:WP 'a) ('wlp2:WP 'a) ('post:Post 'a) (h0:heap) = 
                 (forall (a:'a) (h:heap). 'post a h \/ (if 'guard 
                                                        then 'wlp1 (fun a1 h1 => a=!=a1 /\ h=!=h1) h0
                                                        else 'wlp2 (fun a2 h2 => a=!=a2 /\ h=!=h2) h0))
                 (* ite_wlp 'a 'guard 'wlp1 'wlp2 'post h *)
                 /\ 'wp1 (fun a h_ => True) h0
                 /\ 'wp2 (fun a h => True) h0
             type imp_wp ('a:Type) ('wp1:WP 'a) ('wp2:'WP 'a) = forall ('p:Post 'a) (h:heap). 'wp1 'p h ==> 'wp2 'p h
             type close_wp ('a:Type) ('b:Type) ('wp:'b => 'WP 'a) ('p:Post 'a) = forall (b:'b) (h:heap). 'wp b p h
             with ST ('a:Type) ('pre:Pre) ('post: heap => Post 'a) (mods:refs) = 
                 STATE 'a 
                   (fun ('p:Post 'a) (h:heap) => 'pre h /\ (forall a h1. ('pre h /\ Modifies mods h h1 /\ 'post h a h1) ==> 'p a h1)) (* WP *)
                   (fun ('p:Post 'a) (h:heap) => (forall a h1. ('pre h /\ Modifies mods h h1 /\ 'post h a h1) ==> 'p a h1))           (* WLP *)
;                  
  EXN::
             kind Pre  = Type
             kind Post ('a:Type) = result 'a => Type
             kind WP   ('a:Type) = Post 'a => Pre
             type return ('a:Type) (x:'a) ('p:Post 'a) = 'p (V x)
             type bind_wp ('a:Type) ('b:Type) ('wp1:WP 'a) ('wlp1:WP 'a) ('wp2:'a => WP 'b) ('wlp2:'a => WP 'b) ('p:Post 'b) =
                 (forall (rb:result 'b). 'p rb \/ 'wlp1 (fun ra1 => if b2t (is_V ra1)
                                                                    then 'wlp2 (V.v ra1) (fun rb2 => rb2=!=rb)
                                                                    else retype ra1 =!= rb))
                 /\ 'wp1 (fun ra1 => (ITE (b2t (is_V ra1))
                                          ('wp2 (V.v ra1) (fun rb2 => True))
                                           True))
             type bind_wlp ('a:Type) ('b:Type) ('wp1:WP 'a) ('wlp1:WP 'a) ('wp2:'a => WP 'b) ('wlp2:'a => WP 'b) ('p:Post 'b) =
                 (forall (rb:result 'b). 'p rb \/ 'wlp1 (fun ra1 => if b2t (is_V ra1)
                                                                    then 'wlp2 (V.v ra1) (fun rb2 => rb2=!=rb)
                                                                    else  retype ra1 =!= rb))
             type ite_wlp ('a:Type) ('guard:Type) ('wlp1:WP 'a) ('wlp2:WP 'a) ('post:Post 'a) = 
                 (forall (a:result 'a). 'post a \/ (if 'guard
                                                    then 'wlp1 (fun a1 => a=!=a1)
                                                    else 'wlp2 (fun a2 => a=!=a2)))
             type ite_wp ('a:Type) ('guard:Type) ('wp1:WP 'a) ('wlp1:WP 'a) ('wp2:WP 'a) ('wlp2:WP 'a) ('post:Post 'a) = 
                 (forall (a:result 'a). 'post a \/ (if 'guard
                                                    then 'wlp1 (fun a1 => a=!=a1)
                                                    else 'wlp2 (fun a2 => a=!=a2)))
                 (* ite_wlp 'a 'guard 'wlp1 'wlp2 'post *)
                 /\ 'wp1 (fun ra1 => True)
                 /\ 'wp2 (fun ra2 => True)
             type imp_wp ('a:Type) ('wp1:WP 'a) ('wp2:'WP 'a) = forall ('p:Post 'a). 'wp1 'p ==> 'wp2 'p
             type close_wp ('a:Type) ('b:Type) ('wp:'b => 'WP 'a) ('p:Post 'a) = forall (b:'b). 'wp b p
             with Exn ('a:Type) ('pre:Pre) ('post:Post 'a) =
                 EXN 'a 
                   (fun 'p => 'pre /\ (forall (r:result 'a). ('pre /\ 'post r) ==> 'p r)) (* WP *)
                   (fun 'p => (forall (r:result 'a). ('pre /\ 'post r) ==> 'p r))         (* WLP *)
 ;
  ALL::
             kind Pre  = heap => Type
             kind Post ('a:Type) = result 'a => heap => Type
             kind WP ('a:Type) = Post 'a => Pre
             type return ('a:Type) (x:'a) ('p:Post 'a) = 'p (V x)
             type bind_wp ('a:Type) ('b:Type) ('wp1:WP 'a) ('wlp1:WP 'a) ('wp2:'a => WP 'b) ('wlp2:'a => WP 'b) ('p:Post 'b) (h0:heap) =
                 (forall rb h. 'p rb h \/ 'wlp1 (fun ra h1 => if b2t (is_V ra)
                                                              then 'wlp2 (V.v ra) (fun rb2 h2 => ~(rb==rb2 \/ h==h2)) h1
                                                              else ~(rb==retype ra \/ h==h1)) h0)
                 /\ 'wp1 (fun ra h1 => if b2t (is_V ra)
                                       then 'wp2 (V.v ra) (fun _a _b => True) h1
                                       else True) h0
             type bind_wlp ('a:Type) ('b:Type) ('wp1:WP 'a) ('wlp1:WP 'a) ('wp2:'a => WP 'b) ('wlp2:'a => WP 'b) ('p:Post 'b) (h0:heap) =
                 (forall rb h. 'p rb h \/ 'wlp1 (fun ra h1 => if b2t (is_V ra)
                                                              then 'wlp2 (V.v ra) (fun rb2 h2 => ~(rb==rb2 \/ h==h2)) h1
                                                              else ~(rb==retype ra \/ h==h1)) h0)
                 /\ 'wp1 (fun ra h1 => if b2t (is_V ra)
                                       then 'wp2 (V.v ra) (fun _a _b => True) h1
                                       else True) h0
             type ite_wlp ('a:Type) ('guard:Type) ('wlp1:WP 'a) ('wlp2:WP 'a) ('post:Post 'a) (h0:heap) = 
                 (forall (ra:result 'a) (h:heap). 'post ra h \/ (if 'guard 
                                                                 then 'wlp1 (fun ra1 h1 => ra=!=ra1 /\ h=!=h1) h0
                                                                 else 'wlp2 (fun ra2 h2 => ra=!=ra2 /\ h=!=h2) h0))
             type ite_wp ('a:Type) ('guard:Type) ('wp1:WP 'a) ('wlp1:WP 'a) ('wp2:WP 'a) ('wlp2:WP 'a) ('post:Post 'a) (h0:heap) = 
                 (forall (ra:result 'a) (h:heap). 'post ra h \/ (if 'guard 
                                                                 then 'wlp1 (fun ra1 h1 => ra=!=ra1 /\ h=!=h1) h0
                                                                 else 'wlp2 (fun ra2 h2 => ra=!=ra2 /\ h=!=h2) h0))
                 (* ite_wlp 'a 'guard 'wlp1 'wlp2 'post h *)
                 /\ 'wp1 (fun _a _b => True) h0
                 /\ 'wp2 (fun _a _b => True) h0
             type imp_wp ('a:Type) ('wp1:WP 'a) ('wp2:'WP 'a) = forall ('p:Post 'a) (h:heap). 'wp1 'p h ==> 'wp2 'p h
             type close_wp ('a:Type) ('b:Type) ('wp:'b => 'WP 'a) ('p:Post 'a) = forall (b:'b) (h:heap). 'wp b p h
             with All ('a:Type) ('pre:Pre) ('post: heap => Post 'a) (mods:refs) = 
                 ALL 'a 
                   (fun ('p:Post 'a) (h:heap) => 'pre h /\ (forall ra h1. ('pre h /\ Modifies mods h h1 /\ 'post h ra h1) ==> 'p ra h1)) (* WP *)
                   (fun ('p:Post 'a) (h:heap) => forall ra h1. ('pre h /\ Modifies mods h h1 /\ 'post h ra h1) ==> 'p ra h1)             (* WLP *)
             and ML ('a:Type) =
                 All 'a (fun h => True) (fun h0 ra h1 => True) AllRefs

  with 
  PURE  ~> STATE = (fun ('a:Type) ('wp:PURE.WP 'a) ('p:STATE.Post 'a) (h:heap) => 'wp (fun a => 'p a h));
  STATE ~> ALL   = (fun ('a:Type) ('wp:STATE.WP 'a) ('p:ALL.Post 'a) => 'wp (fun a => 'p (V a)));
  PURE  ~> EXN   = (fun ('a:Type) ('wp:PURE.WP 'a) ('p:EXN.Post 'a) => 'wp (fun a => 'p (V a)));
  EXN   ~> ALL   = (fun ('a:Type) ('wp:EXN.WP 'a) ('p:ALL.Post 'a) (h:heap) => 'wp (fun ra => 'p ra h))
}

logic data type Tuple2: 'a:Type
          => 'b:('a => Type)
          => Type =
  | MkTuple2: 'a:Type
           -> 'b:('a => Type)
           -> _1:'a
           -> _2:'b _1
           -> Tuple2 'a 'b

logic data type Tuple3: 'a:Type
          => 'b:('a => Type)
          => 'c:(x:'a => 'b x => Type)
          => Type =
  | MkTuple3: 'a:Type
           -> 'b:('a => Type)
           -> 'c:(x:'a => 'b x => Type)
           -> _1:'a
           -> _2:'b _1
           -> _3:'c _1 _2
           -> Tuple3 'a 'b 'c

logic data type Tuple4: 'a:Type
          => 'b:(x:'a => Type)
          => 'c:(x:'a => 'b x => Type)
          => 'd:(x:'a => y:'b x => z:'c x y => Type)
          => Type =
  | MkTuple4: 'a:Type
           -> 'b:('a => Type)
           -> 'c:(x:'a => 'b x => Type)
           -> 'd:(x:'a => y:'b x => z:'c x y => Type)
           -> _1:'a
           -> _2:'b _1
           -> _3:'c _1 _2
           -> _4:'d _1 _2 _3
           -> Tuple4 'a 'b 'c 'd

logic data type Tuple5: 'a:Type
          => 'b:('a => Type)
          => 'c:(x:'a => 'b x => Type)
          => 'd:(x:'a => y:'b x => z:'c x y => Type)
          => 'e:(x:'a => y:'b x => z:'c x y => w:'d x y z => Type)
          => Type =
  | MkTuple5: 'a:Type
           -> 'b:('a => Type)
           -> 'c:(x:'a => 'b x => Type)
           -> 'd:(x:'a => y:'b x => z:'c x y => Type)
           -> 'e:(x:'a => y:'b x => z:'c x y => w:'d x y z => Type)
           -> _1:'a
           -> _2:'b _1
           -> _3:'c _1 _2
           -> _4:'d _1 _2 _3
           -> _5:'e _1 _2 _3 _4
           -> Tuple5 'a 'b 'c 'd 'e

logic data type Tuple6: 'a:Type
          => 'b:('a => Type)
          => 'c:(x:'a => 'b x => Type)
          => 'd:(x:'a => y:'b x => z:'c x y => Type)
          => 'e:(x:'a => y:'b x => z:'c x y => w:'d x y z => Type)
          => 'f:(x:'a => y:'b x => z:'c x y => w:'d x y z => u:'e x y z w => Type)
          => Type =
  | MkTuple6: 'a:Type
           -> 'b:('a => Type)
           -> 'c:(x:'a => 'b x => Type)
           -> 'd:(x:'a => y:'b x => z:'c x y => Type)
           -> 'e:(x:'a => y:'b x => z:'c x y => w:'d x y z => Type)
           -> 'f:(x:'a => y:'b x => z:'c x y => w:'d x y z => v:'e x y z w => Type)
           -> _1:'a
           -> _2:'b _1
           -> _3:'c _1 _2
           -> _4:'d _1 _2 _3
           -> _5:'e _1 _2 _3 _4
           -> _6:'f _1 _2 _3 _4 _5
           -> Tuple6 'a 'b 'c 'd 'e 'f

logic data type Tuple7: 'a:Type
          => 'b:('a => Type)
          => 'c:(x:'a => 'b x => Type)
          => 'd:(x:'a => y:'b x => z:'c x y => Type)
          => 'e:(x:'a => y:'b x => z:'c x y => w:'d x y z => Type)
          => 'f:(x:'a => y:'b x => z:'c x y => w:'d x y z => u:'e x y z w => Type)
          => 'g:(x:'a => y:'b x => z:'c x y => w:'d x y z => u:'e x y z w => v:'f x y z w u => Type)
          => Type =
  | MkTuple7: 'a:Type
           -> 'b:('a => Type)
           -> 'c:(x:'a => 'b x => Type)
           -> 'd:(x:'a => y:'b x => z:'c x y => Type)
           -> 'e:(x:'a => y:'b x => z:'c x y => w:'d x y z => Type)
           -> 'f:(x:'a => y:'b x => z:'c x y => w:'d x y z => u:'e x y z w => Type)
           -> 'g:(x:'a => y:'b x => z:'c x y => w:'d x y z => u:'e x y z w => v:'f x y z w u => Type)
           -> _1:'a
           -> _2:'b _1
           -> _3:'c _1 _2
           -> _4:'d _1 _2 _3
           -> _5:'e _1 _2 _3 _4
           -> _6:'f _1 _2 _3 _4 _5
           -> _7:'g _1 _2 _3 _4 _5 _6
           -> Tuple7 'a 'b 'c 'd 'e 'f 'g

logic data type Tuple8: 'a:Type
          => 'b:('a => Type)
          => 'c:(a:'a => 'b a => Type)
          => 'd:(a:'a => b:'b a => c:'c a b => Type)
          => 'e:(a:'a => b:'b a => c:'c a b => d:'d a b c => Type)
          => 'f:(a:'a => b:'b a => c:'c a b => d:'d a b c => e:'e a b c d => Type)
          => 'g:(a:'a => b:'b a => c:'c a b => d:'d a b c => e:'e a b c d => f:'f a b c d e => Type)
          => 'h:(a:'a => b:'b a => c:'c a b => d:'d a b c => e:'e a b c d => f:'f a b c d e => g:'g a b c d e f => Type)
          => Type =
  | MkTuple8: 'a:Type
           -> 'b:('a => Type)
           -> 'c:(a:'a => 'b a => Type)
           -> 'd:(a:'a => b:'b a => c:'c a b => Type)
           -> 'e:(a:'a => b:'b a => c:'c a b => d:'d a b c => Type)
           -> 'f:(a:'a => b:'b a => c:'c a b => d:'d a b c => e:'e a b c d => Type)
           -> 'g:(a:'a => b:'b a => c:'c a b => d:'d a b c => e:'e a b c d => f:'f a b c d e => Type)
           -> 'h:(a:'a => b:'b a => c:'c a b => d:'d a b c => e:'e a b c d => f:'f a b c d e => g:'g a b c d e f => Type)
           -> _1:'a
           -> _2:'b _1
           -> _3:'c _1 _2
           -> _4:'d _1 _2 _3
           -> _5:'e _1 _2 _3 _4
           -> _6:'f _1 _2 _3 _4 _5
           -> _7:'g _1 _2 _3 _4 _5 _6
           -> _8:'h _1 _2 _3 _4 _5 _6 _7
           -> Tuple8 'a 'b 'c 'd 'e 'f 'g 'h

(* Primitive (structural) equality.
   What about for function types? *)
assume val op_Equality : 'a:Type -> 'b:Type -> x:'a -> y:'b -> z:bool {(z==true <==> x==y) /\ (z==false <==> (x=!=y))}
assume val op_disEquality : 'a:Type -> 'b:Type -> x:'a -> y:'b -> z:bool {(z==true <==> x=!=y) /\ (z==false <==> (x==y))}
logic type IfThenElse : 'P:Type => (u:unit{'P} => Type) => (u:unit{~'P} => Type) => Type

logic val Add : int -> int -> int
logic val Sub : int -> int -> int
logic val Mul : int -> int -> int
logic val Div : int -> int -> int
logic val Minus : int -> int
logic val Modulo : int -> int -> int

type LT : int => int => Type
type GT : int => int => Type
type LTE : int => int => Type
type GTE : int => int => Type
type nat = i:int{i >= 0}
type pos = n:nat{n > 0}


logic data type either 'a 'b =
  | Inl : v:'a -> either 'a 'b
  | Inr : v:'b -> either 'a 'b

logic data type list 'a =
  | Nil : list 'a
  | Cons : hd:'a -> tl:list 'a -> list 'a

assume val fst : ('a * 'b) -> 'a
assume val snd : ('a * 'b) -> 'b
assume val Assume: 'P:Type -> unit -> (y:unit{'P})
assume val Assert : 'P:Type -> x:unit{'P} -> y:unit{'P}
assume val lemma : 'P:Type -> x:unit{'P} -> z:unit{'P}
assume val unreachable : x:unit{LBL "unreachable" False} -> 'a
assume val failwith: string -> 'a (* TODO: refine with a monadic type *)
assume val raise: exn -> 'a (* TODO: refine with a monadic type *)
assume val pipe_right: 'a -> ('a -> 'b) -> 'b
assume val pipe_left: ('a -> 'b) -> 'a -> 'b
assume val ignore: 'a -> unit
assume val exit: int -> 'a
assume val try_with: (unit -> 'a) -> (exn -> 'a) -> 'a

(* Primitive functions with trusted specs  *)
assume val op_ColonEquals: ref 'a -> 'a -> unit
assume val op_Dereference: ref 'a -> 'a
assume val op_AmpAmp             : x:bool -> y:bool -> z:bool { z==true ==>  x==true /\  y==true}
assume val op_BarBar             : x:bool -> y:bool -> z:bool { (z==true ==> x==true \/  y==true) /\
                                                                (z==false ==> x==false /\ y==false) }
assume val op_Negation           : x:bool -> y:bool { (y==true ==> x==false) /\ (y==false ==> x==true) }

assume val op_Multiply           : x:int -> y:int -> z:int{z==x*y}
assume val op_Division           : x:int -> y:int{y=!=0} -> z:int{z==x/y}
assume val op_Subtraction        : x:int -> y:int -> z:int{z==x-y}
assume val op_Addition           : x:int -> y:int -> z:int{z==x+y}
assume val op_Minus              : x:int -> y:int{y==Minus x}
assume val op_Modulus            : x:int -> y:int -> z:int{z==x%y}
assume val op_LessThanOrEqual : x:int -> y:int -> z:bool{(z==true ==> x <= y) /\ (z==false ==> x > y)}
assume val op_GreaterThan : x:int -> y:int -> z:bool{(z==true ==> x > y) /\ (z==false ==> x <= y)}

(* TODO: < in operators clashes with t<..> notation. Fix *)
assume val op_GreaterThanOrEqual : x:int -> y:int -> bool(* {(z=true ==> x >= y) /\ (z=false ==> x < y) } *)
assume val op_LessThan : x:int -> y:int -> bool(* {(z=true ==> x < y) /\ (z=false ==> x >= y)} *\) *)
    
