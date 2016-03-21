!@teleport $lib/range=me
!@program RangeLibrary
1 99999 delete
1 insert
( RangeLibrary: $Date: 2016/03/21 15:20:46 $ $Revision: 1.2 $                                             )
( Purpose: Collection of words to perform operations with ranges.             )
( Author: Feaelin [Iain E. Davis]                                             )
( --------------------------------------------------------------------------- )
( rangeCat    [ {range} {range} --> {range} ]                                 )
(             Concatenates/combines two ranges on the top of the stack into 1 )
( rangeDup    [ {range} --> {range} {range} ]                                 )
(             Duplicates the range on top of the stack.                       )
( rangePop    [ {range} --> ]                                                 )
(             Removes a range from the top of the stack.                      )
( rangeRotate [ {range} ? ? ? ... ? depthOfRange --> ? ? ? ... ? {range} ]    )
(             rotates a range buried in the stack to the top of the stack     )
 
: rangePop ( {range} --> )
  popn
; public rangePop
 
: rangeCat ( {range1} {range2} --> {combined} )
  dup 2 + rotate +
; public rangeCat
 
: rangeDup ( {range} --> {range} {range} )
  0                                                                              ( item1 item2 item3 ... itemN N 0 )
  BEGIN dup 2 + pick over = not WHILE                                            ( item1 item2 item3 ... itemN N 0 )
    dup 2 + pick over -                                                          ( item1 item2 item3 ... itemN N c1 c2 c3 ... cX X N-X )
    over 2 + + pick                                                              ( item1 item2 item3 ... itemN N c1 c2 c3 ... cX X nextItem )
    swap 1 +                                                                     ( item1 item2 item3 ... itemN N c1 c2 c3 ... cX nextItem X+1 )
  REPEAT
; public rangeDup
 
: rangeRotate ( {range} ? ? ? ... ? rangeDepth --> ? ? ? ... ? {range} )
 depth popn
; public rangeRotate
.
compile
quit
@register RangeLibrary=lib/range
!@set $lib/range=/_lib-version:$Revision: 1.2 $
!@set $lib/range=/_defs/rangeCat:"$lib/range" match "rangeCat" call
!@set $lib/range=/_defs/rangeDup:"$lib/range" match "rangeDup" call
!@set $lib/range=/_defs/rangePop:"$lib/range" match "rangePop" call
!@set $lib/range=/_defs/rangeRotate:"$lib/range" match "rangeRotate" call
!@teleport $lib/range=#0

whisper me=--------------------------------------------------------------------------------
whisper me=Test Suite
whisper me=--------------------------------------------------------------------------------

!@program RangeLibraryTests
1 99999 delete
1 insert
( RangeLibraryTests: $Date: 2016/03/21 15:20:46 $ $Revision: 1.2 $                                        )
( Purpose: Testing Suite for RangeLibrary                                     )
( Author: Feaelin [Iain E. Davis]                                             )
( --------------------------------------------------------------------------- )

$include $lib/range 
 
: failureNotify ( message -> )
  me @ swap "^FAIL^FAILURE: " swap strcat ansi_notify
;

: checkThatStackIsClean ( testName --> )
  depth 1 = not if
    ": stack is not empty at the beginning of test." strcat failureNotify 1
  then
  pop
  0
;
 
: cleanup ( ? --> )
  depth popn
;
 
: rangeCatHandlesTwoEmptyRanges ( --> )
  0 0 rangeCat
  depth 1 = not if
    "rangeCatHandlesTwoEmptyRanges: Stack should have exactly one item after executing rangeCat." failureNotify cleanup exit
  then
  0 = not if
    "rangeCatHandlesTwoEmptyRanges: Resulting range should be empty." failureNotify cleanup exit
  then  
;
 
: rangeCatHandlesTopRangeEmpty ( --> )
  #5 #3 #7 3 0 rangeCat
  depth 4 = not if
    "rangeCatHandlesTopRangeEmpty: Stack should have exactly four items after executing rangeCat." failureNotify cleanup exit
  then
  3 = not if
    "rangeCatHandlesTopRangeEmpty: new range should have a size of 3." failureNotify cleanup exit
  then
  #7 dbcmp swap #3 dbcmp and swap #5 dbcmp and not if
    "rangeCatHandlesTopRangeEmpty: rangeCat altered the order of the range." failureNotify cleanup exit
  then
;

: rangeCatHandlesBottomRangeEmpty ( --> )
  0 #5 #3 #7 3 rangeCat
  depth 4 = not if
    "rangeCatHandlesBottomRangeEmpty: Stack should have exactly four items after executing rangeCat." failureNotify cleanup exit
  then
  3 = not if
    "rangeCatHandlesBottomRangeEmpty: new range should have a size of 3." failureNotify cleanup exit
  then
  #7 dbcmp swap #3 dbcmp and swap #5 dbcmp and not if
    "rangeCatHandlesBottomRangeEmpty: rangeCat altered the order of the range." failureNotify cleanup exit
  then
;
 
