[ORG 0x100]
jmp start
             snake_length: dw 4
             snake: db 'o---'
             snake_location: dw 1994
			 row: dw 0
			 col: dw 0
			 starting_msg: db 'SNAKE GAME              ',0
			 score_string: db 'score',0
			 ending_msg: db 'OOPS GAME OVER',0
			 rules:db 'Rules',0
			 rule1: db 'control snake with arrow keys',0
			 rule2: db 'Avoid collision with wall and snake itself',0
			 rule3: db 'score will be incremented by one when snake eat food',0
			 design: db 'Designed by',0
			 roll_n01:db '21F-9132',0
			  roll_n02:db '21F-9214',0
			 score_count: dw 0
			 food_location: dw 0
			 tail_of_snake: dw 0


;;;;;;;;;;;clearing screen;;;;;;;;;;;;;;;;;;;;;
clrscr:                                         
    push ax
    push di
    push es

    mov ax,0xb800
    mov es,ax
    mov di,0

  nextloc:
      mov word[es:di],0x0720
      add di,2
      cmp di,4000
     jne nextloc
  
   pop es
   pop di
   pop ax
   ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;calculating length;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

strlen:
       push bp
       mov bp,sp
       push es
       push cx
       push di

       les di,[bp+4]
       mov cx,0xffff
       xor al,al

       repne scasb
       mov ax,0xffff
       sub ax,cx
       sub ax,1

       pop di
       pop cx
       pop es
       pop bp
	ret 4

   

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;print string;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

printstr:
      push bp
      mov bp,sp
      push es
      push ax
      push cx
      push si
      push di

      push ds
      mov ax,[bp+4]
      push ax
      call strlen

      cmp ax,0
      jz exitch
      mov cx,ax

      mov ax,0xb800
      mov es,ax
      mov ax,80
      mul byte[bp+8]
      add ax,[bp+10]
      shl ax,1
      mov di,ax
      mov si,[bp+4]
      mov ah,[bp+6]

      cld
    nextchar:
           lodsb
           stosw
           loop nextchar

    exitch:  
          pop di
          pop si
          pop cx
          pop ax
          pop es
          pop bp
   ret 8


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;score printing;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print_score:
       push bp 
       mov bp,sp
       push ax
       push bx
       push cx
       push dx
       push es
       push di
          
          mov ax,[score_count]
          mov bx,10
          mov cx,0
          loop1:
              mov dx,0
              div bx
              add dl,0x30
              push dx
              inc cx
              cmp ax,0
              jnz loop1
         
         mov ax,0xb800
         mov es,ax
         mov ax,80
         mul byte[bp+6]
         add ax,[bp+4]
         shl ax,1
         mov di,ax

         nextnum:
              pop dx
              mov dh,0x0f
              mov [es:di],dx
              add di,2
              loop nextnum
        
        pop di
        pop es
        pop dx
        pop cx
        pop bx
        pop dx
        pop bp

     ret 4


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;printing snake;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
snake_print:
    push bp
	mov bp,sp
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	push es
	mov si,[bp+6]   ;snake
	mov cx,[bp+8]   ;length_of_snake
	 mov ax,80
	 mov dx,9
	mul dx
	 add ax,22
	 shl ax,1
	 mov di,ax         ;location in di
	mov ax,0xb800
	mov es,ax
	mov bx,[bp+4]
	mov ah,0x0f
snake_next_char:
    mov al,[si]
	mov [es:di],ax
	mov [bx],di    ;changing location
	inc si
	add bx,2
	add di,2
	loop snake_next_char
	
pop es
pop di
pop si
pop dx
pop cx
pop bx
pop ax 
pop bp
ret 6


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;boarder;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

