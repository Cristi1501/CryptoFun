extern puts
extern printf

section .data
filename: db "./input.dat",0
inputlen: dd 2263
fmtstr: db "Key: %d",0xa,0

section .text
global main

; TODO: define functions and helper functions

; TASK 1
xor_strings:
    push ebp
    mov ebp, esp
    mov ecx, [ebp+8]
    mov edx, [ebp+12]
    mov esi, -1             ; counter
byte_by_byte:
    xor eax, eax
    inc esi
    mov al, byte[ecx+esi]   ; byte from message
    xor al, byte[edx+esi]   ; xor it with byte from key
    mov byte[ecx+esi], al   ; overwrite
    
    cmp byte[ecx+esi+1], 0x00
    jne byte_by_byte
    
    leave 
    ret
    
; TASK 2
rolling_xor:
    push ebp
    mov ebp, esp
    mov edx, [ebp+8]
    xor esi, esi            ; counter
    mov cl, byte[edx]       ; remember the previous byte
criptare:
    xor eax, eax
    inc esi
    mov al, byte[edx+esi]   ; byte from message
    xor al, cl              ; xor it with the previous
    mov cl, byte[edx+esi]   ; remember the previous byte for next step
    mov byte[edx+esi], al   ; overwrite
    
    cmp byte[edx+esi+1], 0x00
    jne criptare
    
    leave
    ret

; TASK 3
xor_hex_strings:
    push ebp
    mov ebp, esp
    mov ecx, [ebp+8]
    mov edx, [ebp+12]
    mov esi, -2             ; counter for hexa
    mov edi, -1             ; counter for byte
transformare:
    xor eax, eax
    add esi, 2
    inc edi
    
    ; decrease actual and next byte from message and key with '0' (48 in ASCII)
    sub byte[ecx+esi], 48
    sub byte[ecx+esi+1], 48
    sub byte[edx+esi], 48
    sub byte[edx+esi+1], 48
    
    ; compare every byte with 49 (97-48) to verify if it is a letter
    ; decrease every letter with 39 (97-48-39=10, first letter, 'a')
    cmp byte[ecx+esi], 49
    jge litera1
    jmp continuare1
    
litera1:
    sub byte[ecx+esi], 39

continuare1:
    cmp byte[ecx+esi+1], 49
    jge litera2
    jmp continuare2
    
litera2: 
    sub byte[ecx+esi+1], 39
    
continuare2:
    cmp byte[edx+esi], 49
    jge litera3
    jmp continuare3
    
litera3:
    sub byte[edx+esi], 39

continuare3:
    cmp byte[edx+esi+1], 49
    jge litera4
    jmp continuare4
    
litera4:
    sub byte[edx+esi+1], 39
    
    
; form the bytes for message and key through shifts
continuare4:
    mov al, byte[ecx+esi]       
    shl al, 4
    add al, byte[ecx+esi+1]
    mov byte[ecx+edi], al
    mov al, byte[edx+esi]
    shl al, 4
    add al, byte[edx+esi+1]
    mov byte[edx+edi], al
    cmp byte[ecx+esi+2], 0x00
    jne transformare
    
    add esi, 2
    
; put null terminator and jump to xor byte by byte (first task)
completare_null:
    inc edi
    mov byte[ecx+edi], 0x00
    mov byte[edx+edi], 0x00
    cmp edi, esi
    jne completare_null

    mov esi, -1
    jmp byte_by_byte
    
; TASK 4
base32decode:
    push ebp
    mov ebp, esp
    mov edx, [ebp+8]
    mov esi, -1             ; counter
decodare:
    inc esi
    xor eax, eax
    mov al, byte[edx+esi]   
    
    ; 2 = 50 (ASCII), 2 = 26 (base32)
    ; decrease al and verify if it is a letter or a number
    sub al, 24
    cmp al, 41
    jge litera
    jmp incarcare
litera:
    sub al, 41
    
