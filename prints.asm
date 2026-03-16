#########################################################################################
# 					prints.asm					#
# Contiene todas las funciones de símbolos a printear durante la ejecución del programa #
# 				Daniel Quijada (20-10518)				#
#			       Daniela Gragirena (19-10543)				#
#########################################################################################

#Imprime por la salida estándar el caracter "-" el número de veces indicado en $a1
printGuion:	li $v0,11
		li $a0,0x2d
	_pgLoop:	beqz 	$a1,endPrintGuion
			syscall #print_char
			subi 	$a1,$a1,1
		j  _pgLoop
endPrintGuion:	jr $ra

#Imprime por la salida estándar el caracter "|" el número de veces indicado en $a1
printBarraVer:	li $v0,11
		li $a0,0x7c
	_pbvLoop:	beqz 	$a1,endPrintBarraVer
			syscall #print_char
			subi 	$a1,$a1,1
		   j  _pbvLoop
endPrintBarraVer:  jr $ra

#Imprime por la salida estándar el caracter "=" el número de veces indicado en $a1
printIgualdad:	li $v0,11
		li $a0,0x3d
	_piLoop:	beqz 	$a1,endPrintIgualdad
			syscall #print_string
			subi 	$a1,$a1,1
		   j  _piLoop
	
endPrintIgualdad:  jr $ra

#Imprime por la salida estándar un salto de línea
printSaltoLinea:	li $v0,11
			li $a0,'\n'
			syscall #print_char
endSaltoLinea:	jr $ra

#Imprime por la salida estándar el caracter " " el número de veces indicado en $a1
printEspacio:	li $v0,11
		li $a0,0x20
	_peLoop:	beqz 	$a1,endPrintEspacio
			syscall #print_char
			subi 	$a1,$a1,1
		  j  _peLoop
	
endPrintEspacio:  jr $ra

#Imprime por la salida estándar el caracter "*" el número de veces indicado en $a1
printAsterisco:	li $v0,11
		la $a0,0x2a
	_paLoop:	beqz	$a1,endPrintAsterisco
			syscall #print_char
			subi	$a1,$a1,1
		   j  _paLoop
	
endPrintAsterisco: jr $ra

#Imprime por la salida estándar el caracter "/" el número de veces indicado en $a1
printBarra:	li $v0,11
		la $a0,0x2f
	_pbLoop:	beqz	$a1,endPrintBarra
			syscall #print_char
			subi	$a1,$a1,1
		j  _pbLoop
	
endPrintBarra:  jr $ra

#Imprime por la salida estándar el caracter "$" una vez
printDolar:	li $v0,11
		la $a0,0x24
		syscall #print_char
	jr $ra

#Imprime por la salida estándar el caracter ">" una vez
printMayorQue:	li $v0,11
		la $a0,0x3e
		syscall #print_char
	jr $ra

#Imprime por la salida estándar el caracter "#" una vez
printNumeral:	li $v0,11
		la $a0,0x23
		syscall #print_char
	jr $ra

#Imprime por la salida estándar "am"
printAM:	li	$v0,11
		li	$a0,0x61 # "a"
		syscall	#print_char
		
		li	$a0,0x6d # "m"
		syscall	#print_char
	jr $ra
	
#Imprime por la salida estándar "pm"
printPM:	li	$v0,11
		li	$a0,0x70 # "p"
		syscall	#print_char
		
		li	$a0,0x6d # "m"
		syscall	#print_char
	jr $ra