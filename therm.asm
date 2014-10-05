;  ID: Jim McKenna, CIS 253 Section 1, Fall
; 
;  PURPOSE: 
;   Interact with the thermometer and LED display to emulate a thermostat
;   controller.
;
;  DESIGN:
;   1. Display the temp and current info.
;   2. Use proc to get min/max temp from user.
;   3. Enter loop, getting temp from thermometer and displaying it to the
;      LED display.
;   4. While in loop, check if temp is above or below min/max.  If so,
;      turn heater on/off as need be.
;   5. Loop.  For.  Ever.
;
;   (See inline comments.)

include 'emu8086.inc'

#start=thermometer.exe#
#start=led_display.exe#

org 100h

mov dx, 0100h                   ; to clear zero flag

in al, 125                      ; grab the temp
out 199, al                     ; send temp to lcd

print 'The current temp is: '   ; print out the console display
mov ah, 00h
call print_num
printn
printn
printn 'Min temp: '
printn 'Max temp: '
call keyhit                     ; call keyhit to get min/max
printn
printn
printn 'The heater is: '
printn
print  '* Press any key to set min and max temps *'

start:

    in al, 125                  ; get temp --> into al
    out 199, al                 ; place temp (al) into lcd
    
    gotoxy 21, 0                ; go to spot on screen
    mov ah, 00h                 ; make sure ah is zeroed
    call print_num              ; print temp (ax)
    mov ah, 01h                 ; 01h in ax for interrupt
    
    cmp dh, dl                  ; clear zero flag - no clear call like CLC... :(
    
    int 16h                     ; check for key press
    jz comp                     ; no press, carry on
    call keyhit                 ; else, call keypress and get new temps
    
    comp:
        cmp al, bl                  ; compare temp and low
        jle low                     ; if below, jump to low
        
        cmp al, bh                  ; compare temp and high
        jge high                    ; if too high, jump to high
        jl ok                       ; else, loop
                
        low:
            mov al, 01h                 ; set al to "on"
            out 127, al                 ; turn heater "on".
            gotoxy 15, 5                ; go to heater line
            print 'On '                 ; inform that it is on
            jmp ok                      ; back to the loop...
        
        high:
            mov al, 00h                 ; same concept as low
            out 127, al                 ; 
            gotoxy 15, 5                ;
            print 'Off'                 ;
            jmp ok                      ;
    
ok: 
    jmp start                   ; endless loop.

ret

;-- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

keyhit proc
    
    gotoxy 10, 2                ; go to low spot
    call scan_num               ; scan for number
    mov bl, cl                  ; mov number into low temp register
    
    gotoxy 10, 3                ; same concept as above
    call scan_num               ;
    mov bh, cl                  ;
    
    ret
keyhit endp

define_scan_num
define_print_num_uns
define_print_num