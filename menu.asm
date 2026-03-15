##########################################################
# 			menu.asm			 #
# Contiene los elementos del menú principal de la agenda #
#		Daniel Quijada (20-10518)		 #
#	       Daniela Gragirena (19-10543)		 #
##########################################################

#Imprime por la salida estándar el límite superior de la agenda
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
	
subiu	$sp,$sp,4
lw	$ra,($sp)
jr	$ra

#Imprime en una línea de tamaño 22 la fecha especificada formateada. La fecha se lee de los registros $s4 - $s7 tal que:
# $s4: Número indicador del día de la semana (Número del 0 al 6 donde 0 es lunes, 1 es martes, ..., 6 es domingo)
# $s5: Día
# $s6: Número indicador del mes (Número del 0 al 11 donde 0 es enero, 1 es febrero, ..., 11 es diciembre)
# $s7: Año
printFechaActual:
sw	$ra,($sp)
addiu	$sp,$sp,4

	#Calcula cuantos '-' hay que printear antes de la fecha
	li	$a1,5
	slti	$v1,$s5,10
	add	$a1,$a1,$v1
	slti	$v1,$s6,9
	add	$a1,$a1,$v1
	jal	printGuion
	
	li	$a1,1
	jal	printEspacio
	
	#Printea el día de la semana
	mul	$t0,$s4,4
	li	$v0,4
	la	$a0,dias($t0)
	syscall	#print_string
	
	li	$a1,1
	jal	printEspacio
	
	#Printea el día del mes
	li	$v0,1
	move	$a0,$s5
	syscall	#print_int
	
	li	$a1,1
	jal	printBarra
	
	#Printea el número del mes
	li	$v0,1
	addi	$a0,$s6,1
	syscall	#print_int
	
	li	$a1,1
	jal	printBarra
	
	#Printea el año
	li	$v0,1
	move	$a0,$s7
	syscall	#print_int
	
	li	$a1,1
	jal	printEspacio
	
	li	$a1,1
	jal	printGuion
	
	jal	printSaltoLinea
	
subiu	$sp,$sp,4
lw	$ra,($sp)
jr	$ra

#Imprime la fecha seleccionada en la agenda. La fecha seleccionada se obtiene a partir de los registros $s3-$s7, donde $s3
# representa el número de días desde el día 0, y los registros $s4-$s7 contienen el día 0.
printFecha:
sw	$ra,($sp)
addiu	$sp,$sp,4

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
	li	$t3,0
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
	
subiu	$sp,$sp,4
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
_pmLoop:	beq	$t2,10,_pmEndLoop
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
	li	$a1,23
	jal	printGuion
	
	li	$a1,1
	jal	printBarraVer
	
	jal	printFechaActual
	
	#Línea input
	li	$v0,11
	li	$a0,0x24
	syscall	#print_char
	
	li	$a1,1
	jal	printEspacio
	
subiu	$sp,$sp,4
lw	$ra,($sp)
jr	$ra