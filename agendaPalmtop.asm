.data
dias:		.asciiz	"lun"
			"mar"
			"mie"
			"jue"
			"vie"
			"sab"
			"dom"
enero:		.byte	5
		.byte	31
		.asciiz "enero"
febrero:	.byte	7
		.byte	28
		.asciiz "febrero"
marzo:		.byte	5
		.byte	31
		.asciiz "marzo"
abril:		.byte	5
		.byte	30
		.asciiz "abril"
mayo:		.byte	4
		.byte	31
		.asciiz "mayo"
junio:		.byte	5
		.byte	30
		.asciiz "junio"
julio:		.byte	5
		.byte	31
		.asciiz "julio"
agosto:		.byte	6
		.byte	31
		.asciiz "agosto"
septiembre:	.byte	10
		.byte	30
		.asciiz "septiembre"
octubre:	.byte	7
		.byte	31
		.asciiz "octubre"
noviembre:	.byte	9
		.byte	30
		.asciiz "noviembre"
diciembre:	.byte	9
		.byte	31
		.asciiz "diciembre"
		.align 2
meses:		.space 48
input:		.space 20

.text
j main

#Imprime por la salida estándar el caracter "-" el número de veces indicado en $a1
printGuion:	
	li $v0,11
	li $a0,0x2d
_pgLoop:	beqz 	$a1,endPrintGuion
		syscall #print_char
		subi 	$a1,$a1,1
	j  _pgLoop
	
endPrintGuion:
jr $ra

#Imprime por la salida estándar el caracter "|" el número de veces indicado en $a1
printBarraVer:	
	li $v0,11
	li $a0,0x7c
_pbvLoop:	beqz 	$a1,endPrintBarraVer
		syscall #print_char
		subi 	$a1,$a1,1
	j  _pbvLoop
	
endPrintBarraVer:
jr $ra

#Imprime por la salida estándar el caracter "=" el número de veces indicado en $a1
printIgualdad:	
	li $v0,11
	li $a0,0x3d
_piLoop:	beqz 	$a1,endPrintIgualdad
		syscall #print_string
		subi 	$a1,$a1,1
	j  _piLoop
	
endPrintIgualdad:
jr $ra

#Imprime por la salida estándar un salto de línea
printSaltoLinea:	
	li $v0,11
	li $a0,'\n'
	syscall #print_char
jr $ra

#Imprime por la salida estándar el caracter " " el número de veces indicado en $a1
printEspacio:	
	li $v0,11
	li $a0,0x20
_peLoop:	beqz 	$a1,endPrintEspacio
		syscall #print_char
		subi 	$a1,$a1,1
	j  _peLoop
	
endPrintEspacio:
jr $ra

printAsterisco:
	li $v0,11
	la $a0,0x2a
_paLoop:	beqz	$a1,endPrintAsterisco
		syscall #print_char
		subi	$a1,$a1,1
	j  _paLoop
	
endPrintAsterisco:
jr $ra

#Imprime por la salida estándar el límite superior/inferior de la agenda
printLimite:
	sw	$ra,($sp)
	addiu	$sp,$sp,4
	
	li	$a1,23
	jal	printGuion
	
	li	$a1,1
	jal	printBarraVer
	
	li	$a1,22
	jal	printGuion
	
	jal	printSaltoLinea
	
subi	$sp,$sp,4
lw	$ra,($sp)
jr	$ra

##Imprime en una línea de tamaño 22 la fecha especificada formateada. La fecha se lee de los registros $s4 - $s7 tal que:
## $s4: Número indicador del día de la semana (Número del 0 al 6 donde 0 es lunes, 1 es martes, ..., 6 es domingo)
## $s5: Día
## $s6: Número indicador del mes (Número del 0 al 11 donde 0 es enero, 1 es febrero, ..., 11 es diciembre)
## $s7: Año
#printFecha:
#	sw	$ra,($sp)
#	addiu	$sp,$sp,4
#	
#	mul	$t0,$s4,4
#	li	$v0,4
#	la	$a0,dias($t0)
#	syscall	#print_string
#	
#	li	$a1,1
#	jal	printEspacio
#	
#	li	$v0,1
#	move	$a0,$s5
#	syscall	#print_int
#	
#	li	$a1,1
#	jal	printEspacio
#	
#	mul	$t0,$s6,4
#	li	$v0,4
#	lw	$a0,meses($t0)
#	addiu	$a0,$a0,2
#	syscall	#print_string
#	
#	li	$a1,1
#	jal	printEspacio
#	
#	li	$v0,1
#	move	$a0,$s7
#	syscall	#print_int
#	
#	li	$a1,10
#	lw	$t0,meses($t0)
#	lb	$t0,($t0)
#	sub	$a1,$a1,$t0
#	
#	bge	$s5,10,_pfEspacioFinalFecha
#	addi	$a1,$a1,1
#_pfEspacioFinalFecha:
#	jal	printEspacio
#	li	$a1,1
#	
#subiu	$sp,$sp,4
#lw	$ra,($sp)
#jr	$ra