boarder_printing:
         push ax
         push bx
         push cx
         push dx
         push es
         push di

              mov ax,0xb800
              mov es,ax
              mov di,0
              mov ax,0x0f2b

              left:
                 mov word[es:di],ax
                 add di,160
                 cmp di,4000
                 jb left

             mov di,158
             right:
                 mov word[es:di],ax
                 add di,160
                 cmp di,4000
                 jb right

            mov al,0x2b
            mov di,3840
            down:
                  mov word[es:di],ax
                  add di,2
                  cmp di,4000
                  jb down

            mov di,0
            up:
                 mov word[es:di],ax
                 add di,2
                 cmp di,158
                 jb up

        pop di
        pop es
        pop dx
        pop cx
        pop bx
        pop ax
  ret




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;snake upward movement;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

snake_move_up:
      push bp
	  mov bp,sp
	  push ax
	  push bx
	  push cx
	  push dx
	  push es
	  push si
	  push di
	  
	      mov bx,[bp+4]  
	      mov dx,[bx]
	      mov cx,[bp+8]  
	      sub dx,160  
		  
		  
	 check_up_collision:
	        cmp dx,[bx]
	        jne keep_up
			dead_up:
            call finish
			keep_up:
	        add bx,2
			dec cx
	        jnz check_up_collision

	 move_upward:
	        mov si,[bp+6]      
	        mov bx,[bp+4]      
	        mov dx,[bx]
	        sub dx,160
	        mov di,dx
	 
	    mov ax,0xb800
	    mov es,ax

	    mov ah,0x0f
	    mov al,[si]
	    mov [es:di],ax
	    mov cx,[bp+8]
	    mov di,[bx]
	    inc si
		
	    mov ah,0x0f
	    mov al,[si]
	    mov [es:di],ax
	 
	 remaining_snake_up:
	      mov ax,[bx]
	      mov [bx],dx
	      mov dx,ax
	      add bx,2
		  dec cx
	      jnz remaining_snake_up

	      mov di,dx
	      mov ax,0x0720
	      mov [es:di],ax
		  mov word[tail_of_snake],di
		 ; upward_clearing:
		  sub di,160
		  cmp word[es:di],0x0f03
		  je up1
		  mov ax,0xb800
		  mov es,ax
		  mov ax,0x0720
		  mov[es:di],ax
		  up1:
		  mov di,[tail_of_snake]
		  ;downward_clearing:
		  add di,160
		  cmp word[es:di],0x0f03
		  je up2
		  mov ax,0xb800
		  mov es,ax
		  mov ax,0x0720
		  mov[es:di],ax
		  up2:
		  mov di,[tail_of_snake]
		 ; right_clearing:
		  add di,2
		  cmp word[es:di],0x0f03
		  je up3
		  mov ax,0xb800
		  mov es,ax
		  mov ax,0x0720
		  mov[es:di],ax
		  up3:
		  mov di,[tail_of_snake]
		  ;left_clearing:
		  sub di,2
		  cmp word[es:di],0x0f03
		  je up4
		  mov ax,0xb800
		  mov es,ax
		  mov ax,0x0720
		  mov[es:di],ax
		  up4:
		  
		  jmp exit_up
		  

exit_up:
    pop di
	pop si
	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 6
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;snake downward movement;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

