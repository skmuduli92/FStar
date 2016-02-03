
open Prims
let oktype = Some (FStar_Absyn_Syntax.ktype)

let t_unit = (FStar_All.pipe_left (FStar_Absyn_Syntax.syn FStar_Absyn_Syntax.dummyRange oktype) (FStar_Absyn_Syntax.mk_Typ_const (FStar_Absyn_Util.withsort FStar_Absyn_Const.unit_lid FStar_Absyn_Syntax.ktype)))

let t_bool = (FStar_All.pipe_left (FStar_Absyn_Syntax.syn FStar_Absyn_Syntax.dummyRange oktype) (FStar_Absyn_Syntax.mk_Typ_const (FStar_Absyn_Util.withsort FStar_Absyn_Const.bool_lid FStar_Absyn_Syntax.ktype)))

let t_uint8 = (FStar_All.pipe_left (FStar_Absyn_Syntax.syn FStar_Absyn_Syntax.dummyRange oktype) (FStar_Absyn_Syntax.mk_Typ_const (FStar_Absyn_Util.withsort FStar_Absyn_Const.uint8_lid FStar_Absyn_Syntax.ktype)))

let t_int = (FStar_All.pipe_left (FStar_Absyn_Syntax.syn FStar_Absyn_Syntax.dummyRange oktype) (FStar_Absyn_Syntax.mk_Typ_const (FStar_Absyn_Util.withsort FStar_Absyn_Const.int_lid FStar_Absyn_Syntax.ktype)))

let t_int32 = (FStar_All.pipe_left (FStar_Absyn_Syntax.syn FStar_Absyn_Syntax.dummyRange oktype) (FStar_Absyn_Syntax.mk_Typ_const (FStar_Absyn_Util.withsort FStar_Absyn_Const.int32_lid FStar_Absyn_Syntax.ktype)))

let t_int64 = (FStar_All.pipe_left (FStar_Absyn_Syntax.syn FStar_Absyn_Syntax.dummyRange oktype) (FStar_Absyn_Syntax.mk_Typ_const (FStar_Absyn_Util.withsort FStar_Absyn_Const.int64_lid FStar_Absyn_Syntax.ktype)))

let t_string = (FStar_All.pipe_left (FStar_Absyn_Syntax.syn FStar_Absyn_Syntax.dummyRange oktype) (FStar_Absyn_Syntax.mk_Typ_const (FStar_Absyn_Util.withsort FStar_Absyn_Const.string_lid FStar_Absyn_Syntax.ktype)))

let t_float = (FStar_All.pipe_left (FStar_Absyn_Syntax.syn FStar_Absyn_Syntax.dummyRange oktype) (FStar_Absyn_Syntax.mk_Typ_const (FStar_Absyn_Util.withsort FStar_Absyn_Const.float_lid FStar_Absyn_Syntax.ktype)))

let t_char = (FStar_All.pipe_left (FStar_Absyn_Syntax.syn FStar_Absyn_Syntax.dummyRange oktype) (FStar_Absyn_Syntax.mk_Typ_const (FStar_Absyn_Util.withsort FStar_Absyn_Const.char_lid FStar_Absyn_Syntax.ktype)))

let typing_const = (fun r s -> (match (s) with
| FStar_Const.Const_unit -> begin
t_unit
end
| FStar_Const.Const_bool (_46_5) -> begin
t_bool
end
| FStar_Const.Const_int (_46_8) -> begin
t_int
end
| FStar_Const.Const_int32 (_46_11) -> begin
t_int32
end
| FStar_Const.Const_int64 (_46_14) -> begin
t_int64
end
| FStar_Const.Const_string (_46_17) -> begin
t_string
end
| FStar_Const.Const_float (_46_20) -> begin
t_float
end
| FStar_Const.Const_char (_46_23) -> begin
t_char
end
| FStar_Const.Const_uint8 (_46_26) -> begin
t_uint8
end
| _46_29 -> begin
(Prims.raise (FStar_Absyn_Syntax.Error (("Unsupported constant", r))))
end))

