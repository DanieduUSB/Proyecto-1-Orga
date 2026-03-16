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
	
	#$t3 es el iterador
	li	$t3,0
	lw	$t0,input
	lb	$t0,($t0)
	
	#$t8 lleva la cuenta de cuántas veces se debe mover la hora de ser necesario
	li	$t8,0
	
	#Verifica si se debe mover la hora a una anterior
	beq	$t0,0x5e,horaPrevLoop
	
	#Verifica si se debe mover la hora a una siguiente
	beq	$t0,0x76,horaSigLoop
	
	#Verifica si se debe ir al día siguiente
	beq	$t0,0x3e,dsVerif
	
	#Verifica si se debe ir al día anterior
	beq	$t0,0x3c,dpVerif
	
	#Verifica si debe ir al siguiente día indicado
	beq	$t0,0x4c,sigLunVerif 
	beq	$t0,0x4d,sigMarVerif
	beq	$t0,0x4a,sigJueVerif
	beq	$t0,0x56,sigVieVerif
	beq	$t0,0x53,sigSabVerif
	beq	$t0,0x44,sigDomVerif
	
	#Verifica si se debe ir al mes siguiente
	beq	$t0,0x2d,mesPrev
	
	#Verifica si se debe mover el cursor de la hora a una anterior y guarda cuántas veces se debe mover en $t8
	horaPrevLoop:
		addi	$t8,$t8,1
		addi 	$t3,$t3,1
		lw	$t0,input($t3)
		lb	$t0,($t0)
		beq	$t0,0x5e,horaPrevLoop
	endHoraPrevLoop:
		j	agendar
	
	#Verifica si se debe mover el cursor de la hora a una siguiente y guarda cuántas veces se debe mover en $t8
	horaSigLoop:
		addi	$t8,$t8,1
		addi 	$t3,$t3,1
		lw	$t0,input($t3)
		lb	$t0,($t0)
		beq	$t0,0x76,horaSigLoop
	endHoraSigLoop:
		j	agendar
		
	#Verifica si se debe borrar una cita
	beq	$t0,0x64,delVerif
	
_contInput:	
	#Verifica si se debe ir al día anterior indicado
	addi	$t3,$t3,1
	lw	$t0,input($t3)
	lb	$t0,($t0)
	beq	$t0,0x4c,lunPrevVerif 
	beq	$t0,0x4d,marPrevVerif
	beq	$t0,0x4a,juePrevVerif
	beq	$t0,0x56,viePrevVerif
	beq	$t0,0x53,sabPrevVerif
	beq	$t0,0x44,domPrevVerif
	
	#Verifica si se debe ir al mes anterior
	addi	$t3,$t3,1
	lw	$t0,input($t3)
	lb	$t0,($t0)
	beq	$t0,0x2d,mesPrevVerif	
	
dsVerif:	
	addi	$t3,$t3,1
	lw	$t0,input($t3)
	lb	$t0,($t0)
	beqz	$t0,diaSig
	
dpVerif:	
	addi	$t3,$t3,1
	lw	$t0,input($t3)
	lb	$t0,($t0)
	beqz	$t0,diaPrev
	j	_contInput

#Verifica si se debe ir al siguiente lunes
sigLunVerif:
	addi	$t3,$t3,1
	lw	$t0,input($t3)
	lb	$t0,($t0)
	beq	$t0,0x3e,sigLun
	j	agendar
	
#Verifica si se debe ir al siguiente martes
sigMarVerif:
	addi	$t3,$t3,1
	lw	$t0,input($t3)
	lb	$t0,($t0)
	beq	$t0,0x3e,sigMar
	j	agendar

#Verifica si se debe ir al siguiente jueves
sigJueVerif:
	addi	$t3,$t3,1
	lw	$t0,input($t3)
	lb	$t0,($t0)
	beq	$t0,0x3e,sigJue
	j	agendar

#Verifica si se debe ir al siguiente viernes
sigVieVerif:
	addi	$t3,$t3,1
	lw	$t0,input($t3)
	lb	$t0,($t0)
	beq	$t0,0x3e,sigVie
	j	agendar
	
#Verifica si se debe ir al siguiente sábado
sigSabVerif:
	addi	$t3,$t3,1
	lw	$t0,input($t3)
	lb	$t0,($t0)
	beq	$t0,0x3e,sigSab
	j	agendar

#Verifica si se debe ir al siguiente domingo
sigDomVerif:
	addi	$t3,$t3,1
	lw	$t0,input($t3)
	lb	$t0,($t0)
	beq	$t0,0x3e,sigDom
	j	agendar
	
#Verifica si se debe ir al lunes anterior
lunPrevVerif:
	addi	$t3,$t3,1
	lw	$t0,input($t3)
	lb	$t0,($t0)
	beq	$t0,0x4c,lunPrev
	j	agendar
	
#Verifica si se debe ir al martes anterior
marPrevVerif:
	addi	$t3,$t3,1
	lw	$t0,input($t3)
	lb	$t0,($t0)
	beq	$t0,0x4d,marPrev
	j	agendar

#Verifica si se debe ir al jueves anterior
juePrevVerif:
	addi	$t3,$t3,1
	lw	$t0,input($t3)
	lb	$t0,($t0)
	beq	$t0,0x4a,juePrev
	j	agendar

#Verifica si se debe ir al viernes anterior
viePrevVerif:
	addi	$t3,$t3,1
	lw	$t0,input($t3)
	lb	$t0,($t0)
	beq	$t0,0x56,viePrev
	j	agendar
	
#Verifica si se debe ir al sábado anterior
sabPrevVerif:
	addi	$t3,$t3,1
	lw	$t0,input($t3)
	lb	$t0,($t0)
	beq	$t0,0x53,sabPrev
	j	agendar

#Verifica si se debe ir al domingo anterior
domPrevVerif:
	addi	$t3,$t3,1
	lw	$t0,input($t3)
	lb	$t0,($t0)
	beq	$t0,0x44,domPrev
	j	agendar

#Verifica si se debe ir al mes anterior
mesPrevVerif:
	addi	$t3,$t3,1
	lw	$t0,input($t3)
	lb	$t0,($t0)
	beq	$t0,0x3e,mesPrev
	j	agendar

#Verifica si se debe borrar una cita
delVerif:
	addi	$t3,$t3,1
	lw	$t0,input($t3)
	lb	$t0,($t0)
	bne	$t0,0x65,agendar
	addi	$t3,$t3,1
	lw	$t0,input($t3)
	lb	$t0,($t0)
	bne	$t0,0x6c,agendar
	addi	$t3,$t3,1
	lw	$t0,input($t3)
	lb	$t0,($t0)
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