snake_move_down:
      push bp
	  mov bp,sp
	  push ax
	  push bx
	  push cx
	  push dx
	  push es
	  push si
	  push di
	  
	     mov bx,[bp+4] 
	     mov dx,[bx]
	     mov cx,[bp+8]  
	     add dx,160    
	check_down_collision:
	        cmp dx,[bx]
	       jne keep_down
		   dead_down:
    call finish
	keep_down:
	        add bx,2
			dec cx
            jnz check_down_collision

	mov_downward:
	        mov si,[bp+6]      
	        mov bx,[bp+4]     
	        mov dx,[bx]
	        add dx,160
	        mov di,dx
	 
	        mov ax,0xb800
	        mov es,ax
	        mov ah,0x0f

	        mov al,[si]
	        mov [es:di],ax
	        mov cx,[bp+8]
	        mov di,[bx]
	        inc si 
			
	        mov ah,0x0f
	        mov al,[si]
	        mov [es:di],ax
	 
	 remaining_snake_down:
	        mov ax,[bx]
	        mov [bx],dx
	        mov dx,ax
	        add bx,2
			dec cx
	        jnz remaining_snake_down

	   mov di,dx
	   mov ax,0x0720
	   mov [es:di],ax
	    mov word[tail_of_snake],di
		 ; upward_clearing:
		  sub di,160
		  cmp word[es:di],0x0f03
		  je down1
		  mov ax,0xb800
		  mov es,ax
		  mov ax,0x0720
		  mov[es:di],ax
		  down1:
		  mov di,[tail_of_snake]
		  ;downward_clearing:
		  add di,160
		  cmp word[es:di],0x0f03
		  je down2
		  mov ax,0xb800
		  mov es,ax
		  mov ax,0x0720
		  mov[es:di],ax
		  down2:
		  mov di,[tail_of_snake]
		 ; right_clearing:
		  add di,2
		  cmp word[es:di],0x0f03
		  je down3
		  mov ax,0xb800
		  mov es,ax
		  mov ax,0x0720
		  mov[es:di],ax
		  down3:
		  mov di,[tail_of_snake]
		  ;left_clearing:
		  sub di,2
		  cmp word[es:di],0x0f03
		  je down4
		  mov ax,0xb800
		  mov es,ax
		  mov ax,0x0720
		  mov[es:di],ax
		  down4:
       jmp exit_down
exit_down:
    pop di
	pop si
	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 6
	 
	 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;snake leftward movement;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

snake_move_left:
      push bp
	  mov bp,sp
	  push ax
	  push bx
	  push cx
	  push dx
	  push es
	  push si
	  push di
	  
	     mov bx,[bp+4]  
	     mov dx,[bx]
	     mov cx,[bp+8]  
	     sub dx,2    
	check_left_collision:
	      cmp dx,[bx]
	      jne keep_left
		  dead_left:
     call finish
	      keep_left:
	      add bx,2
	      dec cx
	      jnz check_left_collision

	mov_toward_left:
	      mov si,[bp+6]      
	      mov bx,[bp+4]       
	      mov dx,[bx]
	      sub dx,2
	      mov di,dx
	 
	    mov ax,0xb800
	    mov es,ax
	    mov ah,0x0f
	    mov al,[si]
	    mov [es:di],ax
	    mov cx,[bp+8]
	    mov di,[bx]
	    inc si
		
	    mov ah,0x0f
	    mov al,[si]
	    mov [es:di],ax
	 
	remaining_snake_left:
	        mov ax,[bx]
	        mov [bx],dx
	        mov dx,ax
	        add bx,2
	        dec cx
	        jnz remaining_snake_left

	    mov di,dx
	    mov ax,0x0720
	    mov [es:di],ax
		 mov word[tail_of_snake],di
		 ; upward_clearing:
		  sub di,160
		  cmp word[es:di],0x0f03
		  je left1
		  mov ax,0xb800
		  mov es,ax
		  mov ax,0x0720
		  mov[es:di],ax
		  left1:
		  mov di,[tail_of_snake]
		  ;downward_clearing:
		  add di,160
		  cmp word[es:di],0x0f03
		  je left2
		  mov ax,0xb800
		  mov es,ax
		  mov ax,0x0720
		  mov[es:di],ax
		  left2:
		  mov di,[tail_of_snake]
		 ; right_clearing:
		  add di,2
		  cmp word[es:di],0x0f03
		  je left3
		  mov ax,0xb800
		  mov es,ax
		  mov ax,0x0720
		  mov[es:di],ax
		  left3:
		  mov di,[tail_of_snake]
		  ;left_clearing:
		  sub di,2
		  cmp word[es:di],0x0f03
		  je left4
		  mov ax,0xb800
		  mov es,ax
		  mov ax,0x0720
		  mov[es:di],ax
		  left4:
		jmp exit_left
