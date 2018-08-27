.section .text
	.global controller_asm

.type controller_asm, @function

controller_asm:

	pushl %ebp			#salviamo %ebp nello stack
	movl %esp, %ebp			#mettiamo il contenuto di %esp nel nuovo %ebp
	movl 12(%ebp), %edi		#carichiamo l'indirizzo di bufferout_asm in %edi
	movl 8(%ebp), %esi		#carichiamo l'indirizzo di bufferin in %esi
	movb $48, %dl			#azzeriamo %dl (unità NCK)
	movb $48, %dh			#azzeriamo %dh (decine NCK)

while:
	cmpb $0, (%esi)			#confrontiamo il primo byte di bufferin con il carattere nullo	
	je fine_ciclo			#se abbiamo raggiunto il carattere nullo usciamo dal ciclo
	cmpb $48, (%esi)		#confrontiamo il contenuto di %esi (INIT) con 0 in carattere
	je nulla			#se è uguale a 0 saltiamo alla copia della stringa vuota
	cmpb $49, 2(%esi)		#altrimenti confrontiamo il contenuto di %esi (RESET) con 1
	je nulla			#se è uguale a 1 saltiamo alla copia della stringa vuota
	cmpb $48, 4(%esi)		#altrimenti confrontiamo il contenuto di %esi (centinaia PH) con 0
	jne basico			#se è diverso da 0 saltiamo a basico
	cmpb $54, 5(%esi)		#altrimenti confrontiamo il contenuto di %esi (decine PH) con 6
	jl acido			#se è minore di 6 saltiamo ad acido
	cmpb $56, 5(%esi)		#altrimenti confrontiamo il contenuto di %esi (decine PH) con 8
	jl neutro			#se è minore di 8 saltiamo a neutro
	jg basico			#se è maggiore di 8 saltiamo a basico
	cmpb $48, 6(%esi)		#altrimenti confrontiamo il contenuto di %esi (unità PH) con 0
	jg basico			#se è maggiore di 0 saltiamo a basico
	movb $78, %bl			#altrimenti salviamo il carattere 'N' in %bl
	jmp fine_stato			#saltiamo in ogni caso alla fine del controllo dello stato del sistema

basico:
	movb $66, %bl			#salviamo il carattere 'B' in %bl
	jmp fine_stato			#saltiamo in ogni caso alla fine del controllo dello stato del sistema

acido:
	movb $65, %bl			#salviamo il carattere 'A' in %bl
	jmp fine_stato			#saltiamo in ogni caso alla fine del controllo dello stato del sistema

neutro:
	movb $78, %bl			#salviamo il carattere 'N' in %bl

fine_stato:
	addl $8, %esi			#aggiorniamo %esi perché punti alla riga successiva
	movb %bl, (%edi)		#salviamo il carattere di ST in bufferout_asm
	movb $44, 1(%edi)		#salviamo il carattere ',' in bufferout_asm
	cmpb %cl, %bl			#confrontiamo %cl (OLDST) con %bl (ST)
	je incrementa			#saltiamo ad incrementa se sono uguali
	movb %bl, %cl			#copiamo %bl (ST) in %cl (OLDST)
	movb $48, %dl			#azzeriamo %dl (unità NCK)
	movb $48, %dh			#azzeriamo %dh (decine NCK)

salvataggio_NCK:
	movb %dh, 2(%edi)		#salviamo il contenuto di %dh (decine NCK) in bufferout_asm
	movb %dl, 3(%edi)		#salviamo il contenuto di %dl (unità NCK) in bufferout_asm

no_vlv:
	movb $44, 4(%edi)		#salviamo il carattere ',' in bufferout_asm
	movb $45, 5(%edi)		#salviamo il carattere '-' in bufferout_asm
	movb $45, 6(%edi)		#salviamo il carattere '-' in bufferout_asm

line_feed:
	movb $10, 7(%edi)		#salviamo il carattere '\n' in bufferout_asm
	addl $8, %edi			#incrementiamo bufferout_asm di 8
	jmp while			#saltiamo all'inizio del ciclo

incrementa:
	movb %bl, %cl			#copiamo %bl (ST) in %cl (OLDST)
	cmpb $57, %dl			#confrontiamo il contenuto di %dl (unità NCK) con 9
	je incrementa_decine		#se è uguale a 9 dobbiamo incrementare le decine, saltiamo a incrementa_decine
	inc %dl				#altrimenti incrementiamo %dl (unità NCK) di 1
	cmpb $48, %dh			#confrontiamo il contenuto di %dh (decine NCK) con 0
	je no_decine			#se è uguale a 0 saltiamo a no_decine 
	cmpb $78, %bl			#altrimenti confronta il contenuto di %bl (ST) con il carattere 'N'
	je salvataggio_NCK		#se è uguale saltiamo al salvataggio di NCK in bufferout_asm
	jmp confronto			#altrimenti saltiamo a confronto

incrementa_decine:
	movb $48, %dl			#azzeriamo %dl 
	inc %dh				#incrementiamo il contenuto di %dh (decine NCK) di 1
	jmp confronto			#saltiamo a confronto

no_decine:
	cmpb $52, %dl			#confrontiamo il contenuto di %dl (unità NCK) con 4
	jle salvataggio_NCK		#se è minore uguale a 4 saltiamo al salvataggio di NCK in bufferout_asm
	cmpb $78, %bl			#altrimenti confrontiamo il contenuto di %bl con il carattere 'N'
	je salvataggio_NCK		#se è uguale saltiamo al salvataggio di NCK in bufferout_asm

confronto:
	movb %dh, 2(%edi)		#salviamo il contenuto di %dh (decine NCK) in bufferout_asm
	movb %dl, 3(%edi)		#salviamo il contenuto di %dl (unità NCK) in bufferout_asm
	cmpb $65, %bl			#confrontiamo %cl (OLDST) con 'A'
	jne vlv_acida			#se non è uguale saltiamo ad acida
	movb $44, 4(%edi)		#altrimenti salviamo il carattere ',' in bufferout_asm
	movb $66, 5(%edi)		#salviamo il carattere 'B' in bufferout_asm
	jmp lettera_s			#saltiamo all'aggiunta del carattere 'S'

vlv_acida:
	cmpb $66, %bl			#confrontiamo %cl (OLDST) con 'B'
	jne no_vlv			#se non è uguale saltiamo al salvataggio di nessuna valvola
	movb $44, 4(%edi)		#altrimenti salviamo il carattere ',' in bufferout_asm
	movb $65, 5(%edi)		#salviamo il carattere 'A' in bufferout_asm

lettera_s:
	movb $83, 6(%edi)		#salviamo il carattere 'S' in bufferout_asm
	jmp line_feed			#saltiamo al salvataggio del carattere '\n'

nulla:
	movb $45, %cl			#salviamo il carattere '-' in %cl (OLDST)
	movb $45, (%edi)
	movb $44, 1(%edi)
	movb $45, 2(%edi)
	movb $45, 3(%edi)
	movb $44, 4(%edi)
	movb $45, 5(%edi)
	movb $45, 6(%edi)
	movb $10, 7(%edi)
	addl $8, %edi
	addl $8, %esi			#aggiorniamo %esi perché punti alla riga successiva
	jmp while			#saltiamo all'inizio del ciclo
	
fine_ciclo:
	movb $0, 7(%edi)		#salviamo il carattere nullo '\0' alla fine di bufferout_asm
	popl %ebp			#ripristiniamo il contenuto di %ebp
	
ret	
