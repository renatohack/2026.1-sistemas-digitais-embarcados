    .include "macros.inc"

    .text
    .global _start
    .type _start, %function
_start:
    bl process_metrics
    bl convert_valid_values_lut
    bl sum_first_four_neon
    bl normalize_lut_f32_neon

    LOAD_ADDR x0, expected_sum_ascii
    mov x1, #1000
    bl parse_u64_checked
    cbz x0, 1f
    LOAD_ADDR x2, valid_sum_result
    ldr x2, [x2]
    cmp x1, x2
    cset x19, eq
    b 2f
1:
    mov x19, #0
2:

    WRITE_STDOUT msg_header, msg_header_len
    WRITE_STDOUT msg_values, msg_values_len
    WRITE_STDOUT msg_status, msg_status_len

    WRITE_STDOUT msg_valid_count, msg_valid_count_len
    LOAD_ADDR x0, valid_count_result
    ldr x0, [x0]
    bl print_u64
    WRITE_STDOUT msg_newline, msg_newline_len

    WRITE_STDOUT msg_valid_sum, msg_valid_sum_len
    LOAD_ADDR x0, valid_sum_result
    ldr x0, [x0]
    bl print_u64
    WRITE_STDOUT msg_newline, msg_newline_len

    WRITE_STDOUT msg_valid_avg, msg_valid_avg_len
    LOAD_ADDR x0, valid_avg_result
    ldr x0, [x0]
    bl print_u64
    WRITE_STDOUT msg_newline, msg_newline_len

    WRITE_STDOUT msg_alarm_count, msg_alarm_count_len
    LOAD_ADDR x0, alarm_count_result
    ldr x0, [x0]
    bl print_u64
    WRITE_STDOUT msg_newline, msg_newline_len

    WRITE_STDOUT msg_battery_count, msg_battery_count_len
    LOAD_ADDR x0, battery_count_result
    ldr x0, [x0]
    bl print_u64
    WRITE_STDOUT msg_newline, msg_newline_len

    WRITE_STDOUT msg_status_word, msg_status_word_len
    LOAD_ADDR x0, status_word_result
    ldr x0, [x0]
    bl print_hex16
    WRITE_STDOUT msg_newline, msg_newline_len

    WRITE_STDOUT msg_status_rotl, msg_status_rotl_len
    LOAD_ADDR x0, status_rotl_result
    ldr x0, [x0]
    bl print_hex16
    WRITE_STDOUT msg_newline, msg_newline_len

    WRITE_STDOUT msg_status_signature, msg_status_signature_len
    LOAD_ADDR x0, status_signature_result
    ldr x0, [x0]
    bl print_hex16
    WRITE_STDOUT msg_newline, msg_newline_len

    WRITE_STDOUT msg_lut_values, msg_lut_values_len
    LOAD_ADDR x20, lut_output_values
    LOAD_ADDR x21, lut_count_result
    ldr x21, [x21]
    mov x22, #0
3:
    cmp x22, x21
    b.hs 4f
    cbz x22, 5f
    WRITE_STDOUT msg_space, msg_space_len
