%include "common.asm"

startup_arch:
    ;; Load PMode and GDT
    CLI
    LGDT                    [GDTR]
    LIDT                    [IDTR]

    ;; Set PMode bit to `CR0`
    MOV                     EAX, CR0
    OR                      EAX, 1
    MOV                     CR0, EAX

    ;;  Far jump to load CS with 32-bit segment
    ;;  ...
