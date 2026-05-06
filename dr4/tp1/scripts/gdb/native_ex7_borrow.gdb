set pagination off
set confirm off
set args borrow
set logging file evidence/raspberry/ex04/gdb_mp_sub_128_borrow.txt
set logging overwrite on
set logging on

break mp_sub_128
run

printf "=== Break em mp_sub_128 ===\n"
x/i $pc
info registers x0 x1 x2

stepi 5
printf "\n=== Apos a subtracao da low word ===\n"
x/i $pc
info registers x3 x4 x5 x6 x7 cpsr

stepi 1
printf "\n=== Apos a subtracao da high word ===\n"
x/i $pc
info registers x4 x6 x7 x8 cpsr

continue
quit
