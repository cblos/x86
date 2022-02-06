SECTION .text
USE16

initialize:
;; Enable FPU
;; See: https://wiki.osdev.org/FPU
.fpu:
    MOV                     EAX, CR0
    AND                     AL, 0xF3
    OR                      AL, 0x22
    MOV                     CR0, EAX
    MOV                     EAX, CR4
    OR                      EAX, 0x200
    MOV                     CR4, EAX
    FINIT
    RET

;; Enable SSE
;; See: https://wiki.osdev.org/SSE
.sse:
    MOV                     EAX, CR4
    OR                      AX, 0x600
    MOV                     CR4, EAX
    RET
