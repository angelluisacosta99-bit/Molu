#!/usr/bin/python
# -*- coding: ascii -*-

import funciones
import sys
   

while True:
    print("Que desea hacer?")
    print("1. Movimiento automatico")
    print("2. Movimiento en forma de cuadrado")
    print("3. Salir")
    
    opcion = input("Ingrese su opcion: ")
    
    if opcion == "1":        
        funciones.automatico() 
    elif opcion == "2":
        funciones.cuadrado()
    elif opcion == "3":
        sys.exit("FIN")
    else:
        print("Opcion invalida. Intente nuevamente.")
        

    