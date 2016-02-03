
open Prims
exception Err of (Prims.string)

let is_Err = (fun _discr_ -> (match (_discr_) with
| Err (_) -> begin
true
end
| _ -> begin
false
end))

let ___Err____0 = (fun projectee -> (match (projectee) with
| Err (_31_3) -> begin
_31_3
end))

let parse_error = (fun _31_4 -> (match (()) with
| () -> begin
(FStar_All.failwith "Parse error: ill-formed cache")
end))

type l__Writer =
FStar_Util.oWriter

type l__Reader =
FStar_Util.oReader

let serialize_option = (fun writer f l -> (match (l) with
| None -> begin
(writer.FStar_Util.write_char 'n')
end
| Some (l) -> begin
(let _31_12 = (writer.FStar_Util.write_char 's')
in (f writer l))
end))

let deserialize_option = (fun reader f -> (let n = (reader.FStar_Util.read_char ())
in if (n = 'n') then begin
None
end else begin
(let _122_21 = (f reader)
in Some (_122_21))
end))

let serialize_list = (fun writer f l -> (let _31_22 = (writer.FStar_Util.write_int (FStar_List.length l))
in (FStar_List.iter (fun elt -> (f writer elt)) (FStar_List.rev_append l []))))

let deserialize_list = (fun reader f -> (let n = (reader.FStar_Util.read_int ())
in (let rec helper = (fun accum n -> if (n = 0) then begin
accum
end else begin
(let _122_42 = (let _122_41 = (f reader)
in (_122_41)::accum)
in (helper _122_42 (n - 1)))
end)
in (helper [] n))))

let serialize_ident = (fun writer ast -> (writer.FStar_Util.write_string ast.FStar_Ident.idText))

let deserialize_ident = (fun reader -> (let _122_50 = (let _122_49 = (reader.FStar_Util.read_string ())
in (_122_49, FStar_Absyn_Syntax.dummyRange))
in (FStar_Ident.mk_ident _122_50)))

let serialize_LongIdent = (fun writer ast -> (let _31_37 = (serialize_list writer serialize_ident ast.FStar_Ident.ns)
in (serialize_ident writer ast.FStar_Ident.ident)))

let deserialize_LongIdent = (fun reader -> (let _122_60 = (let _122_59 = (deserialize_list reader deserialize_ident)
in (let _122_58 = (let _122_57 = (deserialize_ident reader)
in (_122_57)::[])
in (FStar_List.append _122_59 _122_58)))
in (FStar_Ident.lid_of_ids _122_60)))

let serialize_lident = serialize_LongIdent

let deserialize_lident = deserialize_LongIdent

let serialize_withinfo_t = (fun writer s_v s_sort ast -> (let _31_46 = (s_v writer ast.FStar_Absyn_Syntax.v)
in (s_sort writer ast.FStar_Absyn_Syntax.sort)))

let deserialize_withinfo_t = (fun reader ds_v ds_sort -> (let _122_90 = (ds_v reader)
in (let _122_89 = (ds_sort reader)
in {FStar_Absyn_Syntax.v = _122_90; FStar_Absyn_Syntax.sort = _122_89; FStar_Absyn_Syntax.p = FStar_Absyn_Syntax.dummyRange})))

let serialize_var = (fun writer s_sort ast -> (serialize_withinfo_t writer serialize_lident s_sort ast))

let deserialize_var = (fun reader ds_sort -> (deserialize_withinfo_t reader deserialize_lident ds_sort))

let serialize_bvdef = (fun writer ast -> (let _31_63 = (serialize_ident writer ast.FStar_Absyn_Syntax.ppname)
in (serialize_ident writer ast.FStar_Absyn_Syntax.realname)))

let deserialize_bvdef = (fun ghost reader -> (let _122_110 = (deserialize_ident reader)
in (let _122_109 = (deserialize_ident reader)
in {FStar_Absyn_Syntax.ppname = _122_110; FStar_Absyn_Syntax.realname = _122_109})))

let serialize_bvar = (fun writer s_sort ast -> (serialize_withinfo_t writer serialize_bvdef s_sort ast))

let deserialize_bvar = (fun ghost reader ds_sort -> (deserialize_withinfo_t reader (deserialize_bvdef ghost) ds_sort))

let serialize_sconst = (fun writer ast -> (match (ast) with
| FStar_Const.Const_effect -> begin
(writer.FStar_Util.write_char '_')
end
| FStar_Const.Const_unit -> begin
(writer.FStar_Util.write_char 'a')
end
| FStar_Const.Const_uint8 (v) -> begin
(let _31_84 = (writer.FStar_Util.write_char 'b')
in (writer.FStar_Util.write_byte v))
end
| FStar_Const.Const_bool (v) -> begin
(let _31_88 = (writer.FStar_Util.write_char 'c')
in (writer.FStar_Util.write_bool v))
end
| FStar_Const.Const_int32 (v) -> begin
(let _31_92 = (writer.FStar_Util.write_char 'd')
in (writer.FStar_Util.write_int32 v))
end
| FStar_Const.Const_int64 (v) -> begin
(let _31_96 = (writer.FStar_Util.write_char 'e')
in (writer.FStar_Util.write_int64 v))
end
| FStar_Const.Const_char (v) -> begin
(let _31_100 = (writer.FStar_Util.write_char 'f')
in (writer.FStar_Util.write_char v))
end
| FStar_Const.Const_float (v) -> begin
(let _31_104 = (writer.FStar_Util.write_char 'g')
in (writer.FStar_Util.write_double v))
end
| FStar_Const.Const_bytearray (v, _31_108) -> begin
(let _31_111 = (writer.FStar_Util.write_char 'h')
in (writer.FStar_Util.write_bytearray v))
end
| FStar_Const.Const_string (v, _31_115) -> begin
(let _31_118 = (writer.FStar_Util.write_char 'i')
in (writer.FStar_Util.write_bytearray v))
end
| FStar_Const.Const_int (v) -> begin
(let _31_122 = (writer.FStar_Util.write_char 'j')
in (writer.FStar_Util.write_string v))
end))

let deserialize_sconst = (fun reader -> (match ((reader.FStar_Util.read_char ())) with
| '_' -> begin
FStar_Const.Const_effect
end
| 'a' -> begin
FStar_Const.Const_unit
end
| 'b' -> begin
(let _122_132 = (reader.FStar_Util.read_byte ())
in FStar_Const.Const_uint8 (_122_132))
end
| 'c' -> begin
(let _122_133 = (reader.FStar_Util.read_bool ())
in FStar_Const.Const_bool (_122_133))
end
| 'd' -> begin
(let _122_134 = (reader.FStar_Util.read_int32 ())
in FStar_Const.Const_int32 (_122_134))
end
| 'e' -> begin
(let _122_135 = (reader.FStar_Util.read_int64 ())
in FStar_Const.Const_int64 (_122_135))
end
| 'f' -> begin
(let _122_136 = (reader.FStar_Util.read_char ())
in FStar_Const.Const_char (_122_136))
end
| 'g' -> begin
(let _122_137 = (reader.FStar_Util.read_double ())
in FStar_Const.Const_float (_122_137))
end
| 'h' -> begin
(let _122_139 = (let _122_138 = (reader.FStar_Util.read_bytearray ())
in (_122_138, FStar_Absyn_Syntax.dummyRange))
in FStar_Const.Const_bytearray (_122_139))
end
| 'i' -> begin
(let _122_141 = (let _122_140 = (reader.FStar_Util.read_bytearray ())
in (_122_140, FStar_Absyn_Syntax.dummyRange))
in FStar_Const.Const_string (_122_141))
end
| 'j' -> begin
(let _122_142 = (reader.FStar_Util.read_string ())
in FStar_Const.Const_int (_122_142))
end
| _31_137 -> begin
(parse_error ())
end))

