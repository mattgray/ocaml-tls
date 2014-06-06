
type id = Cstruct.t

let is_tracing = ref false
let trace   () = is_tracing := true
and untrace () = is_tracing := false

let traces = Hashtbl.create 32

let create () =
  let id = Nocrypto.Rng.generate 32 in
  ( Hashtbl.replace traces id (ref []) ; id )

let item ~id x =
  match !is_tracing with
  | false -> ()
  | true  ->
      let v   = Lazy.force x
      and seq = Hashtbl.find traces id in
      seq := (v :: !seq)

let item_with ~id ~sexpf x = item ~id (lazy (sexpf x))

let cs ~id ~tag cs =
  let sexp = lazy Sexplib.Sexp.(List [
    Atom tag; (* sexp here *)
  ]) in
  item ~id sexp


let get_trace id =
  let seq = Hashtbl.find traces id in
  ( Hashtbl.remove traces id ; List.rev !seq )