5:
    ldr w0, [x20, x22, lsl #2]
    bl print_u64
    add x22, x22, #1
    b 3b
4:
    WRITE_STDOUT msg_newline, msg_newline_len

    WRITE_STDOUT msg_lut_sum, msg_lut_sum_len
    LOAD_ADDR x0, lut_sum_result
    ldr x0, [x0]
    bl print_u64
    WRITE_STDOUT msg_newline, msg_newline_len

    WRITE_STDOUT msg_neon_sum, msg_neon_sum_len
    LOAD_ADDR x0, neon_sum4_result
    ldr x0, [x0]
    bl print_u64
    WRITE_STDOUT msg_newline, msg_newline_len

    WRITE_STDOUT msg_norm, msg_norm_len

    WRITE_STDOUT msg_numeric_validation, msg_numeric_validation_len
    cbz x19, 6f
    WRITE_STDOUT msg_ok, msg_ok_len
    b 7f
6:
    WRITE_STDOUT msg_fail, msg_fail_len
7:
    WRITE_STDOUT msg_newline, msg_newline_len

    EXIT_PROGRAM 0
    .size _start, .-_start

    .global print_u64
    .type print_u64, %function
print_u64:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    LOAD_ADDR x1, num_buffer
    mov x2, #32
    bl u64_to_ascii
    mov x2, x0
    LOAD_ADDR x1, num_buffer
    mov x0, #1
    mov x8, #64
    svc #0
    ldp x29, x30, [sp], #16
    ret
    .size print_u64, .-print_u64

    .global print_hex16
    .type print_hex16, %function
print_hex16:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    mov x23, x0
    WRITE_STDOUT msg_hex_prefix, msg_hex_prefix_len
    mov x0, x23
    LOAD_ADDR x1, hex_buffer
    mov x2, #4
    bl u64_to_hex_fixed
    mov x2, x0
    LOAD_ADDR x1, hex_buffer
    mov x0, #1
    mov x8, #64
    svc #0
    ldp x29, x30, [sp], #16
    ret
    .size print_hex16, .-print_hex16

    .section .rodata
msg_header:
    .ascii "DR4 AT - Diagnostico de Telemetria\n"
    .set msg_header_len, . - msg_header
msg_values:
    .ascii "entrada_valores: 10 20 30 40 50 60 70 80\n"
    .set msg_values_len, . - msg_values
msg_status:
    .ascii "entrada_status: 0x01 0x01 0x05 0x01 0x09 0x01 0x00 0x01\n"
    .set msg_status_len, . - msg_status
msg_valid_count:
    .ascii "amostras_validas: "
    .set msg_valid_count_len, . - msg_valid_count
msg_valid_sum:
    .ascii "soma_validos: "
    .set msg_valid_sum_len, . - msg_valid_sum
msg_valid_avg:
    .ascii "media_inteira: "
    .set msg_valid_avg_len, . - msg_valid_avg
msg_alarm_count:
    .ascii "alarmes_ativos: "
    .set msg_alarm_count_len, . - msg_alarm_count
msg_battery_count:
    .ascii "bateria_baixa: "
    .set msg_battery_count_len, . - msg_battery_count
msg_status_word:
    .ascii "palavra_status: "
    .set msg_status_word_len, . - msg_status_word
msg_status_rotl:
    .ascii "rotacao_status: "
    .set msg_status_rotl_len, . - msg_status_rotl
msg_status_signature:
    .ascii "assinatura_status: "
    .set msg_status_signature_len, . - msg_status_signature
msg_lut_values:
    .ascii "lut_validos: "
    .set msg_lut_values_len, . - msg_lut_values
msg_lut_sum:
    .ascii "soma_lut_validos: "
    .set msg_lut_sum_len, . - msg_lut_sum
msg_neon_sum:
    .ascii "simd_soma4: "
    .set msg_neon_sum_len, . - msg_neon_sum
msg_norm:
    .ascii "simd_normalizado: 0.100 0.200 0.300 0.400\n"
    .set msg_norm_len, . - msg_norm
msg_numeric_validation:
    .ascii "validacao_numerica: "
    .set msg_numeric_validation_len, . - msg_numeric_validation
msg_ok:
    .ascii "ok"
    .set msg_ok_len, . - msg_ok
msg_fail:
    .ascii "falha"
    .set msg_fail_len, . - msg_fail
msg_newline:
    .ascii "\n"
    .set msg_newline_len, . - msg_newline
msg_space:
    .ascii " "
    .set msg_space_len, . - msg_space
msg_hex_prefix:
    .ascii "0x"
    .set msg_hex_prefix_len, . - msg_hex_prefix
expected_sum_ascii:
    .asciz "290"

    .bss
    .balign 16
num_buffer:
    .skip 32
hex_buffer:
    .skip 17