let serialize_either = (fun writer s_l s_r ast -> (match (ast) with
| FStar_Util.Inl (v) -> begin
(let _31_146 = (writer.FStar_Util.write_char 'a')
in (s_l writer v))
end
| FStar_Util.Inr (v) -> begin
(let _31_150 = (writer.FStar_Util.write_char 'b')
in (s_r writer v))
end))

let deserialize_either = (fun reader ds_l ds_r -> (match ((reader.FStar_Util.read_char ())) with
| 'a' -> begin
(let _122_168 = (ds_l reader)
in FStar_Util.Inl (_122_168))
end
| 'b' -> begin
(let _122_169 = (ds_r reader)
in FStar_Util.Inr (_122_169))
end
| _31_160 -> begin
(parse_error ())
end))

let serialize_syntax = (fun writer s_a ast -> (s_a writer ast.FStar_Absyn_Syntax.n))

let deserialize_syntax = (fun reader ds_a ds_b -> (let _122_188 = (ds_a reader)
in (let _122_187 = (FStar_Util.mk_ref None)
in (let _122_186 = (FStar_Util.mk_ref None)
in (let _122_185 = (FStar_Util.mk_ref None)
in {FStar_Absyn_Syntax.n = _122_188; FStar_Absyn_Syntax.tk = _122_187; FStar_Absyn_Syntax.pos = FStar_Absyn_Syntax.dummyRange; FStar_Absyn_Syntax.fvs = _122_186; FStar_Absyn_Syntax.uvs = _122_185})))))

