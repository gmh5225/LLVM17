; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py UTC_ARGS: --version 2
; RUN: llc -mtriple=s390x-linux-gnu -mcpu=z15 < %s | FileCheck %s --check-prefixes=CHECK,Z15
; RUN: llc -mtriple=s390x-linux-gnu -mcpu=z13 < %s | FileCheck %s --check-prefixes=CHECK,Z13
;
; Test inline assembly where the operand is bitcasted.

define signext i32 @int_and_f(i32 signext %cc_dep1) {
; CHECK-LABEL: int_and_f:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vlvgf %v0, %r2, 0
; CHECK-NEXT:    #APP
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    vlgvf %r0, %v0, 0
; CHECK-NEXT:    lgfr %r2, %r0
; CHECK-NEXT:    br %r14
entry:
  %0 = tail call i32 asm sideeffect "", "=f,0"(i32 %cc_dep1)
  ret i32 %0
}

define i64 @long_and_f(i64 %cc_dep1) {
; CHECK-LABEL: long_and_f:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    ldgr %f0, %r2
; CHECK-NEXT:    #APP
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    lgdr %r2, %f0
; CHECK-NEXT:    br %r14
entry:
  %0 = tail call i64 asm sideeffect "", "=f,0"(i64 %cc_dep1)
  ret i64 %0
}

define void @__int128_and_f(ptr noalias nocapture writeonly sret(i128) align 8 %agg.result, ptr %0) {
; Z15-LABEL: __int128_and_f:
; Z15:       # %bb.0: # %entry
; Z15-NEXT:    vl %v0, 0(%r3), 3
; Z15-NEXT:    vrepg %v2, %v0, 1
; Z15-NEXT:    #APP
; Z15-NEXT:    #NO_APP
; Z15-NEXT:    vmrhg %v0, %v0, %v2
; Z15-NEXT:    vst %v0, 0(%r2), 3
; Z15-NEXT:    br %r14
;
; Z13-LABEL: __int128_and_f:
; Z13:       # %bb.0: # %entry
; Z13-NEXT:    ld %f0, 0(%r3)
; Z13-NEXT:    ld %f2, 8(%r3)
; Z13-NEXT:    #APP
; Z13-NEXT:    #NO_APP
; Z13-NEXT:    std %f0, 0(%r2)
; Z13-NEXT:    std %f2, 8(%r2)
; Z13-NEXT:    br %r14
entry:
  %cc_dep1 = load i128, ptr %0, align 8
  %1 = tail call i128 asm sideeffect "", "=f,0"(i128 %cc_dep1)
  store i128 %1, ptr %agg.result, align 8
  ret void
}

define signext i32 @int_and_v(i32 signext %cc_dep1) {
; CHECK-LABEL: int_and_v:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vlvgf %v0, %r2, 0
; CHECK-NEXT:    #APP
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    vlgvf %r0, %v0, 0
; CHECK-NEXT:    lgfr %r2, %r0
; CHECK-NEXT:    br %r14
entry:
  %0 = tail call i32 asm sideeffect "", "=v,0"(i32 %cc_dep1)
  ret i32 %0
}

define i64 @long_and_v(i64 %cc_dep1) {
; CHECK-LABEL: long_and_v:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    ldgr %f0, %r2
; CHECK-NEXT:    #APP
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    lgdr %r2, %f0
; CHECK-NEXT:    br %r14
entry:
  %0 = tail call i64 asm sideeffect "", "=v,0"(i64 %cc_dep1)
  ret i64 %0
}

define void @__int128_and_v(ptr noalias nocapture writeonly sret(i128) align 8 %agg.result, ptr %0) {
; CHECK-LABEL: __int128_and_v:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vl %v0, 0(%r3), 3
; CHECK-NEXT:    #APP
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    vst %v0, 0(%r2), 3
; CHECK-NEXT:    br %r14
entry:
  %cc_dep1 = load i128, ptr %0, align 8
  %1 = tail call i128 asm sideeffect "", "=v,0"(i128 %cc_dep1)
  store i128 %1, ptr %agg.result, align 8
  ret void
}

define float @float_and_r(float %cc_dep1) {
; CHECK-LABEL: float_and_r:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vlgvf %r0, %v0, 0
; CHECK-NEXT:    #APP
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    vlvgf %v0, %r0, 0
; CHECK-NEXT:    br %r14
entry:
  %0 = tail call float asm sideeffect "", "=r,0"(float %cc_dep1)
  ret float %0
}

define double @double_and_r(double %cc_dep1) {
; CHECK-LABEL: double_and_r:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lgdr %r0, %f0
; CHECK-NEXT:    #APP
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    ldgr %f0, %r0
; CHECK-NEXT:    br %r14
entry:
  %0 = tail call double asm sideeffect "", "=r,0"(double %cc_dep1)
  ret double %0
}

