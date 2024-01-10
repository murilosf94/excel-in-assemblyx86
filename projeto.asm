TITLE MURILO DE SOUZA FREITAS 23012056     JOAO PEDRO KAFER BACHIEGA 23006014

.model small
.stack 100h

;macro para linha
linha macro xl,yl,taml,corl
    local voltal
    pushall
    mov bx, taml
    inc bx
    mov cx, xl  
    mov dx, yl 
    mov al, corl 
    
    voltal:
        pixels al, cx, dx
        inc cx  
        dec bx
        jnz voltal

    popall

endm

;macro para os pixels
pixels macro corpix, xp, yp
    pushall

    mov ah, 0ch 
    mov bh, 0
    mov al, corpix 
    mov cx, xp
    mov dx, yp
    int 10h

    popall
endm

;macro para a coluna
coluna macro xc, yc, tamc, corc
    local voltac
    pushall
    mov bx, tamc 
    inc bx
    mov cx, xc
    mov dx, yc
    mov al, corc
    voltac:
        pixels al, cx, dx
        inc dx
        dec bx
        jnz voltac 

    popall
endm

;pushall
pushall macro
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    
endm

;popall
popall macro
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax

endm

;macro para a manipulação do cursor
posicursor macro xcu, ycu
    pushall
    mov ah, 02h
    mov bh, 0
    mov dh, xcu
    mov dl, ycu
    int 10h
    popall
endm

;macro para a impressão dos caracteres
printacaracter macro corl, letra
    pushall

    mov al, letra
    mov ah, 09
    mov bl, corl
    xor bh, bh
    mov cx, 1
    int 10h
    popall
endm

;macro para imprimir uma string colorida na tel
string macro str, tamstr, xstr,ystr,corstr
    local stringvolta
    pushall
    mov ch, ystr
    mov cl, xstr
    mov dl, tamstr
    lea bx, str

    stringvolta:
        posicursor ch, cl
        mov al, [bx]
        printacaracter corstr, al
        inc bx 
        inc cl
        dec dl
        jnz stringvolta

    popall
endm

;interface feita a partir das macros da biblioteca grafica
interface macro 
    ;utilizacao das macros de linha e coluna para montar a interface (x / y / tamanho / cor)
    coluna 10, 9, 181, 8
    coluna 313, 9, 181, 8
    linha 10, 9, 303, 8
    linha 10, 190, 303, 8
    linha 10, 30, 303, 8
    linha 10, 62, 303, 8
    linha 10, 94, 303, 8
    linha 10, 126, 303, 8
    linha 10, 158, 303, 8
    coluna 140, 9, 181, 8
    coluna 178, 9, 181, 8
    coluna 216, 9, 181, 8
    coluna 254, 9, 181, 8

    ;strings na tabela (tamanho / x / y / cor)
    string msg0, 13, 2, 2, 10
    string msg1, 2, 19, 2, 10
    string msg2, 2, 23, 2, 10
    string msg3, 2, 28, 2, 10
    string msg4, 5, 33, 2, 10


   

endm

;macro que fará o contorno de uma determinada área assim que o cursor passar sobre ela
contorna macro  numcn
    local nomecn, fimcn 
    pushall
    mov cx, actx
    mov dx, acty
    mov al, numcn
    mov numcn0, al
    mov ax, actx
    mov actx0, ax
    mov ax, acty
    mov acty0, ax
    


    cmp numcn, 0
    jnz proxcn
    jmp nomecn

    proxcn:
        linha actx, acty, 36, 15
        add dx, 30
        linha actx, dx, 36, 15
        coluna actx, acty, 30, 15
        add cx, 36
        coluna cx, acty, 30, 15 

        jmp fimcn



    nomecn:
        linha actx, acty, 128, 15
        add dx, 30
        linha actx, dx, 128, 15
        coluna actx, acty, 30, 15
        add cx, 128
        coluna cx, acty, 30, 15

    fimcn:

    popall
endm

;macro que descontorna uma determinada área assim que o cursor sair dessa área que ja estava contornada
descontorna macro numdcn
    local nomedcn, fimdcn 
    pushall
    mov cx, actx0
    mov dx, acty0
    cmp numdcn, 0
    jnz proxdcn
    jmp nomedcn

    proxdcn:
        linha actx0, acty0, 36, 0
        add dx, 30
        linha actx0, dx, 36, 0
        coluna actx0, acty0, 30, 0
        add cx, 36
        coluna cx, acty0, 30, 0

        jmp fimdcn



    nomedcn:
        linha actx0, acty0, 128, 0
        add dx, 30
        linha actx0, dx, 128, 0
        coluna actx0, acty0, 30, 0
        add cx, 128
        coluna cx, acty0, 30, 0


    fimdcn:

    popall
