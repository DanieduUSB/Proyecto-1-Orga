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
	
	li	$a1,23
	jal	printGuion
	
	li	$a1,1
	jal	printBarraVer
	
	li	$a1,22
	jal	printGuion
	
	jal	printSaltoLinea
	
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

division64Bits:
	li	$t0,64
	li	$v1,0
	_d64bucle:
		sll	$v1,$v1,1
		srl	$t1,$a1,31
		or	$v1,$v1,$t1
		sll	$a1,$a1,1
		srl	$t1,$a0,31
		or	$a1,$a1,$t1
		sll	$a0,$a0,1
		
		bltz	$v1,_sumar
		subu	$v1,$v1,$a2
		j	_checkBit	
		_sumar:
		addu	$v1,$v1,$a2
		
		_checkBit:
		bltz	$v1,_bucleContinuar
		ori	$a0,$a0,1
		_bucleContinuar:
		subi	$t0,$t0,1
		beqz	$t0,_d64EndBucle
	j	_d64bucle
	_d64EndBucle:
	bgez	$v1,_d64End
	addu	$v1,$v1,$a2
	_d64End:
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

agendar:
subiu	$sp,$sp,4
lw	$ra,($sp)
jr	$ra

main:
jal	cargarMeses

li	$s3,365
li	$s4,5
li	$s5,12
li	$s6,11
li	$s7,2026

li	$t9,10

#jal	printMenu

li	$v0,30
syscall

li	$a2,1000

jal	division64Bits

div	$a0,$a0,86400
