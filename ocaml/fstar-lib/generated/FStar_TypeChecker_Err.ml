open Prims
let (info_at_pos :
  FStar_TypeChecker_Env.env ->
    Prims.string ->
      Prims.int ->
        Prims.int ->
          ((Prims.string, FStar_Ident.lid) FStar_Pervasives.either *
            FStar_Syntax_Syntax.typ * FStar_Compiler_Range_Type.range)
            FStar_Pervasives_Native.option)
  =
  fun env ->
    fun file ->
      fun row ->
        fun col ->
          let uu___ =
            let uu___1 =
              FStar_Compiler_Effect.op_Bang
                env.FStar_TypeChecker_Env.identifier_info in
            FStar_TypeChecker_Common.id_info_at_pos uu___1 file row col in
          match uu___ with
          | FStar_Pervasives_Native.None -> FStar_Pervasives_Native.None
          | FStar_Pervasives_Native.Some info ->
              (match info.FStar_TypeChecker_Common.identifier with
               | FStar_Pervasives.Inl bv ->
                   let uu___1 =
                     let uu___2 =
                       let uu___3 = FStar_Syntax_Print.nm_to_string bv in
                       FStar_Pervasives.Inl uu___3 in
                     let uu___3 = FStar_Syntax_Syntax.range_of_bv bv in
                     (uu___2, (info.FStar_TypeChecker_Common.identifier_ty),
                       uu___3) in
                   FStar_Pervasives_Native.Some uu___1
               | FStar_Pervasives.Inr fv ->
                   let uu___1 =
                     let uu___2 =
                       let uu___3 = FStar_Syntax_Syntax.lid_of_fv fv in
                       FStar_Pervasives.Inr uu___3 in
                     let uu___3 = FStar_Syntax_Syntax.range_of_fv fv in
                     (uu___2, (info.FStar_TypeChecker_Common.identifier_ty),
                       uu___3) in
                   FStar_Pervasives_Native.Some uu___1)
let print_discrepancy : 'a 'b . ('a -> 'b) -> 'a -> 'a -> ('b * 'b) =
  fun f ->
    fun x ->
      fun y ->
        let print uu___ =
          let xs = f x in let ys = f y in (xs, ys, (xs <> ys)) in
        let rec blist_leq l1 l2 =
          match (l1, l2) with
          | (h1::t1, h2::t2) ->
              ((Prims.op_Negation h1) || h2) && (blist_leq t1 t2)
          | ([], []) -> true
          | uu___ -> failwith "print_discrepancy: bad lists" in
        let rec succ l =
          match l with
          | (false)::t -> true :: t
          | (true)::t -> let uu___ = succ t in false :: uu___
          | [] -> failwith "" in
        let full l = FStar_Compiler_List.for_all (fun b1 -> b1) l in
        let get_bool_option s =
          let uu___ = FStar_Options.get_option s in
          match uu___ with
          | FStar_Options.Bool b1 -> b1
          | uu___1 -> failwith "print_discrepancy: impossible" in
        let set_bool_option s b1 =
          FStar_Options.set_option s (FStar_Options.Bool b1) in
        let get uu___ =
          let pi = get_bool_option "print_implicits" in
          let pu = get_bool_option "print_universes" in
          let pea = get_bool_option "print_effect_args" in
          let pf = get_bool_option "print_full_names" in [pi; pu; pea; pf] in
        let set l =
          match l with
          | pi::pu::pea::pf::[] ->
              (set_bool_option "print_implicits" pi;
               set_bool_option "print_universes" pu;
               set_bool_option "print_effect_args" pea;
               set_bool_option "print_full_names " pf)
          | uu___ -> failwith "impossible: print_discrepancy" in
        let bas = get () in
        let rec go cur =
          match () with
          | () when full cur ->
              let uu___ = print () in
              (match uu___ with | (xs, ys, uu___1) -> (xs, ys))
          | () when let uu___ = blist_leq bas cur in Prims.op_Negation uu___
              -> let uu___ = succ cur in go uu___
          | () ->
              (set cur;
               (let uu___1 = print () in
                match uu___1 with
                | (xs, ys, true) -> (xs, ys)
                | uu___2 -> let uu___3 = succ cur in go uu___3)) in
        FStar_Options.with_saved_options (fun uu___ -> go bas)
