############################################
# 	       auxiliares.asm		   #
# Funciones auxiliares varias del programa #
#	  Daniel Quijada (20-10518)	   #
#	 Daniela Gragirena (19-10543)	   #
############################################

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

#Utiliza el algoritmo de división no restauradora para dividir el número unsigned de 64 bits $a1:$a0 entre el número unsigned de
# máximo 32 bits $a2. Retorna el cociente en $a0 y el resto en $v1
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

#Resta el número de 64 bits $a1:$a0 menos el número unsigned de 32 bits $a2. Guarda el resultado en $a1:$a0
sub64:
	sltu	$t0,$a0,$a2 #Si la parte baja del minuendo es menor que el sustraendo, hay acarreo y lo marca en $t0
	subu	$a0,$a0,$a2 #Resta la parte baja del minuendo con el sustraendo
	subu	$a1,$a1,$t0 #Resta el acarreo de la parte alta del minuendo
jr	$ra

#Encuentra el día y fecha actual a partir del syscall 30. Guarda la fecha en los registros $s4-$s7 tal que:
# $s4 contiene el día de la semana (Un número del 0 al 6 donde 0 es lunes, 1 es martes, .., 6 es domingo)
# $s5 contiene el número del día
# $s6 contiene el mes (Un número del 0 al 11 donde 0 es enero, 1 es febrero, .., 11 es diciembre)
# $s7 contiene el año
fechaActual:
sw	$ra,($sp)
addiu	$sp,$sp,4
	
	li	$v0,30
	syscall #system_time
	
	#Se resta 14.400.000 para poder obtener los milisegundos desde el 1ro de enero de 1970 en GMT-4, ya que syscall 30 usa
	# como referencia GMT
	li	$a2,14400000
	jal	sub64
	
	#Se divide el número de 64 bits resultante entre 86.400.000 para convertir de milisegundos a días. Esto nos da el número
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
	
subiu	$sp,$sp,4
lw	$ra,($sp)
jr	$ra

#Calcula el identificador del día actual y lo almacena en $t4
diaAct:
sw	$ra,($sp)
addiu	$sp,$sp,4
	#Se calcula el día actual en base al día lunes
	li	$t1,7
	div	$s3,$t1
	mfhi	$t4
	bgez	$t4,seguir
	#Si $t4 es un número negativo, se le suma 7 para obtener el día de la semana
	addi	$t4,$t4,7
	
seguir:	
	#Se suma el desplazamiento del día 0
	add	$t4,$t4,$s4
	blt	$t4,7,endDiaAct
	subi	$t4,$t4,7
	
endDiaAct:
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
		bgtz	$t2,loopMes
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
		bltz	$t2,loopMesNeg
		j	endLoopMesNeg
		casoIni:
			li 	$t3,12
			j	loopMesNeg
	endLoopMesNeg:
	
	#El día actual pertenece al mes identificado por $t3 que tiene $t7 días
	move	$t5,$t2 #$t5 almacena el día actual
	bgez	$t5,endMdActual
	
endMdActual:
subiu	$sp,$sp,4
lw	$ra,($sp)
jr	$ra

verifChar:
	sw	$ra,($sp)
	addiu	$sp,$sp,4
	
	addi	$t3,$t3,1
	lb	$t0,input($t3)
endVerifChar:
subiu	$sp,$sp,4
lw	$ra,($sp)
jr	$ra

#Busca una cita, si existe, que corresponda al día de la agenda y a la hora indicada en $a2 (Considerando que 0=6am, 1=7am, ..,
# 15=9pm). Utiliza $k0 y $k1 como direcciones límites en la lista para iterar, es decir, $k0 representa la primera cita del día
# seleccionado y $k1 la última cita. Guarda la dirección de la cita en $v1 y el formato de la línea a imprimir en $a3, donde el
# formato es un número tal que:
#  0: La hora inicial y los primeros 15 caracteres de la cita.
#  1: Los siguientes caracteres de la cita.
#  2: La hora final
#  3: El límite inferior
#  4: La hora final sobre el límite inferior
#  5: Línea normal sin cita
#  6: Línea con cita pero sin texto
buscarCitaPrint:
	#Si $k0==0, no hay citas en el día actual seleccionado, por lo que se cae en el caso 5
	beqz	$k0,_bcpCaso5
	
	move	$v1,$k0
	lb	$t0,9($v1)
