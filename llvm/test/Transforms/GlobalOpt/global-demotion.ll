; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -passes=globalopt -S < %s | FileCheck %s

@G1 = internal global i32 5
@G2 = internal global i32 5
@G3 = internal global i32 5
@G4 = internal global i32 5
@G5 = internal global i32 5

define i32 @test1() norecurse {
; CHECK-LABEL: @test1(
; CHECK-NEXT:    [[G1:%.*]] = alloca i32, align 4
; CHECK-NEXT:    store i32 5, ptr [[G1]], align 4
; CHECK-NEXT:    store i32 4, ptr [[G1]], align 4
; CHECK-NEXT:    [[A:%.*]] = load i32, ptr [[G1]], align 4
; CHECK-NEXT:    ret i32 [[A]]
;
  store i32 4, ptr @G1
  %a = load i32, ptr @G1
  ret i32 %a
}

; The load comes before the store which makes @G2 live before the call.
define i32 @test2() norecurse {
; CHECK-LABEL: @test2(
; CHECK-NEXT:    [[A_B:%.*]] = load i1, ptr @G2, align 1
; CHECK-NEXT:    [[A:%.*]] = select i1 [[A_B]], i32 4, i32 5
; CHECK-NEXT:    store i1 true, ptr @G2, align 1
; CHECK-NEXT:    ret i32 [[A]]
;
  %a = load i32, ptr @G2
  store i32 4, ptr @G2
  ret i32 %a
}

; This global is indexed by a GEP - this makes it partial alias and we bail out.
; FIXME: We don't actually have to bail out in this case.
define i32 @test3() norecurse {
; CHECK-LABEL: @test3(
; CHECK-NEXT:    [[A_B:%.*]] = load i1, ptr @G3, align 1
; CHECK-NEXT:    [[A:%.*]] = select i1 [[A_B]], i32 4, i32 5
; CHECK-NEXT:    store i1 true, ptr @G3, align 1
; CHECK-NEXT:    ret i32 [[A]]
;
  %a = load i32, ptr @G3
  store i32 4, ptr @G3
  ret i32 %a
}

; The global is casted away to a larger type then loaded. The store only partially
; covers the load, so we must not demote.
define i32 @test4() norecurse {
; CHECK-LABEL: @test4(
; CHECK-NEXT:    store i32 4, ptr @G4, align 4
; CHECK-NEXT:    [[A:%.*]] = load i64, ptr @G4, align 4
; CHECK-NEXT:    [[B:%.*]] = trunc i64 [[A]] to i32
; CHECK-NEXT:    ret i32 [[B]]
;
  store i32 4, ptr @G4
  %a = load i64, ptr @G4
  %b = trunc i64 %a to i32
  ret i32 %b
}

; The global is casted away to a smaller type then loaded. This one is fine.
define i32 @test5() norecurse {
; CHECK-LABEL: @test5(
; CHECK-NEXT:    [[G5:%.*]] = alloca i32, align 4
; CHECK-NEXT:    store i32 5, ptr [[G5]], align 4
; CHECK-NEXT:    store i32 4, ptr [[G5]], align 4
; CHECK-NEXT:    [[A:%.*]] = load i16, ptr [[G5]], align 2
; CHECK-NEXT:    [[B:%.*]] = zext i16 [[A]] to i32
; CHECK-NEXT:    ret i32 [[B]]
;
  store i32 4, ptr @G5
  %a = load i16, ptr @G5
  %b = zext i16 %a to i32
  ret i32 %b
}