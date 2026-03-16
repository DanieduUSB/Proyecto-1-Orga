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

#Mueve el día actual al siguiente lunes
sigLun:	
	#Se calcula el día actual
	jal	diaAct
	li	$t1,0
	sub	$t1,$t1,$t5
	add	$s3,$s3,$t1
j	programa

#Mueve el día actual al siguiente martes
sigMar:	
	#Se calcula el día actual
	jal	diaAct
	li	$t1,1
	blt	$t5,1,restarSemM
	j	_sigMar
	#Se resta una semana cuando se está en la misma semana
	restarSemM:
		subi	$t1,$t1,7
_sigMar:
	sub	$t1,$t1,$t5
	add	$s3,$s3,$t1
j	programa

sigJue:
	#Se calcula el día actual
	jal	diaAct
	li	$t1,3
	blt	$t5,3,restarSemJ
	j	_sigJue
	#Se resta una semana cuando se está en la misma semana
	restarSemJ:
		subi	$t1,$t1,7
_sigJue:
	sub	$t1,$t1,$t5
	add	$s3,$s3,$t1
j	programa

sigVie:
	#Se calcula el día actual
	jal	diaAct
	li	$t1,4
	blt	$t5,4,restarSemV
	j	_sigVie
	#Se resta una semana cuando se está en la misma semana
	restarSemV:
		subi	$t1,$t1,7
_sigVie:
	sub	$t1,$t1,$t5
	add	$s3,$s3,$t1
j	programa

sigSab:
	#Se calcula el día actual
	jal	diaAct
	li	$t1,5
	blt	$t5,5,restarSemS
	j	_sigSab
	#Se resta una semana cuando se está en la misma semana
	restarSemS:
		subi	$t1,$t1,7
_sigSab:
	sub	$t1,$t1,$t5
	add	$s3,$s3,$t1
j	programa

sigDom:
	#Se calcula el día actual
	jal	diaAct
	li	$t1,6
	blt	$t5,6,restarSemD
	j	_sigDom
	#Se resta una semana cuando se está en la misma semana
	restarSemS:
		subi	$t1,$t1,7
_sigDom:
	sub	$t1,$t1,$t5
	add	$s3,$s3,$t1
j	programa

#Mueve el día actual al lunes previo
lunPrev:
	#Se calcula el día actual
	jal	diaAct
	li	$t1,-7
	add	$t1,$t1,$t5
	sub	$s3,$s3,$t1
j	programa

#Mueve el día actual al martes previo
marPrev:
	#Se calcula el día actual
	jal	diaAct
	li	$t1,1
	bgt	$t5,$t1,resSemM
	j	_semPrevM
	#Se resta una semana cuando se está en la misma semana
	resSemM:
		subi	$t1,$t1,7
_semPrevM:
	add	$t1,$t1,$t5
	sub	$s3,$s3,$t1
j	programa

juePrev:
	#Se calcula el día actual
	jal	diaAct
	li	$t1,3
	bgt	$t5,$t1,resSemJ
	j	_semPrevJ
	#Se resta una semana cuando se está en la misma semana
	resSemM:
		subi	$t1,$t1,7
_semPrevJ:
	add	$t1,$t1,$t5
	sub	$s3,$s3,$t1
j	programa

viePrev:
	#Se calcula el día actual
	jal	diaAct
	li	$t1,4
	bgt	$t5,$t1,resSemV
	j	_semPrevV
	#Se resta una semana cuando se está en la misma semana
	resSemV:
		subi	$t1,$t1,7
_semPrevV:
	add	$t1,$t1,$t5
	sub	$s3,$s3,$t1
j	programa

sabPrev:
	#Se calcula el día actual
	jal	diaAct
	li	$t1,5
	bgt	$t5,$t1,resSemS
	j	_semPrevS
	#Se resta una semana cuando se está en la misma semana
	resSemS:
		subi	$t1,$t1,7
_semPrevS:
	add	$t1,$t1,$t5
	sub	$s3,$s3,$t1
j	programa

domPrev:
	#Se calcula el día actual
	jal	diaAct
	li	$t1,6
	bgt	$t5,$t1,resSemD
	j	_semPrevD
	#Se resta una semana cuando se está en la misma semana
	resSemD:
		subi	$t1,$t1,7
_semPrevD:
	add	$t1,$t1,$t5
	sub	$s3,$s3,$t1
j	programa

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
	#Se calcula la cantidad de días del mes siguiente al actual para el caso donde el día actual esté entre los últimos días del mes
	addi	$t3,$t3,1	
	beq	$t3,12,casoDic
	
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

#Borra una cita agendada
borrarCita:
endBorrarCita: