%define                     BLOCK_SHIFT 12
%define                     BLOCK_SIZE (1 << BLOCK_SHIFT)

struc Extent
    .block:                 RESQ 1,
    .length:                RESQ 1
endstruc

struc Node
    .mode:                  RESW 1
    .uid:                   RESD 1
    .gid:                   RESD 1
    .ctime:                 RESQ 1
    .ctime_nsec:            RESD 1
    .mtime:                 RESQ 1
    .mtime_nsec:            RESD 1
    .atime:                 RESQ 1
    .atime_nsec:            RESD 1
    .name:                  RESB 226
    .parent:                RESQ 1
    .next:                  RESQ 1
    .extents:               RESB (BLOCK_SIZE - 288)
endstruc

struc Header
    .signature:             RESB 9
    .version:               RESQ 1,
    .uuid:                  RESB 16,
    .size:                  RESQ 1,
    .root:                  RESQ 1,
    .free:                  RESQ 1
    .padding:               RESB (BLOCK_SIZE - 56)
endstruc

;; EAX - the first sector of the filesystem
kernelfs:
        MOV                 [.first_sector], EAX
        CALL                kernelfs.open
        TEST                EAX, EAX
        JZ                  .good_header
        RET

    .good_header:
        MOV                 EAX, [.header + Header.root]
        MOV                 BX, .dir
        CALL                .node

        JMP                 kernelfs.root

    ;; EAX - Node
    ;; BX - Buffer
    .node:
        SHL                 EAX, (BLOCK_SHIFT - 9)
        ADD                 EAX, [kernelfs.first_sector]
        MOV                 CX, (BLOCK_SIZE / 512)
        MOV                 DX, 0
        CALL                load
        CALL                print_line
        RET

        align BLOCK_SIZE,   DB 0

    .header:
        times BLOCK_SIZE    DB 0

    .dir:
        times BLOCK_SIZE    DB 0

    .file:
        times BLOCK_SIZE    DB 0

    .first_sector:          DD 0

    .env:
        DB                  "KERNELFS_BLOCK="
    .env.block:
        DB                  "0000000000000000"
    .env.block_end:
        DB                  `\n`
        DB                  "KERNELFS_UUID="
    .env.uuid:
        DB                  "00000000-0000-0000-0000-000000000000"
    .env.end:

kernelfs.open:
        MOV                 EAX, 0
        MOV                 BX, kernelfs.header
        CALL                kernelfs.node
        MOV                 BX, 0

    .sig:
        MOV                 AL, [kernelfs.header + Header.signature + BX]
        MOV                 AH, [.signature + BX]
        CMP                 AL, AH
        JNE                 .sig_err
        INC                 BX
        CMP                 BX, 8
        JL                  .sig
        MOV                 BX, 0

    .ver:
        MOV                 AL, [kernelfs.header + Header.version + BX]
        MOV                 AH, [.version + BX]
        CMP                 AL, AH
        JNE                 .ver_err
        INC                 BX
        JL                  .ver
        LEA                 SI, [kernelfs.header + Header.signature]
        CALL                print
        MOV                 AL, ' '
        CALL                print_char
        PUSH                EAX
        PUSH                edx
        XOR                 edx, edx
        MOV                 EAX, [kernelfs.first_sector]
        MOV                 EBX, (BLOCK_SIZE / 512)
        DIV                 EBX ; EDX:EAX = EDX:EAX / EBX
        MOV                 EBX, EAX
        POP                 EDX
        POP                 EAX
        MOV                 DI, kernelfs.env.block_end - 1

    .block:
        MOV                 AL, BL
        and                 AL, 0x0F
        cmp                 AL, 0x0A
        JB                  .block.below_0xA
        ADD                 AL, 'A' - 0xA - '0'

    .block.below_0xA:
        ADD                 AL, '0'
        MOV                 [ DI ], AL
        DEC                 DI
        SHR                 EBX, 4
        TEST                EBX, EBX
        JNZ                 .block
        MOV                 DI, kernelfs.env.uuid
        XOR                 SI, SI

    .uuid:
        CMP                 SI, 4
        JE                  .uuid.dash
        CMP                 SI, 6
        JE                  .uuid.dash
        CMP                 SI, 8
        JE                  .uuid.dash
        CMP                 SI, 10
        JE                  .uuid.dash
        JMP                 .uuid.no_dash

    .uuid.dash:
        MOV                 AL, '-'
        MOV                 [ DI ], al
        INC                 DI

    .uuid.no_dash:
        MOV                 BX, [ kernelfs.header + Header.uuid + SI ]
        ROL                 BX, 8
        MOV                 CX, 4

    .uuid.char:
        MOV                 AH, BH
        SHR                 AL, 4
        CMP                 AL, 0xA
        JB                  .uuid.below_0xA
        ADD                 AL, 'a' - 0xA - '0'

    .uuid.below_0xA:
        ADD                 AL, '0'
        MOV                 [DI], AL
        INC                 DI
        SHL                 BX, 4
        LOOP                .uuid.char
        ADD                 si, 2
        cmp                 si, 16
        JB                  .uuid
        MOV                 si, kernelfs.env.uuid
        CALL                print
        CALL                print_line
        XOR                 AX, AX
        RET

    .err_msg:               db "Failed to open KernelFS: ", 0
    .sig_err_msg:           db "Signature error", 13, 10, 0
    .ver_err_msg:           db "Version error", 13, 10, 0

    .sig_err:
        MOV                 SI, .err_msg
        CALL                print
        MOV                 SI, .sig_err_msg
        CALL                print
        MOV                 AX, 1
        RET

    .ver_err:
        MOV                 SI, .err_msg
        CALL                print
        MOV                 SI, .ver_err_msg
        CALL                print
        MOV                 AX, 1
        RET

    .signature:             DB "KernelFS",0
    .version:               DQ 4


