struc GDTEntry
    .limitl                 RESW 1
    .basel                  RESW 1
    .basem                  RESB 1
    .attribute              RESB 1
    .flags_limit            RESB 1
    .baseh                  RESB 1
endstruc
