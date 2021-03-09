
section .data
    delim db " ", 0
    cifra: dd 0
    lengthStringAtoi: dd 0
    lengthForCreateNode: dd 0
    wordForStrtok: dd 0
    negative: db 0
    vizitat: dd 0
    nodeValue: dd 0
    Node: dd 0
    createNodeVar: dd 0
    wordForGoThrough: dd 0

section .bss
    root resd 1

section .text

extern check_atoi
extern print_tree_inorder
extern print_tree_preorder
extern evaluate_tree
extern printf
extern strlen
extern malloc
extern strtok
extern calloc

global create_tree
global iocla_atoi

iocla_atoi: 
    ;Salvez registrele.
    enter 0, 0
    push ecx
    push edx
    push ebx

    ;Initiez variabila cifra cu 10.
    mov [cifra], dword 10
    xor eax, eax
    
    ;Calculez lungimea sirului primit ca parametru si salvez valoarea in variabila lengthStringAtoi.
    mov edx, [ebp + 8]
    push edx
    call strlen
    add esp, 4
    mov [lengthStringAtoi], eax

    ;Folosesc o variabila de tip FLAG, si o initializez cu 0.
    mov [negative], byte '0'

    mov edx, [ebp + 8]
    
    ;Registrul edx contine acum sirul, deci pe pozitia 0 va fi semnul "-", daca acesta exista.
    xor ecx, ecx
    cmp byte [edx], '-'
    jne JumpOverNegativeNumbersCode

    ;Daca semnul "-" a fost gasit, atunci variabila steag se schimba in 1.
    mov [negative], byte '1'
    inc ecx

    JumpOverNegativeNumbersCode:
    xor ebx, ebx
    xor eax, eax

    ;Copiez caracter cu caracter sirul din adresa primita ca parametru in registrul eax.
    ;Atunci cand obtin o litera, realizez transformarea din CODUL ASCII in valoarea corespunzatoare a cifrei printr-o scadere de '0' = 48.
    while:
    mov bl, byte [edx + ecx]
    push edx
    mul dword [cifra]
    sub bl, '0'
    add eax, ebx
    pop edx
    inc ecx
    cmp ecx, [lengthStringAtoi] 
    jne while

    ;Daca steag-ul de numar negativ a fost activat , atunci inmultesc numarul obtinut cu -1.
    cmp [negative], byte '1'
    jne FinalAtoi

    imul eax, -1

    FinalAtoi:
    ;Resetez valoarea registrelor.
    pop ebx
    pop edx
    pop ecx
    
    leave
    ret

createNode:
    ;Salvez registrele.
    enter 0,0
    push  ebx
    push  ecx
    push  edx

    ;Salvez string-ul primit ca parametru in variabila wordForStrtok.
    mov eax, [ebp + 8]
    mov [wordForStrtok], eax

    ;Calculez lungimea sirului si salvez rezulatatul in variabila lengthStringAtoi.
    push eax
    call strlen
    add esp, 4
    mov [lengthForCreateNode], eax

    ;Declar spatiu pentru sir.
    mov edx, [lengthForCreateNode]
    push 1
    push edx
    call calloc
    add esp, 8

    ;Copiez caracter cu caracter sirul din adresa primita ca parametru in registrul eax.
    mov edx, [wordForStrtok]
    xor ecx ,ecx
    xor ebx, ebx

    LoopCreateNode:
    xor ebx, ebx
    mov ebx, [edx + ecx]
    mov [eax + ecx], ebx 

    inc ecx
    cmp ecx, [lengthForCreateNode]
    jl LoopCreateNode

    ;Pun pe stiva registrul eax, care contine in prezent sirul.
    push eax

    ;Declar memorie pentru noul nod.
    push 1
    push 12
    call calloc
    add esp, 8

    ;Salvez in variabila createNodeVar, adresa memoriei alocate.
    mov [createNodeVar], eax

    xor ecx, ecx
    xor edx, edx
    xor ebx, ebx

    ;La valoarea adresei memoriei alocate, pun sirul care a fost salvat pe stiva la linia 136.
    mov edx, [createNodeVar]
    pop eax
    mov [edx], eax

    ;Mut in registrul ecx, registrul edx, si declar NULL in dreptul copiilor ( Left & Right ).
    mov ecx, [createNodeVar]

    mov [ecx + 4], dword 0
    mov [ecx + 8], dword 0    
    
    ;In final, nodul se salveaza in registrul eax.
    lea eax, [ecx]

    ;Resetez valoarea registrelor.
    pop edx
    pop ecx
    pop ebx
   
    leave
    ret