_bcpLoop:	beq	$v1,$k1,_bcpEndLoop
		bge	$t0,$a2,_bcpEndLoop
		lw	$v1,4($v1)
		lb	$t0,9($v1)
		j	_bcpLoop
_bcpEndLoop:
	# Si $a2 es menor que $t0, hay que verificar citas anteriores
	blt	$a2,$t0,_bcpVerificarAnterior
	# Si $t0 es igual a $a2, significa que la hora se encuentra sobre la primera línea de una cita, cae caso 0
	beq	$t0,$a2,_bcpCaso0
	j	_bcpVerificarSiguiente
_bcpVerificarAnterior:
	#Si $v1 == $k0, $v1 es la primera cita del día, por lo tanto en líneas anteriores no hay citas. Caso 5
	beq	$v1,$k0,_bcpCaso5
	
	#Carga la dirección anterior a $v1. Si es 0, no hay citas anteriores a $v1, vuelve a caer en Caso 5
	lw	$t1,($v1)
	beqz	$t1,_bcpCaso5
	
	#En caso contrario, tomamos la hora final de la cita anterior. Si $a2 > $t1, entonces la línea actual está después de la
	# cita anterior, caso 5
	lb	$t1,10($t1)
	bgt	$a2,$t1,_bcpCaso5
	
	#En caso contrario, se toma $v1 como su anterior y se verifica en las siguientes líneas
	lw	$v1,($v1)
	lb	$t0,9($v1)
	
_bcpVerificarSiguiente:
	#Cargamos hora de finalización de la cita seleccionada en $t1
	lb	$t1,10($v1)
	#Si $a2 es mayor que $t1, significa que la hora está fuera de la cita en cualquiera de sus posiciones. Caso 5
	bgt	$a2,$t1,_bcpCaso5
	#Duración de la cita
	sub	$t3,$t1,$t0
	
	#Si la duración es mayor que 2, se trata por aparte
	bgt	$t3,2,_bcpDuracionMayor2
	
	#Si es igual a 1, estamos parados en el límite inferior y cae directamente en el caso 4
	beq	$t3,1,_bcpCaso4
	
	#Si no, es igual a 2, debemos ver qué ocurre para elegir el caso a realizar
	lb	$t0,44($v1)
	sne	$t4,$t0,0
	seq	$t1,$a2,$t1
	and	$t3,$t4,$t1
	#Si hay que imprimir la 2da parte del string y estamos en la línea inferior, cae en Caso 4
	beq	$t3,1,_bcpCaso4
	#Si no hay que imprimir 2da parte del string pero estamos en la línea inferior, cae en Caso 3
	beq	$t1,1,_bcpCaso3
	#Si no estamos en la línea inferior pero hay que imprimir 2da parte del string, cae Caso 1
	beq	$t4,1,_bcpCaso1
	#Si no se cumple nada de lo anterior, no hay que imprimir 2da parte del string y estamos en la línea intermedia. Caso 2
	j	_bcpCaso2
	
_bcpDuracionMayor2:
	#Si la hora está en el límite inferior, caso 3
	beq	$a2,$t1,_bcpCaso3
	addi	$t0,$t0,1
	lb	$t3,44($v1)
	sne	$t4,$t3,0
	seq	$t1,$a2,$t0
	and	$t3,$t4,$t1
	#Si hay que printear la 2da parte del string y estamos en la línea inmediatamente siguiente a la hora inicial, caso 1
	beq	$t3,1,_bcpCaso1
	#Si no hay que printear la 2da parte del string, pero estamos en la línea inmediatamente siguiente a la hora inicial, caso 2
	beq	$t1,1,_bcpCaso2
	
	addi	$t0,$t0,1
	seq	$t1,$a2,$t0
	and	$t3,$t4,$t1
	#Si hubo que printear la 2da parte del string y estamos 2 líneas después de la hora inicial, caso 2
	beq	$t3,1,_bcpCaso2
	#En cualquier otra situación, caso 6
	j	_bcpCaso6