kernelfs.root:
        LEA                 SI, [kernelfs.dir + Node.name]
        CALL                print
        CALL                print_line

    .lp:
        MOV                 BX, 0

    .ext:
        MOV                 EAX, [kernelfs.dir + Node.extents + BX + Extent.block]
        TEST                EAX, EAX
        JS                  .next
        MOV                 ECX, [kernelfs.dir + Node.extents + BX + Extent.length]
        TEST                ECX, ECX
        JZ                  .next
        ADD                 ECX, BLOCK_SIZE
        DEC                 ECX
        SHR                 ECX, BLOCK_SHIFT
        PUSH                BX

    .ext_sec:
        PUSH                EAX
        PUSH                ECX
        MOV                 BX, kernelfs.file
        CALL                kernelfs.node
        MOV                 BX, 0

    .ext_sec_kernel:
        MOV                 AL, [kernelfs.file + Node.name + BX]
        MOV                 AH, [.kernel_name + BX]
        cmp                 AL, AH
        JNE                 .ext_sec_kernel_break
        INC                 BX
        TEST                AH, AH
        JNZ                 .ext_sec_kernel
        POP                 ECX
        POP                 EAX
        POP                 BX
        JMP                 kernelfs.kernel

    .ext_sec_kernel_break:
        POP                 ECX
        POP                 EAX
        INC                 EAX
        DEC                 ECX
        JNZ                 .ext_sec
        POP                 BX
        ADD                 BX, Extent_size
        CMP                 BX, (BLOCK_SIZE - 272)
        JB                  .ext

    .next:
        MOV                 EAX, [kernelfs.dir + Node.next]
        TEST                EAX, EAX
        JZ                  .no_kernel
        MOV                 BX, kernelfs.dir
        CALL                kernelfs.node
        JMP                 .lp

    .no_kernel:
        MOV                 SI, .no_kernel_msg
        CALL                print
        MOV                 SI, .kernel_name
        CALL                print
        CALL                print_line
        MOV                 EAX, 1
        RET

    .kernel_name:           db "Kernel",0
    .no_kernel_msg:         db "Did not find: ",0

kernelfs.kernel:
        LEA                 SI, [kernelfs.file + Node.name]
        CALL                print
        CALL                print_line
        MOV                 EDI, [args.kernel_base]

    .lp:
        MOV                 BX, 0

    .ext:
        MOV                 EAX, [kernelfs.file + Node.extents + BX + Extent.block]
        TEST                EAX, EAX
        JZ                  .next
        MOV                 ECX, [kernelfs.file + Node.extents + BX + Extent.length]
        TEST                ECX, ECX
        JZ                  .next
        PUSH                BX
        PUSH                EAX
        PUSH                ECX
        PUSH                EDI
        SHL                 EAX, (BLOCK_SHIFT - 9)
        ADD                 EAX, [kernelfs.first_sector]
        ADD                 ECX, BLOCK_SIZE
        DEC                 ECX
        SHR                 ECX, 9
        CALL                load_extent
        POP                 EDI
        POP                 ECX
        POP                 EAX
        ADD                 EDI, ECX
        POP                 BX
        ADD                 BX, Extent_size
        CMP                 BX, Extent_size * 16
        JB                  .ext

    .next:
        MOV                 EAX, [kernelfs.file + Node.next]
        test                EAX, EAX
        JZ                  .done
        PUSH                EDI
        MOV                 BX, kernelfs.file
        CALL                kernelfs.node
        POP                 EDI
        JMP                 .lp

    .done:
        SUB                 EDI, [args.kernel_base]
        MOV                 [args.kernel_size], EDI
        XOR                 EAX, EAX
        RET