let (errors_smt_detail :
  FStar_TypeChecker_Env.env ->
    FStar_Errors.error Prims.list ->
      FStar_Errors_Msg.error_message -> FStar_Errors.error Prims.list)
  =
  fun env ->
    fun errs ->
      fun smt_detail ->
        let errs1 =
          FStar_Compiler_Effect.op_Bar_Greater errs
            (FStar_Compiler_List.map
               (fun uu___ ->
                  match uu___ with
                  | (e, msg, r, ctx) ->
                      let uu___1 =
                        let msg1 = FStar_Compiler_List.op_At msg smt_detail in
                        if r = FStar_Compiler_Range_Type.dummyRange
                        then
                          let uu___2 = FStar_TypeChecker_Env.get_range env in
                          (e, msg1, uu___2, ctx)
                        else
                          (let r' =
                             let uu___3 =
                               FStar_Compiler_Range_Type.use_range r in
                             FStar_Compiler_Range_Type.set_def_range r uu___3 in
                           let uu___3 =
                             let uu___4 =
                               FStar_Compiler_Range_Ops.file_of_range r' in
                             let uu___5 =
                               let uu___6 =
                                 FStar_TypeChecker_Env.get_range env in
                               FStar_Compiler_Range_Ops.file_of_range uu___6 in
                             uu___4 <> uu___5 in
                           if uu___3
                           then
                             let msg2 =
                               let uu___4 =
                                 let uu___5 =
                                   let uu___6 =
                                     let uu___7 =
                                       FStar_Compiler_Range_Ops.string_of_use_range
                                         r in
                                     Prims.op_Hat "Also see: " uu___7 in
                                   FStar_Pprint.doc_of_string uu___6 in
                                 let uu___6 =
                                   let uu___7 =
                                     let uu___8 =
                                       let uu___9 =
                                         FStar_Compiler_Range_Type.use_range
                                           r in
                                       let uu___10 =
                                         FStar_Compiler_Range_Type.def_range
                                           r in
                                       uu___9 <> uu___10 in
                                     if uu___8
                                     then
                                       let uu___9 =
                                         let uu___10 =
                                           FStar_Compiler_Range_Ops.string_of_def_range
                                             r in
                                         Prims.op_Hat
                                           "Other related locations: "
                                           uu___10 in
                                       FStar_Pprint.doc_of_string uu___9
                                     else FStar_Pprint.empty in
                                   [uu___7] in
                                 uu___5 :: uu___6 in
                               FStar_Compiler_List.op_At msg1 uu___4 in
                             let uu___4 = FStar_TypeChecker_Env.get_range env in
                             (e, msg2, uu___4, ctx)
                           else (e, msg1, r, ctx)) in
                      (match uu___1 with
                       | (e1, msg1, r1, ctx1) -> (e1, msg1, r1, ctx1)))) in
        errs1
let (add_errors :
  FStar_TypeChecker_Env.env -> FStar_Errors.error Prims.list -> unit) =
  fun env ->
    fun errs ->
      let uu___ = errors_smt_detail env errs [] in
      FStar_Errors.add_errors uu___
let (log_issue :
  FStar_TypeChecker_Env.env ->
    FStar_Compiler_Range_Type.range ->
      (FStar_Errors_Codes.raw_error * FStar_Errors_Msg.error_message) -> unit)
  =
  fun env ->
    fun r ->
      fun uu___ ->
        match uu___ with
        | (e, m) ->
            let uu___1 =
              let uu___2 =
                let uu___3 = FStar_Errors.get_ctx () in (e, m, r, uu___3) in
              [uu___2] in
            add_errors env uu___1