_bcpCaso0:
	li	$a3,0
	jr	$ra
_bcpCaso1:
	li	$a3,1
	jr 	$ra
_bcpCaso2:
	li	$a3,2
	jr 	$ra
_bcpCaso3:
	li	$a3,3
	jr 	$ra
_bcpCaso4:
	li	$a3,4
	jr 	$ra
_bcpCaso5:
	li	$a3,5
	jr	$ra
_bcpCaso6:
	li	$a3,6
	jr	$ra

#Verifica si hay que cambiar las direcciones de memoria de $k0 y $k1 a causa de haber creado una nueva cita.
# $k0 es la dirección de memoria de la cita mas temprana del día seleccionado
# $k1 es la dirección de memoria de la cita mas tarde del día seleccionado
arreglarCitasDia:
	beqz	$k0,_acdCitaEnAmbos
	#Tomamos las horas iniciales de las citas
	lb	$t0,9($k0)
	lb	$t1,9($s1)
	#Si la hora inicial de la cita creada es menor que la cita de $k0, hay que estalecer la cita creada como $k0
	blt	$t1,$t0,_acdCitaEnK0
	
	lb	$t0,9($k1)
	#Si la hora inicial de la cita creada es mayor que la de la cita de $k1, hay que estalecer la cita creada como $k1
	bgt	$t1,$t0,_acdCitaEnK1
	
	#En caso contrario, se dejan $k0 y $k1 como estan
	jr	$ra

_acdCitaEnK0:
	move	$k0,$s1
	jr	$ra
	
_acdCitaEnK1:
	move	$k1,$s1
	jr	$ra
	
_acdCitaEnAmbos:
	move	$k0,$s1
	j	_acdCitaEnK1
	
#Verifica si hay que cambiar las direcciones de memoria de $k0 y $k1 a causa de haber borrado una cita.
# $s1 es la dirección de la cita próxima a borrar
# $k0 es la dirección de memoria de la cita mas temprana del día seleccionado
# $k1 es la dirección de memoria de la cita mas tarde del día seleccionado
arreglarCitasDiaBorrar:
	#Verifica si $s1 es la primera o última cita del día para ver que tipo de acción tomar. Si no es ninguna de las dos, no
	# hace nada
	beq	$s1,$k0,_acdbCambiarK0
	beq	$s1,$k1,_acdbCambiarK1
	jr	$ra

_acdbCambiarK0:
	#Carga el siguiente de $k0 para ver que ocurre. Si $k0 es 0, no hay siguiente en la lista, por lo que no hay mas citas en
	# el día actual y establece $k1 como 0 también
	lw	$k0,4($k0)
	beqz	$k0,_acdbK1Cero
	
	#Si el nuevo $k0 == $k1, es la única cita del día luego de borrar $s1, por lo que termina el programa
	beq	$k0,$k1,_acdbEnd
	
	#Si no, toma el número de días desde el día 0 de la cita y verifica que sea igual al actual. Si son distintos, no hay mas
	# citas en el día actual, por lo que establece $k0 y $k1 en 0
	lb	$t0,8($k0)
	bne	$t0,$s3,_acdbK0Cero
	
	#En caso contrario, la cita en $k0 es válida y la cita en $k1 también debe serlo ya que es al menos una cita siguiente a
	# la que se guardaba anteriormente en $k0, por lo que termina la ejecución
	j	_acdbEnd
	
	_acdbK0Cero:
		li	$k0,0
		#Si $k0 es 0, $k1 debe serlo también
		j	_acdbK1Cero
	