incarcare:
    push eax
    
    ; verify if the next byte is '='
    cmp byte[edx+esi+1], '='
    jne decodare
    
    add esi, 2          ; counter for stack (in "functie")
    mov edi, -1         ; counter for message which i will overwrite
    call functie
    mov esp, ebp
    
    inc edi
    mov byte[edx+edi], 0x00     ; put the null terminator
    
    leave
    ret
    
functie:
    push ebp
    mov ebp, esp
    
rezolvare:

    ; first 5 bits
    mov eax, [ebp+4*esi]
    shl eax, 3              ; shift them
    inc edi
    mov byte[edx+edi], al   ; overwrite
    dec esi
    cmp esi, 1
    jle stop
    
    ; second 5 bits
    mov eax, [ebp+4*esi]
    shr eax, 2              ; only 3 bits
    add byte[edx+edi], al   ; add to byte which was overwritten
    mov eax, [ebp+4*esi]
    shl eax, 6              ; last 2 bits
    inc edi
    mov byte[edx+edi], al   ; overwrite
    dec esi
    cmp esi, 1
    jle stop
    
    ; third 5 bits
    mov eax, [ebp+4*esi]
    shl eax, 1              ; all 5 bits
    add byte[edx+edi], al   ; add to byte which was overwritten
    dec esi
    cmp esi, 1
    jle stop
    
    mov eax, [ebp+4*esi]
    shr eax, 4              ; only 1 bits
    add byte[edx+edi], al   ; add to byte
    mov eax, [ebp+4*esi]
    shl eax, 4              ; last 4 bits
    inc edi
    mov byte[edx+edi], al   ; overwrite
    dec esi
    cmp esi, 1
    jle stop
    
    mov eax, [ebp+4*esi]
    shr eax, 1              ; only 4 bits
    add byte[edx+edi], al   ; add to byte which was overwritten
    mov eax, [ebp+4*esi]
    shl eax, 7              ; last byte
    inc edi
    mov byte[edx+edi], al   ; overwrite
    dec esi
    cmp esi, 1
    jle stop
    
    mov eax, [ebp+4*esi]
    shl eax, 2              ; all 5 bits
    add byte[edx+edi], al   ; add to byte which was overwritten
    dec esi
    cmp esi, 1
    jle stop
    
    mov eax, [ebp+4*esi]
    shr eax, 3              ; only 2 bits
    add byte[edx+edi], al   ; add to byte which was overwritten
    mov eax, [ebp+4*esi]
    shl eax, 5              ; last 3 bits
    inc edi
    mov byte[edx+edi], al   ; overwrite
    dec esi
    cmp esi, 1
    jle stop
    
    mov eax, [ebp+4*esi]
    add byte[edx+edi], al   ; add all 5 bits to byte which was overwritten
    
    dec esi
    cmp esi, 1
    jg rezolvare

stop:
    leave 
    ret

; TASK 5
bruteforce_singlebyte_xor:
    push ebp
    mov ebp, esp
    mov edx, [ebp+8]
    mov eax, [ebp+12]           ; here is the key (in al)
    mov esi, -1                 ; counter
singlebyte:
    xor ecx, ecx
    inc esi
    mov cl, byte[edx+esi]       ; keep the byte from message
    xor cl, al                  ; xor it with the key
    mov byte[edx+esi], cl       ; overwrite
    
    cmp byte[edx+esi+1], 0x00
    jne singlebyte
    
    leave 
    ret
    

verifica_rezultat:
    push ebp
    mov ebp, esp
    mov edx, [ebp+8]
    mov esi, -1  
    
; verify if the word (force) is in decrypted message
verificare:
    inc esi
    cmp byte[edx+esi+4], 0x00
    je iesire
    cmp byte[edx+esi], 'f'
    jne verificare
    cmp byte[edx+esi+1], 'o'
    jne verificare
    cmp byte[edx+esi+2], 'r'
    jne verificare
    cmp byte[edx+esi+3], 'c'
    jne verificare
    cmp byte[edx+esi+4], 'e'
    jne verificare
    
    ; if force is in the message, edi = 1
    mov edi, 1
