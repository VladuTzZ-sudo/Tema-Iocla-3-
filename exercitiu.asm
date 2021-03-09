    push eax
    push eax
    call strlen
    add esp, 4

    mov ebx, [wordForStrtok]
    cmp [ebx + eax], dword 0
    jne GO2
    sub eax, 1

GO2:
    inc eax
    mov [lengthForCreateTree], eax

    mov ebx, [lengthForCreateTree]
    push ebx
    push int_atoi_string
    call printf
    add esp, 8

    cmp [lengthForCreateTree], dword 2
    je Simbol_sau_Cifra

    ; APELAM FUNCTIA CARE CREEAZA UN NOD CU UN STRING/CHAR 
CifreSiString:

    call create_node
    add esp, 4
    jmp Comun

Simbol_sau_Cifra:
    mov ebx, [wordForStrtok]
    cmp [ebx], dword '0' 
    jg CifreSiString

    call create_node
    add esp, 4

Comun:
    push eax
    call print_tree_inorder
    add esp, 4
    


create_tree:
    enter 0, 0
    push ecx
    push edx
    push ebx

    ; EXTRAG PRIMUL ELEMENT DIN SIR
    mov eax, [ebp + 8]
    push delim
    push eax
    call strtok
    add esp, 8
    mov [wordForStrtok], eax
    
;push eax
    ;push eax
    ;call iocla_atoi
    ;add esp, 4

    ;push eax
    ;push int_atoi_string
    ;call printf
    ;add esp, 8

    ;pop eax
    ;push eax
    ;call check_atoi
;pop eax

    ; CALCULEZ LUNGIMEA LUI
    push eax
    call strlen
    add esp, 4

    mov ebx, [wordForStrtok]
    cmp [ebx + eax], dword 0
    jne GO
    sub eax, 1

GO: 
    inc eax
    mov [lengthForCreateTree], eax

    mov ebx, [lengthForCreateTree]
    push ebx
    push int_atoi_string
    call printf
    add esp, 8

    ;DECLAR SPATIU PENTRU SIR
    mov edx, [lengthForCreateTree]
    push edx
    call malloc
    add esp, 4

    ;SALVEZ SIRUL CORECT IN EAX
    mov edx, [wordForStrtok]
    mov ecx, 0
    xor ebx, ebx

    whileLoop:
    mov bl, byte [edx + ecx]
    mov [eax + ecx], bl 

    inc ecx
    cmp ecx, [lengthForCreateTree]
    jl whileLoop

    mov bl, byte [edx + ecx]
    mov [eax + ecx], bl 

    push eax

    ;DECLAR MEMORIE PENTRU ROOT
    push 12
    call malloc
    add esp, 4

    mov [root], eax

    xor ecx, ecx
    xor edx, edx
    xor ebx, ebx

    ;INSEREZ SIRUL IN ROOT
    mov edx, [root]
    pop eax
    mov [edx], eax
    
    mov ecx, [root]

    mov [ecx + 4],dword 0
    mov [ecx + 8],dword 0    
    
    lea eax, [ecx]

    ;AFISEZ ROOT-ul
    mov [root], eax
    ;push eax
    ;call print_tree_inorder
    ;pop eax
    
    LOOP_FOR_INPUT:
    ;mov eax, [wordForStrtok]
    push    delim
    push    0
    call    strtok
    add     esp, 8
    mov [wordForStrtok], eax

    test eax, eax
    je FINISH
   
    mov [vizitat], dword 0

    push eax
    mov ebx, [root]
    push ebx
    ;call parcurgere_arbore
    call add_node
    add esp, 8

    jmp LOOP_FOR_INPUT

    FINISH:
    mov eax, [root]
    ;xor eax, eax
    pop ebx
    pop edx
    pop ecx
    leave
    ret



    parcurgere_arbore:
    enter 0,0
    push ecx
    push edx
    push ebx
    
    mov eax, [ebp + 8]  ; eax - nod curent - string-> Nodevalue
    mov ebx, [ebp + 12] ; ebx - string-ul  - wordForstrtok
    mov [wordForStrtok], ebx
    mov [Node], eax
    ; DACA NODUL CURENT ESTE NULL
    cmp eax, dword 0
    je FINISH_parcurgere

    ;Verifica ce se afla in nodul curent
    ;Daca este numar, atunci trebuie sa ramana o frunza
    xor ebx, ebx
    mov ebx, [eax]
    mov [nodeValue], ebx
    push ebx
    call strlen
    add esp, 4
    cmp eax, 1
    jg FINISH_parcurgere

    mov ebx, [wordForStrtok]
    cmp [ebx], byte '0' 
    jge FINISH_parcurgere ;inseamna ca sunt numere 
    
    ;Prin Root->left
    mov ebx, [wordForStrtok]
    mov eax, [Node]
    mov eax, [eax + 4]
    push ebx
    push eax
    call parcurgere_arbore
    add esp, 8

    ;Prin Root->right
    mov ebx, [wordForStrtok]
    mov eax, [Node]
    mov eax, [eax + 8]
    push ebx
    push eax
    call parcurgere_arbore
    add esp, 8

    ;Daca string-ul curent a fost adaugat deja. ( pentru recursivitatea de pe right )
    ;cmp [vizitat], dword 1
    ;je FINISH_parcurgere
    mov ecx, [vizitat]
    cmp ecx, 1
    je FINISH_parcurgere

    ;Daca in stanga este NULL, atunci punem nodul in copilul din stanga.
    mov eax, [Node]
    mov eax, [eax + 4]
    test eax, eax
    je Left
    jmp Right
    ;cmp [eax + 4], dword 0
    ;je left
    ;jmp right

    Left:
    mov eax, [wordForStrtok]
    push eax
    call create_node
    mov ebx, [Node]
    mov [ebx + 4], eax
    mov [vizitat], dword 1
    jmp FINISH_parcurgere
    Right:
    mov eax, [wordForStrtok]
    push eax
    call create_node
    mov ebx, [Node]
    mov [ebx + 8], eax
    mov [vizitat], dword 1

    FINISH_parcurgere:
    pop ebx
    pop edx
    pop ecx
    leave
    ret