_acdbCambiarK1: #Este caso toma en cuenta que $k0 != $k1, ya que en caso contrario, habría caído en el caso _acdbCambiarK0 porque
		# si $k0 == $k1 y $k1 == $s1, entonces $k0 == $s1 => Caso anterior
		
	#Carga el anterior a $k1 en $k1
	lw	$k1,($k1)
	
	#Si son	iguales o distintos termina la ejecución puesto que la nueva dirección de $k1 es igual a $k0 o es distinta pero
	# está en una hora superior a $k0 en el mismo día
	j	_acdbEnd

	_acdbK1Cero:
		li	$k1,0
		jr	$ra

_acdbEnd:
	jr	$ra

#Verifica si está parado en una cita para borrarla, en caso afirmativo, borra la cita, en caso contrario, lanza un error
borrarCitaCheck:
	bnez	$s1,borrarCita
	
	jal	printDolar
	li	$a1,1
	jal	printEspacio
	
	li	$v0,4
	la	$a0,error
	syscall	#print_string
	
	jal	printSaltoLinea
	
	j	programa

#Actualiza los registros $s0, $s1 y $s2 que contienen la cita anterior, la actual y la siguiente, respectivamente, para la acción
# de mover hacia una hora posterior (Aumentar el valor de $t9)
citaHoraSig:
	#Si $s1 es 0, antes de mover el cursor no se estaba parado sobre una cita, por lo que verifica si la siguiente posición
	# está parada sobre una cita
	beqz	$s1,_chsCheckSiguiente
	
	#Si no, el puntero $t9 se encuentra dentro de la cita o inmediatamente fuera de la cita. Verificamos con la hora final
	# de la cita $s1 para ver si hay que salir de la cita actual o no. Si $t9 <= $t0, termina la ejecución
	lb	$t0,10($s1)
	ble	$t9,$t0,_chsEnd
	
	#Si $t9 > $t0, salimos de la cita actual $s1, la marcamos como anterior (la movemos a $s0) y hay que verificar si estamos
	# parados sobre una cita siguiente
	move	$s0,$s1
	li	$s1,0
	
_chsCheckSiguiente:
	#Si $s2 es 0, no hay cita siguiente a $s1, por lo que no hay nada que verificar
	beqz	$s2,_chsEnd
	
	#Si no, se verifica que la siguiente cita esté en el mismo día. Si no lo está, termina la ejecución
	lb	$t0,8($s2)
	bne	$t0,$s3,_chsEnd
	
	#Si la cita está en el mismo día, el puntero $t9 se encuentra antes de la hora inicial o en la hora inicial de la siguiente
	# cita. Si está antes ($t9 != $t0) no hay cita en la posición actual, termina la ejecución
	lb	$t0,9($s2)
	bne	$t0,$t9,_chsEnd
	
	#Si están en la misma posición, entonces $s2 es ahora la cita actual, se asigna como $s1 y $s2 se asigna al siguiente de $s2
	move	$s1,$s2
	lw	$s2,4($s2)

_chsEnd:
	jr	$ra

#Actualiza los registros $s0, $s1 y $s2 que contienen la cita anterior, la actual y la siguiente, respectivamente, para la acción
# de mover hacia una hora previa (Disminuir el valor de $t9)
citaHoraPrev:
	#Si $s1 es 0, antes de mover el cursor no se estaba parado sobre una cita, por lo que verifica si la posición anterior
	# está parada sobre una cita
	beqz	$s1,_chpCheckAnterior
	
	#Si no, el puntero $t9 se encuentra dentro de la cita o inmediatamente fuera de la cita. Verificamos con la hora inicial
	# de la cita $s1 para ver si hay que salir de la cita actual o no. Si $t9 >= $t0, termina la ejecución
	lb	$t0,9($s1)
	bge	$t9,$t0,_chpEnd
	
	#Si $t9 < $t0, salimos de la cita actual $s1, la marcamos como siguiente (la movemos a $s2) y hay que verificar si estamos
	# parados sobre una cita anterior
	move	$s2,$s1
	li	$s1,0
	