endm 

;macro para adicionar contorno ou descontorno dependendo do estado em que a area estiver
contornog macro
    local proxcg0, proxcg, proxcg1, nomecg, fimcg
    pushall 
    confstate
    cmp state, 0
    jnz stateprox
    jmp fimcg 

    stateprox:
        cmp actx0, 0
        jnz proxcg01
        jmp proxcg0

        proxcg01:
            descontorna numcn0

        proxcg0:
            cmp i[0], 4
            jne proxcg

            jmp fimcg

    proxcg:
        contorna i[0]

    fimcg:

    popall
endm


;macro para verificar o estado do mouse e obter suas coordenadas
confmouse macro
    local proxcm
    pushall
    xor bx, bx
    mov click, 0
    mov ax, 3
    int 33h
    shr cx, 1

    mov mousex, cx
    mov mousey, dx

    cmp bx, 1
    jne proxcm
    mov click, 1

    proxcm:

    popall 
endm

;macro para verificar o estado atual do mouse
confstate macro
    local proxcs, continuacs, fimcs
    pushall
    xor cx, cx 
    mov state, 1
    mov ch, i[0]
    mov cl, i[1]
    mov bx, actx
    mov actx0, bx
    mov bx, acty
    mov acty0, bx

    call botoes
    cmp ch, i[0]
    je proxcs
    popall
    jmp fimcs

    proxcs:
        cmp cl, i[1]
        je continuacs
        popall
        jmp fimcs 

    continuacs:
        mov state, 0

    fimcs:

endm

;macro apenas para conferir o numero que foi digitado
conferenum macro
    local simnum
    cmp al, '0'
    je simnum
    cmp al, '1'
    je simnum
    cmp al, '2'
    je simnum
    cmp al, '3'
    je simnum
    cmp al, '4'
    je simnum
    cmp al, '5'
    je simnum
    cmp al, '6'
    je simnum
    cmp al, '7'
    je simnum
    cmp al, '8'
    je simnum
    cmp al, '9'
    je simnum
    jmp naonum

    simnum:
        mov ah, 1
        jmp fimconfn

    naonum:
        mov ah, 0

    fimconfn:
    
endm


;macro principal para lidar com eventos
evento macro
    local eventnum, eventnome, fimev
    cmp i[0], 4
    je fimev
    cmp i[0], 0
    jnz eventnum
    jmp eventnome

    eventnum:
        call digitanum
        jmp fimev
    eventnome:
        call digitanome

    fimev:
endm

;macro para calcular a media
calcmedia macro
    local while1, while2, whilefora, prosseguewhile, continuawhile, ehdez
    pushall
    

    xor si, si
    mov ch, 6 
    mov posx, 34
    mov posy, 1

    while1:
        xor dx, dx
        add posy, 4 
        string limpa, 3, posx, posy, 0
        mov cl, 3
        xor bx, bx
        dec ch
        jnz while2

        jmp fimcm
        
    while2:
            mov al, nota[si]
            cmp al, 11
            jne continuawhile
            jmp whilefora

            continuawhile:
                inc si
                add bl, al
                dec cl
                jnz while2
                mov ax, 10
                mul bl
                mov bx, 3
                div bx
                xor ah, ah
                cmp ax, 100
                jne prosseguewhile
                jmp ehdez 
            
            prosseguewhile:
                mov bl, 10 
                div bl
                add al, 30h
                mov char[0], al
                string char, 1, posx, posy, 15
                inc posx
                mov al, '.'
                mov char[0], al
                string char, 1, posx, posy, 15
                inc posx
                add ah, 30h
                mov char[0], ah
                string char, 1, posx, posy, 15
                sub posx, 2
                jmp while1
        
            ;caso seja dez, imprime a string dez no local da media
            ehdez:
                string dez, 2, posx, posy, 15
                jmp while1

        whilefora:
            inc si
            dec cl
            jnz whilefora
            jmp while1

        fimcm:

    

    popall
endm


