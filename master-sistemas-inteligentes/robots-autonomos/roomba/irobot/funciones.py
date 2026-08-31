#!/usr/bin/python
# -*- coding: ascii -*-

from math import cos, pi, sin
from  pycreate2 import Create2
import time
from math import cos, pi, sin
import matplotlib.pyplot as plt


def automatico():
    
    tEj=get_entero("Defina el tiempo de duracion de la ejecucion en segundos: ")        
     
    port = "COM6" 
    bot = Create2(port)
    bot.start()
    time.sleep(1)
    bot.full()
    time.sleep(1)
    
    sensors=bot.get_sensors()
    EncDv=sensors.encoder_counts_right
    EncIv=sensors.encoder_counts_left
    recorrido=[[0,0,0]]
    xs=[]
    ys=[]
    x=0
    y=0
    cita=0
    umbral=1000
    ti=time.time()
    tf=time.time()
   
                 
    while tf-ti<tEj:
        sensors=bot.get_sensors()
        
        #odometria
        #1.Leer sensores (encoders)
        sensors=bot.get_sensors()
        EncD_act=sensors.encoder_counts_right
        EncI_act=sensors.encoder_counts_left
        
        #2. Calcular diferencia e/ lecturas
        dif_EncD=EncD_act-EncDv
        dif_EncI=EncI_act-EncIv
        
        # Actualizar valores viejos
        EncDv=EncD_act
        EncIv=EncI_act
        
        #Calcular distancia (delta S)
        delta_Sr=(dif_EncD*72*pi)/(508.8) # en milimetros
        delta_Sl=(dif_EncI*72*pi)/(508.8) # en milimetros
        
        #Calcular delta_S y delta_cita
        delta_S=(delta_Sr+delta_Sl)/2
        delta_cita=abs((delta_Sr-delta_Sl)/235)
        
        #Calcular delta_x y delta_y
        delta_x=delta_S*cos(cita+delta_cita)
        delta_y=delta_S*sin(cita+delta_cita)
        
        #Calcular x y y
        x=x+delta_x
        y=y+delta_y
        cita=cita+delta_cita
        
        
        xs.append(x)
        ys.append(y)
        recorrido.append([round(x,2),round(y,2), round(cita,2)])
        time.sleep(0.1)
        
        tf=time.time()
                                
        #******* LIGTH BUMPERS ********
            
        LB_left=sensors.light_bumper_left
        LB_Fleft=sensors.light_bumper_front_left
        LB_Cleft=sensors.light_bumper_center_left        
        LB_right=sensors.light_bumper_right
        LB_Fright=sensors.light_bumper_front_right
        LB_Cright=sensors.light_bumper_center_right       
        
        
        if LB_left>umbral or LB_Cleft>umbral or LB_Fleft>umbral or LB_right>umbral or  LB_Cright>umbral or LB_Fright>umbral:            
            print("************************************************************************************DETECTED!!!************************")
            if LB_left>umbral or LB_Cleft>umbral or LB_Fleft>umbral:
                bot.drive_direct(-80,80)
                time.sleep(1)
            elif LB_right>umbral or  LB_Cright>umbral or LB_Fright>umbral:
                bot.drive_direct(80,-80)
                time.sleep(1)
            
           
        #******* BUMPERS *********
        bump_l=sensors.bumps_wheeldrops.bump_left
        bump_r=sensors.bumps_wheeldrops.bump_right      
        
        if bump_l and bump_r:
            print("Both bumpers turned on")
            bot.drive_stop()
            bot.drive_direct(-80,-80)
            time.sleep(0.5)
            bot.drive_direct(-80,80)
            time.sleep(2)
        
        elif bump_l:
            print("********************************************************************************************** CRASH REDIRECTION***** ")
            bot.drive_stop()
            bot.drive_direct(-80,-80)
            time.sleep(0.5)
            bot.drive_direct(80,-80)
            time.sleep(1)
            
        elif bump_r:
            print("********************************************************************************************** CRASH REDIRECTION ***** ")
            bot.drive_stop()
            bot.drive_direct(-80,-80)
            time.sleep(0.5)
            bot.drive_direct(-80,80)
            time.sleep(1)
                    
        #Cliffs
        cliff_l=sensors.cliff_left
        cliff_fl=sensors.cliff_front_left
        
        cliff_r=sensors.cliff_right
        cliff_fr=sensors.cliff_front_right
    
       
        if cliff_l or cliff_fl or cliff_fr or cliff_r:
            print("********************************************************************************************** UPS! ME CAIGO!")
            if  cliff_fl and cliff_fr:
                bot.drive_stop()
                bot.drive_direct(-80,-80)
                time.sleep(1)
                bot.drive_direct(80,-80)
                time.sleep(2)        
            if cliff_r or cliff_fr:
                bot.drive_stop()
                bot.drive_direct(-80,-80)
                time.sleep(1)
                bot.drive_direct(80,-80)
                time.sleep(1)
            if cliff_l or cliff_fl:
                bot.drive_stop()
                bot.drive_direct(-80,-80)
                time.sleep(1)
                bot.drive_direct(-80,80)
                time.sleep(1)
        
            
        print("Bateria: ",sensors.battery_charge, "/", sensors.battery_capacity)
        
        
        bot.drive_direct(150,150)
    bot.drive_stop()
    bot.close()
    graph(xs,ys)
  

    
    