_chpCheckAnterior:
	#Si $s0 es 0, no hay cita anterior a $s1, por lo que no hay nada que verificar
	beqz	$s0,_chpEnd
	
	#Si no, se verifica que la cita anterior esté en el mismo día. Si no lo está, termina la ejecución
	lb	$t0,8($s0)
	bne	$t0,$s3,_chpEnd
	
	#Si la cita está en el mismo día, el puntero $t9 se encuentra después de la hora final o en la hora final de la cita
	# anterior. Si está después ($t9 != $t0) no hay cita en la posición actual, termina la ejecución
	lb	$t0,10($s0)
	bne	$t0,$t9,_chpEnd
	
	#Si están en la misma posición, entonces $s0 es ahora la cita actual, se asigna como $s1 y $s0 se asigna al anterior de $s0
	move	$s1,$s0
	lw	$s0,($s0)

_chpEnd:
	jr	$ra
	
#Arregla la posición del puntero ($t9) a causa de haber movido la hora a una posterior y que el puntero $t9 haya caido dentro de
# un bloque de una cita
fixHoraSig:
	#Si $s1 es 0, el puntero no cayó en una cita, por lo que termina la ejecución
	beqz	$s1,_fhsEnd
	
	#Si el puntero está en la hora inicial de la cita, se queda en el mismo punto y termina la ejecución
	lb	$t0,9($s1)
	beq	$t0,$t9,_fhsEnd
	
	#En caso contrario, se debe mover el puntero una hora después de la hora final de la cita actual, teniendo en cuenta que
	# si esa hora es después de las 9pm, se debe dejar el puntero en la hora inicial de la cita.
	
	#Hora final
	lb	$t1,10($s1)
	addi	$t1,$t1,1
	#Caso si la hora es mayor a 9pm
	bgt	$t1,15,_fhsHoraInicial
	
	#En caso contrario, establecemos el puntero al valor de $t1 y verificamos si estamos parados en la hora inicial de una
	# nueva cita. Además, marcamos $s1 como cita anterior
	move	$t9,$t1
	move	$s0,$s1
	li	$s1,0
	
	#Si $s2 es 0, no hay cita siguiente a $s1, por lo que no hay nada que verificar
	beqz	$s2,_fhsEnd
	
	#Si no, se verifica que la siguiente cita esté en el mismo día. Si no lo está, termina la ejecución
	lb	$t0,8($s2)
	bne	$t0,$s3,_fhsEnd
	
	#Si la cita está en el mismo día, el puntero $t9 se encuentra en la hora inicial o antes de la hora inicial de la siguiente
	# cita. Si está antes ($t9 != $t0) no hay cita en la posición actual, termina la ejecución
	lb	$t0,9($s2)
	bne	$t0,$t9,_fhsEnd
	
	#Si están en la misma posición, entonces $s2 es ahora la cita actual, se asigna como $s1 y $s2 se asigna al siguiente de $s2
	move	$s1,$s2
	lw	$s2,4($s2)
	
	j	_fhsEnd
	
_fhsHoraInicial:
	move	$t9,$t0
	
_fhsEnd:
	jr	$ra

#Arregla la posición del puntero ($t9) a causa de haber movido la hora a una previa y que el puntero $t9 haya caido dentro de
# un bloque de una cita
fixHoraPrev:
	#Si $s1 es 0, el puntero no cayó en una cita, por lo que termina la ejecución
	beqz	$s1,_fhpEnd
	
	#En caso contrario, hay que mover el puntero a la hora de inicio de la cita
	lb	$t9,9($s1)
_fhpEnd:
	jr	$ra

#Actualiza las direcciones de $s0, $s1, $s2, $k0 y $k1 a causa de moverse a una fecha posterior en el programa. La fecha posterior
# ya debe haber sido actualizada en $s3
citaDiaSig:
sw	$ra,($sp)
addiu	$sp,$sp,4

	#Si $s1 es 0, utiliza $s0 como anterior para la lógica del loop
	beqz	$s1,_cdsLoop
	#En caso contrario, mueve $s1 a $s0 y lo utiliza como anterior para la lógica del loop, además, establece $s1 en 0
	move	$s0,$s1
	li	$s1,0