let rec serialize_typ' = (fun writer ast -> (match (ast) with
| FStar_Absyn_Syntax.Typ_btvar (v) -> begin
(let _31_175 = (writer.FStar_Util.write_char 'a')
in (serialize_btvar writer v))
end
| FStar_Absyn_Syntax.Typ_const (v) -> begin
(let _31_179 = (writer.FStar_Util.write_char 'b')
in (serialize_ftvar writer v))
end
| FStar_Absyn_Syntax.Typ_fun (bs, c) -> begin
(let _31_185 = (writer.FStar_Util.write_char 'c')
in (let _31_187 = (serialize_binders writer bs)
in (serialize_comp writer c)))
end
| FStar_Absyn_Syntax.Typ_refine (v, t) -> begin
(let _31_193 = (writer.FStar_Util.write_char 'd')
in (let _31_195 = (serialize_bvvar writer v)
in (serialize_typ writer t)))
end
| FStar_Absyn_Syntax.Typ_app (t, ars) -> begin
(let _31_201 = (writer.FStar_Util.write_char 'e')
in (let _31_203 = (serialize_typ writer t)
in (let _31_205 = (serialize_args writer ars)
in if ((FStar_ST.read FStar_Options.debug) <> []) then begin
(match (t.FStar_Absyn_Syntax.n) with
| FStar_Absyn_Syntax.Typ_lam (_31_208, _31_210) -> begin
(FStar_Util.print_string "type application node with lam\n")
end
| _31_214 -> begin
()
end)
end else begin
()
end)))
end
| FStar_Absyn_Syntax.Typ_lam (bs, t) -> begin
(let _31_219 = (writer.FStar_Util.write_char 'f')
in (let _31_221 = (serialize_binders writer bs)
in (serialize_typ writer t)))
end
| FStar_Absyn_Syntax.Typ_ascribed (t, k) -> begin
(let _31_227 = (writer.FStar_Util.write_char 'g')
in (let _31_229 = (serialize_typ writer t)
in (serialize_knd writer k)))
end
| FStar_Absyn_Syntax.Typ_meta (m) -> begin
(let _31_233 = (writer.FStar_Util.write_char 'h')
in (serialize_meta_t writer m))
end
| FStar_Absyn_Syntax.Typ_unknown -> begin
(writer.FStar_Util.write_char 'i')
end
| FStar_Absyn_Syntax.Typ_uvar (_31_237, _31_239) -> begin
(Prims.raise (Err ("typ not impl:1")))
end
| FStar_Absyn_Syntax.Typ_delayed (_31_243, _31_245) -> begin
(Prims.raise (Err ("typ not impl:2")))
end))
and serialize_meta_t = (fun writer ast -> (match (ast) with
| FStar_Absyn_Syntax.Meta_pattern (t, l) -> begin
(let _31_254 = (writer.FStar_Util.write_char 'a')
in (let _31_256 = (serialize_typ writer t)
in (serialize_list writer (fun w -> (serialize_list w serialize_arg)) l)))
end
| FStar_Absyn_Syntax.Meta_named (t, lid) -> begin
(let _31_263 = (writer.FStar_Util.write_char 'b')
in (let _31_265 = (serialize_typ writer t)
in (serialize_lident writer lid)))
end
| FStar_Absyn_Syntax.Meta_labeled (t, s, _31_270, b) -> begin
(let _31_274 = (writer.FStar_Util.write_char 'c')
in (let _31_276 = (serialize_typ writer t)
in (let _31_278 = (writer.FStar_Util.write_string s)
in (writer.FStar_Util.write_bool b))))
end
| _31_281 -> begin
(Prims.raise (Err ("unimplemented meta_t")))
end))
and serialize_arg = (fun writer ast -> (let _31_284 = (serialize_either writer serialize_typ serialize_exp (Prims.fst ast))
in (let _122_257 = (FStar_All.pipe_left FStar_Absyn_Syntax.is_implicit (Prims.snd ast))
in (writer.FStar_Util.write_bool _122_257))))
and serialize_args = (fun writer ast -> (serialize_list writer serialize_arg ast))
and serialize_binder = (fun writer ast -> (let _31_290 = (serialize_either writer serialize_btvar serialize_bvvar (Prims.fst ast))
in (let _122_262 = (FStar_All.pipe_left FStar_Absyn_Syntax.is_implicit (Prims.snd ast))
in (writer.FStar_Util.write_bool _122_262))))
and serialize_binders = (fun writer ast -> (serialize_list writer serialize_binder ast))
and serialize_typ = (fun writer ast -> (let _122_267 = (FStar_Absyn_Util.compress_typ ast)
in (serialize_syntax writer serialize_typ' _122_267)))
and serialize_comp_typ = (fun writer ast -> (let _31_298 = (serialize_lident writer ast.FStar_Absyn_Syntax.effect_name)
in (let _31_300 = (serialize_typ writer ast.FStar_Absyn_Syntax.result_typ)
in (let _31_302 = (serialize_args writer ast.FStar_Absyn_Syntax.effect_args)
in (serialize_list writer serialize_cflags ast.FStar_Absyn_Syntax.flags)))))
and serialize_comp' = (fun writer ast -> (match (ast) with
| FStar_Absyn_Syntax.Total (t) -> begin
(let _31_308 = (writer.FStar_Util.write_char 'a')
in (serialize_typ writer t))
end
| FStar_Absyn_Syntax.Comp (c) -> begin
(let _31_312 = (writer.FStar_Util.write_char 'b')
in (serialize_comp_typ writer c))
end))
and serialize_comp = (fun writer ast -> (serialize_syntax writer serialize_comp' ast))
and serialize_cflags = (fun writer ast -> (match (ast) with
| FStar_Absyn_Syntax.TOTAL -> begin
(writer.FStar_Util.write_char 'a')
end
| FStar_Absyn_Syntax.MLEFFECT -> begin
(writer.FStar_Util.write_char 'b')
end
| FStar_Absyn_Syntax.RETURN -> begin
(writer.FStar_Util.write_char 'c')
end
| FStar_Absyn_Syntax.PARTIAL_RETURN -> begin
(writer.FStar_Util.write_char 'd')
end
| FStar_Absyn_Syntax.SOMETRIVIAL -> begin
(writer.FStar_Util.write_char 'e')
end
| FStar_Absyn_Syntax.LEMMA -> begin
(writer.FStar_Util.write_char 'f')
end
| FStar_Absyn_Syntax.DECREASES (e) -> begin
(let _31_326 = (writer.FStar_Util.write_char 'g')
in (serialize_exp writer e))
end))
and serialize_exp' = (fun writer ast -> (match (ast) with
| FStar_Absyn_Syntax.Exp_bvar (v) -> begin
(let _31_332 = (writer.FStar_Util.write_char 'a')
in (serialize_bvvar writer v))
end
| FStar_Absyn_Syntax.Exp_fvar (v, b) -> begin
(let _31_338 = (writer.FStar_Util.write_char 'b')
in (let _31_340 = (serialize_fvvar writer v)
in (writer.FStar_Util.write_bool false)))
end
| FStar_Absyn_Syntax.Exp_constant (c) -> begin
(let _31_344 = (writer.FStar_Util.write_char 'c')
in (serialize_sconst writer c))
end
| FStar_Absyn_Syntax.Exp_abs (bs, e) -> begin
(let _31_350 = (writer.FStar_Util.write_char 'd')
in (let _31_352 = (serialize_binders writer bs)
in (serialize_exp writer e)))
end
| FStar_Absyn_Syntax.Exp_app (e, ars) -> begin
(let _31_358 = (writer.FStar_Util.write_char 'e')
in (let _31_360 = (serialize_exp writer e)
in (serialize_args writer ars)))
end
| FStar_Absyn_Syntax.Exp_match (e, l) -> begin
(let g = (fun writer eopt -> (match (eopt) with
| Some (e1) -> begin
(let _31_371 = (writer.FStar_Util.write_char 'a')
in (serialize_exp writer e1))
end
| None -> begin
(writer.FStar_Util.write_char 'b')
end))
in (let f = (fun writer _31_379 -> (match (_31_379) with
| (p, eopt, e) -> begin
(let _31_380 = (serialize_pat writer p)
in (let _31_382 = (g writer eopt)
in (serialize_exp writer e)))
end))
in (let _31_384 = (writer.FStar_Util.write_char 'f')
in (let _31_386 = (serialize_exp writer e)
in (serialize_list writer f l)))))
end
| FStar_Absyn_Syntax.Exp_ascribed (e, t, l) -> begin
(let _31_393 = (writer.FStar_Util.write_char 'g')
in (let _31_395 = (serialize_exp writer e)
in (let _31_397 = (serialize_typ writer t)
in (serialize_option writer serialize_lident l))))
end
| FStar_Absyn_Syntax.Exp_let (lbs, e) -> begin
(let _31_403 = (writer.FStar_Util.write_char 'h')
in (let _31_405 = (serialize_letbindings writer lbs)
in (serialize_exp writer e)))
end
| FStar_Absyn_Syntax.Exp_meta (m) -> begin
(let _31_409 = (writer.FStar_Util.write_char 'i')
in (serialize_meta_e writer m))
end
| _31_412 -> begin
(Prims.raise (Err ("unimplemented exp\'")))
end))
and serialize_meta_e = (fun writer ast -> (match (ast) with
| FStar_Absyn_Syntax.Meta_desugared (e, s) -> begin
(let _31_419 = (writer.FStar_Util.write_char 'a')
in (let _31_421 = (serialize_exp writer e)
in (serialize_meta_source_info writer s)))
end))
and serialize_meta_source_info = (fun writer ast -> (match (ast) with
| FStar_Absyn_Syntax.Data_app -> begin
(writer.FStar_Util.write_char 'a')
end
| FStar_Absyn_Syntax.Sequence -> begin
(writer.FStar_Util.write_char 'b')
end
| FStar_Absyn_Syntax.Primop -> begin
(writer.FStar_Util.write_char 'c')
end
| FStar_Absyn_Syntax.Masked_effect -> begin
(writer.FStar_Util.write_char 'd')
end
| FStar_Absyn_Syntax.Meta_smt_pat -> begin
(writer.FStar_Util.write_char 'e')
end))
and serialize_exp = (fun writer ast -> (let _122_292 = (FStar_Absyn_Util.compress_exp ast)
in (serialize_syntax writer serialize_exp' _122_292)))
and serialize_btvdef = (fun writer ast -> (serialize_bvdef writer ast))
and serialize_bvvdef = (fun writer ast -> (serialize_bvdef writer ast))
and serialize_pat' = (fun writer ast -> (match (ast) with
| FStar_Absyn_Syntax.Pat_disj (l) -> begin
(let _31_440 = (writer.FStar_Util.write_char 'a')
in (serialize_list writer serialize_pat l))
end
| FStar_Absyn_Syntax.Pat_constant (c) -> begin
(let _31_444 = (writer.FStar_Util.write_char 'b')
in (serialize_sconst writer c))
end
| FStar_Absyn_Syntax.Pat_cons (v, _31_448, l) -> begin
(let _31_452 = (writer.FStar_Util.write_char 'c')
in (let _31_454 = (serialize_fvvar writer v)
in (serialize_list writer (fun w _31_459 -> (match (_31_459) with
| (p, b) -> begin
(let _31_460 = (serialize_pat w p)
in (w.FStar_Util.write_bool b))
end)) l)))
end
| FStar_Absyn_Syntax.Pat_var (v) -> begin
(let _31_464 = (writer.FStar_Util.write_char 'd')
in (serialize_bvvar writer v))
end
| FStar_Absyn_Syntax.Pat_tvar (v) -> begin
(let _31_468 = (writer.FStar_Util.write_char 'e')
in (serialize_btvar writer v))
end
| FStar_Absyn_Syntax.Pat_wild (v) -> begin
(let _31_472 = (writer.FStar_Util.write_char 'f')
in (serialize_bvvar writer v))
end
| FStar_Absyn_Syntax.Pat_twild (v) -> begin
(let _31_476 = (writer.FStar_Util.write_char 'g')
in (serialize_btvar writer v))
end
| FStar_Absyn_Syntax.Pat_dot_term (v, e) -> begin
(let _31_482 = (writer.FStar_Util.write_char 'h')
in (let _31_484 = (serialize_bvvar writer v)
in (serialize_exp writer e)))
end
| FStar_Absyn_Syntax.Pat_dot_typ (v, t) -> begin
(let _31_490 = (writer.FStar_Util.write_char 'i')
in (let _31_492 = (serialize_btvar writer v)
in (serialize_typ writer t)))
end))
and serialize_pat = (fun writer ast -> (serialize_withinfo_t writer serialize_pat' (fun w kt -> ()) ast))
and serialize_knd' = (fun writer ast -> (match (ast) with
| FStar_Absyn_Syntax.Kind_type -> begin
(writer.FStar_Util.write_char 'a')
end
| FStar_Absyn_Syntax.Kind_effect -> begin
(writer.FStar_Util.write_char 'b')
end
| FStar_Absyn_Syntax.Kind_abbrev (ka, k) -> begin
(let _31_506 = (writer.FStar_Util.write_char 'c')
in (let _31_508 = (serialize_kabbrev writer ka)
in (serialize_knd writer k)))
end
| FStar_Absyn_Syntax.Kind_arrow (bs, k) -> begin
(let _31_514 = (writer.FStar_Util.write_char 'd')
in (let _31_516 = (serialize_binders writer bs)
in (serialize_knd writer k)))
end
| FStar_Absyn_Syntax.Kind_lam (bs, k) -> begin
(let _31_522 = (writer.FStar_Util.write_char 'e')
in (let _31_524 = (serialize_binders writer bs)
in (serialize_knd writer k)))
end
| FStar_Absyn_Syntax.Kind_unknown -> begin
(writer.FStar_Util.write_char 'f')
end
| FStar_Absyn_Syntax.Kind_uvar (uv, args) -> begin
(Prims.raise (Err ("knd\' serialization unimplemented:1")))
end
| FStar_Absyn_Syntax.Kind_delayed (_31_532, _31_534, _31_536) -> begin
(Prims.raise (Err ("knd\' serialization unimplemented:2")))
end))
and serialize_knd = (fun writer ast -> (let _122_309 = (FStar_Absyn_Util.compress_kind ast)
in (serialize_syntax writer serialize_knd' _122_309)))
and serialize_kabbrev = (fun writer ast -> (let _31_543 = (serialize_lident writer (Prims.fst ast))
in (serialize_args writer (Prims.snd ast))))
and serialize_lbname = (fun writer ast -> (serialize_either writer serialize_bvvdef serialize_lident ast))
and serialize_letbindings = (fun writer ast -> (let f = (fun writer lb -> (let _31_552 = (serialize_lbname writer lb.FStar_Absyn_Syntax.lbname)
in (let _31_554 = (serialize_lident writer lb.FStar_Absyn_Syntax.lbeff)
in (let _31_556 = (serialize_typ writer lb.FStar_Absyn_Syntax.lbtyp)
in (serialize_exp writer lb.FStar_Absyn_Syntax.lbdef)))))
in (let _31_558 = (writer.FStar_Util.write_bool (Prims.fst ast))
in (serialize_list writer f (Prims.snd ast)))))
and serialize_fvar = (fun writer ast -> (serialize_either writer serialize_btvdef serialize_bvvdef ast))
and serialize_btvar = (fun writer ast -> (serialize_bvar writer serialize_knd ast))
and serialize_bvvar = (fun writer ast -> (serialize_bvar writer serialize_typ ast))
and serialize_ftvar = (fun writer ast -> (serialize_var writer serialize_knd ast))
and serialize_fvvar = (fun writer ast -> (serialize_var writer serialize_typ ast))

let rec deserialize_typ' = (fun reader -> (match ((reader.FStar_Util.read_char ())) with
| 'a' -> begin
(let _122_360 = (deserialize_btvar reader)
in FStar_Absyn_Syntax.Typ_btvar (_122_360))
end
| 'b' -> begin
(let _122_361 = (deserialize_ftvar reader)
in FStar_Absyn_Syntax.Typ_const (_122_361))
end
| 'c' -> begin
(let _122_364 = (let _122_363 = (deserialize_binders reader)
in (let _122_362 = (deserialize_comp reader)
in (_122_363, _122_362)))
in FStar_Absyn_Syntax.Typ_fun (_122_364))
end
| 'd' -> begin
(let _122_367 = (let _122_366 = (deserialize_bvvar reader)
in (let _122_365 = (deserialize_typ reader)
in (_122_366, _122_365)))
in FStar_Absyn_Syntax.Typ_refine (_122_367))
end
| 'e' -> begin
(let _122_370 = (let _122_369 = (deserialize_typ reader)
in (let _122_368 = (deserialize_args reader)
in (_122_369, _122_368)))
in FStar_Absyn_Syntax.Typ_app (_122_370))
end
| 'f' -> begin
(let _122_373 = (let _122_372 = (deserialize_binders reader)
in (let _122_371 = (deserialize_typ reader)
in (_122_372, _122_371)))
in FStar_Absyn_Syntax.Typ_lam (_122_373))
end
| 'g' -> begin
(let _122_376 = (let _122_375 = (deserialize_typ reader)
in (let _122_374 = (deserialize_knd reader)
in (_122_375, _122_374)))
in FStar_Absyn_Syntax.Typ_ascribed (_122_376))
end
| 'h' -> begin
(let _122_377 = (deserialize_meta_t reader)
in FStar_Absyn_Syntax.Typ_meta (_122_377))
end
| 'i' -> begin
FStar_Absyn_Syntax.Typ_unknown
end
| _31_581 -> begin
(parse_error ())
end))
and deserialize_meta_t = (fun reader -> (match ((reader.FStar_Util.read_char ())) with
| 'a' -> begin
(let _122_382 = (let _122_381 = (deserialize_typ reader)
in (let _122_380 = (deserialize_list reader (fun r -> (deserialize_list r deserialize_arg)))
in (_122_381, _122_380)))
in FStar_Absyn_Syntax.Meta_pattern (_122_382))
end
| 'b' -> begin
(let _122_385 = (let _122_384 = (deserialize_typ reader)
in (let _122_383 = (deserialize_lident reader)
in (_122_384, _122_383)))
in FStar_Absyn_Syntax.Meta_named (_122_385))
end
| 'c' -> begin
(let _122_389 = (let _122_388 = (deserialize_typ reader)
in (let _122_387 = (reader.FStar_Util.read_string ())
in (let _122_386 = (reader.FStar_Util.read_bool ())
in (_122_388, _122_387, FStar_Absyn_Syntax.dummyRange, _122_386))))
in FStar_Absyn_Syntax.Meta_labeled (_122_389))
end
| _31_588 -> begin
(parse_error ())
end))
and deserialize_arg = (fun reader -> (let _122_393 = (deserialize_either reader deserialize_typ deserialize_exp)
in (let _122_392 = (let _122_391 = (reader.FStar_Util.read_bool ())
in (FStar_All.pipe_left FStar_Absyn_Syntax.as_implicit _122_391))
in (_122_393, _122_392))))
and deserialize_args = (fun reader -> (deserialize_list reader deserialize_arg))
and deserialize_binder = (fun reader -> (let _122_398 = (deserialize_either reader deserialize_btvar deserialize_bvvar)
in (let _122_397 = (let _122_396 = (reader.FStar_Util.read_bool ())
in (FStar_All.pipe_left FStar_Absyn_Syntax.as_implicit _122_396))
in (_122_398, _122_397))))
and deserialize_binders = (fun reader -> (deserialize_list reader deserialize_binder))
and deserialize_typ = (fun reader -> (deserialize_syntax reader deserialize_typ' FStar_Absyn_Syntax.mk_Kind_unknown))
and deserialize_comp_typ = (fun reader -> (let _122_405 = (deserialize_lident reader)
in (let _122_404 = (deserialize_typ reader)
in (let _122_403 = (deserialize_args reader)
in (let _122_402 = (deserialize_list reader deserialize_cflags)
in {FStar_Absyn_Syntax.effect_name = _122_405; FStar_Absyn_Syntax.result_typ = _122_404; FStar_Absyn_Syntax.effect_args = _122_403; FStar_Absyn_Syntax.flags = _122_402})))))
and deserialize_comp' = (fun reader -> (match ((reader.FStar_Util.read_char ())) with
| 'a' -> begin
(let _122_407 = (deserialize_typ reader)
in FStar_Absyn_Syntax.Total (_122_407))
end
| 'b' -> begin
(let _122_408 = (deserialize_comp_typ reader)
in FStar_Absyn_Syntax.Comp (_122_408))
end
| _31_599 -> begin
(parse_error ())
end))
and deserialize_comp = (fun reader -> (deserialize_syntax reader deserialize_comp' ()))
and deserialize_cflags = (fun reader -> (match ((reader.FStar_Util.read_char ())) with
| 'a' -> begin
FStar_Absyn_Syntax.TOTAL
end
| 'b' -> begin
FStar_Absyn_Syntax.MLEFFECT
end
| 'c' -> begin
FStar_Absyn_Syntax.RETURN
end
| 'd' -> begin
FStar_Absyn_Syntax.PARTIAL_RETURN
end
| 'e' -> begin
FStar_Absyn_Syntax.SOMETRIVIAL
end
| 'f' -> begin
FStar_Absyn_Syntax.LEMMA
end
| 'g' -> begin
(let _122_411 = (deserialize_exp reader)
in FStar_Absyn_Syntax.DECREASES (_122_411))
end
| _31_610 -> begin
(parse_error ())
end))
and deserialize_exp' = (fun reader -> (match ((reader.FStar_Util.read_char ())) with
| 'a' -> begin
(let _122_413 = (deserialize_bvvar reader)
in FStar_Absyn_Syntax.Exp_bvar (_122_413))
end
| 'b' -> begin
(let _122_417 = (let _122_416 = (deserialize_fvvar reader)
in (let _122_415 = (let _31_614 = (let _122_414 = (reader.FStar_Util.read_bool ())
in (FStar_All.pipe_left Prims.ignore _122_414))
in None)
in (_122_416, _122_415)))
in FStar_Absyn_Syntax.Exp_fvar (_122_417))
end
| 'c' -> begin
(let _122_418 = (deserialize_sconst reader)
in FStar_Absyn_Syntax.Exp_constant (_122_418))
end
| 'd' -> begin
(let _122_421 = (let _122_420 = (deserialize_binders reader)
in (let _122_419 = (deserialize_exp reader)
in (_122_420, _122_419)))
in FStar_Absyn_Syntax.Exp_abs (_122_421))
end
| 'e' -> begin
(let _122_424 = (let _122_423 = (deserialize_exp reader)
in (let _122_422 = (deserialize_args reader)
in (_122_423, _122_422)))
in FStar_Absyn_Syntax.Exp_app (_122_424))
end
| 'f' -> begin
(let g = (fun reader -> (match ((reader.FStar_Util.read_char ())) with
| 'a' -> begin
(let _122_427 = (deserialize_exp reader)
in Some (_122_427))
end
| 'b' -> begin
None
end
| _31_625 -> begin
(parse_error ())
end))
in (let f = (fun reader -> (let _122_432 = (deserialize_pat reader)
in (let _122_431 = (g reader)
in (let _122_430 = (deserialize_exp reader)
in (_122_432, _122_431, _122_430)))))
in (let _122_435 = (let _122_434 = (deserialize_exp reader)
in (let _122_433 = (deserialize_list reader f)
in (_122_434, _122_433)))
in FStar_Absyn_Syntax.Exp_match (_122_435))))
end
| 'g' -> begin
(let _122_439 = (let _122_438 = (deserialize_exp reader)
in (let _122_437 = (deserialize_typ reader)
in (let _122_436 = (deserialize_option reader deserialize_lident)
in (_122_438, _122_437, _122_436))))
in FStar_Absyn_Syntax.Exp_ascribed (_122_439))
end
| 'h' -> begin
(let _122_442 = (let _122_441 = (deserialize_letbindings reader)
in (let _122_440 = (deserialize_exp reader)
in (_122_441, _122_440)))
in FStar_Absyn_Syntax.Exp_let (_122_442))
end
| 'i' -> begin
(let _122_443 = (deserialize_meta_e reader)
in FStar_Absyn_Syntax.Exp_meta (_122_443))
end
| _31_632 -> begin
(parse_error ())
end))
and deserialize_meta_e = (fun reader -> (match ((reader.FStar_Util.read_char ())) with
| 'a' -> begin
(let _122_447 = (let _122_446 = (deserialize_exp reader)
in (let _122_445 = (deserialize_meta_source_info reader)
in (_122_446, _122_445)))
in FStar_Absyn_Syntax.Meta_desugared (_122_447))
end
| _31_636 -> begin
(parse_error ())
end))
and deserialize_meta_source_info = (fun reader -> (match ((reader.FStar_Util.read_char ())) with
| 'a' -> begin
FStar_Absyn_Syntax.Data_app
end
| 'b' -> begin
FStar_Absyn_Syntax.Sequence
end
| 'c' -> begin
FStar_Absyn_Syntax.Primop
end
| 'd' -> begin
FStar_Absyn_Syntax.Masked_effect
end
| _31_643 -> begin
(parse_error ())
end))
and deserialize_exp = (fun reader -> (deserialize_syntax reader deserialize_exp' FStar_Absyn_Syntax.mk_Typ_unknown))
and deserialize_btvdef = (fun reader -> (deserialize_bvdef None reader))
and deserialize_bvvdef = (fun reader -> (deserialize_bvdef None reader))
and deserialize_pat' = (fun reader -> (match ((reader.FStar_Util.read_char ())) with
| 'a' -> begin
(let _122_453 = (deserialize_list reader deserialize_pat)
in FStar_Absyn_Syntax.Pat_disj (_122_453))
end
| 'b' -> begin
(let _122_454 = (deserialize_sconst reader)
in FStar_Absyn_Syntax.Pat_constant (_122_454))
end
| 'c' -> begin
(let _122_460 = (let _122_459 = (deserialize_fvvar reader)
in (let _122_458 = (deserialize_list reader (fun r -> (let _122_457 = (deserialize_pat r)
in (let _122_456 = (r.FStar_Util.read_bool ())
in (_122_457, _122_456)))))
in (_122_459, None, _122_458)))
in FStar_Absyn_Syntax.Pat_cons (_122_460))
end
| 'd' -> begin
(let _122_461 = (deserialize_bvvar reader)
in FStar_Absyn_Syntax.Pat_var (_122_461))
end
| 'e' -> begin
(let _122_462 = (deserialize_btvar reader)
in FStar_Absyn_Syntax.Pat_tvar (_122_462))
end
| 'f' -> begin
(let _122_463 = (deserialize_bvvar reader)
in FStar_Absyn_Syntax.Pat_wild (_122_463))
end
| 'g' -> begin
(let _122_464 = (deserialize_btvar reader)
in FStar_Absyn_Syntax.Pat_twild (_122_464))
end
| 'h' -> begin
(let _122_467 = (let _122_466 = (deserialize_bvvar reader)
in (let _122_465 = (deserialize_exp reader)
in (_122_466, _122_465)))
in FStar_Absyn_Syntax.Pat_dot_term (_122_467))
end
| 'i' -> begin
(let _122_470 = (let _122_469 = (deserialize_btvar reader)
in (let _122_468 = (deserialize_typ reader)
in (_122_469, _122_468)))
in FStar_Absyn_Syntax.Pat_dot_typ (_122_470))
end
| _31_659 -> begin
(parse_error ())
end))
and deserialize_pat = (fun reader -> (deserialize_withinfo_t reader deserialize_pat' (fun r -> None)))
and deserialize_knd' = (fun reader -> (match ((reader.FStar_Util.read_char ())) with
| 'a' -> begin
FStar_Absyn_Syntax.Kind_type
end
| 'b' -> begin
FStar_Absyn_Syntax.Kind_effect
end
| 'c' -> begin
(let _122_476 = (let _122_475 = (deserialize_kabbrev reader)
in (let _122_474 = (deserialize_knd reader)
in (_122_475, _122_474)))
in FStar_Absyn_Syntax.Kind_abbrev (_122_476))
end
| 'd' -> begin
(let _122_479 = (let _122_478 = (deserialize_binders reader)
in (let _122_477 = (deserialize_knd reader)
in (_122_478, _122_477)))
in FStar_Absyn_Syntax.Kind_arrow (_122_479))
end
| 'e' -> begin
(let _122_482 = (let _122_481 = (deserialize_binders reader)
in (let _122_480 = (deserialize_knd reader)
in (_122_481, _122_480)))
in FStar_Absyn_Syntax.Kind_lam (_122_482))
end
| 'f' -> begin
FStar_Absyn_Syntax.Kind_unknown
end
| _31_670 -> begin
(parse_error ())
end))
and deserialize_knd = (fun reader -> (deserialize_syntax reader deserialize_knd' ()))
and deserialize_kabbrev = (fun reader -> (let _122_486 = (deserialize_lident reader)
in (let _122_485 = (deserialize_args reader)
in (_122_486, _122_485))))
and deserialize_lbname = (fun reader -> (deserialize_either reader deserialize_bvvdef deserialize_lident))
and deserialize_letbindings = (fun reader -> (let f = (fun reader -> (let _122_494 = (deserialize_lbname reader)
in (let _122_493 = (deserialize_typ reader)
in (let _122_492 = (deserialize_lident reader)
in (let _122_491 = (deserialize_exp reader)
in {FStar_Absyn_Syntax.lbname = _122_494; FStar_Absyn_Syntax.lbtyp = _122_493; FStar_Absyn_Syntax.lbeff = _122_492; FStar_Absyn_Syntax.lbdef = _122_491})))))
in (let _122_496 = (reader.FStar_Util.read_bool ())
in (let _122_495 = (deserialize_list reader f)
in (_122_496, _122_495)))))
and deserialize_fvar = (fun reader -> (deserialize_either reader deserialize_btvdef deserialize_bvvdef))
and deserialize_btvar = (fun reader -> (deserialize_bvar None reader deserialize_knd))
and deserialize_bvvar = (fun reader -> (deserialize_bvar None reader deserialize_typ))
and deserialize_ftvar = (fun reader -> (deserialize_var reader deserialize_knd))
and deserialize_fvvar = (fun reader -> (deserialize_var reader deserialize_typ))

let serialize_formula = serialize_typ

let deserialize_formula = deserialize_typ

let serialize_qualifier = (fun writer ast -> (match (ast) with
| FStar_Absyn_Syntax.Private -> begin
(writer.FStar_Util.write_char 'a')
end
| FStar_Absyn_Syntax.Assumption -> begin
(writer.FStar_Util.write_char 'c')
end
| FStar_Absyn_Syntax.Logic -> begin
(writer.FStar_Util.write_char 'g')
end
| FStar_Absyn_Syntax.Opaque -> begin
(writer.FStar_Util.write_char 'h')
end
| FStar_Absyn_Syntax.Discriminator (lid) -> begin
(let _31_690 = (writer.FStar_Util.write_char 'i')
in (serialize_lident writer lid))
end
| FStar_Absyn_Syntax.Projector (lid, v) -> begin
(let _31_696 = (writer.FStar_Util.write_char 'j')
in (let _31_698 = (serialize_lident writer lid)
in (serialize_either writer serialize_btvdef serialize_bvvdef v)))
end
| FStar_Absyn_Syntax.RecordType (l) -> begin
(let _31_702 = (writer.FStar_Util.write_char 'k')
in (serialize_list writer serialize_lident l))
end
| FStar_Absyn_Syntax.RecordConstructor (l) -> begin
(let _31_706 = (writer.FStar_Util.write_char 'l')
in (serialize_list writer serialize_lident l))
end
| FStar_Absyn_Syntax.ExceptionConstructor -> begin
(writer.FStar_Util.write_char 'm')
end
| FStar_Absyn_Syntax.HasMaskedEffect -> begin
(writer.FStar_Util.write_char 'o')
end
| FStar_Absyn_Syntax.DefaultEffect (l) -> begin
(let _31_712 = (writer.FStar_Util.write_char 'p')
in (serialize_option writer serialize_lident l))
end
| FStar_Absyn_Syntax.TotalEffect -> begin
(writer.FStar_Util.write_char 'q')
end
| _31_716 -> begin
(FStar_All.failwith "Unexpected qualifier")
end))

let deserialize_qualifier = (fun reader -> (match ((reader.FStar_Util.read_char ())) with
| 'a' -> begin
FStar_Absyn_Syntax.Private
end
| 'c' -> begin
FStar_Absyn_Syntax.Assumption
end
| 'g' -> begin
FStar_Absyn_Syntax.Logic
end
| 'h' -> begin
FStar_Absyn_Syntax.Opaque
end
| 'i' -> begin
(let _122_511 = (deserialize_lident reader)
in FStar_Absyn_Syntax.Discriminator (_122_511))
end
| 'j' -> begin
(let _122_514 = (let _122_513 = (deserialize_lident reader)
in (let _122_512 = (deserialize_either reader deserialize_btvdef deserialize_bvvdef)
in (_122_513, _122_512)))
in FStar_Absyn_Syntax.Projector (_122_514))
end
| 'k' -> begin
(let _122_515 = (deserialize_list reader deserialize_lident)
in FStar_Absyn_Syntax.RecordType (_122_515))
end
| 'l' -> begin
(let _122_516 = (deserialize_list reader deserialize_lident)
in FStar_Absyn_Syntax.RecordConstructor (_122_516))
end
| 'm' -> begin
FStar_Absyn_Syntax.ExceptionConstructor
end
| 'o' -> begin
FStar_Absyn_Syntax.HasMaskedEffect
end
| 'p' -> begin
(let _122_518 = (deserialize_option reader deserialize_lident)
in (FStar_All.pipe_right _122_518 (fun _122_517 -> FStar_Absyn_Syntax.DefaultEffect (_122_517))))
end
| 'q' -> begin
FStar_Absyn_Syntax.TotalEffect
end
| _31_731 -> begin
(parse_error ())
end))

let serialize_tycon = (fun writer _31_736 -> (match (_31_736) with
| (lid, bs, k) -> begin
(let _31_737 = (serialize_lident writer lid)
in (let _31_739 = (serialize_binders writer bs)
in (serialize_knd writer k)))
end))

let deserialize_tycon = (fun reader -> (let _122_527 = (deserialize_lident reader)
in (let _122_526 = (deserialize_binders reader)
in (let _122_525 = (deserialize_knd reader)
in (_122_527, _122_526, _122_525)))))

let serialize_monad_abbrev = (fun writer ast -> (let _31_744 = (serialize_lident writer ast.FStar_Absyn_Syntax.mabbrev)
in (let _31_746 = (serialize_binders writer ast.FStar_Absyn_Syntax.parms)
in (serialize_typ writer ast.FStar_Absyn_Syntax.def))))

let deserialize_monad_abbrev = (fun reader -> (let _122_536 = (deserialize_lident reader)
in (let _122_535 = (deserialize_binders reader)
in (let _122_534 = (deserialize_typ reader)
in {FStar_Absyn_Syntax.mabbrev = _122_536; FStar_Absyn_Syntax.parms = _122_535; FStar_Absyn_Syntax.def = _122_534}))))

let serialize_sub_effect = (fun writer ast -> (let _31_751 = (serialize_lident writer ast.FStar_Absyn_Syntax.source)
in (let _31_753 = (serialize_lident writer ast.FStar_Absyn_Syntax.target)
in (serialize_typ writer ast.FStar_Absyn_Syntax.lift))))

let deserialize_sub_effect = (fun reader -> (let _122_545 = (deserialize_lident reader)
in (let _122_544 = (deserialize_lident reader)
in (let _122_543 = (deserialize_typ reader)
in {FStar_Absyn_Syntax.source = _122_545; FStar_Absyn_Syntax.target = _122_544; FStar_Absyn_Syntax.lift = _122_543}))))

let rec serialize_new_effect = (fun writer ast -> (let _31_758 = (serialize_lident writer ast.FStar_Absyn_Syntax.mname)
in (let _31_760 = (serialize_list writer serialize_binder ast.FStar_Absyn_Syntax.binders)
in (let _31_762 = (serialize_list writer serialize_qualifier ast.FStar_Absyn_Syntax.qualifiers)
in (let _31_764 = (serialize_knd writer ast.FStar_Absyn_Syntax.signature)
in (let _31_766 = (serialize_typ writer ast.FStar_Absyn_Syntax.ret)
in (let _31_768 = (serialize_typ writer ast.FStar_Absyn_Syntax.bind_wp)
in (let _31_770 = (serialize_typ writer ast.FStar_Absyn_Syntax.bind_wlp)
in (let _31_772 = (serialize_typ writer ast.FStar_Absyn_Syntax.if_then_else)
in (let _31_774 = (serialize_typ writer ast.FStar_Absyn_Syntax.ite_wp)
in (let _31_776 = (serialize_typ writer ast.FStar_Absyn_Syntax.ite_wlp)
in (let _31_778 = (serialize_typ writer ast.FStar_Absyn_Syntax.wp_binop)
in (let _31_780 = (serialize_typ writer ast.FStar_Absyn_Syntax.wp_as_type)
in (let _31_782 = (serialize_typ writer ast.FStar_Absyn_Syntax.close_wp)
in (let _31_784 = (serialize_typ writer ast.FStar_Absyn_Syntax.close_wp_t)
in (let _31_786 = (serialize_typ writer ast.FStar_Absyn_Syntax.assert_p)
in (let _31_788 = (serialize_typ writer ast.FStar_Absyn_Syntax.assume_p)
in (let _31_790 = (serialize_typ writer ast.FStar_Absyn_Syntax.null_wp)
in (serialize_typ writer ast.FStar_Absyn_Syntax.trivial)))))))))))))))))))
and serialize_sigelt = (fun writer ast -> (match (ast) with
| FStar_Absyn_Syntax.Sig_pragma (_31_795) -> begin
(FStar_All.failwith "NYI")
end
| FStar_Absyn_Syntax.Sig_tycon (lid, bs, k, l1, l2, qs, _31_804) -> begin
(let _31_807 = (writer.FStar_Util.write_char 'a')
in (let _31_809 = (serialize_lident writer lid)
in (let _31_811 = (serialize_binders writer bs)
in (let _31_813 = (serialize_knd writer k)
in (let _31_815 = (serialize_list writer serialize_lident l1)
in (let _31_817 = (serialize_list writer serialize_lident l2)
in (serialize_list writer serialize_qualifier qs)))))))
end
| FStar_Absyn_Syntax.Sig_typ_abbrev (lid, bs, k, t, qs, _31_825) -> begin
(let _31_828 = (writer.FStar_Util.write_char 'b')
in (let _31_830 = (serialize_lident writer lid)
in (let _31_832 = (serialize_binders writer bs)
in (let _31_834 = (serialize_knd writer k)
in (let _31_836 = (serialize_typ writer t)
in (serialize_list writer serialize_qualifier qs))))))
end
| FStar_Absyn_Syntax.Sig_datacon (lid1, t, tyc, qs, mutuals, _31_844) -> begin
(let t' = (match ((FStar_Absyn_Util.function_formals t)) with
| Some (f, c) -> begin
(let _122_555 = (let _122_554 = (FStar_Absyn_Syntax.mk_Total (FStar_Absyn_Util.comp_result c))
in (f, _122_554))
in (FStar_Absyn_Syntax.mk_Typ_fun _122_555 None FStar_Absyn_Syntax.dummyRange))
end
| None -> begin
t
end)
in (let _31_853 = (writer.FStar_Util.write_char 'c')
in (let _31_855 = (serialize_lident writer lid1)
in (let _31_857 = (serialize_typ writer t')
in (let _31_859 = (serialize_tycon writer tyc)
in (let _31_861 = (serialize_list writer serialize_qualifier qs)
in (serialize_list writer serialize_lident mutuals)))))))
end
| FStar_Absyn_Syntax.Sig_val_decl (lid, t, qs, _31_867) -> begin
(let _31_870 = (writer.FStar_Util.write_char 'd')
in (let _31_872 = (serialize_lident writer lid)
in (let _31_874 = (serialize_typ writer t)
in (serialize_list writer serialize_qualifier qs))))
end
| FStar_Absyn_Syntax.Sig_assume (lid, fml, qs, _31_880) -> begin
(let _31_883 = (writer.FStar_Util.write_char 'e')
in (let _31_885 = (serialize_lident writer lid)
in (let _31_887 = (serialize_formula writer fml)
in (serialize_list writer serialize_qualifier qs))))
end
| FStar_Absyn_Syntax.Sig_let (lbs, _31_891, l, quals) -> begin
(let _31_896 = (writer.FStar_Util.write_char 'f')
in (let _31_898 = (serialize_letbindings writer lbs)
in (let _31_900 = (serialize_list writer serialize_lident l)
in (let _122_557 = (FStar_All.pipe_right quals (FStar_Util.for_some (fun _31_1 -> (match (_31_1) with
| FStar_Absyn_Syntax.HasMaskedEffect -> begin
true
end
| _31_905 -> begin
false
end))))
in (writer.FStar_Util.write_bool _122_557)))))
end
| FStar_Absyn_Syntax.Sig_main (e, _31_908) -> begin
(let _31_911 = (writer.FStar_Util.write_char 'g')
in (serialize_exp writer e))
end
| FStar_Absyn_Syntax.Sig_bundle (l, qs, lids, _31_917) -> begin
(let _31_920 = (writer.FStar_Util.write_char 'h')
in (let _31_922 = (serialize_list writer serialize_sigelt l)
in (let _31_924 = (serialize_list writer serialize_qualifier qs)
in (serialize_list writer serialize_lident lids))))
end
| FStar_Absyn_Syntax.Sig_new_effect (n, _31_928) -> begin
(let _31_931 = (writer.FStar_Util.write_char 'i')
in (serialize_new_effect writer n))
end
| FStar_Absyn_Syntax.Sig_effect_abbrev (lid, bs, c, qs, _31_938) -> begin
(let _31_941 = (writer.FStar_Util.write_char 'j')
in (let _31_943 = (serialize_lident writer lid)
in (let _31_945 = (serialize_binders writer bs)
in (let _31_947 = (serialize_comp writer c)
in (serialize_list writer serialize_qualifier qs)))))
end
| FStar_Absyn_Syntax.Sig_sub_effect (se, r) -> begin
(let _31_953 = (writer.FStar_Util.write_char 'k')
in (serialize_sub_effect writer se))
end
| FStar_Absyn_Syntax.Sig_kind_abbrev (l, binders, k, _31_959) -> begin
(let _31_962 = (writer.FStar_Util.write_char 'l')
in (let _31_964 = (serialize_lident writer l)
in (let _31_966 = (serialize_list writer serialize_binder binders)
in (serialize_knd writer k))))
end))

let rec deserialize_new_effect = (fun reader -> (let _122_578 = (deserialize_lident reader)
in (let _122_577 = (deserialize_list reader deserialize_binder)
in (let _122_576 = (deserialize_list reader deserialize_qualifier)
in (let _122_575 = (deserialize_knd reader)
in (let _122_574 = (deserialize_typ reader)
in (let _122_573 = (deserialize_typ reader)
in (let _122_572 = (deserialize_typ reader)
in (let _122_571 = (deserialize_typ reader)
in (let _122_570 = (deserialize_typ reader)
in (let _122_569 = (deserialize_typ reader)
in (let _122_568 = (deserialize_typ reader)
in (let _122_567 = (deserialize_typ reader)
in (let _122_566 = (deserialize_typ reader)
in (let _122_565 = (deserialize_typ reader)
in (let _122_564 = (deserialize_typ reader)
in (let _122_563 = (deserialize_typ reader)
in (let _122_562 = (deserialize_typ reader)
in (let _122_561 = (deserialize_typ reader)
in {FStar_Absyn_Syntax.mname = _122_578; FStar_Absyn_Syntax.binders = _122_577; FStar_Absyn_Syntax.qualifiers = _122_576; FStar_Absyn_Syntax.signature = _122_575; FStar_Absyn_Syntax.ret = _122_574; FStar_Absyn_Syntax.bind_wp = _122_573; FStar_Absyn_Syntax.bind_wlp = _122_572; FStar_Absyn_Syntax.if_then_else = _122_571; FStar_Absyn_Syntax.ite_wp = _122_570; FStar_Absyn_Syntax.ite_wlp = _122_569; FStar_Absyn_Syntax.wp_binop = _122_568; FStar_Absyn_Syntax.wp_as_type = _122_567; FStar_Absyn_Syntax.close_wp = _122_566; FStar_Absyn_Syntax.close_wp_t = _122_565; FStar_Absyn_Syntax.assert_p = _122_564; FStar_Absyn_Syntax.assume_p = _122_563; FStar_Absyn_Syntax.null_wp = _122_562; FStar_Absyn_Syntax.trivial = _122_561})))))))))))))))))))
and deserialize_sigelt = (fun reader -> (match ((reader.FStar_Util.read_char ())) with
| 'a' -> begin
(let _122_586 = (let _122_585 = (deserialize_lident reader)
in (let _122_584 = (deserialize_binders reader)
in (let _122_583 = (deserialize_knd reader)
in (let _122_582 = (deserialize_list reader deserialize_lident)
in (let _122_581 = (deserialize_list reader deserialize_lident)
in (let _122_580 = (deserialize_list reader deserialize_qualifier)
in (_122_585, _122_584, _122_583, _122_582, _122_581, _122_580, FStar_Absyn_Syntax.dummyRange)))))))
in FStar_Absyn_Syntax.Sig_tycon (_122_586))
end
| 'b' -> begin
(let _122_592 = (let _122_591 = (deserialize_lident reader)
in (let _122_590 = (deserialize_binders reader)
in (let _122_589 = (deserialize_knd reader)
in (let _122_588 = (deserialize_typ reader)
in (let _122_587 = (deserialize_list reader deserialize_qualifier)
in (_122_591, _122_590, _122_589, _122_588, _122_587, FStar_Absyn_Syntax.dummyRange))))))
in FStar_Absyn_Syntax.Sig_typ_abbrev (_122_592))
end
| 'c' -> begin
(let _122_598 = (let _122_597 = (deserialize_lident reader)
in (let _122_596 = (deserialize_typ reader)
in (let _122_595 = (deserialize_tycon reader)
in (let _122_594 = (deserialize_list reader deserialize_qualifier)
in (let _122_593 = (deserialize_list reader deserialize_lident)
in (_122_597, _122_596, _122_595, _122_594, _122_593, FStar_Absyn_Syntax.dummyRange))))))
in FStar_Absyn_Syntax.Sig_datacon (_122_598))
end
| 'd' -> begin
(let _122_602 = (let _122_601 = (deserialize_lident reader)
in (let _122_600 = (deserialize_typ reader)
in (let _122_599 = (deserialize_list reader deserialize_qualifier)
in (_122_601, _122_600, _122_599, FStar_Absyn_Syntax.dummyRange))))
in FStar_Absyn_Syntax.Sig_val_decl (_122_602))
end
| 'e' -> begin
(let _122_606 = (let _122_605 = (deserialize_lident reader)
in (let _122_604 = (deserialize_formula reader)
in (let _122_603 = (deserialize_list reader deserialize_qualifier)
in (_122_605, _122_604, _122_603, FStar_Absyn_Syntax.dummyRange))))
in FStar_Absyn_Syntax.Sig_assume (_122_606))
end
| 'f' -> begin
(let _122_610 = (let _122_609 = (deserialize_letbindings reader)
in (let _122_608 = (deserialize_list reader deserialize_lident)
in (let _122_607 = if (reader.FStar_Util.read_bool ()) then begin
(FStar_Absyn_Syntax.HasMaskedEffect)::[]
end else begin
[]
end
in (_122_609, FStar_Absyn_Syntax.dummyRange, _122_608, _122_607))))
in FStar_Absyn_Syntax.Sig_let (_122_610))
end
| 'g' -> begin
(let _122_612 = (let _122_611 = (deserialize_exp reader)
in (_122_611, FStar_Absyn_Syntax.dummyRange))
in FStar_Absyn_Syntax.Sig_main (_122_612))
end
| 'h' -> begin
(let _122_616 = (let _122_615 = (deserialize_list reader deserialize_sigelt)
in (let _122_614 = (deserialize_list reader deserialize_qualifier)
in (let _122_613 = (deserialize_list reader deserialize_lident)
in (_122_615, _122_614, _122_613, FStar_Absyn_Syntax.dummyRange))))
in FStar_Absyn_Syntax.Sig_bundle (_122_616))
end
| 'i' -> begin
(let _122_618 = (let _122_617 = (deserialize_new_effect reader)
in (_122_617, FStar_Absyn_Syntax.dummyRange))
in FStar_Absyn_Syntax.Sig_new_effect (_122_618))
end
| ('j') | ('k') | ('l') -> begin
(FStar_All.failwith "TODO")
end
| _31_983 -> begin
(parse_error ())
end))

let serialize_sigelts = (fun writer ast -> (serialize_list writer serialize_sigelt ast))

let deserialize_sigelts = (fun reader -> (deserialize_list reader deserialize_sigelt))

let serialize_modul = (fun writer ast -> (let _31_989 = (serialize_lident writer ast.FStar_Absyn_Syntax.name)
in (let _31_991 = (serialize_sigelts writer [])
in (let _31_993 = (serialize_sigelts writer ast.FStar_Absyn_Syntax.exports)
in (writer.FStar_Util.write_bool ast.FStar_Absyn_Syntax.is_interface)))))

let deserialize_modul = (fun reader -> (let m = (let _122_634 = (deserialize_lident reader)
in (let _122_633 = (deserialize_sigelts reader)
in (let _122_632 = (deserialize_sigelts reader)
in (let _122_631 = (reader.FStar_Util.read_bool ())
in {FStar_Absyn_Syntax.name = _122_634; FStar_Absyn_Syntax.declarations = _122_633; FStar_Absyn_Syntax.exports = _122_632; FStar_Absyn_Syntax.is_interface = _122_631; FStar_Absyn_Syntax.is_deserialized = true}))))
in (let _31_997 = m
in {FStar_Absyn_Syntax.name = _31_997.FStar_Absyn_Syntax.name; FStar_Absyn_Syntax.declarations = m.FStar_Absyn_Syntax.exports; FStar_Absyn_Syntax.exports = _31_997.FStar_Absyn_Syntax.exports; FStar_Absyn_Syntax.is_interface = _31_997.FStar_Absyn_Syntax.is_interface; FStar_Absyn_Syntax.is_deserialized = _31_997.FStar_Absyn_Syntax.is_deserialized})))




