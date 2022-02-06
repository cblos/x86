%include "inc/cpuid.inc"

required_features:
    .edx                    EQU features_edx.fpu | features_edx.sse | features_edx.pae | features_edx.pse | features_edx.pge | features_edx.fxsr
    .ecx                    EQU features_ecx.xsave

check_cpuid:
    MOV                     EAX, 1
    CPUID

    AND                     EDX, required_features.edx
    cmp                     EDX, required_features.edx
    JNE                     .error

    AND                     ECX, required_features.ecx
    CMP                     ECX, required_features.ecx
    JNE .error

    RET

.error:
    MOV                     SI, .err_features
    CALL                    print

.halt:
    JMP .halt

.err_features:              db "Required CPU features are not present", 13, 10, 0