#Itera hasta que consigue una cita cuya cantidad de días desde el día 0 sea mayor o igual a $s3, o hasta que $s2 sea una dirección
# nula (igual a 0). Si lo último ocurre, entonces la última cita agendada está en un día anterior al seleccionado, por lo que
# termina la ejecución en el caso en que no hay citas en el día actual
_cdsLoop:	beqz	$s2,_cdsEnd0
		lb	$t0,8($s2)
		bge	$t0,$s3,_cdsContinuar
		move	$s0,$s2
		lw	$s2,4($s2)
		j	_cdsLoop
_cdsContinuar:
	#Si $t0 es mayor que $t3, entonces la cita en $s2 tiene un día mayor al seleccionado y la cita en $s0 un día menor (en caso
	# contrario $s0 habría sido tomado en cuenta como $s2 en una iteración anterior), por lo que termina la ejecución en el
	# caso en que no hay citas en el día actual
	bgt	$t0,$s3,_cdsEnd0
	#Si son iguales, entonces este es el valor de $k0
	move	$k0,$s2

#En este loop se encuentra el valor exacto de $s0 y un posible valor de $s2 y $k1
		#Si $s2 es 0, para nuestro puntero actual no hay una siguiente cita
_cdsLoop2:	beqz	$s2,_cdsEnd

		#Si la cita $s2 tiene un día distinto, entonces la siguiente cita no se encuentra en el día actual, por lo que
		# se termina la ejecución con los valores ya tomados
		lb	$t0,8($s2)
		bgt	$t0,$s3,_cdsEnd
		
		#Si tiene el mismo día, entonces es una posible dirección de $k1 y se actualiza
		move	$k1,$s2
		
		#Si la cita en $s2 tiene una hora final mayor o igual al puntero $t9, entonces podemos dar por encontrada
		# la dirección de $s0 y continuamos para encontrar $s1, $s2 y $k1
		lb	$t1,10($s2)
		bge	$t1,$t9,_cdsContinuar2
		
		#En caso contrario, $s2 es una posible dirección de $s0 y tomamos la cita siguiente a $s2 para continuar el loop
		move	$s0,$s2
		lw	$s2,4($s2)
		j	_cdsLoop2
_cdsContinuar2:
	#Cargamos en $t4 la dirección siguiente a $k1
	lw	$t4,4($k1)
	
		#Si $t4 es 0, $k1 es la última dirección de cita correspondiente al día actual
_cdsLoop3:	beqz	$t4,_cdsEnd2
		lb	$t2,8($t4)
		
		#Si es distinto de 0 pero la cita corresponde a un día distinto, entonces el valor actual de $k1 es el correcto
		bne	$t2,$s3,_cdsEnd2
		
		#En caso contrario, sigue buscando a $k1
		move	$k1,$t4
		lw	$t4,4($t4)
		j	_cdsLoop3
_cdsEnd0:
	li	$k0,0
	li	$k1,0
	j	_cdsEnd

#Verifica si el valor actual en $s2 pertenece a $s1
_cdsEnd2:
	lb	$t2,9($s2)
	
	#Si la hora de inicio de $s2 es mayor que la del puntero $t9, los valores quedan iguales
	bgt	$t2,$t9,_cdsEnd
	
	#En caso contrario, $s2 es el valor de $s1 y se asigna $s2 con su siguiente dirección
	move	$s1,$s2
	lw	$s2,4($s2)
	
_cdsEnd:
	#Si el puntero está en un bloque, hay que actualizarlo para moverlo a la hora inicial
	jal	fixHoraPrev

subiu	$sp,$sp,4
lw	$ra,($sp)
jr	$ra