.data
    msg0 db 'NOME DO ALUNO $'
    msg1 db 'P1 $'
    msg2 db 'P2 $'
    msg3 db 'P3 $'
    msg4 db 'MEDIA $'
    seta1 db '< $'
    sea2 db '^ $'
    dez db '10 $'

    ;armazenar as notas e a média
    media1 db 5 dup (11)
    media db 0, 0, 0
    notac db 2 dup (11)
    nota db 15 dup (11)

    ;string usada para limpar áreas da tela
    limpa db 15 dup ('')

    ;string usada para armazenar o nome do aluno
    nome db 14 dup ('')

    ;char 
    char db ' '

    ;coordenadas atuais do cursor
    actx dw 0
    acty dw 0

    ;coordenadas iniciais do cursor
    actx0 dw 0
    acty0 dw 0

    ;número do contorno atual
    numcn0 db 0

    ;estado do clique do mouse
    click db 0

    ;último valor de 'i' (para controle)
    lasti db 1, 1

    ;estado do cursor
    state db 1

    cor db 0
    cont db 0

    ;coordenadas da posicao do cursor
    posx db 0
    posy db 0
    
    ;coordenadas do mouse
    mousex dw ?
    mousey dw ?

    ;vetor para armazenar valores de 'i'
    i db 0, 0

.code
    main proc
        ;inicializa o codigo
        mov ax, @data
        mov ds, ax

        ;definir a cor do fundo
        mov ax, 13
        int 10h 
        mov ah, 0bh
        mov bl, 01h
        int 10h

        ;chama a macro de interface para colocar a tabela na tela
        interface

        ;inicializa o mouse com a int 33h
        mov ax, 0
        int 33h
        
        ;loop para verificar se clicou o mouse, enqnto click for 0 aq fica rodando, assim que mudar para 1 ele continua o código dando um jmp para evento
        inicio1:
            contornog
            cmp click, 0
            jnz proxmain
            jmp inicio1

            proxmain:
                evento
                calcmedia       

            jmp inicio1

        ;finaliza o codigo
        mov ah, 4ch 
        int 21h
        
    main endp



;procedimento para tratar a posição do mouse e determinar a área de clique, testando sempre onde ele está
botoes proc
    confmouse
    mov i[0], 4
    mov actx, 0
    mov acty, 0

    ;se o mousex for maior que 10 ele jmp para o testax2
    cmp mousex, 10
    ja testax2
    ret

    ;testax2 para verificar se o mousex é menor que 254, caso seja, ele da um jump para testa y
    testax2:
        cmp mousex, 254
        jb testay

    ret

    ;testay para testar se o mousey é maior que 30, caso seja ele testa se é menor que 191 
    testay:
        cmp mousey, 30
        ja testay2
        ret

    testay2:
        cmp mousey, 191
        jb proxb
        ret

    ;daqui em diante é para determinar o actx e acty (x e y no momento atual)
    proxb:
        cmp mousex, 140
        ja proxb1
        mov i[0], 0
        mov actx, 11
        jmp proy

    proxb1: 
        cmp mousex, 178
        ja proxb2
        mov i[0], 1
        mov actx, 141
        jmp proy

    proxb2:
        cmp mousex, 216
        ja proxb3
        mov i[0], 2
        mov actx, 179
        jmp proy
    
    proxb3:
        mov i[0], 3  
        mov actx, 217


    proy:
        cmp mousey, 62
        ja proy1
        mov i[1], 0
        mov acty, 31
        ret
    proy1:
        cmp mousey, 94
        ja proy2
        mov i[1], 1
        mov acty, 63
        ret
    proy2:
        cmp mousey, 126
        ja proy3
        mov i[1], 2
        mov acty, 95
        ret
    proy3:
        cmp mousey, 158
        ja proy4
        mov i[1], 3
        mov acty, 127
        ret
    proy4:
        mov i[1], 4
        mov acty, 159

    ret

botoes endp

