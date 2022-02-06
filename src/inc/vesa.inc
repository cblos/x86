ABSOLUTE 0x5000
VBECardInfo:
    .signature              RESB 4
    .version                RESW 1
    .oemstring              RESD 1
    .capabilities           RESD 1
    .videomodeptr           RESD 1
    .totalmemory            RESW 1
    .oemsoftwarerev         RESW 1
    .oemvendornameptr       RESD 1
    .oemproductnameptr      RESD 1
    .oemproductrevptr       RESD 1
    .reserved               RESB 222
    .oemdata                RESB 256

ABSOLUTE 0x5200
VBEModeInfo:
    .attributes             RESW 1
    .winA                   RESB 1
    .winB                   RESB 1
    .granularity            RESW 1
    .winsize                RESW 1
    .segmentA               RESW 1
    .segmentB               RESW 1
    .winfuncptr             RESD 1
    .bytesperscanline       RESW 1
    .xresolution            RESW 1
    .yresolution            RESW 1
    .xcharsize              RESB 1
    .ycharsize              RESB 1
    .numberofplanes         RESB 1
    .bitsperpixel           RESB 1
    .numberofbanks          RESB 1
    .memorymodel            RESB 1
    .banksize               RESB 1
    .numberofimagepages     RESB 1
    .unused                 RESB 1
    .redmasksize            RESB 1
    .redfieldposition       RESB 1
    .greenmasksize          RESB 1
    .greenfieldposition     RESB 1
    .bluemasksize           RESB 1
    .bluefieldposition      RESB 1
    .rsvdmasksize           RESB 1
    .rsvdfieldposition      RESB 1
    .directcolormodeinfo    RESB 1
    .physbaseptr            RESD 1
    .offscreenmemoryoffset  RESD 1
    .offscreenmemsize       RESW 1
    .reserved               RESB 206

VBE.ModeAttributes:
    .available              EQU 1 << 0
    .bios                   EQU 1 << 2
    .color                  EQU 1 << 3
    .graphics               EQU 1 << 4
    .vgacompatible          EQU 1 << 5
    .notbankable            EQU 1 << 6
    .linearframebuffer      EQU 1 << 7
 
ABSOLUTE 0x5400
VBEEDID:
    .header                 RESB 8
    .manufacturer           RESW 1
    .productid              RESW 1
    .serial                 RESD 1
    .manufactureweek        RESB 1
    .manufactureyear        RESB 1
    .version                RESB 1
    .revision               RESB 1
    .input                  RESB 1
    .horizontalsize         RESB 1
    .verticalsize           RESB 1
    .gamma                  RESB 1
    .displaytype            RESB 1
    .chromaticity           RESB 10
    .timingI                RESB 1
    .timingII               RESB 1
    .timingreserved         RESB 1
    .standardtiming:        RESW 8
        .aspect.16.10       EQU 0
        .aspect.4.3         EQU 1 << 6
        .aspect.5.4         EQU 2 << 6
        .aspect.16.9        EQU 3 << 6
    .descriptorblock1       RESB 18
    .descriptorblock2       RESB 18
    .descriptorblock3       RESB 18
    .descriptorblock4       RESB 18
    .extensionflag          RESB 1
    .checksum               RESB 1