: rangeCatConcatenateTwoPopulatedRanges ( --> )
  #5 #7 #3 3 #2 #4 #6 #8 #10 5 rangeCat
  depth 9 = not if
    "rangeCatConcatenateTwoPopulatedRanges: Stack should have exactly nine items after executing rangeCat." failureNotify cleanup exit
  then
  8 = not if
    "rangeCatConcatenateTwoPopulatedRanges: new range should have a size of 8." failureNotify cleanup exit
  then
  #10 dbcmp swap #8 dbcmp and swap #6 dbcmp and swap #4 dbcmp and swap #2 dbcmp and not if
    "rangeCatConcatenateTwoPopulatedRanges: rangeCat changed the order of the second range." failureNotify cleanup exit
  then
  #3 dbcmp swap #7 dbcmp and swap #5 dbcmp and not if
    "rangeCatConcatenateTwoPopulatedRanges: rangeCat changed the order of the first range." failureNotify cleanup exit
  then
;
 
: rangeCatTests ( --> )
  rangeCatHandlesTwoEmptyRanges cleanup
  rangeCatHandlesBottomRangeEmpty cleanup
  rangeCatHandlesTopRangeEmpty cleanup
  rangeCatConcatenateTwoPopulatedRanges cleanup
;
 
: rangeDupDupsZero ( --> )
  "rangeDupDupsZero" checkThatStackIsClean if exit then

  0 rangeDup

  depth 2 = not if
    "rangeDupDupsZero: stack should have exactly two stack items after executing rangeDup." failureNotify cleanup exit
  then

  dup int? not if
    "rangeDupDupsZero: top stack item (the copy's range size) was not an integer." failureNotify cleanup exit
  then
  over int? not if
    "rangeDupDupsZero: bottom stack item (the original's range size) was not an integer." failureNotify cleanup exit
  then
  dup 0 = not if
    "rangeDupDupsZero: top stack item (the copy's range size) was not zero." failureNotify cleanup exit
  then
  = not if
    "rangeDupDupsZero: bottom stack item (the original's range size) was not zero." failureNotify cleanup exit
  then
;
 
: rangeDupDupsOne
  "rangeDupDupsOne" checkThatStackIsClean if cleanup exit then
  
  #1 1 rangeDup

  depth 4 = not if
    "rangeDupDupsOne: stack should have exactly four stack items after executing rangeDup." failureNotify cleanup exit
  then

  dup int? not if
    "rangeDupDupsOne: the copy's count is missing." failureNotify cleanup exit
  then

  1 = not if
    "rangeDupDupsOne: the copy's count is wrong." failureNotify cleanup exit
  then  

  dup dbref? not if
    "rangeDupDupsOne: the copy's content is missing." failureNotify cleanup exit
  then
  
  #1 dbcmp not if
    "rangeDupDupsOne: the copy's content is present but wrong." failureNotify cleanup exit
  then

  dup int? not if
    "rangeDupDupsOne: the original's count is missing." failureNotify cleanup exit
  then

  1 = not if
    "rangeDupDupsOne: the original's count is wrong." failureNotify cleanup exit
  then

  dup dbref? not if
    "rangeDupDupsOne: the original's content is missing." failureNotify cleanup exit
  then

  #1 dbcmp not if
    "rangeDupDupsOne: the original's content is present but wrong." failureNotify cleanup exit
  then
;
 
: rangeDupDupsMany ( --> )
  #1 #5 #3 #7 #2 5 rangeDup
  depth 12 = not if
    "rangeDupDupsMany: the number of items (" depth 1 - intostr strcat ") on the stack is wrong." strcat failureNotify cleanup exit
  then
  
  3 pick #7 dbcmp not if
    "rangeDupDupsMany: 4th item is wrong (order of the range may have been altered)." failureNotify cleanup exit
  then
;
 
: rangeDupTests
  rangeDupDupsZero cleanup
  rangeDupDupsOne cleanup
  rangeDupDupsMany cleanup
;
 
: rangePopShouldNotPopMoreThanTheRange
  "something" #1 #2 #3 3 rangePop
  depth 1 = not if "rangePop popped more than it should." failureNotify cleanup then
  pop
;
 
: rangePopPopsRange ( --> )
  "foo" "bar" "baz" 3 rangePop
  depth 0 = not if "rangePop left items on the stack." failureNotify cleanup then
;
 
: rangePopPopsTWo ( --> )
  #1 #2 2 rangePop
  depth 0 = not if "rangePop left items on the stack." failureNotify cleanup then
; 
 
: rangePopPopsOne ( --> )
  #1 1 rangePop
  depth 0 = not if "rangePop left items on the stack." failureNotify cleanup then
; 

: rangePopTests ( --> )
  rangePopPopsRange cleanup
  rangePopPopsOne cleanup
  rangePopPopsTwo cleanup
  rangePopShouldNotPopMoreThanTheRange cleanup
;
 
: main ( argumentString --> )
  pop
  rangePopTests
  rangeDupTests
  rangeCatTests
;
.
compile
quit
!@action testRangeLibrary=me=temporary/testRangeLibrary
!@success $temporary/testRangeLibrary=Running tests...
!@link $temporary/testRangeLibrary=RangeLibraryTests
!@set RangeLibraryTests=!z
testRangeLibrary
!@recycle $temporary/testRangeLibrary
!@recycle RangeLibraryTests
!@set me=/_reg/temporary:
