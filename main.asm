INCLUDE Irvine32.inc
INCLUDE macros.inc

.data
;int birdPos = WIN_WIDTH/2;
;int score = 0;
;int bullets[20][4];
;int bulletsLife[20];
;int bIndex = 0;
;int enemyY[3];
;int enemyX[3];
;int enemyFlag[3];
;char bird[3][5] = { ' ',' ','±',' ',' ',
;					'|','±','±','±','|',
;					'±','±','±','±','±' }; 

 ;   enemyX   DWORD 5, 10, 15, 20, 25
  ;  enemyY   DWORD 5, 5, 5, 5, 5

     bulletsLife DWORD 20 DUP(?)
    bird DWORD 3 DUP (5 DUP (?)) ; Assuming a 3x5 array for the bird
    bullets DWORD 20 DUP (4 DUP (?)) ; Assuming 20 bullets with each having 4 elements
    op BYTE ?
score DWORD 0
bIndex DWORD 0
    birdPos DWORD 35;70/2
    enemyX   DWORD 3 DUP(?)
    enemyY   DWORD 3 DUP(?)
    enemyFlag   DWORD 3 DUP(?)
    WIN_WIDTH DWORD 70
    SCREEN_WIDTH DWORD 90
    SCREEN_HEIGHT DWORD 26
    MENU_WIDTH DWORD 20
    GAP_SIZE DWORD 7
    Enemy_DIF DWORD 45
    consoleHandle HANDLE ?
    CursorPosition COORD <10, 5>
    ;setcursor func
    cursorVisible BYTE ?
    cursorSize DWORD ?

.code

gotoxy PROC
    ; Parameters: eax = X coordinate, ebx = Y coordinate
   ; mov CursorPosition.X, eax
    ;mov CursorPosition.Y, ebx
    ;invoke SetConsoleCursorPosition, consoleHandle, ADDR CursorPosition
    mov dh,al
    mov dl,bl
    call Gotoxy
    ret
gotoxy ENDP

drawBorder PROC
    ; Draw top border
    mov ecx, SCREEN_WIDTH
    mov edx, SCREEN_HEIGHT
    mov eax, 0
    call drawHorizontalBorder

    ; Draw left and right borders
    mov ecx, SCREEN_HEIGHT
    mov eax, 0
    mov ebx, SCREEN_WIDTH
    sub ebx, 1
    call drawVerticalBorders

    ; Draw vertical border at WIN_WIDTH
    mov ecx, SCREEN_HEIGHT
    mov eax, WIN_WIDTH
    call drawVerticalBorder

    ret
drawBorder ENDP
drawHorizontalBorder PROC
    ; Parameters: ecx = width, edx = height, eax = starting position
    push ebp
    mov ebp, esp

    mov ebx, eax ; Starting position
    mov esi, 0   ; Counter

drawHorizontalLoop:
    ; Draw a horizontal line
    mov dl, '±'
    call writechar

    inc ebx
    inc esi
    cmp esi, ecx
    jl drawHorizontalLoop

    ; Move to the next line
    mov eax, ebp
    call gotoxy
    pop ebp
    ret
drawHorizontalBorder ENDP

drawVerticalBorders PROC
    ; Parameters: ecx = height, eax = starting position, ebx = ending position
    push ebp
    mov ebp, esp

    mov esi, eax ; Starting position
    mov edi, ebx ; Ending position

drawVerticalBordersLoop:
    ; Draw left border
    mov dl, '±'
    mov eax, esi
    call gotoxy
    call writechar

    ; Draw right border
    mov dl, '±'
    mov eax, edi
    call gotoxy
    call writechar

    inc esi
    dec edi
    cmp esi, ecx
    jl drawVerticalBordersLoop

    pop ebp
    ret
drawVerticalBorders ENDP

drawVerticalBorder PROC
    ; Parameters: ecx = height, eax = position
    push ebp
    mov ebp, esp

    mov esi, 0 ; Counter

drawVerticalBorderLoop:
    ; Draw a vertical line
    mov dl, '±'
    mov eax, esi
    call gotoxy
    call writechar

    inc esi
    cmp esi, ecx
    jl drawVerticalBorderLoop

    pop ebp
    ret