let rec recompute_kind = (fun t -> (let recompute = (fun t -> (match (t.FStar_Absyn_Syntax.n) with
| FStar_Absyn_Syntax.Typ_delayed (_46_34) -> begin
(let _137_30 = (FStar_Absyn_Util.compress_typ t)
in (recompute_kind _137_30))
end
| FStar_Absyn_Syntax.Typ_btvar (a) -> begin
a.FStar_Absyn_Syntax.sort
end
| FStar_Absyn_Syntax.Typ_const (tc) -> begin
(match (tc.FStar_Absyn_Syntax.sort.FStar_Absyn_Syntax.n) with
| FStar_Absyn_Syntax.Kind_unknown -> begin
(let _137_32 = (let _137_31 = (FStar_Absyn_Print.typ_to_string t)
in (FStar_Util.format1 "UNKNOWN KIND FOR %s" _137_31))
in (FStar_All.failwith _137_32))
end
| _46_42 -> begin
tc.FStar_Absyn_Syntax.sort
end)
end
| (FStar_Absyn_Syntax.Typ_fun (_)) | (FStar_Absyn_Syntax.Typ_refine (_)) -> begin
FStar_Absyn_Syntax.ktype
end
| (FStar_Absyn_Syntax.Typ_ascribed (_, k)) | (FStar_Absyn_Syntax.Typ_uvar (_, k)) -> begin
k
end
| (FStar_Absyn_Syntax.Typ_meta (FStar_Absyn_Syntax.Meta_labeled (_))) | (FStar_Absyn_Syntax.Typ_meta (FStar_Absyn_Syntax.Meta_slack_formula (_))) | (FStar_Absyn_Syntax.Typ_meta (FStar_Absyn_Syntax.Meta_pattern (_))) -> begin
FStar_Absyn_Syntax.ktype
end
| FStar_Absyn_Syntax.Typ_meta (FStar_Absyn_Syntax.Meta_named (t, _46_72)) -> begin
(recompute_kind t)
end
| FStar_Absyn_Syntax.Typ_meta (FStar_Absyn_Syntax.Meta_refresh_label (t, _46_78, _46_80)) -> begin
(recompute_kind t)
end
| FStar_Absyn_Syntax.Typ_lam (binders, body) -> begin
(let _137_34 = (let _137_33 = (recompute_kind body)
in (binders, _137_33))
in (FStar_Absyn_Syntax.mk_Kind_arrow _137_34 t.FStar_Absyn_Syntax.pos))
end
| FStar_Absyn_Syntax.Typ_app (t1, args) -> begin
(match (t1.FStar_Absyn_Syntax.n) with
| FStar_Absyn_Syntax.Typ_const (tc) when ((((FStar_Absyn_Syntax.lid_equals tc.FStar_Absyn_Syntax.v FStar_Absyn_Const.forall_lid) || (FStar_Absyn_Syntax.lid_equals tc.FStar_Absyn_Syntax.v FStar_Absyn_Const.exists_lid)) || (FStar_Absyn_Syntax.lid_equals tc.FStar_Absyn_Syntax.v FStar_Absyn_Const.allTyp_lid)) || (FStar_Absyn_Syntax.lid_equals tc.FStar_Absyn_Syntax.v FStar_Absyn_Const.exTyp_lid)) -> begin
FStar_Absyn_Syntax.ktype
end
| _46_95 -> begin
(let k1 = (recompute_kind t1)
in (let _46_99 = (FStar_Absyn_Util.kind_formals k1)
in (match (_46_99) with
| (bs, k) -> begin
(let rec aux = (fun subst bs args -> (match ((bs, args)) with
| ([], []) -> begin
(FStar_Absyn_Util.subst_kind subst k)
end
| (_46_108, []) -> begin
(let _137_41 = (FStar_Absyn_Syntax.mk_Kind_arrow (bs, k) t.FStar_Absyn_Syntax.pos)
in (FStar_All.pipe_right _137_41 (FStar_Absyn_Util.subst_kind subst)))
end
| (b::bs, a::args) -> begin
(let subst = (let _137_42 = (FStar_Absyn_Util.subst_formal b a)
in (_137_42)::subst)
in (aux subst bs args))
end
| _46_120 -> begin
(let _137_48 = (let _137_47 = (FStar_Range.string_of_range t.FStar_Absyn_Syntax.pos)
in (let _137_46 = (FStar_Absyn_Print.kind_to_string k1)
in (let _137_45 = (FStar_Absyn_Print.tag_of_typ t)
in (let _137_44 = (FStar_Absyn_Print.kind_to_string k)
in (let _137_43 = (FStar_All.pipe_right (FStar_List.length args) FStar_Util.string_of_int)
in (FStar_Util.format5 "(%s) HEAD KIND is %s\nToo many arguments in type %s; result kind is %s\nwith %s remaining args\n" _137_47 _137_46 _137_45 _137_44 _137_43))))))
in (FStar_All.failwith _137_48))
end))
in (aux [] bs args))
end)))
end)
end
| FStar_Absyn_Syntax.Typ_unknown -> begin
FStar_Absyn_Syntax.kun
end))
in (match ((FStar_ST.read t.FStar_Absyn_Syntax.tk)) with
| Some (k) -> begin
k
end
| None -> begin
(let k = (recompute t)
in (let _46_126 = (FStar_ST.op_Colon_Equals t.FStar_Absyn_Syntax.tk (Some (k)))
in k))
end)))

