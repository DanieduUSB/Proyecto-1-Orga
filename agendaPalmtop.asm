.kdata
error1:		.asciiz "Error fatal ("
error2:		.asciiz ") en "
abortando:	.asciiz ". Abortando"

.ktext 0x80000180
	#Se extrae el código de error y se guarda en $a0
	mfc0	$a1,$13
	srl	$a1,$a1,2
	andi	$a1,$a1,0x1f
	
	#Si el código de error es 8, el error está siendo generado por el syscall 5 al pedir una duración de la cita. Se maneja
	# redirigiendo el programa a la línea que pide agendar la duración nuevamente para que el usuario pueda ingresar un entero
	# válido
	beq	$a1,8,error_8
	
	#En caso contrario, muestra el código de error y la dirección de la instrucción que causó el error y termina el programa
	li	$v0,4
	la	$a0,error1
	syscall	#print_string
	
	li	$v0,1
	move	$a0,$a1
	syscall	#print_int
	
	li	$v0,4
	la	$a0,error2
	syscall	#print_string
	
	li	$v0,34
	mfc0	$a0,$14
	syscall	#print_hex
	
	li	$v0,10
	syscall	#exit
	
error_8:
	la	$a0,_agendarDuracion
	jr	$a0

.data
duracion:	.asciiz "Duración: "
duracionMenu:	.asciiz	"Duración? (S/N)"
confirmar:	.asciiz "Confirmar?(S/N)"
error:		.asciiz "Error. Cancelando"
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
citas:		.space 4
input:		.space 32
inputAux:	.space 17

.text
j main

.include "prints.asm"
.include "menu.asm"
.include "auxiliares.asm"
.include "acciones.asm"
.include "agendar.asm"
.include "input.asm"

main:
jal	cargarMeses
jal	fechaActual

#Inicia el programa en sí
programa:
li	$t5,-1
li	$t6,-1
li	$t7,-1
bgt	$s3,365,limitar365Pos
blt	$s3,-365,limitar365Neg
jal	printMenu
j	funcionInput

#Si la cantidad de días desde el día 0 es mayor a 365, la asigna como 365 para limitar hasta que fecha se puede mover en la agenda
limitar365Pos:
	li	$s3,365
	j	programa
	
#Si la cantidad de días desde el día 0 es menor a -365, la asigna como -365 para limitar hasta que fecha se puede mover en la agenda
limitar365Neg:
	li	$s3,-365
	j	programa
	
