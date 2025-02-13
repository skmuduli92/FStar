﻿module FStar.Defensive

open FStar.Compiler.Effect
open FStar.Compiler.Util
open FStar.Class.Binders
open FStar.Class.Show
open FStar.Errors
open FStar.Errors.Msg
open FStar.Pprint

let () = let open FStar.Syntax.Print in ()

val __def_check_scoped :
  #env_t:Type -> #thing_t:Type ->
  {| hasBinders env_t |} ->
  {| hasNames thing_t |} ->
  {| pretty thing_t |} ->
  range -> string ->
  env_t -> thing_t -> unit

instance pp_bv : pretty FStar.Syntax.Syntax.bv = {
  pp = (fun bv -> arbitrary_string (show bv));
}

instance pp_set #a (_ : pretty a) : Tot (pretty (set a)) = {
  pp = (fun s ->
    let doclist (ds : list Pprint.document) : Pprint.document =
      surround_separate 2 0 (doc_of_string "[]") lbracket (semi ^^ break_ 1) rbracket ds
    in
    doclist (set_elements s |> List.map pp))
}

let __def_check_scoped rng msg env thing =
  let free = freeNames thing in
  let scope = boundNames env in
  if not (set_is_empty <| set_difference free scope) then
    Errors.log_issue_doc rng (Errors.Warning_Defensive, [
         text "Internal: term is not well-scoped " ^/^ parens (doc_of_string msg);
         text "t =" ^/^ pp thing;
         text "FVs =" ^/^ pp free;
         text "Scope =" ^/^ pp scope;
         text "Diff =" ^/^ pp (set_difference free scope);
       ])

let def_check_scoped rng msg env thing =
  if Options.defensive () then
    __def_check_scoped rng msg env thing