iesire:
    leave
    ret
    
; TASK 6
break_substitution:
    push ebp
    mov ebp, esp
    mov edx, [ebp+8]
    mov eax, [ebp+12]
    mov esi, -1             ; counter for message
    
inlocuire:
    inc esi
    mov edi, -1             ; counter for substitution_table_addr
    cmp byte[edx+esi], 0x00
    je iesire
    
; search the character and change it
cautare:
    add edi, 2
    cmp byte[eax+edi-1], 0x00
    je inlocuire
    mov cl, byte[eax+edi]
    cmp byte[edx+esi], cl
    jne cautare
    
    mov cl, byte[eax+edi-1]
    mov byte[edx+esi], cl
    jmp inlocuire
    

main:
    mov ebp, esp; for correct debugging
    push ebp
    mov ebp, esp
    sub esp, 2300
    
    ; fd = open("./input.dat", O_RDONLY);
    mov eax, 5
    mov ebx, filename
    xor ecx, ecx
    xor edx, edx
    int 0x80
    
	; read(fd, ebp-2300, inputlen);
	mov ebx, eax
	mov eax, 3
	lea ecx, [ebp-2300]
	mov edx, [inputlen]
	int 0x80

	; close(fd);
	mov eax, 6
	int 0x80

	; all input.dat contents are now in ecx (address on stack)

	; TASK 1: Simple XOR between two byte streams
	; TODO: compute addresses on stack for str1 and str2

        mov ebx, -1
        xor eax, eax
        
cauta_adresa2:
        inc ebx
        cmp byte[ecx+ebx], 0x00
        jne cauta_adresa2
        
        ; remember the address for string 2
        lea edx, [ecx+ebx+1]
        
        ; TODO: XOR them byte by byte
        
        push edx                ;push addr_str2
        push ecx                ;push addr_str1
        call xor_strings        ;call xor_strings
        add esp, 8              ;add esp, 8

	; Print the first resulting string

        push ecx                ;push addr_str1
        call puts               ;call puts
        add esp, 4              ;add esp, 4

	; TASK 2: Rolling XOR
	; TODO: compute address on stack for str3
	
cauta_adresa3:
        inc ebx
        cmp byte[esp+ebx], 0x00
        jne cauta_adresa3
        
        ; remember the address for string 3
        lea edx, [esp+ebx+1]
        
        ; TODO: implement and apply rolling_xor function
        
        push edx                ;push addr_str3
        call rolling_xor        ;call rolling_xor
        add esp, 4              ;add esp, 4

	; Print the second resulting string

        push edx                ;push addr_str3
        call puts               ;call puts
        add esp, 4              ;add esp, 4

	
	; TASK 3: XORing strings represented as hex strings
	; TODO: compute addresses on stack for strings 4 and 5

cauta_adresa4:
        inc ebx
        cmp byte[esp+ebx], 0x00
        jne cauta_adresa4
        
        ; remember the address for string 4
        lea ecx, [esp+ebx+1]
        
cauta_adresa5:
        inc ebx
        cmp byte[esp+ebx], 0x00
        jne cauta_adresa5
        
        ; remember the address for string 5
        lea edx, [esp+ebx+1]
        
        ; TODO: implement and apply xor_hex_strings
        
        push edx                ;push addr_str5
        push ecx                ;push addr_str4
        call xor_hex_strings    ;call xor_hex_strings
        add esp, 8              ;add esp, 8

	; Print the third string

        push ecx                ;push addr_str4
        call puts               ;call puts
        add esp,4               ;add esp, 4
	
	; TASK 4: decoding a base32-encoded string
	; TODO: compute address on stack for string 6
	
