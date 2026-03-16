#######################################
# 	     acciones.asm	      #
# Acciones realizables en el programa #
#	Daniel Quijada (20-10518)     #
#      Daniela Gragirena (19-10543)   #
#######################################

#Mueve el cursor de la línea actual (el asterisco del menú - $t9) el número de veces indicado en &t8, o hasta que $t9 sea 15
horaSig:
	beqz	$t8,endHoraSig
	beq	$t9,15,endHoraSig
	addi	$t9,$t9,1
	subi	$t8,$t8,1
	j	horaSig
endHoraSig:
jr	$ra

#Resta en 1 el cursor de la línea actual (el asterisco del menú - $t9) el número de veces indicado en &t8, o hasta que $t9 sea 0
horaPrev:
	beqz	$t8,endHoraPrev
	beqz	$t9,endHoraPrev
	subi	$t9,$t9,1
	subi	$t8,$t8,1
	j	horaPrev
endHoraPrev:
jr	$ra

#En base al input, revisa si debe hacer la instrucción de horaPrev, y cuántas veces en tal caso. Si sí debe hacerla, la ejecuta,
# en caso contrario salta a la instrucción agendar
checkHoraPrev:
endCheckHoraPrev:

#Mueve el día actual al siguiente.
diaSig:
	addi	$s3,$s3,1
endDiaSig:
jr	$ra

#Mueve el día actual al anterior.
diaPrev:
	subi	$s3,$s3,1
endDiaPrev:
jr	$ra

#Mueve el día actual al día especificado almacenado en $t7, el cual se encuentra en formato L>.
semSig:
	sw	$ra,($sp)
	addi	$sp,$sp,4
	
	#Se calcula el día actual
	jal	diaAct
	
	#Se verifica el día de la semana al que se debe mover el día actual y se desplaza una semana adelante hacia dicho día
	beq	$t7,0x3e4c,sigLun
	beq	$t7,0x3e4d,sigMar
	beq	$t7,0x3e4a,sigJue
	beq	$t7,0x3e56,sigVie
	beq	$t7,0x3e53,sigSab
	beq	$t7,0x3e44,sigDom
	j	endSemSig
	
	sigLun:	li	$t1,0
		j	_semSig
	sigMar:	
		li	$t1,1
		blt	$t5,1,restarSem
		j	_semSig
	sigJue:
		li	$t1,3
		blt	$t5,3,restarSem
		j	_semSig
	sigVie:	
		li	$t1,4
		blt	$t5,4,restarSem
		j	_semSig
	sigSab:
		li	$t1,5
		blt	$t5,5,restarSem
		j	_semSig
	sigDom:	
		li	$t1,6
		blt	$t5,6,restarSem
		j	_semSig
	#Se resta una semana cuando se está en la misma semana
	restarSem:
		subi	$t1,$t1,7
	_semSig:
		sub	$t1,$t1,$t5
		add	$s3,$s3,$t1	
endSemSig:

subiu	$sp,$sp,4
lw	$ra,($sp)
jr	$ra

#Mueve el día actual al día especificado almacenado en $t7, el cual se encuentra en formato <L.
semPrev:
	sw	$ra,($sp)
	addiu	$sp,$sp,4
	
	#Se calcula el día actual
	jal	diaAct
	
	#Se verifica el día de la semana al que se debe mover el día actual y se desplaza una semana atrás hacia dicho día
	beq	$t7,0x4c3c,lunPrev
	beq	$t7,0x4d3c,marPrev
	beq	$t7,0x4a3c,juePrev
	beq	$t7,0x563c,viePrev
	beq	$t7,0x533c,sabPrev
	beq	$t7,0x443c,domPrev
	j	endSemSig
	
	lunPrev:
		li	$t1,-7
		j	_semPrev
	marPrev:	
		li	$t1,1
		bgt	$t5,1,sumarSem
		j	_semPrev
	juePrev:
		li	$t1,3
		bgt	$t5,3,sumarSem
		j	_semPrev
	viePrev:	
		li	$t1,4
		bgt	$t5,4,sumarSem
		j	_semPrev
	sabPrev:
		li	$t1,5
		bgt	$t5,5,sumarSem
		j	_semPrev
	domPrev:	
		li	$t1,6
		bgt	$t5,6,sumarSem
		j	_semPrev
		
	#Se resta una semana cuando se está en la misma semana
	sumarSem:
		addi	$t1,$t1,-7
	_semPrev:
		add	$t1,$t1,$t5
		sub	$s3,$s3,$t1
	
endSemPrev:
subiu	$sp,$sp,4
lw	$ra,($sp)
jr	$ra

#Mueve el día actual al mismo día del mes siguiente
mesSig:
	sw 	$ra,($sp)
	addiu	$sp,$sp,4
	
	#Se calcula el día y mes actuales
	jal	mdActual
	
	#Se suma al día actual el número de días del mes actual
	add	$s3,$s3,$t7
	ble	$t5,28,endMesSig
	
	#$t3 contiene el mes actual	
	beq	$t3,12,casoDic
	
	#Se calcula la cantidad de días del mes siguiente al actual para el caso donde el día actual esté entre los últimos días del mes
	addi	$t3,$t3,1
	
_contSig:
	mul	$t1,$t3,4
	lw	$t7,meses($t1)
	lb	$t7,1($t7) #$t7 ahora tiene el número de días del mes siguiente al actual
	
	ble	$t5,$t7,endMesSig
	
	sub	$t2,$t5,$t7 #$t2 ahora tiene la diferencia entre el día actual y el número de días del mes siguiente al actual
	sub	$s3,$s3,$t2 #Se vuelve al último día del mes siguiente
	j	endMesSig
		
	casoDic:
		li 	$t3,0
		j	_contSig
	
endMesSig:
subiu	$sp,$sp,4
lw	$ra,($sp)
jr	$ra

#Mueve el día actual al mismo día del mes anterior
mesPrev:
	sw 	$ra,($sp)
	addiu	$sp,$sp,4
	
	#Se calcula el día y mes actuales
	jal	mdActual
	
	#$t3 contiene el mes actual
	beq	$t3,0,casoEne
	
	#Se calcula la cantidad de días del mes anterior al actual
	subi	$t3,$t3,1
_contPrev:
	mul	$t1,$t3,4
	lw	$t7,meses($t1)
	lb	$t7,1($t7) #$t7 ahora tiene el número de días del mes anterior al actual
	
	sub	$s3,$s3,$t7
	ble	$t5,28,endMesPrev
	
	sub	$t2,$t5,$t7
	blez	$t2,endMesPrev
	
	#Se suma al día actual el número de días del mes anterior
	add	$s3,$s3,$t2
	
	j	endMesPrev
		
	casoEne:
		li 	$t3,11
		j	_contPrev
	
endMesPrev:
subiu	$sp,$sp,4
lw	$ra,($sp)
jr	$ra
