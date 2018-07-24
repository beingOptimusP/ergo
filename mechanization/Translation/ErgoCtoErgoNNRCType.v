(*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *)

(* Support for ErgoType models *)

Require Import String.
Require Import List.

Require Import ErgoSpec.Common.Utils.ENames.
Require Import ErgoSpec.Common.Utils.EResult.
Require Import ErgoSpec.Common.Utils.EAstUtil.
Require Import ErgoSpec.Common.Types.ErgoType.
Require Import ErgoSpec.ErgoC.Lang.ErgoC.
Require Import ErgoSpec.ErgoNNRC.Lang.ErgoNNRC.
Require Import ErgoSpec.Backend.ErgoBackend.

Section ErgoCtoErgoNNRCType.

  (** A semantics for ErgoType is obtained through translation
      into branded types. *)
  Program Fixpoint ergoc_type_to_nnrc_type {m:brand_relation} (t:ergoc_type) : ErgoNNRCType.ectype :=
    match t with
    | ErgoTypeAny _ => ErgoNNRCType.Top
    | ErgoTypeNone _ => ErgoNNRCType.Unit
    | ErgoTypeBoolean _ => ErgoNNRCType.Bool
    | ErgoTypeString _ => ErgoNNRCType.String
    | ErgoTypeDouble _ => ErgoNNRCType.Float
    | ErgoTypeLong _ => ErgoNNRCType.Integer (* XXX To be decided *)
    | ErgoTypeInteger _ => ErgoNNRCType.Integer
    | ErgoTypeDateTime _ => ErgoNNRCType.Unit (* XXX TBD *)
    | ErgoTypeClassRef _ cr => ErgoNNRCType.Brand (cr::nil)
    | ErgoTypeOption _ t => ErgoNNRCType.Option (ergoc_type_to_nnrc_type t)
    | ErgoTypeRecord _ rtl =>
      ErgoNNRCType.Rec
        ErgoNNRCType.open_kind
        (rec_sort (List.map (fun xy => (fst xy, ergoc_type_to_nnrc_type (snd xy))) rtl))
        (rec_sort_sorted
           (List.map (fun xy => (fst xy, ergoc_type_to_nnrc_type (snd xy))) rtl)
           (rec_sort (List.map (fun xy => (fst xy, ergoc_type_to_nnrc_type (snd xy))) rtl))
           eq_refl)
    | ErgoTypeArray _ t => ErgoNNRCType.Coll (ergoc_type_to_nnrc_type t)
    | ErgoTypeSum _ t1 t2 => ErgoNNRCType.Either (ergoc_type_to_nnrc_type t1) (ergoc_type_to_nnrc_type t2)
    end.

End ErgoCtoErgoNNRCType.
