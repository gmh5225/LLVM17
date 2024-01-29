; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -passes=constraint-elimination -S %s | FileCheck %s

; Tests for using inbounds information from GEPs where the GEP only causes UB in the use blocks.

declare void @noundef(ptr noundef) willreturn nounwind
declare void @noundef2(ptr noundef)

declare void @use(i1)

; %start + %n.ext is guaranteed to not overflow (due to inbounds).
; %start + %idx.ext does not overflow if %idx.ext <= %n.ext.
define i1 @inbounds_poison_is_ub_in_use_block_1(ptr %src, i32 %n, i32 %idx) {
; CHECK-LABEL: @inbounds_poison_is_ub_in_use_block_1(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[N_EXT:%.*]] = zext i32 [[N:%.*]] to i64
; CHECK-NEXT:    [[UPPER:%.*]] = getelementptr inbounds i32, ptr [[SRC:%.*]], i64 [[N_EXT]]
; CHECK-NEXT:    [[CMP_IDX:%.*]] = icmp ult i32 [[IDX:%.*]], [[N]]
; CHECK-NEXT:    [[IDX_EXT:%.*]] = zext i32 [[IDX]] to i64
; CHECK-NEXT:    [[SRC_IDX:%.*]] = getelementptr i32, ptr [[SRC]], i64 [[IDX_EXT]]
; CHECK-NEXT:    br i1 [[CMP_IDX]], label [[THEN:%.*]], label [[ELSE:%.*]]
; CHECK:       then:
; CHECK-NEXT:    call void @noundef(ptr [[UPPER]])
; CHECK-NEXT:    [[CMP_UPPER_1:%.*]] = icmp ule ptr [[SRC_IDX]], [[UPPER]]
; CHECK-NEXT:    ret i1 [[CMP_UPPER_1]]
; CHECK:       else:
; CHECK-NEXT:    [[CMP_UPPER_2:%.*]] = icmp ule ptr [[SRC_IDX]], [[UPPER]]
; CHECK-NEXT:    ret i1 [[CMP_UPPER_2]]
;
entry:
  %n.ext = zext i32 %n to i64
  %upper = getelementptr inbounds i32, ptr %src, i64 %n.ext
  %cmp.idx = icmp ult i32 %idx, %n
  %idx.ext = zext i32 %idx to i64
  %src.idx = getelementptr i32, ptr %src, i64 %idx.ext
  br i1 %cmp.idx, label %then, label %else

then:
  call void @noundef(ptr %upper)
  %cmp.upper.1 = icmp ule ptr %src.idx, %upper
  ret i1 %cmp.upper.1

else:
  %cmp.upper.2 = icmp ule ptr %src.idx, %upper
  ret i1 %cmp.upper.2
}

define i1 @inbounds_poison_is_ub_in_use_block_2(ptr %src, i32 %n, i32 %idx, i1 %c) {
; CHECK-LABEL: @inbounds_poison_is_ub_in_use_block_2(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[N_EXT:%.*]] = zext i32 [[N:%.*]] to i64
; CHECK-NEXT:    [[UPPER:%.*]] = getelementptr inbounds i32, ptr [[SRC:%.*]], i64 [[N_EXT]]
; CHECK-NEXT:    [[CMP_IDX:%.*]] = icmp ult i32 [[IDX:%.*]], [[N]]
; CHECK-NEXT:    [[IDX_EXT:%.*]] = zext i32 [[IDX]] to i64
; CHECK-NEXT:    [[SRC_IDX:%.*]] = getelementptr i32, ptr [[SRC]], i64 [[IDX_EXT]]
; CHECK-NEXT:    br i1 [[CMP_IDX]], label [[THEN:%.*]], label [[ELSE:%.*]]
; CHECK:       then:
; CHECK-NEXT:    [[CMP_UPPER_1:%.*]] = icmp ule ptr [[SRC_IDX]], [[UPPER]]
; CHECK-NEXT:    call void @noundef(ptr [[UPPER]])
; CHECK-NEXT:    ret i1 [[CMP_UPPER_1]]
; CHECK:       else:
; CHECK-NEXT:    [[CMP_UPPER_2:%.*]] = icmp ule ptr [[SRC_IDX]], [[UPPER]]
; CHECK-NEXT:    ret i1 [[CMP_UPPER_2]]
;
entry:
  %n.ext = zext i32 %n to i64
  %upper = getelementptr inbounds i32, ptr %src, i64 %n.ext
  %cmp.idx = icmp ult i32 %idx, %n
  %idx.ext = zext i32 %idx to i64
  %src.idx = getelementptr i32, ptr %src, i64 %idx.ext
  br i1 %cmp.idx, label %then, label %else

then:
  %cmp.upper.1 = icmp ule ptr %src.idx, %upper
  call void @noundef(ptr %upper)
  ret i1 %cmp.upper.1

else:
  %cmp.upper.2 = icmp ule ptr %src.idx, %upper
  ret i1 %cmp.upper.2
}