let (log_issue_text :
  FStar_TypeChecker_Env.env ->
    FStar_Compiler_Range_Type.range ->
      (FStar_Errors_Codes.raw_error * Prims.string) -> unit)
  =
  fun env ->
    fun r ->
      fun uu___ ->
        match uu___ with
        | (e, m) ->
            let uu___1 =
              let uu___2 = let uu___3 = FStar_Errors_Msg.text m in [uu___3] in
              (e, uu___2) in
            log_issue env r uu___1
let (err_msg_type_strings :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      FStar_Syntax_Syntax.term -> (Prims.string * Prims.string))
  =
  fun env ->
    fun t1 ->
      fun t2 ->
        print_discrepancy (FStar_TypeChecker_Normalize.term_to_string env) t1
          t2
let (err_msg_comp_strings :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.comp ->
      FStar_Syntax_Syntax.comp -> (Prims.string * Prims.string))
  =
  fun env ->
    fun c1 ->
      fun c2 ->
        print_discrepancy (FStar_TypeChecker_Normalize.comp_to_string env) c1
          c2
let (exhaustiveness_check : Prims.string) = "Patterns are incomplete"
let (subtyping_failed :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.typ ->
      FStar_Syntax_Syntax.typ -> unit -> Prims.string)
  =
  fun env ->
    fun t1 ->
      fun t2 ->
        fun uu___ ->
          let uu___1 = err_msg_type_strings env t1 t2 in
          match uu___1 with
          | (s1, s2) ->
              FStar_Compiler_Util.format2
                "Subtyping check failed; expected type %s; got type %s" s2 s1
let (ill_kinded_type : Prims.string) = "Ill-kinded type"
let (totality_check : Prims.string) = "This term may not terminate"
let (unexpected_signature_for_monad :
  FStar_TypeChecker_Env.env ->
    FStar_Ident.lident ->
      FStar_Syntax_Syntax.term ->
        (FStar_Errors_Codes.raw_error * Prims.string))
  =
  fun env ->
    fun m ->
      fun k ->
        let uu___ =
          let uu___1 = FStar_Ident.string_of_lid m in
          let uu___2 = FStar_TypeChecker_Normalize.term_to_string env k in
          FStar_Compiler_Util.format2
            "Unexpected signature for monad \"%s\". Expected a signature of the form (a:Type -> WP a -> Effect); got %s"
            uu___1 uu___2 in
        (FStar_Errors_Codes.Fatal_UnexpectedSignatureForMonad, uu___)
let (expected_a_term_of_type_t_got_a_function :
  FStar_TypeChecker_Env.env ->
    Prims.string ->
      FStar_Syntax_Syntax.term ->
        FStar_Syntax_Syntax.term ->
          (FStar_Errors_Codes.raw_error * Prims.string))
  =
  fun env ->
    fun msg ->
      fun t ->
        fun e ->
          let uu___ =
            let uu___1 = FStar_TypeChecker_Normalize.term_to_string env t in
            let uu___2 = FStar_Syntax_Print.term_to_string e in
            FStar_Compiler_Util.format3
              "Expected a term of type \"%s\"; got a function \"%s\" (%s)"
              uu___1 uu___2 msg in
          (FStar_Errors_Codes.Fatal_ExpectTermGotFunction, uu___)
let (unexpected_implicit_argument :
  (FStar_Errors_Codes.raw_error * Prims.string)) =
  (FStar_Errors_Codes.Fatal_UnexpectedImplicitArgument,
    "Unexpected instantiation of an implicit argument to a function that only expects explicit arguments")
