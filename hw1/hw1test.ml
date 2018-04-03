let my_subset_test0 = not (subset [2;3] [1])

let my_subset_test1 = subset ['e';'g';'w'] ['e';'g';'w';'k']

let my_equal_sets_test0 = not (equal_sets [2;3;4] [4;5;6])

let my_set_union_test0 = equal_sets (set_union [1;2] [3;4]) [1;2;3;4]

let my_set_intersection_test0 = equal_sets (set_intersection [5;6;7] [3;4;5]) [5]

let my_set_diff_test0 = equal_sets (set_diff [1;2;3;4] [3;4]) [1;2]

let my_func1 x = x / 3

let my_computed_fixed_point_test0 = (computed_fixed_point (=) my_func1 500) = 0

let my_func2 x = x * 2 - 2

let my_computed_periodic_point_test0 = (computed_periodic_point (=) my_func2 2 (-5)) = 2

let my_while_away_test0 = equal_sets (while_away (( * ) 2) ((>) 10) 1) [1;2;4;8]

let my_rle_decode_test0 = rle_decode [3,'s'; 2,'a'; 1, 'q'] = ['s';'s';'s';'a';'a';'q']

type my_nonterminals = 
| Apple | Samsung | Microsoft |Mi | Phone | IPhone

let my_rules = 
[Apple, [N Phone];
Apple, [T "expensive"];
Apple, [N IPhone];
Apple, [T "laptop"];
Samsung, [N Phone];
Samsung, [T "explode"];
Microsoft, [T "OS"];
Mi, [N Phone];
Mi, [T "cheap"];
IPhone, [T "8"]
]

let my_filter_blind_alley_test0 = 
(filter_blind_alleys (Apple, my_rules) = 
(Apple,
[Apple, [T "expensive"];
Apple, [N IPhone];
Apple, [T "laptop"];
Samsung, [T "explode"];
Microsoft, [T "OS"];
Mi, [T "cheap"];
IPhone, [T "8"]
])
)