exit_left:
    pop di
	pop si
	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 6 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;rightward movement;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


snake_move_right:
      push bp
	  mov bp,sp
	  push ax
	  push bx
	  push cx
	  push dx
	  push es
	  push si
	  push di
	  
	         mov bx,[bp+4] 
	         mov dx,[bx]
	         mov cx,[bp+8]  
	         add dx,2    
	   check_right_collision:
	           cmp dx,[bx]
	            jne keep_right
				dead_right:
    call finish
				keep_right:
	           add bx,2
	           dec cx
	           jnz check_right_collision
			   
	   mov_toward_right:
	           mov si,[bp+6]      
	           mov bx,[bp+4]       
	           mov dx,[bx]
	           add dx,2
	           mov di,dx
	 
	           mov ax,0xb800
	           mov es,ax
	           mov ah,0x0f
	           mov al,[si]
	           mov [es:di],ax
	           mov cx,[bp+8]
	           mov di,[bx]
	           inc si
			   
	           mov ah,0x0f
	           mov al,[si]
	           mov [es:di],ax
	 
	 remaining_snake_right:
	       mov ax,[bx]
	       mov [bx],dx
	       mov dx,ax
	       add bx,2
	       dec cx
	       jnz remaining_snake_right

	       mov di,dx
	       mov ax,0x0720
	       mov [es:di],ax
		    mov word[tail_of_snake],di
		 ; upward_clearing:
		  sub di,160
		  cmp word[es:di],0x0f03
		  je right1
		  mov ax,0xb800
		  mov es,ax
		  mov ax,0x0720
		  mov[es:di],ax
		  right1:
		  mov di,[tail_of_snake]
		  ;downward_clearing:
		  add di,160
		  cmp word[es:di],0x0f03
		  je right2
		  mov ax,0xb800
		  mov es,ax
		  mov ax,0x0720
		  mov[es:di],ax
		  right2:
		  mov di,[tail_of_snake]
		 ; right_clearing:
		  add di,2
		  cmp word[es:di],0x0f03
		  je right3
		  mov ax,0xb800
		  mov es,ax
		  mov ax,0x0720
		  mov[es:di],ax
		  right3:
		  mov di,[tail_of_snake]
		  ;left_clearing:
		  sub di,2
		  cmp word[es:di],0x0f03
		  je right4
		  mov ax,0xb800
		  mov es,ax
		  mov ax,0x0720
		  mov[es:di],ax
		  right4:
		   jmp exit_right
  exit_right:	
    pop di
	pop si
	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 6  	
	  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;keyboard;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


snake_through_keys:
    push ax
	push bx
	push cx
	push dx
	
       keep_moving:
         mov ah,0
	     int 0x16

	        cmp ah,0x48
	        je up_movement

	        cmp ah,0x4B
	        je left_movement

	        cmp ah,0x4D
	        je right_movement

	        cmp ah,0x50
	        je down_movement

	        cmp ah,1
	        jne keep_moving

	      mov ax,0x4c00
	      je exit

    up_movement:
		   push word[snake_length]
		   mov bx,snake
		   push bx
		   mov bx,snake_location
		   push bx
		   call snake_move_up
		   call check_dead_element
		   call check_food_eating_proccess
		   jmp keep_moving

	down_movement:
		   push word[snake_length]
		   mov bx,snake
		   push bx
		   mov bx,snake_location
		   push bx
		   call snake_move_down
		   call check_dead_element
		    call check_food_eating_proccess
		   jmp keep_moving

	left_movement:
		 push word[snake_length]
		 mov bx,snake
	     push bx
		 mov bx,snake_location
		 push bx
		 call snake_move_left
		 call check_dead_element
		  call check_food_eating_proccess
		 jmp keep_moving

	right_movement:
		 push word[snake_length]
		 mov bx,snake
		 push bx
		 mov bx,snake_location
		 push bx
		 call snake_move_right
		 call check_dead_element
		  call check_food_eating_proccess
		 jmp keep_moving

  exit:
	pop bx
	pop ax
	ret
  
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;deadline;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

