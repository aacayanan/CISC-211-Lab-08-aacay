/*** asmMult.s   ***/
/* Tell the assembler to allow both 16b and 32b extended Thumb instructions */
.syntax unified

#include <xc.h>

/* Tell the assembler that what follows is in data memory    */
.data
.align
 
/* define and initialize global variables that C can access */

.global a_Multiplicand,b_Multiplier,rng_Error,a_Sign,b_Sign,prod_Is_Neg,a_Abs,b_Abs,init_Product,final_Product
.type a_Multiplicand,%gnu_unique_object
.type b_Multiplier,%gnu_unique_object
.type rng_Error,%gnu_unique_object
.type a_Sign,%gnu_unique_object
.type b_Sign,%gnu_unique_object
.type prod_Is_Neg,%gnu_unique_object
.type a_Abs,%gnu_unique_object
.type b_Abs,%gnu_unique_object
.type init_Product,%gnu_unique_object
.type final_Product,%gnu_unique_object

/* NOTE! These are only initialized ONCE, right before the program runs.
 * If you want these to be 0 every time asmMult gets called, you must set
 * them to 0 at the start of your code!
 */
a_Multiplicand:  .word     0  
b_Multiplier:    .word     0  
rng_Error:       .word     0  
a_Sign:          .word     0  
b_Sign:          .word     0 
prod_Is_Neg:     .word     0  
a_Abs:           .word     0  
b_Abs:           .word     0 
init_Product:    .word     0
final_Product:   .word     0

 /* Tell the assembler that what follows is in instruction memory    */
.text
.align

    
/********************************************************************
function name: asmMult
function description:
     output = asmMult ()
     
where:
     output: 
     
     function description: The C call ..........
     
     notes:
        None
          
********************************************************************/    
.global asmMult
.type asmMult,%function
asmMult:   

    /* save the caller's registers, as required by the ARM calling convention */
    push {r4-r11,LR}
 
.if 0
    /* profs test code. */
    mov r0,r0
.endif
    
    /** note to profs: asmMult.s solution is in Canvas at:
     *    Canvas Files->
     *        Lab Files and Coding Examples->
     *            Lab 8 Multiply
     * Use it to test the C test code */
    
    /*** STUDENTS: Place your code BELOW this line!!! **************/
    
    /* initialize all variables to 0 */
    mov r4, #0
    ldr r5, =a_Multiplicand
    str r4, [r5]
    ldr r5, =b_Multiplier
    str r4, [r5]
    ldr r5, =rng_Error
    str r4, [r5]
    ldr r5, =a_Sign
    str r4, [r5]
    ldr r5, =b_Sign
    str r4, [r5]
    ldr r5, =prod_Is_Neg
    str r4, [r5]
    ldr r5, =a_Abs
    str r4, [r5]
    ldr r5, =b_Abs
    str r4, [r5]
    ldr r5, =init_Product
    str r4, [r5]
    ldr r5, =final_Product
    str r4, [r5]
    
    /* copy r0 to a_Multiplicand, r1 to b_Multiplier */
    ldr r4, =a_Multiplicand
    str r0, [r4]
    ldr r4, =b_Multiplier
    str r1, [r4]
    
    /* check if r0 or r1 exceeds 16bit signed range */
    // check for r0
    mov r5, r0
    mov r6, r1
    asr r5, r5, #15
    cmp r5, #0
    beq a_in_range
    cmp r5, #0xFFFFFFFF
    beq a_in_range
    
    b out_of_range
    
a_in_range:
    // now for r1, checked if 'a' is in range
    asr r6, r6, #15
    cmp r6, #0
    beq in_range
    cmp r6, #0xFFFFFFFF
    beq in_range

    b out_of_range
    
in_range:   // checked that both 'a' and 'b' are in range
    /* store sign bits in respective location */
    // a_Multiplicand, a_Sign
    mov r7, #1
    ands r7, r5, r7
    ldr r8, =a_Sign
    str r7, [r8]
    
    // b_Multiplier, b_Sign
    mov r7, #1
    ands r7, r6, r7
    ldr r8, =b_Sign
    str r7, [r8]
    
    /* decide final output sign */
    ldr r5, =a_Sign
    ldr r5, [r5]
    ldr r6, =b_Sign
    ldr r6, [r6]
    eor r7, r5, r6
    ldr r8, =prod_Is_Neg
    str r7, [r8]
    
    // if either r0 or r1 is zero, then product is positive
    mov r5, r0
    cmp r5, #0
    beq set_to_pos
    mov r6, r1
    cmp r6, #0
    beq set_to_pos
    b end_zero_check
    
end_zero_check:
    /* store absolute values in respective locations */
    // start with r0
    mov r5, r0
    cmp r5, #0
    rsblt r5, r5, #0
    ldr r4, =a_Abs
    str r5, [r4]
    
    // now for r1
    mov r5, r1
    cmp r5, #0
    rsblt r5, r5, #0
    ldr r4, =b_Abs
    str r5, [r4]
    
    /* multiply using shift-and-add */
    ldr r4, =a_Abs
    ldr r4, [r4]
    ldr r5, =b_Abs
    ldr r5, [r5]
    mov r8, #0
    
    mov r6, #0
    mov r7, #1
    
iterate:    // procedes to iterate if multiplier is not zero
    cmp r5, #0
    beq store
    
    ands r9, r5, r7
    bne adding
    
add_ret:    // does appropriate shifts
    lsr r5, r5, #1
    lsl r4, r4, #1
    b iterate
    
adding:	    // responsible for adding to the product result
    add r8, r8, r4
    b add_ret
    
store:	    // stores the product
    ldr r9, =init_Product
    str r8, [r9]
    ldr r4, =prod_Is_Neg
    ldr r4, [r4]
    cmp r4, #1	    // checks if final result should be negative
    beq final_prod_neg
    ldr r5, =final_Product
    str r8, [r5]
    /* copy final result to r0 */
    mov r0, r8
    
    b done
    
final_prod_neg:	    // if final result is negative
    rsb r8, r8, #0
    ldr r5, =final_Product
    str r8, [r5]
    /* copy final result to r0 */
    mov r0, r8
    
    b done
    
set_to_pos:	// if either r0 or r1 is zero, then product is positive
    mov r4, #0
    str r4, [r8]
    b end_zero_check

out_of_range:
    /* if out of range, set rng_Error to 1, r0 to 0, and exit */
    mov r4, #1
    ldr r5, =rng_Error
    str r4, [r5]
    b done
    
    
    /*** STUDENTS: Place your code ABOVE this line!!! **************/

done:    
    /* restore the caller's registers, as required by the 
     * ARM calling convention 
     */
    mov r0,r0 /* these are do-nothing lines to deal with IDE mem display bug */
    mov r0,r0 

screen_shot:    pop {r4-r11,LR}

    mov pc, lr	 /* asmMult return to caller */
   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           