iocla_atoi: 
    enter 0, 0
    push ecx
    push edx
    push ebx
    push edi
    push esi

    mov [cifra], dword 10
    xor eax, eax
    
    mov edx, [ebp + 8]
    push edx
    call strlen
    add esp, 4

    mov edx, [ebp + 8]
    cmp [edx + eax],dword 0
    jne WithOutEndOfLIne
    sub eax, 1  


WithOutEndOfLIne: 
    ;push eax
    ;push int_atoi_string
    ;call printf
    ;add esp, 4
    ;pop eax

    mov [lengthString], eax

    ;flag de negative
    mov [negative], byte '0'

    mov edx, [ebp + 8]
    
    xor ecx, ecx
    cmp byte [edx], '-'
    jne JumpOverNegativeNumbersCode

    mov [negative], byte '1'
    inc ecx

JumpOverNegativeNumbersCode:
    xor ebx, ebx
    xor eax, eax
    jmp while

    while:
    mov bl, byte [edx + ecx]
    push edx
    mul dword [cifra]
    sub bl, '0'
    add eax, ebx
    pop edx
    inc ecx
    cmp ecx, [lengthString] 
    jne while

    cmp [negative], byte '1'
    jne FinalAtoi

    imul eax, -1

FinalAtoi:
    pop esi
    pop edi
    pop ebx
    pop edx
    pop ecx
    leave
    ret

    createnode:
    enter 0,0
    push ebx
    push ecx
    push edx

    mov eax,[ebp+8]
    mov [createnodecuvant],eax

    push eax
    call strlen
    add esp,4
    mov [createnodelungime],eax

    push 1
    push 12
    call calloc
    add esp,8
    mov [node],eax

    mov eax,[createnodelungime]
    push 1
    push eax
    call calloc
    add esp,8
    mov edx,[node]
    mov [edx],eax

    mov eax,[createnodecuvant]
    mov ebx,[edx]
    push eax
    push ebx
    call strcpy
    add esp,8

    mov edx,[node]
    mov [edx+4],dword 0
    mov [edx+8],dword 0

    mov eax,[node]


    pop edx
    pop ecx
    pop ebx
    leave
    ret