drawVerticalBorder ENDP
genEnemy PROC
    ; Parameter: eax = index
    push ebp
    mov ebp, esp

    ; Calculate enemyX[ind] = 3 + rand() % (WIN_WIDTH - 10)
    mov eax,WIN_WIDTH
    SUB eax,3
    call RandomRange
    add eax, 3

    ; Store the result in enemyX[ind]
    mov ecx, ebp
    add ecx, 4 ; Offset to get the index parameter
    mov [ecx], eax

    pop ebp
    ret
genEnemy ENDP

drawEnemy PROC
    ; Check if enemyFlag[ind] == true
    cmp [enemyFlag], 1
    jne drawEnemyEnd

    ; Draw enemy at the specified position
    push eax ; Save eax
    push ebx ; Save ebx
    mov eax, [enemyX]
    mov ebx, [enemyY]
    call gotoxy
    mWrite ".."
    call crlf

    mov eax, enemyX
    add ebx, 1
    call gotoxy
    mWrite ""
    call crlf

    mov eax, enemyX
    add ebx, 1
    call gotoxy
    mWrite ""
    call crlf

    mov eax, enemyX
    add ebx, 1
    call gotoxy
    mWrite ".."
    call crlf
    pop ebx  ; Restore ebx
    pop eax  ; Restore eax
    drawEnemyEnd:
    ret
drawEnemy ENDP

eraseEnemy PROC
    ; Check if enemyFlag[ind] == true
    cmp enemyFlag, 1
    jne eraseEnemyEnd

    ; Erase enemy at the specified position
    mov eax, enemyX
    mov ebx, enemyY
    call gotoxy
    mWrite "    "
    call crlf

    mov eax, enemyX
    add ebx, 1
    call gotoxy
    mWrite "    "
    call crlf

    mov eax, enemyX
    add ebx, 1
    call gotoxy
    mWrite "    "
    call crlf

    mov eax, enemyX
    add ebx, 1
    call gotoxy
    mWrite "    "
    call crlf

eraseEnemyEnd:
    ret
eraseEnemy ENDP
resetEnemy PROC
    ; Parameter: eax = ind
    push ebp
    mov ebp, esp

    ; Call eraseEnemy function
    mov eax, [ebp + 8] ; Get the ind parameter
    call eraseEnemy

    ; Set enemyY[ind] = 4
    mov ecx, [ebp + 8] ; Get the ind parameter
    mov [enemyY + ecx * 4], 4

    ; Call genEnemy function
    mov eax, [ebp + 8] ; Get the ind parameter
    call genEnemy

    pop ebp
    ret
resetEnemy ENDP

genBullet PROC
    ; Generate a new bullet
    mov eax, bIndex
    mov [bullets + eax * 4], 22 ; x coordinate
    add eax, 1
    
    mov edx,birdPos
    add edx,4
    mov [bullets + eax * 4], edx ; y coordinate
    add eax, 1
    mov [bullets + eax * 4], 22 ; x coordinate
    add eax, 1

    mov edx,birdPos
    add edx,4
    mov [bullets + eax * 4],edx; birdPos + 4 ; y coordinate

    ; Increment bIndex
    add bIndex, 1
    cmp bIndex, 20
    jne genBulletEnd
    mov bIndex, 0

genBulletEnd:
    ret
genBullet ENDP


moveBullet PROC
    ; Move bullets based on the provided conditions
    mov ecx, 0 ; Initialize loop counter

moveBulletLoop:
    ; Check if bullets[i][0] > 2
    mov eax, [bullets + ecx * 4]
    cmp eax, 2
    jle moveBulletElse1

    ; Decrease bullets[i][0]
    sub [bullets + ecx * 4], 1
    jmp moveBulletNext

moveBulletElse1:
    ; Set bullets[i][0] to 0
    mov [bullets + ecx * 4], 0

