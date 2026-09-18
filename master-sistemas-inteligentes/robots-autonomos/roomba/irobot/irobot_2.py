#!/usr/bin/python
# -*- coding: ascii -*-

from math import cos, pi, sin
from telnetlib import ENCRYPT
import matplotlib.pyplot as plt
from  pycreate2 import Create2
import time
port = "COM3"  # where is your serial port
bot = Create2(port)

bot.start()
bot.full()



def dist(N_count):
    return ((N_count*72*pi)/508.8)

def ang_degree(enc_left, enc_right):
    rad=(abs(dist(enc_left)-dist(enc_right))/235)
    return (rad*180)/pi 
    
bot.reset()
sensors=bot.get_sensors()
enc_L_old=sensors.encoder_counts_left
enc_R_old=sensors.encoder_counts_right
recorrido=[[0,0,0]]
xs=[]
ys=[]
x=0
y=0
cita=0
s=0
sl_old=0
sr_old=0
               
    
def odometry(): 
    encLnew=sensors.encoder_counts_left
    encRnew=sensors.encoder_counts_right
    
    #diferencia entre lecturas
    encL=encLnew-enc_L_old
    encR=-encRnew-enc_R_old
    
    #actualizar enc old
    enc_L_old=encLnew
    enc_R_old=encRnew
    
    print("Encoders: ", encL, encR)
    
    #calculo de la distancia recorrida por cada rueda
    sl_new=dist(encL)
    sr_new=dist(encR)
    print("distancia:", sl_new, sr_new)
    
    #calculo de las delta S     
    delta_sl=sl_new - sl_old
    delta_sr=sr_new - sr_old
            
    #actualizar sl_old
    sl_old=sl_new
    sr_old=sr_new
    
    delta_cita=((delta_sr-delta_sl)/235)*(180/pi) # en grados
    
    delta_s=((delta_sr+delta_sl)/2)
    
    delta_x=delta_s * sin(cita+delta_cita)
    delta_y=delta_s * cos(cita+delta_cita)
    
    x=x+delta_x
    y=y+delta_y
    s=s+delta_s
    cita=cita+delta_cita
    print("y y Y ",delta_x,delta_y)
    xs.append(x)
    ys.append(y)
    recorrido.append([round(x,2),round(y,2), round(cita,2)])
        
    plt.ion()    
    # nuevo punto
    plt.figure(figsize=(8, 6))
    plt.plot(xs, ys, marker="o", linestyle="-", color="b")
    plt.title("Recorrido del Roomba 650")
    plt.xlabel("Posicion en el eje X")
    plt.ylabel("Posicion en el eje Y")
    plt.grid(True)
    plt.plot()
    plt.pause(0.1)
    #time.sleep(0.1)  # fijarme, tal vez sobre
    plt.ioff()   # Desactiva el modo interactivo y muestra el grafico final
    plt.show() 
      
    time.sleep(0.2)
    print(sensors.battery_charge)
    print(recorrido)
                        


bot.stop()
bot.close()
    
    