let (expected_expression_of_type :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      FStar_Syntax_Syntax.term ->
        FStar_Syntax_Syntax.term ->
          (FStar_Errors_Codes.raw_error * FStar_Pprint.document Prims.list))
  =
  fun env ->
    fun t1 ->
      fun e ->
        fun t2 ->
          let d1 = FStar_TypeChecker_Normalize.term_to_doc env t1 in
          let d2 = FStar_TypeChecker_Normalize.term_to_doc env t2 in
          let ed = FStar_TypeChecker_Normalize.term_to_doc env e in
          let uu___ =
            let uu___1 =
              let uu___2 =
                let uu___3 =
                  FStar_Errors_Msg.text "Expected expression of type" in
                FStar_Pprint.prefix (Prims.of_int (4)) Prims.int_one uu___3
                  d1 in
              let uu___3 =
                let uu___4 =
                  let uu___5 = FStar_Errors_Msg.text "got expression" in
                  FStar_Pprint.prefix (Prims.of_int (4)) Prims.int_one uu___5
                    ed in
                let uu___5 =
                  let uu___6 = FStar_Errors_Msg.text "of type" in
                  FStar_Pprint.prefix (Prims.of_int (4)) Prims.int_one uu___6
                    d2 in
                FStar_Pprint.op_Hat_Slash_Hat uu___4 uu___5 in
              FStar_Pprint.op_Hat_Slash_Hat uu___2 uu___3 in
            [uu___1] in
          (FStar_Errors_Codes.Fatal_UnexpectedExpressionType, uu___)
let (expected_pattern_of_type :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      FStar_Syntax_Syntax.term ->
        FStar_Syntax_Syntax.term ->
          (FStar_Errors_Codes.raw_error * Prims.string))
  =
  fun env ->
    fun t1 ->
      fun e ->
        fun t2 ->
          let uu___ = err_msg_type_strings env t1 t2 in
          match uu___ with
          | (s1, s2) ->
              let uu___1 =
                let uu___2 = FStar_Syntax_Print.term_to_string e in
                FStar_Compiler_Util.format3
                  "Expected pattern of type \"%s\"; got pattern \"%s\" of type \"%s\""
                  s1 uu___2 s2 in
              (FStar_Errors_Codes.Fatal_UnexpectedPattern, uu___1)
let (basic_type_error :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term FStar_Pervasives_Native.option ->
      FStar_Syntax_Syntax.term ->
        FStar_Syntax_Syntax.term ->
          (FStar_Errors_Codes.raw_error * Prims.string))
  =
  fun env ->
    fun eopt ->
      fun t1 ->
        fun t2 ->
          let uu___ = err_msg_type_strings env t1 t2 in
          match uu___ with
          | (s1, s2) ->
              let msg =
                match eopt with
                | FStar_Pervasives_Native.None ->
                    FStar_Compiler_Util.format2
                      "Expected type \"%s\"; got type \"%s\"" s1 s2
                | FStar_Pervasives_Native.Some e ->
                    let uu___1 =
                      FStar_TypeChecker_Normalize.term_to_string env e in
                    FStar_Compiler_Util.format3
                      "Expected type \"%s\"; but \"%s\" has type \"%s\"" s1
                      uu___1 s2 in
              (FStar_Errors_Codes.Error_TypeError, msg)
let (occurs_check : (FStar_Errors_Codes.raw_error * Prims.string)) =
  (FStar_Errors_Codes.Fatal_PossibleInfiniteTyp,
    "Possibly infinite typ (occurs check failed)")
let constructor_fails_the_positivity_check :
  'uuuuu .
    'uuuuu ->
      FStar_Syntax_Syntax.term ->
        FStar_Ident.lid -> (FStar_Errors_Codes.raw_error * Prims.string)
  =
  fun env ->
    fun d ->
      fun l ->
        let uu___ =
          let uu___1 = FStar_Syntax_Print.term_to_string d in
          let uu___2 = FStar_Syntax_Print.lid_to_string l in
          FStar_Compiler_Util.format2
            "Constructor \"%s\" fails the strict positivity check; the constructed type \"%s\" occurs to the left of a pure function type"
            uu___1 uu___2 in
        (FStar_Errors_Codes.Fatal_ConstructorFailedCheck, uu___)