moveBulletNext:
    ; Check if bullets[i][2] > 2
    mov eax, [bullets + ecx * 4 + 2]
    cmp eax, 2
    jle moveBulletElse2

    ; Decrease bullets[i][2]
    sub [bullets + ecx * 4 + 2], 1
    jmp moveBulletEnd

moveBulletElse2:
    ; Set bullets[i][2] to 0
    mov [bullets + ecx * 4 + 2], 0

moveBulletEnd:
    inc ecx
    cmp ecx, 20
    jl moveBulletLoop

    ret
moveBullet ENDP

drawBullets PROC
    ; Draw bullets on the screen
    mov ecx, 0 ; Initialize loop counter

drawBulletsLoop:
    ; Check if bullets[i][0] > 1
    mov eax, [bullets + ecx * 4]
    cmp eax, 1
    jle drawBulletsEnd

    ; Draw bullet at bullets[i][1], bullets[i][0]
    mov eax, [bullets + ecx * 4 + 1]
    mov ebx, [bullets + ecx * 4]
    call gotoxy
    mWrite "."

    ; Draw bullet at bullets[i][3], bullets[i][2]
    mov eax, [bullets + ecx * 4 + 3]
    mov ebx, [bullets + ecx * 4 + 2]
    call gotoxy
    mWrite "."

drawBulletsEnd:
    inc ecx
    cmp ecx, 20
    jl drawBulletsLoop

    ret
drawBullets ENDP

eraseBullets PROC
    ; Erase bullets from the screen
    mov ecx, 0 ; Initialize loop counter

eraseBulletsLoop:
    ; Check if bullets[i][0] >= 1
    mov eax, [bullets + ecx * 4]
    cmp eax, 1
    jae eraseBulletsDraw

    ; If bullets[i][0] is less than 1, set it to 0
    mov [bullets + ecx * 4], 0

eraseBulletsDraw:
    ; Erase bullet at bullets[i][1], bullets[i][0]
    mov eax, [bullets + ecx * 4 + 1]
    mov ebx, [bullets + ecx * 4]
    call gotoxy
    mWrite " "

    ; Erase bullet at bullets[i][3], bullets[i][2]
    mov eax, [bullets + ecx * 4 + 3]
    mov ebx, [bullets + ecx * 4 + 2]
    call gotoxy
    mWrite " "

    inc ecx
    cmp ecx, 20
    jl eraseBulletsLoop

    ret
eraseBullets ENDP


eraseBullet PROC
    ; Parameter: eax = index
    ; Erase a bullet at the specified index
    mov ecx, eax
    mov eax, [bullets + ecx * 4 + 1] ; x coordinate
    mov ebx, [bullets + ecx * 4] ; y coordinate
    call gotoxy
    mWrite " "

    mov eax, [bullets + ecx * 4 + 3] ; x coordinate
    mov ebx, [bullets + ecx * 4 + 2] ; y coordinate
    call gotoxy
    mWrite " "

    ret
eraseBullet ENDP

drawBird PROC
    ; Draw the bird on the screen
    mov ecx, 0 ; Initialize row counter

drawBirdRowLoop:
    mov ebx, 0 ; Initialize column counter

drawBirdColLoop:
    ; Draw bird[i][j] at j+birdPos, i+22
    mov eax, ebx
    add eax, birdPos
    mov ebx, ecx
    add ebx, 22
    call gotoxy
    ;bird
    mWrite"  ±  " 
	mWrite "|±±±|"
	mWrite "±±±±±"

    inc ebx
    cmp ebx, 5
    jl drawBirdColLoop

    inc ecx
    cmp ecx, 3
    jl drawBirdRowLoop

    ret
drawBird ENDP

eraseBird PROC
    ; Erase the bird from the screen
    mov ecx, 0 ; Initialize row counter

eraseBirdRowLoop:
    mov ebx, 0 ; Initialize column counter

eraseBirdColLoop:
    ; Erase bird[i][j] at j+birdPos, i+22
    mov eax, ebx
    add eax, birdPos
    mov ebx, ecx
    add ebx, 22
    call gotoxy
    mWrite " "

    inc ebx
    cmp ebx, 5
    jl eraseBirdColLoop

    inc ecx
    cmp ecx, 3
    jl eraseBirdRowLoop

    ret
