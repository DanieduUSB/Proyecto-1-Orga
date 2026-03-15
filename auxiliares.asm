############################################
# 	       auxiliares.asm		   #
# Funciones auxiliares varias del programa #
#	  Daniel Quijada (20-10518)	   #
#	 Daniela Gragirena (19-10543)	   #
############################################

#Coloca los strings de cada mes en un array
cargarMeses:
	la	$t0,enero
	sw	$t0,meses
	
	la	$t0,febrero
	sw	$t0,meses+4
	
	la	$t0,marzo
	sw	$t0,meses+8
	
	la	$t0,abril
	sw	$t0,meses+12
	
	la	$t0,mayo
	sw	$t0,meses+16
	
	la	$t0,junio
	sw	$t0,meses+20
	
	la	$t0,julio
	sw	$t0,meses+24
	
	la	$t0,agosto
	sw	$t0,meses+28
	
	la	$t0,septiembre
	sw	$t0,meses+32
	
	la	$t0,octubre
	sw	$t0,meses+36
	
	la	$t0,noviembre
	sw	$t0,meses+40
	
	la	$t0,diciembre
	sw	$t0,meses+44

jr $ra

#Utiliza el algoritmo de división no restauradora para dividir el número unsigned de 64 bits $a1:$a0 entre el número unsigned de
# máximo 32 bits $a2. Retorna el cociente en $a0 y el resto en $v1
div64Bits:
	li	$t0,64 #Contador
	li	$v1,0  #Resto

_div64loop:	
		#Shift a la izquierda de $v1:$a1:$a0
		sll	$v1,$v1,1
		srl	$t1,$a1,31
		or	$v1,$v1,$t1
		sll	$a1,$a1,1
		srl	$t1,$a0,31
		or	$a1,$a1,$t1
		sll	$a0,$a0,1
		
		#Si $v1<0, $v1 = $v1 + $a2 (Resto + divisor)
		bltz	$v1,_sumar
		#Si $v1>=0, $v1 = $v1-$a2 (Resto - divisor)
		subu	$v1,$v1,$a2
		j	_checkBit
	_sumar:
		addu	$v1,$v1,$a2
		
	_checkBit:
		#Si $v1<0, El bit menos significativo del cociente (De $a0) es 0. No se hace nada
		bltz	$v1,_div64LoopContinuar
		#Si $v1>=0, El bit menos significativo del cociente (De $a0) es 1. Se hace un or
		ori	$a0,$a0,1
		
	_div64LoopContinuar:
		subi	$t0,$t0,1
		#Si $t0 es igual a 0, termina el ciclo
		beqz	$t0,_div64EndLoop
	j	_div64loop
_div64EndLoop:
	bgez	$v1,_div64End
	#Si $v1 < 0, $v1 = $v1 + $a2 (Resto + Divisor) para restaurar el resto
	addu	$v1,$v1,$a2
	
_div64End:
jr	$ra

#Encuentra el día y fecha actual a partir del syscall 30. Guarda la fecha en los registros $s4-$s7 tal que:
# $s4 contiene el día de la semana (Un número del 0 al 6 donde 0 es lunes, 1 es martes, .., 6 es domingo)
# $s5 contiene el número del día
# $s6 contiene el mes (Un número del 0 al 11 donde 0 es enero, 1 es febrero, .., 11 es diciembre)
# $s7 contiene el año
fechaActual:
sw	$ra,($sp)
addiu	$sp,$sp,4
	
	li	$v0,30
	syscall #system_time
	
	#Se divide el número de 64 bits resultante entre 86400000 para convertir de milisegundos a días. Esto nos da el número
	# de días desde el 1ro de enero de 1970 hasta hoy en $a0
	li	$a2,86400000
	jal	div64Bits
	
	#Divide el número entre 7, obtiene el resto y le suma 3 para obtener el día de la semana. El 3 es debido a que al hacer el
	# módulo se asume que 1ro de enero de 1970 es lunes, pero en realidad es jueves, por lo que hay que arreglar este offset
	li	$t0,7
	div	$a0,$t0
	mfhi	$s4
	addi	$s4,$s4,3
	blt	$s4,7,_faContinuar
	subi	$s4,$s4,7