check_dead_element:
       push ax
	   push bx
	   push cx
	   push dx
	   push di
	   push si
	   push es



    right_dead:
       mov dx,0
       right_collision:
          add dx,160
          cmp dx,4000
          jae left_dead
           cmp [snake_location],dx
           je finish
           ja right_collision

   left_dead:
      mov dx,0      
      left_collision:
          add dx,160
          cmp dx,4000
          jae up_dead
          cmp [snake_location],dx
          je finish
          ja left_collision

   up_dead:     
     mov dx,0
     up_collision:
          add dx,2
          cmp dx,158
          jae down_dead
          cmp [snake_location],dx
          je finish
          ja up_collision

	down_dead:
     mov dx,3840
     down_collision:
          add dx,2
          cmp dx,4000
          jae end
          cmp [snake_location],dx
          je finish
          jb down_collision



finish:
    call clrscr
	
	mov ax,25
    push ax
    mov ax,10
    push ax
    mov ax,0x0f
    push ax
    mov ax,ending_msg
    push ax
    call printstr
	
	
	mov ax,25
    push ax
    mov ax,11
    push ax
    mov ax,0x0f
    push ax
    mov ax,score_string
    push ax
    call printstr

     mov ax,11
     push ax
     mov ax,31
     push ax
     call print_score

	   pop es
	   pop si
	   pop di
	   pop dx
	   pop cx
	   pop bx
	   pop ax

  mov ax,0x4c00
  int 0x21

end:
	   pop es
	   pop si
	   pop di
	   pop dx
	   pop cx
	   pop bx
	   pop ax
ret

;;;;;;;;;;;random by kamla;;;;;;;;;;;;;
random_function:
   push ax
   push cx
   push dx
   loop_of_rand:
   MOV AH, 00h  ; interrupts to get system time        
   INT 1AH      ; CX:DX now hold number of clock ticks since midnight      

   mov  ax, dx
   xor  dx, dx
   mov  cx, 25    
   div  cx      

   mov word[row],dx

 MOV AH, 00h       
   INT 1AH           

   mov  ax, dx
   xor  dx, dx
   mov  cx, 80    
   div  cx      

   mov word[col],dx

  mov ax,[row]
  mov bx,80
  mul bx
 add ax,[col]
 shl ax,1
 
 ;;;;;comparing to check if the random location is other than boarder location;;;;;;;
 check_up_boarder_food_collision:
        mov dx,0
		food_up_collision:
		    cmp ax,dx
			je loop_of_rand
			add dx,2
			cmp dx,160
			jb food_up_collision
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
check_left_boarder_food_collision:
        mov dx,0
		food_left_collision:
		    cmp ax,dx
			je loop_of_rand
			add dx,160
			cmp dx,3840
			jb food_left_collision
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
check_right_boarder_food_collision:
        mov dx,158
		food_right_collision:
		    cmp ax,dx
			je loop_of_rand
			add dx,160
			cmp dx,4000
			jb food_right_collision
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
check_down_boarder_food_collision:
        mov dx,3840
		food_down_collision:
		    cmp ax,dx
			je loop_of_rand
			add dx,2
			cmp dx,4000
			jb food_down_collision
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
 cmp ax,4000
 jg loop_of_rand
 mov di,[snake_location]
 mov bx,0xb800
 mov es,bx
 loop_to_check_food_in_snake:
 cmp word[es:di],0x0f03
 je loop_of_rand
 add di,2
 cmp di,word[tail_of_snake]
 jb loop_to_check_food_in_snake

mov word[food_location],ax

pop dx
pop cx
pop ax
ret

	
;;;;;;;;;;;;;;display food at random position;;;;;;;;;;;;;;

