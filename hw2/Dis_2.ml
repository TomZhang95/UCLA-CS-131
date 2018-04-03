(* dictionary, d is a func, so (d k) wiykd return either 
None or Some v *)
let get2 k d = 
	d k

let empty2 = 
function x -> None


let put2 k v d = 
	function k_in -> q
	if k_in = k 
	then Some v 
else (d k_in)

let d = empty2
let tmp_dict = put2 "123" "456" d
(* Then tmp_dict "123" would return Some 456 *)

(* matcher and acceptor *)
let rec matcher ... = 
	...

let rec parse_prefix grammer acceptor gragment = 
	match grammer with 
	| (start, rules) ->
	| matcher start rules ... acceptor ... fragment ...