def cuadrado():
        
    port = "COM6"  
    bot = Create2(port)
    bot.start()
    time.sleep(1)
    bot.full()
    time.sleep(1)
    lado=get_entero("Defina la longitud del lado del cuadrado en mm: ")
    sensors=bot.get_sensors()
    EncDv=sensors.encoder_counts_right
    EncIv=sensors.encoder_counts_left
    recorrido=[[0,0,0]]
    xs=[]
    ys=[]
    x=0
    y=0
    cita=0
    n=0
         
    #odometria
    #1.Leer sensores (encoders)
    sensors=bot.get_sensors()
    EncD_act=sensors.encoder_counts_right
    EncI_act=sensors.encoder_counts_left
        
    #2. Calcular diferencia e/ lecturas
    dif_EncD=EncD_act-EncDv
    dif_EncI=EncI_act-EncIv
        
    # Actualizar valores viejos
    EncDv=EncD_act
    EncIv=EncI_act
        
    #Calcular distancia (delta S)
    delta_Sr=(dif_EncD*72*pi)/(508.8) # en milimetros
    delta_Sl=(dif_EncI*72*pi)/(508.8) # en milimetros
        
    #Calcular delta_S y delta_cita
    delta_S=(delta_Sr+delta_Sl)/2
    delta_cita=abs((delta_Sr-delta_Sl)/235)
        
    #Calcular delta_x y delta_y
    delta_x=delta_S*cos(cita+delta_cita)
    delta_y=delta_S*sin(cita+delta_cita)
        
    #Calcular x y y
    x=x+delta_x
    y=y+delta_y
    cita=cita+delta_cita
    
    xi,yi=x,y   
                
    xs.append(x)
    ys.append(y)
    recorrido.append([round(x,2),round(y,2), round(cita,2)])
    time.sleep(0.1)
                   
    while True:                 
        #odometria
        #1.Leer sensores (encoders)
        sensors=bot.get_sensors()
        EncD_act=sensors.encoder_counts_right
        EncI_act=sensors.encoder_counts_left
                
        #2. Calcular diferencia e/ lecturas
        dif_EncD=EncD_act-EncDv
        dif_EncI=EncI_act-EncIv
               
        # Actualizar valores viejos
        EncDv=EncD_act
        EncIv=EncI_act        
        
        #Calcular distancia (delta S)
        delta_Sr=(dif_EncD*72*pi)/(508.8) # en milimetros
        delta_Sl=(dif_EncI*72*pi)/(508.8) # en milimetros        
        
        #Calcular delta_S y delta_cita
        delta_S=(delta_Sr+delta_Sl)/2
        delta_cita=abs((delta_Sr-delta_Sl)/235)
        
        #Calcular delta_x y delta_y
        delta_x=delta_S*cos(cita+delta_cita)
        delta_y=delta_S*sin(cita+delta_cita)
                
        #Calcular x y y
        x=x+delta_x
        y=y+delta_y
        cita=cita+delta_cita
                        
        xs.append(x)
        ys.append(y)
        recorrido.append([round(x,2),round(y,2), round(cita,2)])
        time.sleep(0.1)
        if n<4:
            bot.drive_direct(100,103)
        if (abs(x-xi)>=lado or abs(y-yi)>=lado) and n<4:
            n=n+1
            xi=x
            yi=y
            bot.drive_stop()
            print("****************************************************************GIRANDO**************************")
            bot.drive_direct(153,-150)
            time.sleep(1)
        elif n>=4:
            bot.drive_stop()
            bot.close()
            graph(xs,ys)
            break
    
     
def graph(xs,ys):
    fig,ax = plt.subplots()
    # Dibujar puntos
    ax.plot(xs, ys)
    # Guardar el grafico en formato png
    plt.savefig('recorrido.png')
    # Mostrar el grafico
    plt.show()  
        
        
def dist(N_count):
    return ((N_count*72*pi)/508.8)

def ang_degree(enc_left, enc_right):
    rad=(abs(dist(enc_left)-dist(enc_right))/235)
    return (rad*180)/pi       

def get_entero(sms):
       while True:
           try: 
               entero=int(input(sms))
           except ValueError:
               print("Valor no admisible. Intentelo otra vez")
               pass
           else:
               return entero
           