#Imprime la fecha seleccionada en la agenda. La fecha seleccionada se obtiene a partir de los registros $s3-$s7, donde $s3
# representa el número de días desde el día 0, y los registros $s4-$s7 contienen el día 0.
printFecha:
	sw	$ra,($sp)
	addi	$sp,$sp,4
	
	#Día de la semana:
	add	$t0,$s4,$s3
	li	$t1,7
	div	$t0,$t1
	mfhi	$t0
	bgez	$t0,_pfContinuar
	add	$t0,$t1,$t0
	
	_pfContinuar:
	mul	$t0,$t0,4
	la	$a0,dias($t0)
	li	$v0,4
	syscall	#print_string
	
	li	$a1,1
	jal	printEspacio
	
	#Mes y día del mes:
	add	$t0,$s5,$s3 #Carga el valor del día real tomando como referencia el 1ro del mes actual
	
	mul	$t1,$s6,4 #Carga el mes actual (0-11) multiplicado por 4, para acceder a la info de la variable 'meses'
	lw	$t4,meses($t1)
	lb	$t4,1($t4) #Carga la cantidad de días del mes actual
	blt	$t0,1,_pfLoopNeg
	
	_pfLoop: #Loop si $t0 es positivo
		ble	$t0,$t4,_pfEndLoop
		sub	$t0,$t0,$t4
		addi	$t1,$t1,4
		blt	$t1,48,_pfContinuarLoop #Si el mes actual no es el 12, continúa con el loop en el mes y año actual, en caso
					        # contrario, establece el mes como 0 (enero) y se mueve al siguiente año
		li	$t1,0x0
		addi	$t3,$t3,1 #Calcula de antemano el cambio de año
		_pfContinuarLoop:
		lw	$t4,meses($t1)
		addi	$t4,$t4,1
		lb	$t4,($t4)
		j	_pfLoop
	
	_pfLoopNeg: #Loop si $t0 es negativo
		subi	$t1,$t1,4
		bgez	$t1,_pfContinuarLoopNeg
		
		li	$t1,0x2c
		subi	$t3,$t3,1
		_pfContinuarLoopNeg:
		
		lw	$t4,meses($t1)
		addi	$t4,$t4,1
		lb	$t4,($t4)
		
		subi	$t4,$t4,1
		not	$t4,$t4

		bgt	$t0,$t4,_pfEndLoopNeg
		sub	$t0,$t0,$t4
		j	_pfLoopNeg
	
	_pfEndLoopNeg:
	subi	$t4,$t4,1
	not	$t4,$t4
	
	add	$t0,$t4,$t0
	subi	$t4,$t4,4
		
	_pfEndLoop:
	move	$a0,$t0
	li	$v0,1
	syscall #print_int
	
	li	$a1,1
	jal	printEspacio
	
	lw	$t1,meses($t1)
	addi	$a0,$t1,2
	li	$v0,4
	syscall	#print_string
	
	li	$a1,1
	jal	printEspacio
	
	#Año:
	add	$a0,$s7,$t3
	li	$v0,1
	syscall	#print_int
	
	#Espacios finales:
	slti	$a1,$t0,10
	addi	$a1,$a1,10
	lbu	$t1,($t1)
	sub	$a1,$a1,$t1
	
	jal	printEspacio
	
subi	$sp,$sp,4
lw	$ra,($sp)
jr	$ra

#Imprime por la salida estándar la mitad del menú. $a2 indica el número de línea (Considerando que la línea 0 es la línea de las
# 6am en el menú y la línea 15 las 9pm en el menú).
printMedioMenu:
	sw	$ra,($sp)
	addiu	$sp,$sp,4
	
	slti	$a1,$a2,4
	jal	printEspacio
	
	addi	$a0,$a2,6
	blt	$a0,13,_pmmContinuar
	subi	$a0,$a0,12