define void @longdouble_and_r(ptr noalias nocapture writeonly sret(fp128) align 8 %agg.result, ptr %0) {
; CHECK-LABEL: longdouble_and_r:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lg %r1, 8(%r3)
; CHECK-NEXT:    lg %r0, 0(%r3)
; CHECK-NEXT:    #APP
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    stg %r1, 8(%r2)
; CHECK-NEXT:    stg %r0, 0(%r2)
; CHECK-NEXT:    br %r14
entry:
  %cc_dep1 = load fp128, ptr %0, align 8
  %1 = tail call fp128 asm sideeffect "", "=r,0"(fp128 %cc_dep1)
  store fp128 %1, ptr %agg.result, align 8
  ret void
}

define float @float_and_v(float %cc_dep1) {
; CHECK-LABEL: float_and_v:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    #APP
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    br %r14
entry:
  %0 = tail call float asm sideeffect "", "=v,0"(float %cc_dep1)
  ret float %0
}

define double @double_and_v(double %cc_dep1) {
; CHECK-LABEL: double_and_v:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    #APP
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    br %r14
entry:
  %0 = tail call double asm sideeffect "", "=v,0"(double %cc_dep1)
  ret double %0
}

define void @longdouble_and_v(ptr noalias nocapture writeonly sret(fp128) align 8 %agg.result, ptr %0) {
; CHECK-LABEL: longdouble_and_v:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vl %v0, 0(%r3), 3
; CHECK-NEXT:    #APP
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    vst %v0, 0(%r2), 3
; CHECK-NEXT:    br %r14
entry:
  %cc_dep1 = load fp128, ptr %0, align 8
  %1 = tail call fp128 asm sideeffect "", "=v,0"(fp128 %cc_dep1)
  store fp128 %1, ptr %agg.result, align 8
  ret void
}

define <2 x i16> @vec32_and_r(<2 x i16> %cc_dep1) {
; CHECK-LABEL: vec32_and_r:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vlgvf %r0, %v24, 0
; CHECK-NEXT:    #APP
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    vlvgf %v24, %r0, 0
; CHECK-NEXT:    br %r14
entry:
  %0 = tail call <2 x i16> asm sideeffect "", "=r,0"(<2 x i16> %cc_dep1)
  ret <2 x i16> %0
}

define <2 x i32> @vec64_and_r(<2 x i32> %cc_dep1) {
; CHECK-LABEL: vec64_and_r:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vlgvg %r0, %v24, 0
; CHECK-NEXT:    #APP
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    vlvgg %v24, %r0, 0
; CHECK-NEXT:    br %r14
entry:
  %0 = tail call <2 x i32> asm sideeffect "", "=r,0"(<2 x i32> %cc_dep1)
  ret <2 x i32> %0
}

define <4 x i32> @vec128_and_r(<4 x i32> %cc_dep1) {
; CHECK-LABEL: vec128_and_r:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vlgvg %r1, %v24, 1
; CHECK-NEXT:    vlgvg %r0, %v24, 0
; CHECK-NEXT:    #APP
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    vlvgp %v24, %r0, %r1
; CHECK-NEXT:    br %r14
entry:
  %0 = tail call <4 x i32> asm sideeffect "", "=r,0"(<4 x i32> %cc_dep1)
  ret <4 x i32> %0
}

define <2 x i16> @vec32_and_f(<2 x i16> %cc_dep1) {
; CHECK-LABEL: vec32_and_f:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vlr %v0, %v24
; CHECK-NEXT:    #APP
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    vlr %v24, %v0
; CHECK-NEXT:    br %r14
entry:
  %0 = tail call <2 x i16> asm sideeffect "", "=f,0"(<2 x i16> %cc_dep1)
  ret <2 x i16> %0
}

define <2 x i32> @vec64_and_f(<2 x i32> %cc_dep1) {
; CHECK-LABEL: vec64_and_f:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vlr %v0, %v24
; CHECK-NEXT:    #APP
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    vlr %v24, %v0
; CHECK-NEXT:    br %r14
entry:
  %0 = tail call <2 x i32> asm sideeffect "", "=f,0"(<2 x i32> %cc_dep1)
  ret <2 x i32> %0
}

define <4 x i32> @vec128_and_f(<4 x i32> %cc_dep1) {
; CHECK-LABEL: vec128_and_f:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vrepg %v2, %v24, 1
; CHECK-NEXT:    vlr %v0, %v24
; CHECK-NEXT:    #APP
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    vmrhg %v24, %v0, %v2
; CHECK-NEXT:    br %r14
entry:
  %0 = tail call <4 x i32> asm sideeffect "", "=f,0"(<4 x i32> %cc_dep1)
  ret <4 x i32> %0
}
