struc mbr_partition_rec
    .sys:                   RESB 1
    .chs_start:             RESB 3
    .ty:                    RESB 1
    .chs_end:               RESB 3
    .lba_start:             RESD 1
    .sector_count:          RESD 1
endstruc

find_kernelfs_partition:
    XOR                     EBX, EBX

.lp:
    MOV                     AL, BYTE [partitions + mbr_partition_rec + mbr_partition_rec.ty]
    CMP                     AL, 0x83
    JE                      .found
    ADD                     EBX, 1
    CMP                     EBX, 4
    JB                      .lp
    JMP                     .notfound

.found:
    MOV                     EAX, [partitions + mbr_partition_rec + mbr_partition_rec.lba_start]
    RET

.notfound:
    MOV                     SI, .no_partition_found_msg
    CALL                    print
    MOV                     EAX, (filesystem - boot) / 512
    RET

.no_partition_found_msg: db "No MBR partition with type 0x83 found", 0xA, 0xD, 0
