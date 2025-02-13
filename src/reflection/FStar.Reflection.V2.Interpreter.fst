(*
   Copyright 2008-2022 Microsoft Research

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
module FStar.Reflection.V2.Interpreter

module BU    = FStar.Compiler.Util
module Cfg   = FStar.TypeChecker.Cfg
module EMB   = FStar.Syntax.Embeddings
module Env   = FStar.TypeChecker.Env
module NBET  = FStar.TypeChecker.NBETerm
module NRE   = FStar.Reflection.V2.NBEEmbeddings
module PO    = FStar.TypeChecker.Primops
module RB    = FStar.Reflection.V2.Builtins
module RD    = FStar.Reflection.V2.Data
module RE    = FStar.Reflection.V2.Embeddings
module Z     = FStar.BigInt
module Range = FStar.Compiler.Range
open FStar.Compiler
open FStar.Compiler.List
open FStar.Ident
open FStar.Syntax.Syntax
open FStar.Reflection.V2.Constants

let unembed      = EMB.unembed
let try_unembed  = EMB.try_unembed
let embed ea r x norm_cb     = EMB.embed ea x r None norm_cb

(* We use `try_unembed` instead of `unembedding`, since we very well
 * might fail to unembed during the *previous* normalization stages
 * of metaprograms. When actually running, we certainly expect
 * everything to reduce to proper values and unembed just fine, but
 * we cannot ignore this case. So, use `try_` so we don't generate
 * spurious warnings. *)

let int1 (m:lid) (f:'a -> 'r) (ea:EMB.embedding 'a) (er:EMB.embedding 'r)
                 (psc:PO.psc) n (args : args) : option term =
    match args with
    | [(a, _)] ->
        BU.bind_opt (try_unembed ea a n) (fun a ->
        Some (embed er (PO.psc_range psc) (f a) n))
    | _ -> None

let int2 (m:lid) (f:'a -> 'b -> 'r) (ea:EMB.embedding 'a) (eb:EMB.embedding 'b) (er:EMB.embedding 'r)
                 (psc:PO.psc) n (args : args) : option term =
    match args with
    | [(a, _); (b, _)] ->
        BU.bind_opt (try_unembed ea a n) (fun a ->
        BU.bind_opt (try_unembed eb b n) (fun b ->
        Some (embed er (PO.psc_range psc) (f a b) n)))
    | _ -> None

let int3 (m:lid) (f:'a -> 'b -> 'c -> 'r) (ea:EMB.embedding 'a) (eb:EMB.embedding 'b) (ec:EMB.embedding 'c) (er:EMB.embedding 'r)
                 (psc:PO.psc) n (args : args) : option term =
    match args with
    | [(a, _); (b, _); (c, _)] ->
        BU.bind_opt (try_unembed ea a n) (fun a ->
        BU.bind_opt (try_unembed eb b n) (fun b ->
        BU.bind_opt (try_unembed ec c n) (fun c ->
        Some (embed er (PO.psc_range psc) (f a b c) n))))
    | _ -> None

let nbe_int1 (m:lid) (f:'a -> 'r) (ea:NBET.embedding 'a) (er:NBET.embedding 'r)
                     (cb:NBET.nbe_cbs) (args : NBET.args) : option NBET.t =
    match args with
    | [(a, _)] ->
        BU.bind_opt (NBET.unembed ea cb a) (fun a ->
        Some (NBET.embed er cb (f a)))
    | _ -> None

let nbe_int2 (m:lid) (f:'a -> 'b -> 'r) (ea:NBET.embedding 'a) (eb:NBET.embedding 'b) (er:NBET.embedding 'r)
                     (cb:NBET.nbe_cbs) (args : NBET.args) : option NBET.t =
    match args with
    | [(a, _); (b, _)] ->
        BU.bind_opt (NBET.unembed ea cb a) (fun a ->
        BU.bind_opt (NBET.unembed eb cb b) (fun b ->
        Some (NBET.embed er cb (f a b))))
    | _ -> None

let nbe_int3 (m:lid) (f:'a -> 'b -> 'c -> 'r) (ea:NBET.embedding 'a) (eb:NBET.embedding 'b) (ec:NBET.embedding 'c) (er:NBET.embedding 'r)
                     (cb:NBET.nbe_cbs) (args : NBET.args) : option NBET.t =
    match args with
    | [(a, _); (b, _); (c, _)] ->
        BU.bind_opt (NBET.unembed ea cb a) (fun a ->
        BU.bind_opt (NBET.unembed eb cb b) (fun b ->
        BU.bind_opt (NBET.unembed ec cb c) (fun c ->
        Some (NBET.embed er cb (f a b c)))))
    | _ -> None

let mklid (nm : string) : lid = fstar_refl_builtins_lid nm

let mk_us (l : lid) (u_arity:int) (arity : int)
            (fn     : PO.psc -> EMB.norm_cb -> args -> option term)
            (nbe_fn : NBET.nbe_cbs -> NBET.args -> option NBET.t) : PO.primitive_step
  =
  { name                         = l
  ; arity                        = arity
  ; univ_arity                   = u_arity
  ; auto_reflect                 = None
  ; strong_reduction_ok          = true
  ; requires_binder_substitution = false
  ; renorm_after                 = false
  ; interpretation               = (fun psc cbs _us args -> fn psc cbs args)
  ; interpretation_nbe           = (fun cbs _us args -> nbe_fn cbs args)
  }

(* Most primitives are not universe polymorphic. *)
let mk l arity fn nbe_fn = mk_us l 0 arity fn nbe_fn

(*
 ** Packing both regular and NBE embedding in a single type, for brevity
 ** in the table below. This should all be unfolded at F* initialization
 ** time so it won't be a performance concern.
 *)
type dualemb 'a = (EMB.embedding 'a & NBET.embedding 'a)

let e_int             : dualemb Z.t                = (EMB.e_int, NBET.e_int)
let e_bool            : dualemb bool               = (EMB.e_bool, NBET.e_bool)
let e_string          : dualemb string             = (EMB.e_string, NBET.e_string)
let e_order           : dualemb FStar.Order.order  = (RE.e_order, NRE.e_order)

let e_term            : dualemb term               = (RE.e_term, NRE.e_term)
let e_term_view       : dualemb RD.term_view       = (RE.e_term_view, NRE.e_term_view)
let e_fv              : dualemb fv                 = (RE.e_fv, NRE.e_fv)
let e_bv              : dualemb bv                 = (RE.e_bv, NRE.e_bv)
let e_namedv          : dualemb RE.namedv          = (RE.e_namedv, NRE.e_namedv)
let e_bv_view         : dualemb RD.bv_view         = (RE.e_bv_view, NRE.e_bv_view)
let e_namedv_view     : dualemb RD.namedv_view     = (RE.e_namedv_view, NRE.e_namedv_view)
let e_binding         : dualemb RD.binding         = (RE.e_binding, NRE.e_binding)
let e_comp            : dualemb comp               = (RE.e_comp, NRE.e_comp)
let e_comp_view       : dualemb RD.comp_view       = (RE.e_comp_view, NRE.e_comp_view)
let e_universe        : dualemb universe           = (RE.e_universe, NRE.e_universe)
let e_universe_view   : dualemb RD.universe_view   = (RE.e_universe_view, NRE.e_universe_view)
let e_sigelt          : dualemb sigelt             = (RE.e_sigelt, NRE.e_sigelt)
let e_sigelt_view     : dualemb RD.sigelt_view     = (RE.e_sigelt_view, NRE.e_sigelt_view)
let e_binder          : dualemb binder             = (RE.e_binder, NRE.e_binder)
let e_binder_view     : dualemb RD.binder_view     = (RE.e_binder_view, NRE.e_binder_view)
let e_binders         : dualemb binders            = (RE.e_binders, NRE.e_binders)

let e_letbinding      : dualemb letbinding         = (RE.e_letbinding, NRE.e_letbinding)
let e_lb_view         : dualemb RD.lb_view         = (RE.e_lb_view, NRE.e_lb_view)
(* ^ Inconsistent naming with these.. but too long otherwise, and userspace has
 * lb_view already. Probably not worth the fix. *)

let e_env             : dualemb Env.env            = (RE.e_env, NRE.e_env)
let e_aqualv          : dualemb RD.aqualv          = (RE.e_aqualv, NRE.e_aqualv)
let e_vconfig         : dualemb VConfig.vconfig    = (EMB.e_vconfig, NBET.e_vconfig)
let e_attributes      : dualemb (list attribute)   = (RE.e_attributes, NRE.e_attributes)
let e_qualifiers      : dualemb RD.qualifiers      = (RE.e_qualifiers, NRE.e_qualifiers)
let e_range           : dualemb Range.range              =
  (FStar.Syntax.Embeddings.e_range, FStar.TypeChecker.NBETerm.e_range)

let nbe_dummy #a : NBET.embedding a =
  let open FStar.Compiler.Effect in
  NBET.mk_emb
    (fun _ _ -> failwith "nbe_dummy embed")
    (fun _ _ -> failwith "nbe_dummy unembed")
    (NBET.mk_t NBET.Unknown)
    ET_abstract

let e_ident           : dualemb Ident.ident            = (RE.e_ident, nbe_dummy #Ident.ident)

let e_subst           : dualemb (list subst_elt)   = (RE.e_subst, NRE.e_subst)

let e_list (e : dualemb 'a) : dualemb (list 'a) =
  (EMB.e_list (fst e), NBET.e_list (snd e))

let e_option (e : dualemb 'a) : dualemb (option 'a) =
  (EMB.e_option (fst e), NBET.e_option (snd e))

let e_tuple2 (ea : dualemb 'a) (eb : dualemb 'b) : dualemb ('a & 'b) =
  (EMB.e_tuple2 (fst ea) (fst eb), NBET.e_tuple2 (snd ea) (snd eb))

let e_string_list = e_list e_string

(** Helpers to create a (total) primitive step from a function and embeddings. *)
let mk1' nm (f  : 'a  -> 'r) (ea  : dualemb 'a)
        (er  : dualemb 'r): PO.primitive_step =
    let l = mklid nm in
    mk_us l 1 1 (int1     l f (fst ea) (fst er))
           (nbe_int1 l f (snd ea) (snd er))

let mk1 nm (f  : 'a  -> 'r) (ea  : dualemb 'a)
        (er  : dualemb 'r): PO.primitive_step =
    let l = mklid nm in
    mk l 1 (int1     l f (fst ea) (fst er))
           (nbe_int1 l f (snd ea) (snd er))

let mk2 nm (f  : 'a  -> 'b -> 'r) (ea  : dualemb 'a) (eb : dualemb 'b)
        (er  : dualemb 'r): PO.primitive_step =
    let l = mklid nm in
    mk l 2 (int2     l f (fst ea) (fst eb) (fst er))
           (nbe_int2 l f (snd ea) (snd eb) (snd er))

let mk3 nm (f  : 'a  -> 'b -> 'c -> 'r) (ea  : dualemb 'a) (eb : dualemb 'b) (ec : dualemb 'c)
        (er  : dualemb 'r): PO.primitive_step =
    let l = mklid nm in
    mk l 3 (int3     l f (fst ea) (fst eb) (fst ec) (fst er))
           (nbe_int3 l f (snd ea) (snd eb) (snd ec) (snd er))

(*
 * NOTE: all primitives must be carefully inspected to make sure they
 * do not break the abstraction barrier imposed by the term_view.
 * Otherwise, the pack_inspect_inv and inspect_pack_inv lemmas could
 * likely be used to derive a contradiction.
 *
 * The way to go about adding new primitives is to implement them in the
 * FStar.Reflection.V2.Builtins module and implement them using the (internal)
 * inspect_ln and pack_ln functions, which means they should not break
 * the view abstraction.
 *
 * _Any_ call to functions elsewhere, say term_to_string or
 * Util.term_eq, will _very likely_ be inconsistent with the view.
 * Exceptions to the "way to go" above should be well justified.
 *)
let reflection_primops : list PO.primitive_step = [
  (****** Inspecting/packing various kinds of syntax ******)
  mk1 "inspect_ln"
    RB.inspect_ln
    e_term
    e_term_view;

  mk1 "pack_ln"
    RB.pack_ln
    e_term_view
    e_term;

  mk1 "inspect_fv"
    RB.inspect_fv
    e_fv
    e_string_list;

  mk1 "pack_fv"
    RB.pack_fv
    e_string_list
    e_fv;

  mk1 "inspect_comp"
    RB.inspect_comp
    e_comp
    e_comp_view;

  mk1 "pack_comp"
    RB.pack_comp
    e_comp_view
    e_comp;

  mk1 "inspect_universe"
    RB.inspect_universe
    e_universe
    e_universe_view;

  mk1 "pack_universe"
    RB.pack_universe
    e_universe_view
    e_universe;

  mk1 "inspect_sigelt"
    RB.inspect_sigelt
    e_sigelt
    e_sigelt_view;

  mk1 "pack_sigelt"
    RB.pack_sigelt
    e_sigelt_view
    e_sigelt;

  mk1 "inspect_lb"
    RB.inspect_lb
    e_letbinding
    e_lb_view;

  mk1 "pack_lb"
    RB.pack_lb
    e_lb_view
    e_letbinding;

  mk1 "inspect_namedv"
    RB.inspect_namedv
    e_namedv
    e_namedv_view;

  mk1 "pack_namedv"
    RB.pack_namedv
    e_namedv_view
    e_namedv;

  mk1 "inspect_bv"
    RB.inspect_bv
    e_bv
    e_bv_view;

  mk1 "pack_bv"
    RB.pack_bv
    e_bv_view
    e_bv;

  (* TODO: Make this consistent with others? No good reason for it to be "exploded" *)
  mk1 "inspect_binder"
    RB.inspect_binder
    e_binder
    e_binder_view;

  mk1 "pack_binder"
    RB.pack_binder
    e_binder_view
    e_binder;

  (****** Actual primitives ******)

  mk1 "sigelt_opts"
    RB.sigelt_opts
    e_sigelt
    (e_option e_vconfig);

  (* This exposes the embedding of vconfig since it is useful to create attributes *)
  mk1 "embed_vconfig"
    RB.embed_vconfig
    e_vconfig
    e_term;

  mk1 "sigelt_attrs"
    RB.sigelt_attrs
    e_sigelt
    e_attributes;

  mk2 "set_sigelt_attrs"
    RB.set_sigelt_attrs
    e_attributes  e_sigelt
    e_sigelt;

  mk1 "sigelt_quals"
    RB.sigelt_quals
    e_sigelt
    e_qualifiers;

  mk2 "set_sigelt_quals"
    RB.set_sigelt_quals
    e_qualifiers e_sigelt
    e_sigelt;

  mk2 "subst_term"
    RB.subst_term
    e_subst e_term e_term;

  mk2 "subst_comp"
    RB.subst_comp
    e_subst e_comp e_comp;

  mk2 "compare_bv"
    RB.compare_bv
    e_bv
    e_bv
    e_order;

  mk2 "compare_namedv"
    RB.compare_namedv
    e_namedv
    e_namedv
    e_order;

  mk2 "lookup_attr"
    RB.lookup_attr
    e_term
    e_env
    (e_list e_fv);

  mk1 "all_defs_in_env"
    RB.all_defs_in_env
    e_env
    (e_list e_fv);

  mk2 "defs_in_module"
    RB.defs_in_module
    e_env
    e_string_list
    (e_list e_fv);

  mk2 "term_eq"
    RB.term_eq
    e_term e_term
    e_bool;

  mk1 "moduleof"
    RB.moduleof
    e_env
    e_string_list;

  mk1 "vars_of_env"
    RB.vars_of_env
    e_env
    (e_list e_binding);

  mk2 "lookup_typ"
    RB.lookup_typ
    e_env
    e_string_list
    (e_option e_sigelt);

  mk1 "env_open_modules"
    RB.env_open_modules
    e_env
    (e_list e_string_list);

  (* See note in ulib/FStar.Reflection.V2.Builints.fsti: we expose these
     three to reduce dependencies. *)
  mk1 "implode_qn"
    RB.implode_qn
    e_string_list
    e_string;

  mk1 "explode_qn"
    RB.explode_qn
    e_string
    e_string_list;

  mk2 "compare_string"
    RB.compare_string
    e_string e_string
    e_int;

  mk2 "push_namedv"
    RB.push_namedv
    e_env
    e_namedv
    e_env;

  mk1 "range_of_term"
    RB.range_of_term
    e_term
    e_range;

  mk1 "range_of_sigelt"
    RB.range_of_sigelt
    e_sigelt
    e_range;

  mk1 "inspect_ident"
    RB.inspect_ident
    e_ident
    (e_tuple2 e_string e_range);

  mk1 "pack_ident"
    RB.pack_ident
    (e_tuple2 e_string e_range)
    e_ident;
]

let _ = List.iter FStar.TypeChecker.Cfg.register_extra_step reflection_primops