declare void @llvm.assume(i1)

; %start + %n.ext is guaranteed to not overflow (due to inbounds).
; %start + %idx.ext does not overflow if %idx.ext <= %n.ext.
define i1 @inbounds_poison_is_ub_in_use_block_by_assume(ptr %src, i32 %n, i32 %idx) {
; CHECK-LABEL: @inbounds_poison_is_ub_in_use_block_by_assume(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[N_EXT:%.*]] = zext i32 [[N:%.*]] to i64
; CHECK-NEXT:    [[UPPER:%.*]] = getelementptr inbounds i32, ptr [[SRC:%.*]], i64 [[N_EXT]]
; CHECK-NEXT:    [[CMP_IDX:%.*]] = icmp ult i32 [[IDX:%.*]], [[N]]
; CHECK-NEXT:    [[IDX_EXT:%.*]] = zext i32 [[IDX]] to i64
; CHECK-NEXT:    [[SRC_IDX:%.*]] = getelementptr i32, ptr [[SRC]], i64 [[IDX_EXT]]
; CHECK-NEXT:    br i1 [[CMP_IDX]], label [[THEN:%.*]], label [[ELSE:%.*]]
; CHECK:       then:
; CHECK-NEXT:    [[CMP_NE:%.*]] = icmp ule ptr null, [[UPPER]]
; CHECK-NEXT:    call void @llvm.assume(i1 [[CMP_NE]])
; CHECK-NEXT:    [[CMP_UPPER_1:%.*]] = icmp ule ptr [[SRC_IDX]], [[UPPER]]
; CHECK-NEXT:    ret i1 [[CMP_UPPER_1]]
; CHECK:       else:
; CHECK-NEXT:    [[CMP_UPPER_2:%.*]] = icmp ule ptr [[SRC_IDX]], [[UPPER]]
; CHECK-NEXT:    ret i1 [[CMP_UPPER_2]]
;
entry:
  %n.ext = zext i32 %n to i64
  %upper = getelementptr inbounds i32, ptr %src, i64 %n.ext
  %cmp.idx = icmp ult i32 %idx, %n
  %idx.ext = zext i32 %idx to i64
  %src.idx = getelementptr i32, ptr %src, i64 %idx.ext
  br i1 %cmp.idx, label %then, label %else

then:
  %cmp.ne = icmp ule ptr null, %upper
  call void @llvm.assume(i1 %cmp.ne)
  %cmp.upper.1 = icmp ule ptr %src.idx, %upper
  ret i1 %cmp.upper.1

else:
  %cmp.upper.2 = icmp ule ptr %src.idx, %upper
  ret i1 %cmp.upper.2
}