_faContinuar:
	
	#Se divide $a0 entre 365 para obtener los años concurridos desde 1970 hasta el año presente
	div	$t0,$a0,365
	addi	$s7,$t0,1970
	
	#Se divide $t0 entre 4 para obtener el número de años bisiestos desde 1970 hasta el año presente
	div	$t1,$t0,4
	
	#Se multiplica $t0 por 365 y se le suma $t1 para obtener el número exacto de días desde el 1ro de enero de 1970 hasta
	# el 1ro de enero del año actual, se le resta 1 al resultado para obtener el número de días concurridos hasta el 31 de
	# diciembre del año anterior y se resta este resultado a $a0 para obtener el número de días concurridos este año.
	mul	$s5,$t0,365
	add	$s5,$s5,$t1
	subi	$s5,$s5,1
	sub	$s5,$a0,$s5
	
	#Se itera sobre los meses para buscar el mes actual y obtener el día del mes actual
	li	$s6,0
	lw	$t2,meses
	lb	$t2,1($t2)
_faLoop:
		ble	$s5,$t2,_faEndLoop
		sub	$s5,$s5,$t2
		addi	$s6,$s6,1
		mul	$t1,$s6,4
		lw	$t2,meses($t1)
		lb	$t2,1($t2)
	j	_faLoop
_faEndLoop:
	
subiu	$sp,$sp,4
lw	$ra,($sp)
jr	$ra

#Calcula el identificador del día actual y lo almacena en $t5
diaAct:
	sw	$ra,($sp)
	addiu	$sp,$sp,4
	li	$t1,7
	div	$s3,$t1
	mfhi	$t5
	bgez	$t5,seguir
	#Número negativo
	addi	$t5,$t5,7
	
seguir:	add	$t5,$t5,$s4
	blt	$t5,7,endDiaAct
	subi	$t5,$t5,7
	
endDiaAct:
subiu	$sp,$sp,4
lw	$ra,($sp)
jr	$ra

#Calcula el número de días del mes del día actual y lo almacena en $t7, almacena el día actual en $t5
mdActual:
sw	$ra,($sp)
addiu	$sp,$sp,4
	
	mul 	$t1,$s6,4
	lw	$t7,meses($t1)
	lb	$t7,1($t7)
	
	sub	$t1,$t7,$s5 #Número de días desde el día 0 hasta el final del mes del día 0
	
	bltz	$s3,diaNegativo #Caso día actual negativo
	
	sub	$t1,$s3,$t1 #Se calcula la cantidad de días entre el día actual y el inicio del mes siguiente al mes del día 0
	move	$t4,$t1
	move	$t3,$s6
	
	#El día actual se encuentra en el mes 0
	move 	$t2,$t1
	blez	$t1,endLoopMes
	
	loopMes:
		addi	$t3,$t3,1 #$t3 almacena el mes de la iteración actual
		beq	$t3,12,casoFin
		mul	$t1,$t3,4
		lw	$t7,meses($t1)
		lb	$t7,1($t7) #$t7 ahora tiene el número de días del mes siguiente
		sub	$t2,$t4,$t7
		move	$t4,$t2
		bgez	$t2,loopMes
		j	endLoopMes
		casoFin:
			li 	$t3,-1
			j	loopMes
	endLoopMes:
	
	#El día actual pertenece al mes identificado por $t3 que tiene $t2 días
	add	$t5,$t7,$t2 #$t5 almacena el día actual
	j	endMdActual
	
	diaNegativo:
	add 	$t1,$s3,$s5 #Se calcula la cantidad de días entre el día actual y el final del mes anterior al mes del día 0
	move	$t4,$t1
	move 	$t3,$s6
		
	loopMesNeg:
		beqz	$t3,casoIni
		subi	$t3,$t3,1 #$t3 almacena el mes de la iteración actual
		mul	$t1,$t3,4
		lw	$t7,meses($t1)
		lb	$t7,1($t7) #$t7 ahora tiene el número de días del mes anterior
		add	$t2,$t4,$t7
		move	$t4,$t2
		blez	$t2,loopMesNeg
		j	endLoopMesNeg
		casoIni:
			li 	$t3,12
			j	loopMesNeg
	endLoopMesNeg:
	
	#El día actual pertenece al mes identificado por $t3 que tiene $t7 días
	move	$t5,$t2 #$t5 almacena el día actual
	
endMdActual:
subiu	$sp,$sp,4
lw	$ra,($sp)
jr	$ra