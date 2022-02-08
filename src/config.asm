SECTION .text
USE16

align                       512, DB 0

config:
    .xres:                  DW 0
    .yres:                  DW 0

times                       512 - ($ - config) db 0

save_config:
    MOV                     EAX, (config - boot) / 512
    MOV                     BX, config
    MOV                     CX, 1
    XOR                     DX, DX
    CALL                    store
    RET

;; store some sectors to disk from a buffer in memory
;; buffer has to be below 1MiB
;; IN
;;      AX - Start sector
;;      BX - Offset of buffer
;;      CX - Number of sectors (512 bytes each)
;;      DX - Segment of buffer
;; CLOBBER
;;   AX, BX, CX, DX, SI

;; TODO rewrite to (eventually) move larger parts at once
;; If that is done, increase `buffer_size_sectors` in `common.asm`
;; to that (max 0x80000 - startup_end)
store:
    CMP                     CX, 127
    JBE                     .good_size

    PUSHA
    MOV                     CX, 127
    CALL                    store
    POPA
    ADD                     AX, 127
    ADD                     DX, 127 * 512 / 16
    SUB CX, 127

    JMP                     store

.good_size:
    MOV                     [DAPACK.addr], EAX
    MOV                     [DAPACK.buf], BX
    MOV                     [DAPACK.count], CX
    MOV                     [DAPACK.seg], DX

    call                    print_dapack

    MOV                     DL, [disk]
    MOV                     SI, DAPACK
    MOV                     Ah, 0x43
    INT                     0x13
    
    JC                      error
    RET