display_food:
    push ax
    push di
    push es

    mov ax, 0xb800
    mov es, ax
    mov di, [food_location]        ;food location
    mov ax, 0x0f03
    mov [es:di], ax

    pop es
    pop di
    pop ax
    ret 2
	
check_food_eating_proccess:
    push ax
	push bx
	mov ax,[food_location]
	mov bx,[snake_location]
	mov dx,snake_location
	cmp ax,bx
	jne no_rand_generation_of_food
	mov di,162
	mov ax,0xb800
	mov es,ax
	clearing:
	mov ax,0x0720
	cmp word[es:di],0x0f03
	je noclearing 
	cmp word[es:di],0x0f6f
	je noclearing
	cmp word[es:di],0x0f2d
	je noclearing
	mov[es:di],ax
	noclearing:
	add di,2
	 cmp di,318
	 jb clearing
	 call boarder_printing
	call random_function
	add word[score_count],1
	add word[snake_length],1
    call display_food
	jmp keep_moving
	
no_rand_generation_of_food:
call boarder_printing
mov di,162
	mov ax,0xb800
	mov es,ax
	clearing1:
	mov ax,0x0720
	cmp word[es:di], 0x0f03
	je noclearing1
	cmp word[es:di],0x0f6f 
	je noclearing1
	cmp word[es:di],0x0f2d
	je noclearing1
	mov[es:di],ax
	noclearing1:
	add di,2
	 cmp di,318
	 jb clearing1
	 call boarder_printing
   pop bx
   pop ax
	ret

	
;;;;;;;;;;;;;;;;;start;;;;;;;;;;;;;;;;;;;;;;;;
start:

   call clrscr
   call boarder_printing
   mov cx,10
   mov di,1324
   mov ax,0xb800
   mov es,ax
   mov ax,0x0f03
   heart_loop:
   mov[es:di],ax
   add di,2
   dec cx
   jnz  heart_loop 
   
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov cx,10
   mov di,1644
   mov ax,0xb800
   mov es,ax
   mov ax,0x0f03
   heart_loop2:
   mov[es:di],ax
   add di,2
   dec cx
   jnz  heart_loop2 
   
   mov ax,22
   push ax
   mov ax,9
   push ax
   mov ax,0x0f
   push ax
   mov ax,starting_msg
   push ax
   call printstr
    mov ax,22
   push ax
   mov ax,11
   push ax
   mov ax,0x0A
   push ax
   mov ax,design
   push ax
   call printstr
   mov ax,22
   push ax
   mov ax,12
   push ax
   mov ax,0x0A
   push ax
   mov ax,roll_n01
   push ax
   call printstr
   mov ax,22
   push ax
   mov ax,13
   push ax
   mov ax,0x0A
   push ax
   mov ax,roll_n02
   push ax
   call printstr
   

   mov ah,0x1                           ;when you press any key then next instruction execute
   int 0x21
   call clrscr
   call boarder_printing
	mov ax,22
   push ax
   mov ax,9
   push ax
   mov ax,0x0C
   push ax
   mov ax,rules
   push ax
   call printstr
   ;;;;;;;;;;;;;;;;;;;;;;;;;
   mov ax,22
   push ax
   mov ax,10
   push ax
   mov ax,0x0A
   push ax
   mov ax,rule1
   push ax
   call printstr
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov ax,22
   push ax
   mov ax,11
   push ax
   mov ax,0x09
   push ax
   mov ax,rule2
   push ax
   call printstr
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     mov ax,22
   push ax
   mov ax,12
   push ax
   mov ax,0x07
   push ax
   mov ax,rule3
   push ax
   call printstr
   mov ah,0x1                           ;when you press any key then next instruction execute
   int 0x21
    call clrscr
   call boarder_printing

	 push word[snake_length]
	 mov ax,snake
	 push ax
	 mov ax,snake_location
	 push ax
	 call snake_print
	call random_function
    call display_food

	 call snake_through_keys

mov ax,0x4c00
int 21h