;procedimento para digitar um número
digitanum proc
    pushall
    mov bl, 11
    mov notac[0], bl
    mov notac[1], bl
    xor bx, bx
    xor cx, cx
    mov dh, i[1]
    mov ax, 4
    mul dh
    add al, 5
    mov posy, al
    mov dh, i[0]
    dec dl
    mov ax, 3
    mul dl
    add al, i[1]
    mov dl, al
    xor dh, dh
    mov si, dx 
    mov cl, 11
    mov nota[si], cl

    cmp i[0], 1
    jne proxdnum
    mov posx, 19
    mov cl, posx
    dec cl
    jmp continuadn

    proxdnum:
        cmp i[0], 2
        jne proxdnum1
        mov posx, 24
        mov cl, posx
        dec cl
        jmp continuadn

    proxdnum1:
        mov posx, 29
        mov cl, posx
        dec cl

    continuadn:
        mov ch, 1
        add ch, posy


    string limpa, 2, cl, posy, 0
    string seta1, 1, cl, posy, 14


    dec posx


    digitnum:
        mov ah, 08
        int 21h
        cmp al, 8
        je backspacenum

        jmp proxdnumb

        backspacenum:
            or bl, bl
            jz digitnum
            dec bl
            mov si, offset notac

        add si, bx
        mov al, 11
        mov [si], al
        string limpa, 1, cl, posy, 0
        dec cl
        string seta1, 1, cl, posy, 14
        or bx, bx
        jnz backspacenum1
        jmp digitnum

        backspacenum1:
            mov si, offset notac 
            string [si], bl, cl, posy, 15
            string seta1, 1, cl, posy, 14

        jmp digitnum


        proxdnumb:
            cmp al, 13
            jne proxdnumb1
            jmp foradigitnum

        proxdnumb1:
            cmp bl, 2
            jb proxdnumb2
            jmp digitnum
        proxdnumb2:
            mov si, offset notac
            add si, bx
            mov [si], al
            inc bl
            mov si, offset notac
            string [si], 2, posx, posy, 15
            inc cl
            string seta1, 1, cl, posy, 14

        jmp digitnum 
            
        foradigitnum:
            string limpa, 1, cl, posy, 0
            xor bx, bx
            mov dl, i[1]
            mov bl, i[0]
            dec bl
            mov ax, 3
            mul dl
            mov si, offset nota
            add si, ax
            add si, bx
            mov ah, notac[0]
            mov al, notac[1]
            mov dl, 11
            cmp notac[1], dl
            jne proxfdn
            
            mov notac[1], ah
            mov notac[0], dl
            jmp tavalendo

            proxfdn:
                cmp ah, '1'
                je confdez
                cmp ah, '0'
                je tavalendo
                cmp ah, 11
                je tavalendo
                jmp limpafim

        tavalendo:
            mov al, notac[1]
            conferenum
            or ah, ah
            jz limpafim

            sub al, 30h

            mov [si], al
            jmp fimnormal

        confdez:
            mov ah, notac[1]
            cmp ah, '0'
            jne limpafim

            mov al, 10

            mov [si], al
            jmp fimnormal

        limpafim:    
            mov cl, 11
            mov [si], cl
            mov cl, posx
            string limpa, 2, cl, posy, 0
        fimnormal:

        popall
        ret 
digitanum endp

;procedimento para digitar um nome
digitanome proc
    pushall
    xor bx, bx
    xor cx, cx
    mov dh, i[1]
    mov ax, 4
    mul dh
    add al, 5
    mov posx, 2
    mov posy, al

    
    string limpa, 15, posx, posy, 0

    string seta1, 1, 2, posy, 14


    digit:
        mov ah, 08
        int 21h

        cmp al, 13
        jne proxdgn1
        jmp foradigit

        proxdgn1:



        cmp al, 8
        je backspace

        jmp proxdn

        backspace:
        or bx, bx
        jz digit


        dec bx
        mov si, offset nome
        add si, bx
        mov al, 11
        mov [si], al
        string limpa, 1, cl, posy, 0
        dec cl
        string seta1, 1, cl, posy, 14
        or bx, bx
        jnz backspace1
        jmp digit

        backspace1:
        mov si, offset nome 
        string [si], bl, posx, posy, 15
        string seta1, 1, cl, posy, 14

        jmp digit
        proxdn: 
            cmp bx, 14
            jb prosseguedn

            jmp digit
            prosseguedn:

            proxdn1:
            mov si, offset nome
            add si, bx
            mov [si], al 
            mov si, offset nome
            inc bx 
            mov cl, bl
            add cl, posx
            string [si], bl, posx, posy, 15
            string seta1, 1, cl, posy, 14

            jmp digit


        foradigit:
            string limpa, 15, posx, posy, 0
            or bx, bx
            jz fimdg
            string nome, bl, posx, posy, 15

            fimdg:
    popall

    ret
digitanome endp



end main