eraseBird ENDP

collision PROC
    ; Check for collision
    mov eax, [enemyY + 0]
    add eax, 4
    cmp eax, 8
    jge collisionElse

    ; Calculate the difference between enemyX[0]+4 and birdPos
    mov eax, [enemyX + 0]
    add eax, 4
    sub eax, birdPos
    cmp eax, 0
    jl collisionElse

    ; Check if the difference is less than 8
    cmp eax, 8
    jl collisionIf
    jmp collisionElse

collisionIf:
    ; Collision occurred
    mov eax, 1
    ret

collisionElse:
    ; No collision
    mov eax, 0
    ret
collision ENDP

bulletHit PROC
    ; Check for bullet hit
    mov ecx, 0 ; Initialize outer loop counter

bulletHitOuterLoop:
    mov ebx, 0 ; Initialize inner loop counter

bulletHitInnerLoop:
    ; Calculate index in bullets array
    mov eax, ecx
    shl eax, 2
    add eax, ebx
    lea edx, [bullets + eax]

    ; Check if bullets[i][j] != 0
    mov eax, [edx]
    test eax, eax
    jz bulletHitInnerLoopEnd

    ; Check if bullets[i][j] >= enemyY[0] and <= enemyY[0]+4
    mov eax, [edx]
    cmp eax, [enemyY + 0]
    jl bulletHitInnerLoopEnd
    cmp eax, [enemyY + 0]
    add eax, 4
    jg bulletHitInnerLoopEnd

    ; Check if bullets[i][j+1] >= enemyX[0] and <= enemyX[0]+4
    mov eax, [edx + 4]
    cmp eax, [enemyX + 0]
    jl bulletHitInnerLoopEnd
    cmp eax, [enemyX + 0]
    add eax, 4
    jg bulletHitInnerLoopEnd

    ; Erase bullet, reset enemy, and return 1
    push ecx
    push ebx
    mov eax, ecx
    call eraseBullet
    pop ebx
    pop ecx


    mov esi,0
    mov [edx], esi
    ;mov [edx], 0
    call resetEnemy
    mov eax, 1
    ret

bulletHitInnerLoopEnd:
    add ebx, 4
    cmp ebx, 20
    jl bulletHitInnerLoop

bulletHitOuterLoopEnd:
    add ecx, 1
    cmp ecx, 20
    jl bulletHitOuterLoop

    ; No bullet hit
    mov eax, 0
    ret
bulletHit ENDP

gameover PROC
		call Clrscr
		call crlf
;		mWrite"			--------------------------" ,0
		call crlf
		mWrite"			-------- Game Over -------" 
		call crlf
		mWrite"			--------------------------" 
		call crlf
		call crlf
		mWrite"			Press any key to go back to menu."
		call ReadChar
	ret
gameover ENDP

updateScore PROC
    ; Update and display the score
    mov eax, WIN_WIDTH
    add eax, 7
    mov dh, 5
    call Gotoxy
    mWrite "Score: "
    mov eax, score
    call WriteDec
    call crlf
    ret
updateScore ENDP

instructions PROC
    ; Display instructions
    call Clrscr
    mWrite "Instructions"
    call crlf
    mWrite "----------------"
    call crlf
    mWrite "Press spacebar to make bird fly"
    call crlf
    call crlf
    mWrite "Press any key to go back to menu"
    call ReadChar
    ret
instructions ENDP

