.data
duracion:	.asciiz "Duración: "
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
li	$s3,16
jal	printMenu

jal	mesPrev

jal	printMenu

jal	mesSig

jal	printMenu