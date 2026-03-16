######################################################
#		     input.asm			     #
# Lee y direcciona el input ingresado por el usuario #
#	       Daniel Quijada (20-10518)	     #
#	      Daniela Gragirena (19-10543)	     #
######################################################

#Pide una entrada al usuario, y decide que acción hacer en base a dicha entrada
funcionInput:

	#Limpia los espacios de memoria que contienen al input
	li	$t0,0
_fiLimpiarInput:
		beq	$t0,32,_fiLeerInput
		sb	$zero,input($t0)
		blt	$t0,17,_fiLimpiarInputAux
		addi	$t0,$t0,1
		j	_fiLimpiarInput
_fiLimpiarInputAux:
		sb	$zero,inputAux($t0)
		addi	$t0,$t0,1
		j	_fiLimpiarInput
	
_fiLeerInput:
	li	$v0,8
	la	$a0,input
	li	$a1,31
	syscall	#read_string
	
	jal	printSaltoLinea
	jal	arreglarInput
	
	#$t3 es el iterador y $t0 almacena el byte a verificar
	li	$t3,0
	lb	$t0,input
	
	#$t8 lleva la cuenta de cuántas veces se debe mover la hora de ser necesario
	li	$t8,0
	
	#Verifica si se debe mover la hora a una anterior
	beq	$t0,0x5e,horaPrevLoop
	
	#Verifica si se debe mover la hora a una siguiente
	beq	$t0,0x76,horaSigLoop
	
	#Verifica si se debe ir al día siguiente
	beq	$t0,0x3e,dsVerif
	
	#Verifica si se debe ir al día anterior
	#Si no, verifica si se debe ir a un día anterior específico
	#Si no, verifica si se debe ir al mes anterior
	beq	$t0,0x3c,dpVerif
	
	#Verifica si debe ir al siguiente día indicado
	beq	$t0,0x4c,sigLunVerif 
	beq	$t0,0x4d,sigMarVerif
	beq	$t0,0x4a,sigJueVerif
	beq	$t0,0x56,sigVieVerif
	beq	$t0,0x53,sigSabVerif
	beq	$t0,0x44,sigDomVerif
	
	#Verifica si se debe ir al mes siguiente
	beq	$t0,0x2d,mesSigVerif
	
	#Verifica si se debe borrar una cita
	beq	$t0,0x64,delVerif
	
	#Si no inicia con un carácter de un comando, salta a agendar
	j	agendar
	
	#Verifica si se debe mover el cursor de la hora a una anterior y guarda cuántas veces se debe mover en $t8
	horaPrevLoop:
		addi	$t8,$t8,1
		jal	verifChar
		beq	$t0,0x5e,horaPrevLoop
	endHoraPrevLoop:
		jal	verifChar
		beqz	$t0,horaPrev
		j	agendar
	
	#Verifica si se debe mover el cursor de la hora a una siguiente y guarda cuántas veces se debe mover en $t8
	horaSigLoop:
		addi	$t8,$t8,1
		jal	verifChar
		beq	$t0,0x76,horaSigLoop
	endHoraSigLoop:
		jal	verifChar
		beqz	$t0,horaSig
		j	agendar
		
_contInput:	
	#Verifica si se debe ir al día anterior indicado
	beq	$t0,0x4c,lunPrevVerif 
	beq	$t0,0x4d,marPrevVerif
	beq	$t0,0x4a,juePrevVerif
	beq	$t0,0x56,viePrevVerif
	beq	$t0,0x53,sabPrevVerif
	beq	$t0,0x44,domPrevVerif
	
	#Verifica si se debe ir al mes anterior
	bne	$t0,0x2d,agendar
	jal	verifChar
	beqz	$t0,mesPrev
	j	agendar

#Verifica si se debe ir al día siguiente
dsVerif:	
	jal	verifChar
	beqz	$t0,diaSig
	j	agendar