parcurge_sir5:
        inc ebx
        cmp byte[esp+ebx], 0x00
        jne parcurge_sir5
        
cauta_adresa6:
        inc ebx
        cmp byte[esp+ebx], 0x00
        je cauta_adresa6
        
        ; remember the address for string 6
        lea edx, [esp+ebx]
        
        ; TODO: implement and apply base32decode
        
        push edx                ;push addr_str6
        call base32decode       ;call base32decode
        add esp, 4              ;add esp, 4

	; Print the fourth string
	
        push edx                ;push addr_str6
        call puts               ;call puts
        add esp, 4              ;add esp, 4

	; TASK 5: Find the single-byte key used in a XOR encoding
	; TODO: determine address on stack for string 7

parcurge_sir6:
        inc ebx
        cmp byte[esp+ebx], 0x00
        jne parcurge_sir6
        
        inc ebx
parcurge_spatiu_liber:
        inc ebx
        cmp byte[esp+ebx], 0x00
        jne parcurge_spatiu_liber
        
        ; remember the address for string 7
        lea edx, [esp+ebx+1]
        
        ; remember the keyvalue
        xor eax, eax
        mov al, 0x00
        
cheie:
        ; TODO: implement and apply bruteforce_singlebyte_xor
        
        push eax                ;push key_addr
        push edx                ;push addr_str7
        call bruteforce_singlebyte_xor  ;call bruteforce_singlebyte_xor
        add esp, 8              ;add esp, 8
        
        ; verify if the result is correct
        xor edi, edi
        push edx
        call verifica_rezultat
        add esp, 4
        cmp edi, 1
        je corect
        
        ; form the string back (unless it is correct)
        push eax
        push edx
        call bruteforce_singlebyte_xor
        add esp, 8
        
        ; increment the keyvalue
        inc al
        jmp cheie
	   
corect:
        ; Print the fifth string and the found key value
        
        ; remember the address for eax
        lea esi, [eax]
        
        push edx                ;push addr_str7
        call puts               ;call puts
        add esp, 4              ;add esp, 4
	
        ; move eax on its address
        lea eax, [esi]
        
        push eax                ;push keyvalue
        push fmtstr             ;push fmtstr
        call printf             ;call printf
        add esp, 8              ;add esp, 8

	; TASK 6: Break substitution cipher
	; TODO: determine address on stack for string 8
			
parcurge_sir7:
        inc ebx
        cmp byte[esp+ebx], 0x00
        jne parcurge_sir7
        
        ; remember the address for string 8
        lea edx, [esp+ebx+1]
        
        ; memory allocation for substitution cipher
        sub esp, 60
        xor eax, eax
        
        ; TODO: implement break_substitution
        
        mov dword[esp], "aqbr"
        mov dword[esp+4], "cwde"
        mov dword[esp+8], "e fu"
        mov dword[esp+12], "gthy"
        mov dword[esp+16], "iijo"
        mov dword[esp+20], "kplf"
        mov dword[esp+24], "mhn."
        mov dword[esp+28], "ogpd"
        mov dword[esp+32], "qars"
        mov dword[esp+36], "sltk"
        mov dword[esp+40], "umvj"
        mov dword[esp+44], "wnxb"
        mov dword[esp+48], "yzzv"
        mov dword[esp+52], " c.x"
        mov byte[esp+56], 0x00
        
        lea eax, [esp]
        
        push eax                ;push substitution_table_addr
        push edx                ;push addr_str8
        call break_substitution ;call break_substitution
        add esp, 8              ;add esp, 8
        
	; Print final solution (after some trial and error)

        push edx                ;push addr_str8
        call puts               ;call puts
        add esp, 4              ;add esp, 4

	; Print substitution table
        lea eax, [esp]
        
        push eax                ;push substitution_table_addr
        call puts               ;call puts
        add esp, 4              ;add esp, 4

	; Phew, finally done
    xor eax, eax
    leave
    ret