; %start + %n.ext is guaranteed to not overflow (due to inbounds).
; %start + %idx.ext does not overflow if %idx.ext <= %n.ext.
define i1 @inbounds_poison_is_ub_in_in_multiple_use_blocks_1(ptr %src, i32 %n, i32 %idx, i1 %c) {
; CHECK-LABEL: @inbounds_poison_is_ub_in_in_multiple_use_blocks_1(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[N_EXT:%.*]] = zext i32 [[N:%.*]] to i64
; CHECK-NEXT:    [[UPPER:%.*]] = getelementptr inbounds i32, ptr [[SRC:%.*]], i64 [[N_EXT]]
; CHECK-NEXT:    br i1 [[C:%.*]], label [[CHECK_BB:%.*]], label [[EXIT:%.*]]
; CHECK:       check.bb:
; CHECK-NEXT:    call void @noundef(ptr [[UPPER]])
; CHECK-NEXT:    [[CMP_IDX:%.*]] = icmp ult i32 [[IDX:%.*]], [[N]]
; CHECK-NEXT:    [[IDX_EXT:%.*]] = zext i32 [[IDX]] to i64
; CHECK-NEXT:    [[SRC_IDX:%.*]] = getelementptr i32, ptr [[SRC]], i64 [[IDX_EXT]]
; CHECK-NEXT:    br i1 [[CMP_IDX]], label [[THEN:%.*]], label [[ELSE:%.*]]
; CHECK:       then:
; CHECK-NEXT:    call void @noundef(ptr [[UPPER]])
; CHECK-NEXT:    [[CMP_UPPER_1:%.*]] = icmp ule ptr [[SRC_IDX]], [[UPPER]]
; CHECK-NEXT:    ret i1 [[CMP_UPPER_1]]
; CHECK:       else:
; CHECK-NEXT:    [[CMP_UPPER_2:%.*]] = icmp ule ptr [[SRC_IDX]], [[UPPER]]
; CHECK-NEXT:    ret i1 [[CMP_UPPER_2]]
; CHECK:       exit:
; CHECK-NEXT:    ret i1 false
;
entry:
  %n.ext = zext i32 %n to i64
  %upper = getelementptr inbounds i32, ptr %src, i64 %n.ext
  br i1 %c, label %check.bb, label %exit

check.bb:
  call void @noundef(ptr %upper)
  %cmp.idx = icmp ult i32 %idx, %n
  %idx.ext = zext i32 %idx to i64
  %src.idx = getelementptr i32, ptr %src, i64 %idx.ext
  br i1 %cmp.idx, label %then, label %else

then:
  call void @noundef(ptr %upper)
  %cmp.upper.1 = icmp ule ptr %src.idx, %upper
  ret i1 %cmp.upper.1

else:
  %cmp.upper.2 = icmp ule ptr %src.idx, %upper
  ret i1 %cmp.upper.2

exit:
  ret i1 false
}

define i1 @may_exit_before_ub_is_caused(ptr %src, i32 %n, i32 %idx) {
; CHECK-LABEL: @may_exit_before_ub_is_caused(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[N_EXT:%.*]] = zext i32 [[N:%.*]] to i64
; CHECK-NEXT:    [[UPPER:%.*]] = getelementptr inbounds i32, ptr [[SRC:%.*]], i64 [[N_EXT]]
; CHECK-NEXT:    [[CMP_IDX:%.*]] = icmp ult i32 [[IDX:%.*]], [[N]]
; CHECK-NEXT:    [[IDX_EXT:%.*]] = zext i32 [[IDX]] to i64
; CHECK-NEXT:    [[SRC_IDX:%.*]] = getelementptr i32, ptr [[SRC]], i64 [[IDX_EXT]]
; CHECK-NEXT:    br i1 [[CMP_IDX]], label [[THEN:%.*]], label [[ELSE:%.*]]
; CHECK:       then:
; CHECK-NEXT:    [[CMP_UPPER_1:%.*]] = icmp ule ptr [[SRC_IDX]], [[UPPER]]
; CHECK-NEXT:    call void @use(i1 [[CMP_UPPER_1]])
; CHECK-NEXT:    call void @noundef(ptr [[UPPER]])
; CHECK-NEXT:    ret i1 [[CMP_UPPER_1]]
; CHECK:       else:
; CHECK-NEXT:    [[CMP_UPPER_2:%.*]] = icmp ule ptr [[SRC_IDX]], [[UPPER]]
; CHECK-NEXT:    ret i1 [[CMP_UPPER_2]]
;
entry:
  %n.ext = zext i32 %n to i64
  %upper = getelementptr inbounds i32, ptr %src, i64 %n.ext
  %cmp.idx = icmp ult i32 %idx, %n
  %idx.ext = zext i32 %idx to i64
  %src.idx = getelementptr i32, ptr %src, i64 %idx.ext
  br i1 %cmp.idx, label %then, label %else

then:
  %cmp.upper.1 = icmp ule ptr %src.idx, %upper
  call void @use(i1 %cmp.upper.1);
  call void @noundef(ptr %upper)
  ret i1 %cmp.upper.1

else:
  %cmp.upper.2 = icmp ule ptr %src.idx, %upper
  ret i1 %cmp.upper.2
}