#Verifica si se debe ir al día anterior
dpVerif:	
	jal	verifChar
	beqz	$t0,diaPrev
	#Verifica otros casos de input que inician con "<"
	j	_contInput

#Verifica si se debe ir al mes siguiente
mesSigVerif:
	jal	verifChar
	bne	$t0,0x3e,agendar
	jal	verifChar
	beqz	$t0,mesSig
	j	agendar

#Verifica si se debe ir al siguiente lunes
sigLunVerif:
	jal	verifChar
	bne	$t0,0x3e,agendar
	jal	verifChar
	beqz	$t0,sigLun
	j	agendar
	
#Verifica si se debe ir al siguiente martes
sigMarVerif:
	jal	verifChar
	bne	$t0,0x3e,agendar
	jal	verifChar
	beqz	$t0,sigMar
	j	agendar

#Verifica si se debe ir al siguiente jueves
sigJueVerif:
	jal	verifChar
	bne	$t0,0x3e,agendar
	jal	verifChar
	beqz	$t0,sigJue
	j	agendar

#Verifica si se debe ir al siguiente viernes
sigVieVerif:
	jal	verifChar
	bne	$t0,0x3e,agendar
	jal	verifChar
	beqz	$t0,sigVie
	j	agendar
	
#Verifica si se debe ir al siguiente sábado
sigSabVerif:
	jal	verifChar
	bne	$t0,0x3e,agendar
	jal	verifChar
	beqz	$t0,sigSab
	j	agendar

#Verifica si se debe ir al siguiente domingo
sigDomVerif:
	jal	verifChar
	bne	$t0,0x3e,agendar
	jal	verifChar
	beqz	$t0,sigDom
	j	agendar
	
#Verifica si se debe ir al lunes anterior
lunPrevVerif:

	jal	verifChar
	beqz	$t0,lunPrev
	j	agendar
	
#Verifica si se debe ir al martes anterior
marPrevVerif:
	jal	verifChar
	beqz	$t0,marPrev
	j	agendar

#Verifica si se debe ir al jueves anterior
juePrevVerif:
	jal	verifChar
	beqz	$t0,juePrev
	j	agendar

#Verifica si se debe ir al viernes anterior
viePrevVerif:
	jal	verifChar
	beqz	$t0,viePrev
	j	agendar
	
#Verifica si se debe ir al sábado anterior
sabPrevVerif:
	jal	verifChar
	beqz	$t0,sabPrev
	j	agendar

#Verifica si se debe ir al domingo anterior
domPrevVerif:
	jal	verifChar
	beqz	$t0,domPrev
	j	agendar

#Verifica si se debe borrar una cita
delVerif:
	jal	verifChar
	bne	$t0,0x65,agendar
	jal	verifChar
	bne	$t0,0x6c,agendar
	jal	verifChar
	beqz	$t0,borrarCita

	j	agendar

#Elimina el caracter '\n' al final del input, mueve los primeros 15 caracteres del input a la dirección de memoria inputAux y
# cuenta cuantos caracteres tiene cada parte del input
arreglarInput:
	la	$t0,input
	lb	$t1,($t0)
	li	$t2,0 #Contador
	_aiLoop:
		beqz 	$t1,_endAiLoop
		beq	$t1,'\n',_endAiLoop
		bge	$t2,15,_aiContinueLoop
		sb	$t1,inputAux($t2)
		_aiContinueLoop:
		addi	$t0,$t0,1
		lb	$t1,($t0)
		addi	$t2,$t2,1
		j	_aiLoop	
	_endAiLoop:
	sb	$zero,($t0)
	
	ble	$t2,15,_aiMenorIgual15
	j	_aiMayor15
	
_aiMenorIgual15:
	sb	$zero,input+31
	sb	$t2,inputAux+16
	j	_aiEnd
	
_aiMayor15:
	li	$t0,15
	sb	$t0,inputAux+16
	sub	$t2,$t2,$t0
	sb	$t2,input+31
	
_aiEnd:
jr	$ra
