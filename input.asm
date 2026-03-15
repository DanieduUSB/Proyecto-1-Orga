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
	li	$a1,30
	syscall	#read_string
	
	jal	arreglarInput
	
#IMPORTANTE: Colocar acá que funciones llamar en base al input
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