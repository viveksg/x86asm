segment .text
global _start

_start:
  push MSG
  push MSG_LEN
  call _write
  push num
  push INP_LEN
  call _read
  pop eax
  push int_num
  call _parseInt
  call _exit

_read:
  push ebp
  mov ebp, esp
  mov eax, SYS_READ
  mov ebx, READ_FD
  mov ecx, [ebp + 0xc]
  mov edx, [ebp + 0x8]
  int 0x80
  _read_exit:
    mov esp, ebp
    pop ebp
    ret

_write:
  push ebp
  mov ebp, esp
  mov eax, SYS_WRITE
  mov ebx, WRITE_FD
  mov ecx, [ebp + 0xc]
  mov edx, [ebp + 0x8]
  int 0x80
  _write_exit:
    mov esp, ebp
    pop ebp
    ret


_parseInt:
  push ebp
  mov ebp, esp
  push 0x0 ; Is first byte parsed, set to false
  push 0x0 ; Is first byte negative, set to false
  mov ebx, [ebp + 0xc]
  xor ecx, ecx
  _loop:
    mov al, byte [ebx]

    first_byte_check:
      mov edx, [ebp - 0x4]
      cmp edx, 0x0
      jne end_line_check
      mov word [ebp - 0x4], 0x1

      negative_sign_check:
        cmp al, NEGATIVE_SIGN
        jne end_line_check
        mov word [ebp - 0x8], 0x1
        jmp _inc

    end_line_check:
      cmp al, LINE_BREAK
      je _exit_loop

    space_check:
      cmp al, SPACE
      je _exit_loop

    lower_bound_check:
      cmp al, ZERO_IND
      jge upper_bound_check
      call _not_int
      jmp _exit_loop

    upper_bound_check:
      cmp al, NINE_IND
      jle convert_to_int
      call _not_int
      jmp _exit_loop

    convert_to_int:  
      sub al, ZERO_IND
      mov byte [ebx], al

    _save_int:
      push ecx
      push ebx   ; save current input byte address, to allow ebx store address of result
      push eax ; save current byte (stored in al register, so eax saved)
      mov ebx, [ebp + 0x8]
      mov ecx, [ebx]
      imul ecx, 0xa
      pop eax
      add ecx ,eax
      cmp ecx, [ebx]
      jg _save_result
      call _raise_overflow_exception

      _save_result:
      mov [ebx], ecx
      pop ebx
      pop ecx      

    _inc:
      add ebx, 0x1
      add ecx, 0x1
      cmp ecx, INP_LEN
      jne _loop 

  _exit_loop:
    nop

  _convert_to_negative: ;if required
    mov edx, [ebp - 0x8]
    cmp edx, 0x1
    jne _exit_negative_conversion
    mov eax, [ebp + 0x8]
    mov ebx, [eax]
    neg ebx
    mov [eax], ebx
  _exit_negative_conversion:
    nop 

  _exit_parse_int:
    mov esp, ebp
    pop ebp
    ret 

_raise_overflow_exception:
  push OVER_FLOW_MSG
  push OF_EXC_LEN
  call _write
  call _exit

_not_int:
 push ebp
 mov ebp, esp
 push NOT_INT_MSG
 push EXC_LEN
 call _write
 exit_not_int:
   mov esp, ebp
   pop ebp
   ret 

_int_malloc:
  nop
_exit:
  mov eax, SYS_EXIT
  xor ebx, ebx
  int 0x80

segment .data
  SYS_READ equ 3
  SYS_WRITE equ 4
  READ_FD equ 2
  WRITE_FD equ 1
  SYS_EXIT equ 1
  MSG db 'write input: '
  MSG_LEN equ $-MSG
  NOT_INT_MSG db 'Exception: Not an integer'
  EXC_LEN equ $-NOT_INT_MSG
  OVER_FLOW_MSG db 'Exception: Overflow'
  OF_EXC_LEN equ $-OVER_FLOW_MSG
  INP_LEN equ 20
  NEGATIVE_SIGN equ 0x2d
  LINE_BREAK equ 0x0a
  ZERO_IND equ 0x30
  NINE_IND equ 0x39
  SPACE equ 0x20

segment .bss
  num resb 20
  int_num resb 4