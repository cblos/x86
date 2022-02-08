%include "inc/vesa.inc"

SECTION .text
USE16

vesa:
.getcardinfo:
    MOV                 AX, 0x4F00
    MOV                 DI, VBECardInfo
    INT                 0x10
    CMP                 AX, 0x4F
    JE                  .findmode
    MOV                 EAX, 1
    RET

.resetlist:
    XOR                 CX, CX
    MOV                 [.minx], CX
    MOV                 [.miny], CX
    MOV                 [config.xres], CX
    MOV                 [config.yres], CX

.findmode:
    MOV                 SI, [VBECardInfo.videomodeptr]
    MOV                 AX, [VBECardInfo.videomodeptr + 2]
    MOV                 FS, AX
    SUB                 SI, 2

.searchmodes:
    ADD                 SI, 2
    MOV                 CX, [FS:SI]
    CMP                 CX, 0xFFFF
    JNE                 .getmodeinfo
    CMP                 WORD [.goodmode], 0
    JE                  .resetlist
    JMP                 .findmode

.getmodeinfo:
    PUSH                ESI
    MOV                 [.currentmode], CX
    MOV                 AX, 0x4F01
    MOV                 DI, VBEModeInfo
    INT                 0x10
    POP                 ESI
    CMP                 AX, 0x4F
    JE                  .foundmode
    MOV                 EAX, 1
    RET

.foundmode:
    CMP                 BYTE [VBEModeInfo.bitsperpixel], 32
    JB                  .searchmodes

.testx:
    MOV                 CX, [VBEModeInfo.xresolution]
    CMP                 WORD [config.xres], 0
    JE                  .notrequiredx
    CMP                 CX, [config.xres]
    JE                  .testy
    JMP                 .searchmodes

.notrequiredx:
    CMP                 CX, [.minx ]
    JB                  .searchmodes

.testy:
    MOV                 CX, [VBEModeInfo.yresolution]
    CMP                 WORD [config.yres], 0
    JE                  .notrequiredy
    CMP                 CX, [config.yres]
    JNE                 .searchmodes
    CMP                 WORD [config.xres], 0
    JNZ                 .setmode
    JMP                 .testgood

.notrequiredy:
    CMP                 CX, [.miny]
    JB                  .searchmodes

.testgood:
    MOV                 AL, 13
    CALL                print_char
    MOV                 CX, [.currentmode]
    MOV                 [.goodmode], CX
    PUSH                ESI
    MOV                 CX, [VBEModeInfo.xresolution]
    CALL                print_dec
    MOV                 AL, 'x'
    CALL                print_char
    MOV                 CX, [VBEModeInfo.yresolution]
    CALL                print_dec
    MOV                 AL, '@'
    CALL                print_char
    XOR                 CH. CH
    MOV                 CL, [VBEModeInfo.bitsperpixel]
    CALL                print_dec
    MOV                 SI, .modeok
    CALL                print
    XOR                 AX, AX
    INT                 0x16
    POP                 ESI
    CMP AL,             'y'
    JE                  .setmode
    CMP                 AL, 's'
    JE                  .savemode
    JMP                 .searchmodes

.savemode:
    MOV                 CX, [VBEModeInfo.xresolution]
    MOV                 [config.xres], CX
    MOV                 CX, [VBEModeInfo.yresolution]
    MOV                 [config.yres], CX
    CALL                save_config

.setmode:
    MOV                 BX, [.currentmode]
    CMP                 BX, 0
    JE                  .nomode
    OR                  BX, 0x4000
    MOV                 AX, 0x4F02
    INT                 0x10

.nomode:
    CMP                 AX, 0x4F
    JE                  .returngood
    MOV                 EAX, 1
    RET

.returngood:
    XOR                 EAX, EAX
    RET

.modeok                     DB ": Is this OK? (s)ave/(y)es/(n)o    ", 8, 8, 8, 8, 0
.minx                       DW 640
.miny                       DW 480
.goodmode                   DW 0
.currentmode                DW 0

print_dec:
    MOV                     SI, .number

.clear:
    MOV                     AL, "0"
    MOV                     [SI], AL
    INC                     SI
    CMP                     SI, .numberend
    JB                      .clear
    DEC                     SI
    CALL                    convert_dec
    MOV                     SI, .number

.lp:
    LODSB
    CMP                     SI, .numberend
    JAE                     .end
    CMP                     AL, "0"
    JBE .lp

.end:
    DEC                     SI
    CALL                    print
    RET

.number                     TIMES 7 DB 0
.numberend                  DB 0

convert_dec:
    DEC                     SI
    MOV                     BX, SI

.cnvrt:
    MOV                     SI, BX
    SUB                     SI, 4

.ten4:
    INC                     SI
    CMP                     CX, 10000
    JB                      .ten3
    SUB                     CX, 10000
    INC                     byte [SI]
    JMP                     .cnvrt

.ten3:
    INC                     SI
    CMP                     CX, 1000
    JB                      .ten2
    SUB                     CX, 1000
    INC                     BYTE [SI]
    JMP                     .cnvrt

.ten2:
    INC                     SI
    CMP                     CX, 100
    JB                      .ten1
    SUB                     CX, 100
    INC                     BYTE [SI]
    JMP                     .cnvrt

.ten1:
    INC                     SI
    CMP                     CX, 10
    JB                      .ten0
    SUB                     CX, 10
    INC                     BYTE [SI]
    JMP                     .cnvrt

.ten0:
    INC                     SI
    CMP                     CX, 1
    JB                      .return
    SUB                     CX, 1
    INC                     BYTE [SI]
    JMP                     .cnvrt

.return:
    ret