define i1 @only_UB_in_false_block(ptr %src, i32 %n, i32 %idx) {
; CHECK-LABEL: @only_UB_in_false_block(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[N_EXT:%.*]] = zext i32 [[N:%.*]] to i64
; CHECK-NEXT:    [[UPPER:%.*]] = getelementptr inbounds i32, ptr [[SRC:%.*]], i64 [[N_EXT]]
; CHECK-NEXT:    [[CMP_IDX:%.*]] = icmp ult i32 [[IDX:%.*]], [[N]]
; CHECK-NEXT:    [[IDX_EXT:%.*]] = zext i32 [[IDX]] to i64
; CHECK-NEXT:    [[SRC_IDX:%.*]] = getelementptr i32, ptr [[SRC]], i64 [[IDX_EXT]]
; CHECK-NEXT:    br i1 [[CMP_IDX]], label [[THEN:%.*]], label [[ELSE:%.*]]
; CHECK:       then:
; CHECK-NEXT:    [[CMP_UPPER_1:%.*]] = icmp ule ptr [[SRC_IDX]], [[UPPER]]
; CHECK-NEXT:    ret i1 [[CMP_UPPER_1]]
; CHECK:       else:
; CHECK-NEXT:    call void @noundef(ptr [[UPPER]])
; CHECK-NEXT:    [[CMP_UPPER_2:%.*]] = icmp ule ptr [[SRC_IDX]], [[UPPER]]
; CHECK-NEXT:    ret i1 [[CMP_UPPER_2]]
;
entry:
  %n.ext = zext i32 %n to i64
  %upper = getelementptr inbounds i32, ptr %src, i64 %n.ext
  %cmp.idx = icmp ult i32 %idx, %n
  %idx.ext = zext i32 %idx to i64
  %src.idx = getelementptr i32, ptr %src, i64 %idx.ext
  br i1 %cmp.idx, label %then, label %else

then:
  %cmp.upper.1 = icmp ule ptr %src.idx, %upper
  ret i1 %cmp.upper.1

else:
  call void @noundef(ptr %upper)
  %cmp.upper.2 = icmp ule ptr %src.idx, %upper
  ret i1 %cmp.upper.2
}

define i1 @only_ub_by_assume_in_false_block(ptr %src, i32 %n, i32 %idx) {
; CHECK-LABEL: @only_ub_by_assume_in_false_block(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[N_EXT:%.*]] = zext i32 [[N:%.*]] to i64
; CHECK-NEXT:    [[UPPER:%.*]] = getelementptr inbounds i32, ptr [[SRC:%.*]], i64 [[N_EXT]]
; CHECK-NEXT:    [[CMP_IDX:%.*]] = icmp ult i32 [[IDX:%.*]], [[N]]
; CHECK-NEXT:    [[IDX_EXT:%.*]] = zext i32 [[IDX]] to i64
; CHECK-NEXT:    [[SRC_IDX:%.*]] = getelementptr i32, ptr [[SRC]], i64 [[IDX_EXT]]
; CHECK-NEXT:    br i1 [[CMP_IDX]], label [[THEN:%.*]], label [[ELSE:%.*]]
; CHECK:       then:
; CHECK-NEXT:    [[CMP_UPPER_1:%.*]] = icmp ule ptr [[SRC_IDX]], [[UPPER]]
; CHECK-NEXT:    ret i1 [[CMP_UPPER_1]]
; CHECK:       else:
; CHECK-NEXT:    [[CMP_NE:%.*]] = icmp ule ptr null, [[UPPER]]
; CHECK-NEXT:    call void @llvm.assume(i1 [[CMP_NE]])
; CHECK-NEXT:    [[CMP_UPPER_2:%.*]] = icmp ule ptr [[SRC_IDX]], [[UPPER]]
; CHECK-NEXT:    ret i1 [[CMP_UPPER_2]]
;
entry:
  %n.ext = zext i32 %n to i64
  %upper = getelementptr inbounds i32, ptr %src, i64 %n.ext
  %cmp.idx = icmp ult i32 %idx, %n
  %idx.ext = zext i32 %idx to i64
  %src.idx = getelementptr i32, ptr %src, i64 %idx.ext
  br i1 %cmp.idx, label %then, label %else

then:
  %cmp.upper.1 = icmp ule ptr %src.idx, %upper
  ret i1 %cmp.upper.1

else:
  %cmp.ne = icmp ule ptr null, %upper
  call void @llvm.assume(i1 %cmp.ne)
  %cmp.upper.2 = icmp ule ptr %src.idx, %upper
  ret i1 %cmp.upper.2
}