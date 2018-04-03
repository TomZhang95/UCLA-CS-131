type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal

 
let rec convert_one rules input = 
	match rules with
	| [] -> []
	| (expr, rule)::tail -> 
	if input = expr then rule::(convert_one tail input)
	else convert_one tail input

let convert_grammar gram1 = 
	match gram1 with
	| (expr, rules) -> (expr, convert_one rules)

let parse_prefix gram = 
	let rules_function = snd gram
	and starting_symbol = fst gram in

	let append_derivation new_dev derivation= 
	derivation @ new_dev in

	let rec find_matching_terminal rules_function = function
		(* If no matching symbol found, return whatever acceptor returns *)
		| [] -> ((fun acceptor derivation fragment -> 
		acceptor derivation fragment))

		(* Else we found a terminal symbol: *)
		| (T terminal_symbol)::tail -> (fun acceptor derivation -> function
			(* If nothing in suffix, but need a terminal symbol, return None *)
			| [] -> None

			(* Else, recursively matching the rest of suffix *)
			| suffix_head::suffix_tail ->
			if suffix_head = terminal_symbol then
			(find_matching_terminal rules_function tail) acceptor derivation suffix_tail
			else None)
		| (N nonterminal_symbol)::tail -> (fun acceptor derivation fragment ->
			let matcher_prefix = 
			find_matching_nonterminal rules_function nonterminal_symbol (rules_function nonterminal_symbol)
			and tmp_acceptor = 
			find_matching_terminal rules_function tail acceptor in
			matcher_prefix tmp_acceptor derivation fragment)

	and find_matching_nonterminal rules_function input = function
	(* If no matching found, return None *)
	| [] -> (fun acceptor derivation fragment -> None)

	(* Eles, call the acceptor with derivation, suffix *)
	| head::tail -> (fun acceptor derivation fragment ->
		let matcher_symbol = find_matching_terminal rules_function head
		and matcher_prefix = find_matching_nonterminal rules_function input tail in

		let matcher = matcher_symbol acceptor 
		(append_derivation [(input, head)] derivation) fragment in
		match matcher with
		
		(* If we cannot find a match for first element, then keep matching
		in the rest of the list *)
		| None -> matcher_prefix acceptor derivation fragment
		
		(* If we found a match, return whatever acceptor returns *)
		| _ -> matcher
	)
	in
	fun acceptor fragment ->
	find_matching_nonterminal rules_function starting_symbol (rules_function starting_symbol) acceptor [] fragment