let rec recompute_typ = (fun e -> (let recompute = (fun e -> (match (e.FStar_Absyn_Syntax.n) with
| FStar_Absyn_Syntax.Exp_delayed (_46_132) -> begin
(let _137_53 = (FStar_Absyn_Util.compress_exp e)
in (recompute_typ _137_53))
end
| FStar_Absyn_Syntax.Exp_bvar (x) -> begin
x.FStar_Absyn_Syntax.sort
end
| FStar_Absyn_Syntax.Exp_fvar (f, _46_138) -> begin
f.FStar_Absyn_Syntax.sort
end
| FStar_Absyn_Syntax.Exp_constant (s) -> begin
(typing_const e.FStar_Absyn_Syntax.pos s)
end
| FStar_Absyn_Syntax.Exp_abs (bs, body) -> begin
(let _137_56 = (let _137_55 = (let _137_54 = (recompute_typ body)
in (FStar_Absyn_Syntax.mk_Total _137_54))
in (bs, _137_55))
in (FStar_Absyn_Syntax.mk_Typ_fun _137_56 None e.FStar_Absyn_Syntax.pos))
end
| FStar_Absyn_Syntax.Exp_app (head, args) -> begin
(let t1 = (recompute_typ head)
in (match ((FStar_Absyn_Util.function_formals t1)) with
| None -> begin
FStar_Absyn_Syntax.tun
end
| Some (bs, c) -> begin
(let rec aux = (fun subst bs args -> (match ((bs, args)) with
| ([], []) -> begin
(FStar_Absyn_Util.subst_typ subst (FStar_Absyn_Util.comp_result c))
end
| (_46_165, []) -> begin
(let _137_63 = (FStar_Absyn_Syntax.mk_Typ_fun (bs, c) None e.FStar_Absyn_Syntax.pos)
in (FStar_All.pipe_right _137_63 (FStar_Absyn_Util.subst_typ subst)))
end
| (b::bs, a::args) -> begin
(let subst = (let _137_64 = (FStar_Absyn_Util.subst_formal b a)
in (_137_64)::subst)
in (aux subst bs args))
end
| _46_177 -> begin
(FStar_All.failwith "Too many arguments")
end))
in (aux [] bs args))
end))
end
| FStar_Absyn_Syntax.Exp_match (_46_179) -> begin
(FStar_All.failwith "Expect match nodes to be annotated already")
end
| FStar_Absyn_Syntax.Exp_ascribed (_46_182, t, _46_185) -> begin
t
end
| FStar_Absyn_Syntax.Exp_let (_46_189, e) -> begin
(recompute_typ e)
end
| FStar_Absyn_Syntax.Exp_uvar (_46_194, t) -> begin
t
end
| FStar_Absyn_Syntax.Exp_meta (FStar_Absyn_Syntax.Meta_desugared (e, _46_200)) -> begin
(recompute_typ e)
end))
in (match ((FStar_ST.read e.FStar_Absyn_Syntax.tk)) with
| Some (t) -> begin
t
end
| None -> begin
(let t = (recompute e)
in (let _46_208 = (FStar_ST.op_Colon_Equals e.FStar_Absyn_Syntax.tk (Some (t)))
in t))
end)))




