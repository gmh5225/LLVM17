; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx,-slow-unaligned-mem-32 | FileCheck %s --check-prefix=ALL --check-prefix=FAST32
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx,+slow-unaligned-mem-32 | FileCheck %s --check-prefix=ALL --check-prefix=SLOW32

define <4 x float> @merge_2_floats(ptr nocapture %p) nounwind readonly {
; ALL-LABEL: merge_2_floats:
; ALL:       # %bb.0:
; ALL-NEXT:    vmovsd {{.*#+}} xmm0 = mem[0],zero
; ALL-NEXT:    retq
  %tmp1 = load float, ptr %p
  %vecins = insertelement <4 x float> undef, float %tmp1, i32 0
  %add.ptr = getelementptr float, ptr %p, i32 1
  %tmp5 = load float, ptr %add.ptr
  %vecins7 = insertelement <4 x float> %vecins, float %tmp5, i32 1
  ret <4 x float> %vecins7
}

; Test-case generated due to a crash when trying to treat loading the first
; two i64s of a <4 x i64> as a load of two i32s.
define <4 x i64> @merge_2_floats_into_4() {
; ALL-LABEL: merge_2_floats_into_4:
; ALL:       # %bb.0:
; ALL-NEXT:    movq (%rax), %rax
; ALL-NEXT:    vmovups (%rax), %xmm0
; ALL-NEXT:    retq
  %1 = load ptr, ptr undef, align 8
  %2 = load i64, ptr %1
  %3 = insertelement <4 x i64> undef, i64 %2, i32 0
  %4 = load ptr, ptr undef, align 8
  %5 = getelementptr inbounds i64, ptr %4, i64 1
  %6 = load i64, ptr %5
  %7 = insertelement <4 x i64> %3, i64 %6, i32 1
  %8 = shufflevector <4 x i64> %7, <4 x i64> undef, <4 x i32> <i32 0, i32 1, i32 4, i32 5>
  ret <4 x i64> %8
}

define <4 x float> @merge_4_floats(ptr %ptr) {
; ALL-LABEL: merge_4_floats:
; ALL:       # %bb.0:
; ALL-NEXT:    vmovups (%rdi), %xmm0
; ALL-NEXT:    retq
  %a = load float, ptr %ptr, align 8
  %vec = insertelement <4 x float> undef, float %a, i32 0
  %idx1 = getelementptr inbounds float, ptr %ptr, i64 1
  %b = load float, ptr %idx1, align 8
  %vec2 = insertelement <4 x float> %vec, float %b, i32 1
  %idx3 = getelementptr inbounds float, ptr %ptr, i64 2
  %c = load float, ptr %idx3, align 8
  %vec4 = insertelement <4 x float> %vec2, float %c, i32 2
  %idx5 = getelementptr inbounds float, ptr %ptr, i64 3
  %d = load float, ptr %idx5, align 8
  %vec6 = insertelement <4 x float> %vec4, float %d, i32 3
  ret <4 x float> %vec6
}

; PR21710 ( http://llvm.org/bugs/show_bug.cgi?id=21710 )
; Make sure that 32-byte vectors are handled efficiently.
; If the target has slow 32-byte accesses, we should still generate
; 16-byte loads.

define <8 x float> @merge_8_floats(ptr %ptr) {
; FAST32-LABEL: merge_8_floats:
; FAST32:       # %bb.0:
; FAST32-NEXT:    vmovups (%rdi), %ymm0
; FAST32-NEXT:    retq
;
; SLOW32-LABEL: merge_8_floats:
; SLOW32:       # %bb.0:
; SLOW32-NEXT:    vmovups (%rdi), %xmm0
; SLOW32-NEXT:    vinsertf128 $1, 16(%rdi), %ymm0, %ymm0
; SLOW32-NEXT:    retq
  %a = load float, ptr %ptr, align 4
  %vec = insertelement <8 x float> undef, float %a, i32 0
  %idx1 = getelementptr inbounds float, ptr %ptr, i64 1
  %b = load float, ptr %idx1, align 4
  %vec2 = insertelement <8 x float> %vec, float %b, i32 1
  %idx3 = getelementptr inbounds float, ptr %ptr, i64 2
  %c = load float, ptr %idx3, align 4
  %vec4 = insertelement <8 x float> %vec2, float %c, i32 2
  %idx5 = getelementptr inbounds float, ptr %ptr, i64 3
  %d = load float, ptr %idx5, align 4
  %vec6 = insertelement <8 x float> %vec4, float %d, i32 3
  %idx7 = getelementptr inbounds float, ptr %ptr, i64 4
  %e = load float, ptr %idx7, align 4
  %vec8 = insertelement <8 x float> %vec6, float %e, i32 4
  %idx9 = getelementptr inbounds float, ptr %ptr, i64 5
  %f = load float, ptr %idx9, align 4
  %vec10 = insertelement <8 x float> %vec8, float %f, i32 5
  %idx11 = getelementptr inbounds float, ptr %ptr, i64 6
  %g = load float, ptr %idx11, align 4
  %vec12 = insertelement <8 x float> %vec10, float %g, i32 6
  %idx13 = getelementptr inbounds float, ptr %ptr, i64 7
  %h = load float, ptr %idx13, align 4
  %vec14 = insertelement <8 x float> %vec12, float %h, i32 7
  ret <8 x float> %vec14
}

define <4 x double> @merge_4_doubles(ptr %ptr) {
; FAST32-LABEL: merge_4_doubles:
; FAST32:       # %bb.0:
; FAST32-NEXT:    vmovups (%rdi), %ymm0
; FAST32-NEXT:    retq
;
; SLOW32-LABEL: merge_4_doubles:
; SLOW32:       # %bb.0:
; SLOW32-NEXT:    vmovups (%rdi), %xmm0
; SLOW32-NEXT:    vinsertf128 $1, 16(%rdi), %ymm0, %ymm0
; SLOW32-NEXT:    retq
  %a = load double, ptr %ptr, align 8
  %vec = insertelement <4 x double> undef, double %a, i32 0
  %idx1 = getelementptr inbounds double, ptr %ptr, i64 1
  %b = load double, ptr %idx1, align 8
  %vec2 = insertelement <4 x double> %vec, double %b, i32 1
  %idx3 = getelementptr inbounds double, ptr %ptr, i64 2
  %c = load double, ptr %idx3, align 8
  %vec4 = insertelement <4 x double> %vec2, double %c, i32 2
  %idx5 = getelementptr inbounds double, ptr %ptr, i64 3
  %d = load double, ptr %idx5, align 8
  %vec6 = insertelement <4 x double> %vec4, double %d, i32 3
  ret <4 x double> %vec6
}

; PR21771 ( http://llvm.org/bugs/show_bug.cgi?id=21771 )
; Recognize and combine consecutive loads even when the
; first of the combined loads is offset from the base address.
define <4 x double> @merge_4_doubles_offset(ptr %ptr) {
; FAST32-LABEL: merge_4_doubles_offset:
; FAST32:       # %bb.0:
; FAST32-NEXT:    vmovups 32(%rdi), %ymm0
; FAST32-NEXT:    retq
;
; SLOW32-LABEL: merge_4_doubles_offset:
; SLOW32:       # %bb.0:
; SLOW32-NEXT:    vmovups 32(%rdi), %xmm0
; SLOW32-NEXT:    vinsertf128 $1, 48(%rdi), %ymm0, %ymm0
; SLOW32-NEXT:    retq
  %arrayidx4 = getelementptr inbounds double, ptr %ptr, i64 4
  %arrayidx5 = getelementptr inbounds double, ptr %ptr, i64 5
  %arrayidx6 = getelementptr inbounds double, ptr %ptr, i64 6
  %arrayidx7 = getelementptr inbounds double, ptr %ptr, i64 7
  %e = load double, ptr %arrayidx4, align 8
  %f = load double, ptr %arrayidx5, align 8
  %g = load double, ptr %arrayidx6, align 8
  %h = load double, ptr %arrayidx7, align 8
  %vecinit4 = insertelement <4 x double> undef, double %e, i32 0
  %vecinit5 = insertelement <4 x double> %vecinit4, double %f, i32 1
  %vecinit6 = insertelement <4 x double> %vecinit5, double %g, i32 2
  %vecinit7 = insertelement <4 x double> %vecinit6, double %h, i32 3
  ret <4 x double> %vecinit7
}
