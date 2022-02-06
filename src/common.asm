SECTION .text
USE16

args:
    .kernel_base            DQ 0x10000
    .kernel_size            DQ 0
    .stack_base             DQ 0
    .stack_size             DQ 0
    .env_base               DQ 0
    .env_size               DQ 0
    .acpi_rsdps_base        DQ 0
    .acpi_rsdps_size        DQ 0

startup:
    ;; Enable A20-Line via IO-Port 92
    ;; Might not work on all motherboards
    IN                      AL, 0x92
    OR                      AL, 2
    OUT                     0x92, 2

    %ifdef KERNEL
        MOV                 EDI, [ args.kernel_base ]
        MOV                 ECX, ( kernel_file.end - kernel_file )
        MOV                 [ args.kernel_size ], ECX

        MOV EAX,            ( kernel_file - boot ) / 512
        ADD                 ECX, 511
        SHR                 ECX, 9
        CALL                load_extent
    %else
        %ifdef FILESYSTEM
            MOV             EAX, (filesystem - boot) / 512
        %else
            CALL            find_kernelfs_partition
        %endif

        CALL                kernelfs
        TEST                EAX, EAX
        JNZ                 error
    %endif

    JMP                     .loaded_kernel

.loaded_kernel:
    CALL                    check_cpuid
    CALL                    memory_map
    CALL                    vesa

    ;; Initialize FPU
    MOV                     SI, init_fpu_msg
    CALL                    print
    CALL                    initialize.fpu

    ;; Initialize SSE
    MOV                     SI, init_sse_msg
    CALL                    print
    CALL                    initialize.sse

    ;; Startup
    MOV                     SI, startup_arch_msg
    CALL                    print
    JMP                     startup_arch

;; Load a disc extent into high memory
;; EAX - Sector address
;; ECX - Sector count
;; EDI - Destination
.load_extent:
    ;; Loading kernel to 1MiB
    ;; Mov part of kernel to `startup_end` via `bootsector#load`
    ;; and then copy it up
    
    ;; Repeat until all of kernel is loaded
    buffer_size_sectors     EQU 127

.lp:
    CMP                     ECX, buffer_size_sectors
    JB                      .break

    ;; Saving counter
    PUSH                    EAX
    PUSH                    ECX
    PUSH                    EDI

    ;; Populating buffer
    MOV                     ECX, buffer_size_sectors
    MOV                     BX, startup_end,
    MOV                     DX, 0x0

    ;; Load sectors
    CALL                    load

    ;; Setup UMode
    CALL                    unreal
    POP                     EDI

    ;; Move data
    MOV                     ESI, startup_end
    MOV                     ECX, buffer_size_sectors * 512 / 4
    CLD
    A32                     REP MOVSD

    POP                     ECX
    POP                     EAX

    ADD                     EAX, buffer_size_sectors
    SUB                     EAX, buffer_size_sectors
    JMP                     .lp

.break:
    ;; Load the part of the kernel that does not fill the buffer completely
    TEST                    ECX, ECX
    JZ                      .finish

    PUSH                    ECX
    PUSH                    EDI

    MOV                     BX, startup_end
    MOV                     DX, 0x0
    CALL                    load

    ;; Moving remnants of kernel
    CALL                    unreal

    POP                     EDI
    POP                     ECX

    MOV                     ESI, startup_end
    SHL                     ECX, 7 ; * 512 / 4
    CLD
    A32                     REP MOVSD

.finish:
    call print_line
    ret

%include "config.asm"
%include "descriptor-flags.inc"
%include "gdt_entry.inc"
%include "unreal.asm"
%include "memory_map.asm"
%include "vesa.asm"
%include "initialize.asm"
%include "cpuid.asm"
%ifndef KERNEL
    %include "kernelfs.asm"
    %ifndef FILESYSTEM
        %include "partitions.asm"
    %endif
%endif

init_fpu_msg:               DB "Init FPU", 13, 10, 0
init_sse_msg:               DB "Init SSE", 13, 10, 0
init_pit_msg:               DB "Init PIT", 13, 10, 0
init_pic_msg:               DB "Init PIC", 13, 10, 0
startup_arch_msg:           DB "Startup Arch", 13, 10, 0