play PROC
;    mov birdPos, -1 + WIN_WIDTH/2
    mov eax,WIN_WIDTH
    mov edx,2
    DIV dx
    dec eax
    mov birdPos,eax
    mov score, 0
    mov enemyFlag[0], 1
    mov enemyFlag[1], 1
    mov enemyY[0], 4
    mov enemyY[1], 4

    ; Initialize bullets array
    mov ecx, 0
    mov esi, OFFSET bullets
    mov edx, OFFSET bullets
    mov eax, 4 * 20 * 4 ; 4 elements per bullet, 20 bullets, 4 bytes each
    rep stosd

    call Clrscr
   call drawBorder
    call genEnemy;, 0
    call genEnemy;1
    call updateScore

    mov edx, WIN_WIDTH + 5
    mov dh, 2
    call Gotoxy
    mWrite "Space Shooter"

    mov edx, WIN_WIDTH + 6
    mov dh, 4
    call Gotoxy
    mWrite "----------"

    mov edx, WIN_WIDTH + 6
    mov dh, 6
    call Gotoxy
    mWrite "----------"

    mov edx, WIN_WIDTH + 7
    mov dh, 12
    call Gotoxy
    mWrite "Control "

    mov edx, WIN_WIDTH + 7
    mov dh, 13
    call Gotoxy
    mWrite "-------- "

    mov edx, WIN_WIDTH + 2
    mov dh, 14
    call Gotoxy
    mWrite " A Key - Left"

    mov edx, WIN_WIDTH + 2
    mov dh, 15
    call Gotoxy
    mWrite " D Key - Right"

    mov edx, WIN_WIDTH + 2
    mov dh, 16
    call Gotoxy
    mWrite " Spacebar = Shoot"

    mov edx, 10
    mov dh, 5
    call Gotoxy
    mWrite "Press any key to start"
    call readchar
    mov edx, 10
    mov dh, 5
    call Gotoxy
    mWrite "                      "

    playLoop:
        ; Check for keyboard input
        call readchar
        test al, al
        jz playLoopSkipInput

        ; Get the pressed key
        call readchar
        movzx eax, al

        ; Handle the pressed key
        cmp eax, 'a'
        je playLoopLeft
        cmp eax, 'A'
        je playLoopLeft
        cmp eax, 'd'
        je playLoopRight
        cmp eax, 'D'
        je playLoopRight
        cmp eax, 32 ; Spacebar
        je playLoopShoot
        cmp eax, 27 ; Escape
        je playLoopEnd

        playLoopSkipInput:
            ; Your existing logic here...

        playLoopLeft:
            ; Handle left movement
            cmp birdPos, 2
            jle playLoopSkipInput
            sub birdPos, 2
            jmp playLoopSkipInput

        playLoopRight:
            ; Handle right movement
            mov eax, WIN_WIDTH
            sub eax, 7
            cmp birdPos, eax
            jge playLoopSkipInput
            add birdPos, 2
            jmp playLoopSkipInput

        playLoopShoot:
            ; Handle shooting
            call genBullet
            jmp playLoopSkipInput

        playLoopEnd:
            ; End the game
            jmp playEnd

    playEnd:
        ret
play ENDP

main PROC
    ; Initialize cursor and random seed
 ;   call setcursor, 0, 0
;    invoke srand, (unsigned)time(NULL)

mainLoop:
    ; Clear the screen
    call Clrscr

    ; Display menu options
    mov edx, 10
    mov dh, 5
    call Gotoxy
    mWrite " -------------------------- "

    mov edx, 10
    mov dh, 6
    call Gotoxy
    mWrite " |     Space Shooter      | "

    mov edx, 10
    mov dh, 7
    call Gotoxy
    mWrite " --------------------------"

    mov edx, 10
    mov dh, 9
    call Gotoxy
    mWrite "1. Start Game"

    mov edx, 10
    mov dh, 10
    call Gotoxy
    mWrite "2. Instructions"

    mov edx, 10
    mov dh, 11
    call Gotoxy
    mWrite "3. Quit"

    mov edx, 10
    mov dh, 13
    call Gotoxy
    mWrite "Select option: "

    ; Read user input
    call ReadChar
    mov op, al

    ; Process user input
    cmp op, '1'
    je startGame
    cmp op, '2'
    je showInstructions
    cmp op, '3'
    je exitProgram

    ; Invalid option, continue loop
    jmp mainLoop

startGame:
    ; Call the play function
    call play
    jmp mainLoop

showInstructions:
    ; Call the instructions function
    call instructions
    jmp mainLoop

exitProgram:
    ; Exit the program
    invoke ExitProcess, 0

main ENDP

END MAIN
