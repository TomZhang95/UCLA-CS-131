(* Helper function *)
let rec contain element list = match list with
	| [] -> false
	| head::tail -> if element = head then true
		else (contain element tail);;

(* 1. *)
let rec subset a b = match a with
	| [] -> true
	| head::tail -> if (contain head b) 
		then (subset tail b)
		else false;;

(* 2. *)
let rec equal_sets a b = (subset a b) && (subset b a);;

(* 3. *)
let rec set_union a b = match a with
	| [] -> b
	| head::tail -> if (contain head b) 
		then (set_union tail b)
		else head::(set_union tail b);;

(* 4. *)
let rec set_intersection a b = match a with
	| [] -> []
	| head::tail -> if (contain head b) 
		then head::(set_intersection tail b)
		else (set_intersection tail b);;

(* 5. *)
let rec set_diff a b = match a with
	| [] -> []
	| head::tail -> if (contain head b)
		then (set_diff tail b)
		else head::(set_diff tail b);;

(* 6. *)
let rec computed_fixed_point eq f x = 
	if (eq (f x) x) then x
	else (computed_fixed_point eq f (f x));;

(* 7. *)
let rec p_times f p x = 
	if p = 1 then (f x)
	else (p_times f (p-1) (f x));;

let rec computed_periodic_point eq f p x = 
	if p = 0 then x
	else if (eq (p_times f p x) x) then x
else (computed_periodic_point eq f p (f x));;

(* 8. *)
let rec while_away s p x =
	if (p x) then x::(while_away s p (s x))
else [];;

(* 9. *)
let rec repeat (num, word) = match num with
	| 0 -> []
	| _ -> word::(repeat (num - 1, word));;

let rec rle_decode lp = match lp with
	| [] -> []
	| head::tail -> 
		(set_union (repeat head) (rle_decode tail));;

(* 10. *)
type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal

let is_terminal_symbol symbol safe_list = match symbol with
	| T _ -> true
	| N element -> (contain element safe_list)

let rec contain_terminal_symbol lst safe_list = match lst with
	| [] -> true
	| head::tail -> if (is_terminal_symbol head safe_list)
	then (contain_terminal_symbol tail safe_list)
else false

let rec create_safe_list safe_list original_rules = 
	match original_rules with
	| [] -> safe_list
	| (symbol, rhs)::tail -> 
	if (contain_terminal_symbol rhs safe_list)
	&& not (contain symbol safe_list) then
	(create_safe_list (symbol::safe_list) tail)
else (create_safe_list safe_list tail)

let rec adjust_order_and_filter safe_list original_rules =
	match original_rules with
	| [] -> []
	| head::tail -> 
	if (contain_terminal_symbol (snd head) safe_list) then
	(head::(adjust_order_and_filter safe_list tail))
else (adjust_order_and_filter safe_list tail)

let create_safe_list_wrapper (safe_list, original_rules) = 
	((create_safe_list safe_list original_rules),
original_rules)

let rec eq (x1, y1) (x2, y2) = equal_sets x1 x2

let filter_blind_alleys g = 
	let original_rules = (snd g) in
	(fst g), (adjust_order_and_filter (fst (computed_fixed_point 
		eq create_safe_list_wrapper ([], original_rules))) original_rules)