_pmmContinuar:
	li	$v0,1
	syscall	#print_int
	
	seq	$t3,$a2,$t9
	move	$a1,$t3
	jal	printAsterisco
	
	li	$a1,20
	sub	$a1,$a1,$t3
	jal	printEspacio
	
subiu	$sp,$sp,4
lw	$ra,($sp)
jr	$ra

#Imprime por la salida estándar el menú principal de la agenda
printMenu:
	sw	$ra,($sp)
	addiu	$sp,$sp,4
	
	#1ra línea:
	jal	printLimite
	
	#líneas 2-10
	li	$t2,1
	_pmLoop:
		beq	$t2,10,_pmEndLoop
		
		li	$a1,1
		jal	printBarraVer
		
		subi	$a2,$t2,3
		
		beq	$t2,1,__pmlPrintFecha
		beq	$t2,2,__pmlPrintBarraDoble
	
		jal	printMedioMenu
		j	__pmlContinue
		
	__pmlPrintFecha:
		jal	printFecha
		j	__pmlContinue
	
	__pmlPrintBarraDoble:
		li	$a1,22
		jal	printIgualdad
		
	__pmlContinue:
		li	$a1,1
		jal	printBarraVer
		
		addi	$a2,$a2,9
		jal	printMedioMenu
		
		li	$a1,1
		jal	printBarraVer
		
		jal	printSaltoLinea
		
		addi	$t2,$t2,1
		j	_pmLoop
	_pmEndLoop:
	
	#11va línea
	jal	printLimite
	
	#Línea input
	li	$v0,11
	li	$a0,0x24
	syscall	#print_char
	
	li	$a1,1
	jal	printEspacio
	
subiu	$sp,$sp,4
lw	$ra,($sp)
jr	$ra

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

#Utiliza el algoritmo de división no restauradora para dividir el número unsigned de 64 bits $a1:$a0 entre el número unsigned de máximo 32
# bits $a2. Retorna el cociente en $a0 y el resto en $v1
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
	addi	$sp,$sp,4
	
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
	
subi	$sp,$sp,4
lw	$ra,($sp)
jr	$ra

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

	jal	diaAct
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
	
	jal	diaAct
	beq	$t7,0x4c3c,lunPrev #Lunes
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
	sumarSem:
		addi	$t1,$t1,-7
	_semPrev:
		add	$t1,$t1,$t5
		sub	$s3,$s3,$t1
	
endSemPrev:
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

#Mueve el día actual al mismo día del mes siguiente
mesSig:
	sw 	$ra,($sp)
	addiu	$sp,$sp,4
	
	jal	mdActual
	
	#Se suma el número de días del mes actual
	add	$s3,$s3,$t7
	ble	$t5,28,endMesSig
		
	beq	$t3,12,casoDic
	
	#Se calcula la cantidad de días del mes siguiente al actual para el caso donde el día actual esté entre los últimos días del mes
	addi	$t3,$t3,1
	
next:	mul	$t1,$t3,4
	lw	$t7,meses($t1)
	lb	$t7,1($t7) #$t7 ahora tiene el número de días del mes siguiente al actual
	
	ble	$t5,$t7,endMesSig
	
	sub	$t2,$t5,$t7 #$t2 ahora tiene la diferencia entre el día actual y el número de días del mes siguiente al actual
	sub	$s3,$s3,$t2 #Se vuelve al último día del mes siguiente
	j	endMesSig
		
	casoDic:
		li 	$t3,0
		j	next	
	
endMesSig:
subiu	$sp,$sp,4
lw	$ra,($sp)
jr	$ra

#Mueve el día actual al mismo día del mes anterior
mesPrev:
	sw 	$ra,($sp)
	addiu	$sp,$sp,4
	
	jal	mdActual

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
	add	$s3,$s3,$t2
	
	j	endMesPrev
		
	casoEne:
		li 	$t3,11
		j	_contPrev
	
endMesPrev:
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

agendar:
subiu	$sp,$sp,4
lw	$ra,($sp)
jr	$ra

main:
jal	cargarMeses
jal	fechaActual
li	$s3,0
jal	printMenu
