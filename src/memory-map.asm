SECTION .text
USE16

;; Generate a memory map at 0x500 to 0x5000 (available memory not used for kernel or bootloader)
memory_map:
    .start               EQU 0x0500
    .end                 EQU 0x5000
    .length              EQU .end - .start

    XOR                 EAX, EAX
    MOV                 DI, .start
    MOV                 ECX, .length / 4    ;; Moving 4 bytes at once
    CLD
    REP STOSD

    MOV                 DI, .start
    MOV                 EAX, 0x534D4150
    xor                 EBX, EBX

.lp:
    MOV                 EAX, 0xE820
    MOV                 ECX, 24

    INT                 0x15
    JC                  .done               ;; Errored or finished

    CMP                 EBX, 0
    JE                  .done               ;; Finished

    ADD                 DI, 24
    CMP                 DI, .end
    JB                  .lp                 ;; Buffer space still available

.done:
    ret
