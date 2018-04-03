let accept_all derivation string = Some (derivation, string)
let accept_new = fun d -> function 
  | "I love you!"::tail -> Some (d,"I love you!"::tail) 
  | _ -> None

type test_1_nonterminals =
  | Conversation | Phrase | Name | Sentence | Greet | Agree

let test_1_grammar =
  (Conversation,
  [Conversation, [N Phrase; N Conversation];
   Conversation, [N Sentence];
   Conversation, [N Phrase];
   Phrase, [N Sentence];
   Phrase, [N Greet];
   Phrase, [N Agree];
   Phrase, [N Name];
   Sentence, [T "I love you!"];
   Greet, [T "Hi!"];
   Agree, [T "Me too!"];
   Name, [T "Tom:"];
   Name, [T "Fiona:"]])

let new_test_1_grammar = convert_grammar test_1_grammar

let test_1 =
  (parse_prefix new_test_1_grammar accept_all 
    ["Tom:";"Hi!";"I love you!";"Fiona:";"Me too!"])
    = Some
  ([(Conversation, [N Phrase; N Conversation]); (Phrase, [N Name]);
     (Name, [T "Tom:"]); (Conversation, [N Phrase; N Conversation]);
     (Phrase, [N Greet]); (Greet, [T "Hi!"]);
     (Conversation, [N Phrase; N Conversation]); (Phrase, [N Sentence]);
     (Sentence, [T "I love you!"]);
     (Conversation, [N Phrase; N Conversation]); (Phrase, [N Name]);
     (Name, [T "Fiona:"]); (Conversation, [N Phrase]); (Phrase, [N Agree]);
     (Agree, [T "Me too!"])],
    [])

let test_2 =
  (parse_prefix new_test_1_grammar accept_new 
    ["Tom:";"Hi!";"I love you!";"Fiona:";"Me too!"]) = Some
  ([(Conversation, [N Phrase; N Conversation]); (Phrase, [N Name]);
     (Name, [T "Tom:"]); (Conversation, [N Phrase]); (Phrase, [N Greet]);
     (Greet, [T "Hi!"])],
    ["I love you!"; "Fiona:"; "Me too!"])