let (inline_type_annotation_and_val_decl :
  FStar_Ident.lid -> (FStar_Errors_Codes.raw_error * Prims.string)) =
  fun l ->
    let uu___ =
      let uu___1 = FStar_Syntax_Print.lid_to_string l in
      FStar_Compiler_Util.format1
        "\"%s\" has a val declaration as well as an inlined type annotation; remove one"
        uu___1 in
    (FStar_Errors_Codes.Fatal_DuplicateTypeAnnotationAndValDecl, uu___)
let (inferred_type_causes_variable_to_escape :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      FStar_Syntax_Syntax.bv -> (FStar_Errors_Codes.raw_error * Prims.string))
  =
  fun env ->
    fun t ->
      fun x ->
        let uu___ =
          let uu___1 = FStar_TypeChecker_Normalize.term_to_string env t in
          let uu___2 = FStar_Syntax_Print.bv_to_string x in
          FStar_Compiler_Util.format2
            "Inferred type \"%s\" causes variable \"%s\" to escape its scope"
            uu___1 uu___2 in
        (FStar_Errors_Codes.Fatal_InferredTypeCauseVarEscape, uu___)
let (expected_function_typ :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term -> (FStar_Errors_Codes.raw_error * Prims.string))
  =
  fun env ->
    fun t ->
      let uu___ =
        let uu___1 = FStar_TypeChecker_Normalize.term_to_string env t in
        FStar_Compiler_Util.format1
          "Expected a function; got an expression of type \"%s\"" uu___1 in
      (FStar_Errors_Codes.Fatal_FunctionTypeExpected, uu___)
let (expected_poly_typ :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      FStar_Syntax_Syntax.term ->
        FStar_Syntax_Syntax.term ->
          (FStar_Errors_Codes.raw_error * Prims.string))
  =
  fun env ->
    fun f ->
      fun t ->
        fun targ ->
          let uu___ =
            let uu___1 = FStar_Syntax_Print.term_to_string f in
            let uu___2 = FStar_TypeChecker_Normalize.term_to_string env t in
            let uu___3 = FStar_TypeChecker_Normalize.term_to_string env targ in
            FStar_Compiler_Util.format3
              "Expected a polymorphic function; got an expression \"%s\" of type \"%s\" applied to a type \"%s\""
              uu___1 uu___2 uu___3 in
          (FStar_Errors_Codes.Fatal_PolyTypeExpected, uu___)
let (disjunctive_pattern_vars :
  FStar_Syntax_Syntax.bv Prims.list ->
    FStar_Syntax_Syntax.bv Prims.list ->
      (FStar_Errors_Codes.raw_error * Prims.string))
  =
  fun v1 ->
    fun v2 ->
      let vars v =
        let uu___ =
          FStar_Compiler_Effect.op_Bar_Greater v
            (FStar_Compiler_List.map FStar_Syntax_Print.bv_to_string) in
        FStar_Compiler_Effect.op_Bar_Greater uu___
          (FStar_Compiler_String.concat ", ") in
      let uu___ =
        let uu___1 = vars v1 in
        let uu___2 = vars v2 in
        FStar_Compiler_Util.format2
          "Every alternative of an 'or' pattern must bind the same variables; here one branch binds (\"%s\") and another (\"%s\")"
          uu___1 uu___2 in
      (FStar_Errors_Codes.Fatal_DisjuctivePatternVarsMismatch, uu___)
