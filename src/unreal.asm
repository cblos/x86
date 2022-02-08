SECTION .text
USE16

;; Switch to UMode
;; DS and ES can address up to 4GiB
unreal:
    CLI

    LGDT                    [unreal_gdtr]

    PUSH ES
    PUSH DS

    MOV                     EAX, CR0            ;; Switch to PMode by
    OR                      AL, 1               ;; setting pmode bit
    MOV                     CR0, EAX

    JMP $+2

    ;; When this register given a "selector", a "segment descriptor cache register"
    ;; is filled with the descriptor values, including the size (or limit). After
    ;; the switch back to real mode, these values are not modified, regardless of
    ;; what value is in the 16-bit segment register. So the 64k limit is no longer
    ;; valid and 32-bit offsets can be used with the real-mode addressing rules
    ;; See: http://wiki.osdev.org/Babystep7

    MOV                     BX, unreal_gdt.data
    MOV                     ES, BX
    MOV                     DS, BX

    AND                     AL, 0xFE            ;; Back to realmode
    MOV                     CR0, EAX            ;; By toggling bit again

    POP DS
    POP ES
    STI
    RET

unreal_gdtr:
    DW                      unreal_gdt.end + 1  ;; Size
    DW                      unreal_gdt          ;; Offset

unreal_gdt:
.null                       EQU $ - unreal_gdt
    DQ                      0
.data                       EQU $ - unreal_gdt
    istruc GDTEntry
        at GDTEntry.limitl,         DW 0xFFFF
        at GDTEntry.basel,          DW 0x0
        at GDTEntry.basem,          DB 0x0
        at GDTEntry.attribute,      DB attrib.present | attrib.user | attrib.writable
        at GDTEntry.flags_limit,    DB 0xFF | flags.granularity | flags.default_operand_size
        at GDTEntry.baseh,          DB 0x0
    iend
.end                        EQU $ - unreal_gdt