#Actualiza las direcciones de $s0, $s1, $s2, $k0 y $k1 a causa de moverse a una fecha anterior en el programa. La fecha anterior
# ya debe haber sido actualizada en $s3
citaDiaPrev:
sw	$ra,($sp)
addiu	$sp,$sp,4

	#Si $s1 es 0, utiliza $s2 como siguiente para la lógica del loop
	beqz	$s1,_cdpLoop
	#En caso contrario, mueve $s1 a $s2 y lo utiliza como siguiente para la lógica del loop, además, establece $s1 en 0
	move	$s2,$s1
	li	$s1,0

#Itera hasta que consigue una cita cuya cantidad de días desde el día 0 sea menor o igual a $s3, o hasta que $s2 sea una dirección
# nula (igual a 0). Si lo último ocurre, entonces la última cita agendada está en un día siguiente al seleccionado, por lo que
# termina la ejecución en el caso en que no hay citas en el día actual
_cdpLoop:	beqz	$s0,_cdpEnd0
		lb	$t0,8($s0)
		ble	$t0,$s3,_cdpContinuar
		move	$s2,$s0
		lw	$s0,($s0)
		j	_cdpLoop
_cdpContinuar:
	#Si $t0 es menor que $t3, entonces la cita en $s0 tiene un día menor al seleccionado y la cita en $s2 un día mayor (en caso
	# contrario $s2 habría sido tomado en cuenta como $s0 en una iteración anterior), por lo que termina la ejecución en el
	# caso en que no hay citas en el día actual
	blt	$t0,$s3,_cdpEnd0
	#Si son iguales, entonces este es el valor de $k1
	move	$k1,$s0

#En este loop se encuentra el valor exacto de $s2 y un posible valor de $s0 y $k0
		#Si $s0 es 0, para nuestro puntero actual no hay una cita anterior
_cdpLoop2:	beqz	$s0,_cdpEnd

		#Si la cita $s0 tiene un día distinto, entonces la cita anterior no se encuentra en el día actual, por lo que
		# se termina la ejecución con los valores ya tomados
		lb	$t0,8($s0)
		blt	$t0,$s3,_cdpEnd
		
		#Si tiene el mismo día, entonces es una posible dirección de $k0 y se actualiza
		move	$k0,$s0
		
		#Si la cita en $s0 tiene una hora inicial menor o igual al puntero $t9, entonces podemos dar por encontrada
		# la dirección de $s2 y continuamos para encontrar $s1, $s0 y $k0
		lb	$t1,9($s0)
		ble	$t1,$t9,_cdpContinuar2
		
		#En caso contrario, $s0 es una posible dirección de $s2 y tomamos la cita anterior a $s0 para continuar el loop
		move	$s2,$s0
		lw	$s0,($s0)
		j	_cdpLoop2
_cdpContinuar2:
	#Cargamos en $t4 la dirección anterior a $k0
	lw	$t4,($k0)
	
		#Si $t4 es 0, $k0 es la primera dirección de cita correspondiente al día actual
_cdpLoop3:	beqz	$t4,_cdpEnd2
		lb	$t2,8($t4)
		
		#Si es distinto de 0 pero la cita corresponde a un día distinto, entonces el valor actual de $k0 es el correcto
		bne	$t2,$s3,_cdpEnd2
		
		#En caso contrario, sigue buscando a $k0
		move	$k0,$t4
		lw	$t4,($t4)
		j	_cdpLoop3
_cdpEnd0:
	li	$k0,0
	li	$k1,0
	j	_cdpEnd

#Verifica si el valor actual en $s0 pertenece a $s1
_cdpEnd2:
	lb	$t2,10($s0)
	
	#Si la hora de inicio de $s0 es menor que la del puntero $t9, los valores quedan iguales
	blt	$t2,$t9,_cdpEnd
	
	#En caso contrario, $s0 es el valor de $s1 y se asigna $s0 con su dirección anterior
	move	$s1,$s0
	lw	$s0,($s0)
	
_cdpEnd:
	#Si el puntero está en un bloque, hay que actualizarlo para moverlo a la hora inicial
	jal	fixHoraPrev

subiu	$sp,$sp,4
lw	$ra,($sp)
jr	$ra		