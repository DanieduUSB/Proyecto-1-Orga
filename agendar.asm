#######################################
# 	     agendar.asm	      #
# Esto probablemente debería estar en acciones.asm, veremos #
#	Daniel Quijada (20-10518)     #
#      Daniela Gragirena (19-10543)   #
#######################################

#Maneja todo lo relacionado con la lógica al momento de agendar una entrada dada por el usuario.
agendar:
	#Chequea que no haya otra cita en la hora seleccionada
	bnez	$s1,errorAgendar
	
	jal	printMenu
	move	$t8,$t9
	
	#Confirmación para la duración. Si la duración sobrepasa las 9pm, omite esta pregunta
	beq	$t9,15,_agendarCrearCita
_agendarConfirmar:
	li	$v0,12
	syscall	#read_char
	jal	printSaltoLinea
	beq	$v0,0x53,_agendarDuracion
	beq	$v0,0x73,_agendarDuracion
	beq	$v0,0x4e,_agendarCrearCita
	beq	$v0,0x6e,_agendarCrearCita
	#Lanzar un error si llega a este punto
	j	_agendarConfirmar
	
_agendarDuracion:
	li	$v0,4
	la	$a0,duracion
	syscall	#print_string
	
	li	$v0,5
	syscall	#read_int
	
	#Si el número ingresado es negativo, vuelve a pedir ingresar duración
	bltz	$v0,_agendarDuracion
	add	$t8,$t8,$v0
	#Agrega la hora de holgura
	addi	$t8,$t8,1
	#Si $t8 es mayor que 15, la hora final es mayor a las 9pm, en dado caso limita la hora final a las 9pm
	ble	$t8,15,_agendarCheckSolapamiento
	li	$t8,15
	j	_agendarCheckSolapamiento
	
_agendarCheckSolapamiento:

	#Chequea que la hora de finalización no solape con una cita mas tarde
	
	beqz	$s2,_agendarCrearCita
	lb	$t7,8($s2)
	bge	$t8,$t7,errorAgendar
		
_agendarCrearCita:

	#Se crea una cita en la lista enlazada con 45 bytes, de manera que:
	# Los primeros 4 bytes son un apuntador a la cita anterior (o 0 si no hay anterior)
	# Los siguientes 4 bytes son un apuntador a la cita siguiente (o 0 si no hay siguiente)
	# El siguiente byte es el número de días a partir del día 0 en el que se ubica la cita (Es decir, el valor de $s3 al crear
	#  la cita)
	# El siguiente byte es la hora inicial de la cita (0=6am, 15=9pm)
	# El siguiente byte es la hora final de la cita (0=6am, 15=9pm)
	# Los siguientes 17 bytes corresponden a: 15 bytes que guardan un string, un byte nulo, y un byte que contiene la longitud
	#  del string
	# Los siguientes 17 bytes vuelven a ser iguales al de arriba
	li	$v0,9
	li	$a0,45
	syscall #sbrk
	
	lb	$s3,8($v0)
	lb	$t9,9($v0)
	lb	$t8,10($v0)
	
	#Guardar primer string
	li	$t0,0
	addi	$t2,$v0,11
_agendarString1Loop:
		beq	$t0,17,_agendarString2
		lb	$t1,inputAux($t0)
		sb	$t1,($t2)
		addi	$t2,$t2,1
		addi	$t0,$t0,1
	j	_agendarString1Loop

	#Guardar 2do string
_agendarString2:
	subi	$t0,$t0,2

_agendarString2Loop:
		beq	$t0,32,_agendarDireccionesLista
		lb	$t1,input($t0)
		sb	$t1,($t2)
		addi	$t2,$t2,1
		addi	$t0,$t0,1
	j	_agendarString2Loop

_agendarDireccionesLista:
	move	$s1,$v0
	jal	linkearAnteriorLista
	
	sw	$s2,4($s1)
	
#Conecta el nodo al que se apunta en $s2 con el nodo en $s1 en la lista enlazada de las citas agendadas.
linkearSiguienteLista:
	sw	$s2,4($s1)
	#Si $s2 es 0, significa que no hay elemento siguiente en la lista.
	beqz	$s2,_lslContinuar
	sw	$a1,($s2)
_lslContinuar:
	jr	$ra

#Conecta el nodo al que se apunta en $s0 con el nodo en $s1 en la lista enlazada de las citas agendadas.
linkearAnteriorLista:
	sw	$s0,($s1)
	#Si $s0 es 0, significa que no hay elemento anterior, por lo que $s1 debe ser la cabeza de la lista
	beqz	$s0,establecerCabezaLista
	sw	$s1,4($s0)
	jr	$ra
	
#Establece el nodo en $s1 como la cabeza de la lista
establecerCabezaLista:
	sw	$s1,citas
	jr	$ra

errorAgendar:
	