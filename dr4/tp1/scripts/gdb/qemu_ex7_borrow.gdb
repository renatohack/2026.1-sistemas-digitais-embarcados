set pagination off
set confirm off
set logging file evidence/qemu/ex04/gdb_mp_sub_128_borrow.txt
set logging overwrite on
set logging on

target remote :1234
break mp_sub_128
continue

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