let (name_and_result :
  FStar_Syntax_Syntax.comp' FStar_Syntax_Syntax.syntax ->
    (Prims.string * FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax))
  =
  fun c ->
    match c.FStar_Syntax_Syntax.n with
    | FStar_Syntax_Syntax.Total t -> ("Tot", t)
    | FStar_Syntax_Syntax.GTotal t -> ("GTot", t)
    | FStar_Syntax_Syntax.Comp ct ->
        let uu___ =
          FStar_Syntax_Print.lid_to_string ct.FStar_Syntax_Syntax.effect_name in
        (uu___, (ct.FStar_Syntax_Syntax.result_typ))
let computed_computation_type_does_not_match_annotation :
  'uuuuu .
    FStar_TypeChecker_Env.env ->
      'uuuuu ->
        FStar_Syntax_Syntax.comp' FStar_Syntax_Syntax.syntax ->
          FStar_Syntax_Syntax.comp' FStar_Syntax_Syntax.syntax ->
            (FStar_Errors_Codes.raw_error * Prims.string)
  =
  fun env ->
    fun e ->
      fun c ->
        fun c' ->
          let uu___ = name_and_result c in
          match uu___ with
          | (f1, r1) ->
              let uu___1 = name_and_result c' in
              (match uu___1 with
               | (f2, r2) ->
                   let uu___2 = err_msg_type_strings env r1 r2 in
                   (match uu___2 with
                    | (s1, s2) ->
                        let uu___3 =
                          FStar_Compiler_Util.format4
                            "Computed type \"%s\" and effect \"%s\" is not compatible with the annotated type \"%s\" effect \"%s\""
                            s1 f1 s2 f2 in
                        (FStar_Errors_Codes.Fatal_ComputedTypeNotMatchAnnotation,
                          uu___3)))
let computed_computation_type_does_not_match_annotation_eq :
  'uuuuu .
    FStar_TypeChecker_Env.env ->
      'uuuuu ->
        FStar_Syntax_Syntax.comp ->
          FStar_Syntax_Syntax.comp ->
            (FStar_Errors_Codes.raw_error * Prims.string)
  =
  fun env ->
    fun e ->
      fun c ->
        fun c' ->
          let uu___ = err_msg_comp_strings env c c' in
          match uu___ with
          | (s1, s2) ->
              let uu___1 =
                FStar_Compiler_Util.format2
                  "Computed type \"%s\" does not match annotated type \"%s\", and no subtyping was allowed"
                  s1 s2 in
              (FStar_Errors_Codes.Fatal_ComputedTypeNotMatchAnnotation,
                uu___1)
let (unexpected_non_trivial_precondition_on_term :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term -> (FStar_Errors_Codes.raw_error * Prims.string))
  =
  fun env ->
    fun f ->
      let uu___ =
        let uu___1 = FStar_TypeChecker_Normalize.term_to_string env f in
        FStar_Compiler_Util.format1
          "Term has an unexpected non-trivial pre-condition: %s" uu___1 in
      (FStar_Errors_Codes.Fatal_UnExpectedPreCondition, uu___)
let (expected_pure_expression :
  FStar_Syntax_Syntax.term ->
    FStar_Syntax_Syntax.comp' FStar_Syntax_Syntax.syntax ->
      Prims.string -> (FStar_Errors_Codes.raw_error * Prims.string))
  =
  fun e ->
    fun c ->
      fun reason ->
        let msg = "Expected a pure expression" in
        let msg1 =
          if reason = ""
          then msg
          else FStar_Compiler_Util.format1 (Prims.op_Hat msg " (%s)") reason in
        let uu___ =
          let uu___1 = FStar_Syntax_Print.term_to_string e in
          let uu___2 =
            let uu___3 = name_and_result c in
            FStar_Compiler_Effect.op_Less_Bar FStar_Pervasives_Native.fst
              uu___3 in
          FStar_Compiler_Util.format2
            (Prims.op_Hat msg1
               "; got an expression \"%s\" with effect \"%s\"") uu___1 uu___2 in
        (FStar_Errors_Codes.Fatal_ExpectedPureExpression, uu___)