create_tree:
    ;Salvez valoarea registrelor.
    push    ebp
    mov     ebp, esp
    push    ebx
    push    ecx
    push    edx
    
    ;Folosind functia strtok, extrag primul subsir din string-ul primit ca parametru.
    mov eax, [ebp + 8]
    push delim
    push eax
    call strtok
    add esp, 8
    
    ;Apelez functia createNode de substring-ul obtinut.
    push eax
    call createNode
    add esp, 4

    ;Nodul creat, ce contine string-ul dorit este salvat in [root], pentru respectarea recursivitatii din loop-ul LOOP_FOR_INPUT.
    mov [root], eax

    LOOP_FOR_INPUT:
    ;Obtin in registrul eax urmatoarele "cuvinte" din sir-ul primit ca paramtru in functia create_tree.
    push    delim
    push    0
    call    strtok
    add     esp, 8
    mov [wordForStrtok], eax

    ;Compar subsir-ul intors de functia strtok cu NULL, daca nu mai exista cuvinte -> jump FINISH
    cmp eax, 0
    je FINISH
   
    ;Initializez o variabila de tip steag pentru parcurgerea recursiva de pe arbore, din functia parcurgere_arbore.
    mov [vizitat], dword 0

    ;Apelez functia parcurgere_arbore, care se plimba pe copac si insereaza nodul nou acolo unde este cazul.
    ;Primul argument primit de functie este nodul Root ( ebx ), iar al doilea argument este substring-ul curent ( eax ).
    push eax
    mov ebx, [root]
    push ebx
    call parcurgere_arbore
    add esp, 8

    ;Se reintoarce in LOOP.
    jmp LOOP_FOR_INPUT

    FINISH:
    ;Salveaza adresa arborelui in registrul eax si restabileste celelalte registre.
    mov     eax, [root]
    pop     edx
    pop     ecx
    pop     ebx

    leave
    ret

parcurgere_arbore:
    ;Salveaza registrele pe stiva.
    push    ebp
    mov     ebp, esp
    push    ebx
    push    ecx
    push    edx

    ;Extrage parametrii de pe stiva.
    mov eax, [ebp + 8]                  ; eax -> Nodul curent.
    mov ebx, [ebp + 12]                 ; ebx -> Substring-ul.
    mov [wordForGoThrough], ebx
    mov [Node], eax

    ;Daca nodul curent este NULL, atunci jump FINISH_parcurgere.
    cmp eax, dword 0
    je FINISH_parcurgere

    ;Verifica daca string-ul este de un caracter ( posibil simbol ) sau nu.
    xor ebx, ebx
    mov ebx, [eax]
    mov [nodeValue], ebx
    push ebx
    call strlen
    add esp, 4
    cmp eax, 1
    jg FINISH_parcurgere
    
    ;Daca lungimea string-ului este 1, atunci verifica daca este un simbol sau o cifra.
    xor ebx, ebx
    mov ebx, [Node]
    mov ecx, [ebx]
    cmp [ecx], byte '0' 
    jge FINISH_parcurgere 
    
    ;Apeleaza recursiv functia, mergand pe copilul din stanga.
    mov ebx, [wordForGoThrough]
    mov eax, [Node]
    mov eax, [eax + 4]
    push ebx
    push eax
    call parcurgere_arbore
    add esp, 8

    mov edx, [ebp + 8]
    mov [Node], edx

    ;Apeleaza recursiv functia, mergand pe copilul din dreapta.
    mov ebx, [wordForGoThrough]
    mov eax, [Node]
    mov eax, [eax + 8]
    push ebx
    push eax
    call parcurgere_arbore
    add esp, 8

    ;Verifica daca string-ul a fost deja pus intr-un nod.
    ;La intoarcerea din recursivitate este nevoie de acest "steag".
    mov ecx, [vizitat]
    cmp ecx, 1
    je FINISH_parcurgere

check_left:
    mov edx, [ebp + 8]
    mov [Node], edx
    ;Verifica daca copilul stang al nodului curent exista sau nu
    ;Daca este NULL, atunci se poate adauga nodul curent acolo.
    mov eax, [Node]
    mov eax, [eax + 4]
    cmp eax, 0
    jne check_right

left:
    mov edx, [ebp + 8]
    mov [Node], edx

    ;Creaza un nod nou cu string-ul dorit si il aseaza la adresa gasita, copilul stang al nodului curent.
    mov ebx, [wordForGoThrough]
    push ebx
    call createNode
    add esp, 4
    mov ebx, [Node]
    mov [ebx + 4], eax

    ;Se stabileste valoarea steag-ului la 1 si sare la final.
    mov [vizitat], dword 1

    jmp     FINISH_parcurgere

check_right:
    mov edx, [ebp + 8]
    mov [Node], edx
        
    ;Verifica daca copilul stang al nodului curent exista sau nu
    ;Daca este NULL, atunci se poate adauga nodul curent acolo.
    mov eax, [Node]
    mov eax, [eax + 8]
    cmp eax, 0
    jne FINISH_parcurgere

right:  
    mov edx, [ebp + 8]
    mov [Node], edx

    ;Creaza un nod nou cu string-ul dorit si il aseaza la adresa gasita, copilul stang al nodului curent.
    mov ebx, [wordForGoThrough]
    push ebx
    call createNode
    add esp, 4
    mov ebx, [Node]
    mov [ebx + 8], eax

    ;Se stabileste valoarea steag-ului la 1 si sare la final.
    mov [vizitat], dword 1

FINISH_parcurgere:
    ;Se restabilesc registrele.
    pop     edx
    pop     ecx
    pop     ebx
    
    leave
    ret
