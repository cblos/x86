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

    ;; ...

    MOV                     SI, init_fpu_msg

init_fpu_msg:               DB "Init FPU", 13, 10, 0
init_sse_msg:               DB "Init SSE", 13, 10, 0
init_pit_msg:               DB "Init PIT", 13, 10, 0
init_pic_msg:               DB "Init PIC", 13, 10, 0
startup_arch_msg:           DB "Startup Arch", 13, 10, 0