let (expected_ghost_expression :
  FStar_Syntax_Syntax.term ->
    FStar_Syntax_Syntax.comp' FStar_Syntax_Syntax.syntax ->
      Prims.string -> (FStar_Errors_Codes.raw_error * Prims.string))
  =
  fun e ->
    fun c ->
      fun reason ->
        let msg = "Expected a ghost expression" in
        let msg1 =
          if reason = ""
          then msg
          else FStar_Compiler_Util.format1 (Prims.op_Hat msg " (%s)") reason in
        let uu___ =
          let uu___1 = FStar_Syntax_Print.term_to_string e in
          let uu___2 =
            let uu___3 = name_and_result c in
            FStar_Compiler_Effect.op_Less_Bar FStar_Pervasives_Native.fst
              uu___3 in
          FStar_Compiler_Util.format2
            (Prims.op_Hat msg1
               "; got an expression \"%s\" with effect \"%s\"") uu___1 uu___2 in
        (FStar_Errors_Codes.Fatal_ExpectedGhostExpression, uu___)
let (expected_effect_1_got_effect_2 :
  FStar_Ident.lident ->
    FStar_Ident.lident -> (FStar_Errors_Codes.raw_error * Prims.string))
  =
  fun c1 ->
    fun c2 ->
      let uu___ =
        let uu___1 = FStar_Syntax_Print.lid_to_string c1 in
        let uu___2 = FStar_Syntax_Print.lid_to_string c2 in
        FStar_Compiler_Util.format2
          "Expected a computation with effect %s; but it has effect %s"
          uu___1 uu___2 in
      (FStar_Errors_Codes.Fatal_UnexpectedEffect, uu___)
let (failed_to_prove_specification_of :
  FStar_Syntax_Syntax.lbname ->
    Prims.string Prims.list -> (FStar_Errors_Codes.raw_error * Prims.string))
  =
  fun l ->
    fun lbls ->
      let uu___ =
        let uu___1 = FStar_Syntax_Print.lbname_to_string l in
        let uu___2 =
          FStar_Compiler_Effect.op_Bar_Greater lbls
            (FStar_Compiler_String.concat ", ") in
        FStar_Compiler_Util.format2
          "Failed to prove specification of %s; assertions at [%s] may fail"
          uu___1 uu___2 in
      (FStar_Errors_Codes.Error_TypeCheckerFailToProve, uu___)
let (failed_to_prove_specification :
  Prims.string Prims.list -> (FStar_Errors_Codes.raw_error * Prims.string)) =
  fun lbls ->
    let msg =
      match lbls with
      | [] ->
          "An unknown assertion in the term at this location was not provable"
      | uu___ ->
          let uu___1 =
            FStar_Compiler_Effect.op_Bar_Greater lbls
              (FStar_Compiler_String.concat "\n\t") in
          FStar_Compiler_Util.format1
            "The following problems were found:\n\t%s" uu___1 in
    (FStar_Errors_Codes.Error_TypeCheckerFailToProve, msg)
let (top_level_effect : (FStar_Errors_Codes.raw_error * Prims.string)) =
  (FStar_Errors_Codes.Warning_TopLevelEffect,
    "Top-level let-bindings must be total; this term may have effects")
let (cardinality_constraint_violated :
  FStar_Ident.lid ->
    FStar_Syntax_Syntax.bv FStar_Syntax_Syntax.withinfo_t ->
      (FStar_Errors_Codes.raw_error * Prims.string))
  =
  fun l ->
    fun a ->
      let uu___ =
        let uu___1 = FStar_Syntax_Print.lid_to_string l in
        let uu___2 = FStar_Syntax_Print.bv_to_string a.FStar_Syntax_Syntax.v in
        FStar_Compiler_Util.format2
          "Constructor %s violates the cardinality of Type at parameter '%s'; type arguments are not allowed"
          uu___1 uu___2 in
      (FStar_Errors_Codes.Fatal_CardinalityConstraintViolated, uu___)