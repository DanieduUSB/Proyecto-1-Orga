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
	jal	citaHoraSig
	j	horaSig
endHoraSig:
jal	fixHoraSig
j	programa

#Resta en 1 el cursor de la línea actual (el asterisco del menú - $t9) el número de veces indicado en &t8, o hasta que $t9 sea 0
horaPrev:
	beqz	$t8,endHoraPrev
	beqz	$t9,endHoraPrev
	subi	$t9,$t9,1
	subi	$t8,$t8,1
	jal	citaHoraPrev
	j	horaPrev
endHoraPrev:
jal	fixHoraPrev
j	programa

#Mueve el día actual al siguiente.
diaSig:
	addi	$s3,$s3,1
	jal	citaDiaSig
endDiaSig:
j	programa

#Mueve el día actual al anterior.
diaPrev:
	subi	$s3,$s3,1
	jal	citaDiaPrev
endDiaPrev:
j	programa

#Mueve el día actual al siguiente lunes
sigLun:	
	#Se calcula el día actual
	jal	diaAct
	li	$t1,7
	sub	$t1,$t1,$t4
	add	$s3,$s3,$t1
jal	citaDiaSig
j	programa

#Mueve el día actual al siguiente martes
sigMar:	
	#Se calcula el día actual
	jal	diaAct
	blt	$t4,1,diaPrevM
	li	$t1,8
	j	_sigMar
	#Se suma un solo día si es lunes
	diaPrevM:
		li	$t1,1
_sigMar:
	sub	$t1,$t1,$t4
	add	$s3,$s3,$t1
jal	citaDiaSig
j	programa

sigJue:
	#Se calcula el día actual
	jal	diaAct
	blt	$t4,3,diaPrevJ
	li	$t1,10
	j	_sigJue
	#Caso si se está antes del jueves
	diaPrevJ:
		li	$t1,3
_sigJue:
	sub	$t1,$t1,$t4
	add	$s3,$s3,$t1
jal	citaDiaSig
j	programa

sigVie:
	#Se calcula el día actual
	jal	diaAct
	blt	$t4,4,diaPrevV
	li	$t1,11
	j	_sigVie
	#Caso si se está antes del viernes
	diaPrevV:
		li	$t1,4
_sigVie:
	sub	$t1,$t1,$t4
	add	$s3,$s3,$t1
jal	citaDiaSig
j	programa

sigSab:
	#Se calcula el día actual
	jal	diaAct
	blt	$t4,5,diaPrevS
	li	$t1,12
	j	_sigSab
	#Caso si se está antes del sábado
	diaPrevS:
		li	$t1,5
_sigSab:
	sub	$t1,$t1,$t4
	add	$s3,$s3,$t1
jal	citaDiaSig
j	programa

sigDom:
	#Se calcula el día actual
	jal	diaAct
	blt	$t4,6,diaPrevD
	li	$t1,13
	j	_sigDom
	#Se resta una semana cuando se está en la misma semana
	diaPrevD:
		li	$t1,6
_sigDom:
	sub	$t1,$t1,$t4
	add	$s3,$s3,$t1
jal	citaDiaSig
j	programa

#Mueve el día actual al lunes previo
lunPrev:
	#Se calcula el día actual
	jal	diaAct
	move	$t1,$t4
	bnez	$t4,_lunPrev
	li	$t1,7
_lunPrev:	
	sub	$s3,$s3,$t1
jal	citaDiaPrev
j	programa

#Mueve el día actual al martes previo
marPrev:
	#Se calcula el día actual
	jal	diaAct
	li	$t1,1
	sub	$t1,$t4,$t1
	bgt	$t4,1,_marPrev
	addi	$t1,$t1,7
_marPrev:
	sub	$s3,$s3,$t1
jal	citaDiaPrev
j	programa

juePrev:
	#Se calcula el día actual
	jal	diaAct
	li	$t1,3
	sub	$t1,$t4,$t1
	bgt	$t4,3,_juePrev
	addi	$t1,$t1,7
_juePrev:
	sub	$s3,$s3,$t1
jal	citaDiaPrev
j	programa

viePrev:
	#Se calcula el día actual
	jal	diaAct
	li	$t1,4
	sub	$t1,$t4,$t1
	bgt	$t4,4,_viePrev
	addi	$t1,$t1,7
_viePrev:
	sub	$s3,$s3,$t1
jal	citaDiaPrev
j	programa

sabPrev:
	#Se calcula el día actual
	jal	diaAct
	li	$t1,5
	sub	$t1,$t4,$t1
	bgt	$t4,5,_sabPrev
	addi	$t1,$t1,7
_sabPrev:
	sub	$s3,$s3,$t1
jal	citaDiaPrev
j	programa

domPrev:
	#Se calcula el día actual
	jal	diaAct
	li	$t1,6
	sub	$t1,$t4,$t1
	bgt	$t4,6,_domPrev
	addi	$t1,$t1,7
_domPrev:
	sub	$s3,$s3,$t1
jal	citaDiaPrev
j	programa

#Mueve el día actual al mismo día del mes siguiente
mesSig:
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
jal	citaDiaSig
j	programa

#Mueve el día actual al mismo día del mes anterior
mesPrev:
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
jal	citaDiaPrev
j	programa
