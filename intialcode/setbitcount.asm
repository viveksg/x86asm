segment .text
global _start
_start:
  push READ_MSG
  push READ_MSG_LEN
  call _writeconsole
  call _readconsole
  push ecx
  call _process
  push ecx
  push OUTPUT_MSG
  push OUTPUT_MSG_LEN
  call _writeconsole
  add esp, 0x8
  mov eax, [esp]
  add eax, '0'
  mov [esp], eax
  push esp
  push SET_BITS_LEN
  call _writeconsole
  call _exit

_writeconsole:
   push ebp
   mov ebp, esp
   mov edx, [ebp + 0x8]
   mov ecx, [ebp + 0xc]
   mov eax, SYS_WRITE
   mov ebx, WRITE_FD
   int 0x80
   _return_wc:
      mov esp,ebp
      pop ebp
      ret


_readconsole:
   push ebp
   mov ebp, esp
   mov eax, SYS_READ
   mov ebx, READ_FD
   mov ecx, num
   mov edx, INP_LEN
   int 0x80
   mov ecx, [num]
   sub ecx, 0xa30
   _return_rc:
      mov esp, ebp
      pop ebp
      ret

_process:
   push ebp
   mov ebp, esp
   mov eax, [ebp + 0x8]
   xor ecx, ecx
   mov edx, CONST_MAX
   push 0x0
   _loop:
    mov ebx, eax
    and ebx, 0x1
    add ecx, ebx
    shr eax, 0x1
    inc DWORD [esp]
    cmp edx, [esp]
    jne _loop
   _return_pr:
    mov esp, ebp
    pop ebp
    ret 

_exit:
   mov eax, SYS_EXIT
   xor ebx, ebx
   int 0x80

segment .data
   SYS_EXIT equ 1
   SYS_READ equ 3
   SYS_WRITE equ 4
   READ_FD equ 2
   WRITE_FD equ 1
   CONST_ONE equ 1
   CONST_MAX equ 32
   READ_MSG db 'enter a four byte number : '
   READ_MSG_LEN equ $-READ_MSG
   OUTPUT_MSG db 'number of set bits = '
   OUTPUT_MSG_LEN equ $-OUTPUT_MSG
   SET_BITS_LEN equ 4
   INP_LEN equ 5

segment .bss
   num resb 5