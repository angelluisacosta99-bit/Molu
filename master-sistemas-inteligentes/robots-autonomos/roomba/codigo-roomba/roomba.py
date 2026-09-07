## código de odometría - Robots autonomos

# Libreria para funciones matematicas
import math

# Libreria para timers
import time

# Libreria para crear interfaz 
import tkinter as tk
from tkinter import Button, Label

# Libreria para crear graficas
import matplotlib.pyplot as plt

# Libreria para el robot Roomba
from pycreate2 import Create2


class RoombaController:
    def __init__(self, master):
        self.master = master
        master.title("Roomba Controller")

        # Inicializar parametros
        self.bot = None
        self.is_connected = False

        self.move_speed = 100 
        self.turn_speed = 50 

        self.radio_rueda = 36 # diametro entre dos (en milimetros) 72 mm
        self.distancia_entre_ruedas = 235 #en milimetros

        # Inicializar a cero las variables de desplazamiento
        self.distancia = 0 
        self.angulo = 0
        self.eje_x = 0
        self.eje_y = 0

        self.option = ""

        # Creación de los botones de la interfaz
        self.move_forward_button = Button(master, text="Adelante",command=self.move_forward)
        self.move_backward_button = Button(master, text="Atras", command=self.move_backward)
        self.move_left_button = Button(master, text="Izquierda", command=self.turn_left)
        self.move_right_button = Button(master, text="Derecha", command=self.turn_right)
        self.stop_button = Button(master, text="PARO", command=self.stop)
        self.route_button = Button(master, text="Ruta", command=self.route)
        self.plot_button = Button(master, text="Gráfica", command=self.plot_trajectory)
        self.exit_button = Button(master, text="Salir", command=self.exit)

        # Creación de los textos de la interfaz
        self.battery_label = Label(master, text="Battery: 0 %")
        self.distance_label = Label(master, text="Distance: 0 mm")
        self.angle_label = Label(master, text="Angle: 0 degrees")
        self.x_axes_label = Label(master, text="X-Axis: 0")
        self.y_axes_label = Label(master, text="Y-Axis: 0")
        self.obstacle_label = Label(master, text="Obstacle: None")
        
        # Ubicacion de los botones y los textos en la interfaz
        self.battery_label.grid(row=1, column=0, columnspan=2, pady=5)
        self.move_forward_button.grid(row=2, columnspan=2, pady=5)
        self.move_left_button.grid(row=3, column=0, pady=5)
        self.move_right_button.grid(row=3, column=1, pady=5)
        self.move_backward_button.grid(row=4, columnspan=2, pady=5)
        self.stop_button.grid(row=6, column=0, columnspan=2, pady=5)
        self.route_button.grid(row=7, column=0, columnspan=2, pady=5)
        self.distance_label.grid(row=8, column=0, columnspan=2, pady=5)
        self.angle_label.grid(row=9, column=0, columnspan=2, pady=5)
        self.x_axes_label.grid(row=10, column=0, columnspan=2, pady=5)
        self.y_axes_label.grid(row=11, column=0, columnspan=2, pady=5)
        self.obstacle_label.grid(row=12, column=0, columnspan=2, pady=5)
        self.plot_button.grid(row=13, column=0, columnspan=2, pady=10)
        self.exit_button.grid(row=14, column=0, columnspan=2, pady=10)

        # Conectarse al robot
        self.connect()

        # Trayectorias para pintar en la gráfica
        self.trajectory_x = []
        self.trajectory_y = []
    
    # Funcion para conectar
    def connect(self):
        port = 'COM4' #puerto
        baud = {
            'default': 115200, #vel conexión
            'alt': 19200
        } 
        self.bot = Create2(port=port, baud=baud['default'])
        self.bot.start()
        time.sleep(1)
        self.bot.full()
        self.is_connected = True

    # Funcion para salir de la aplicacion
    def exit(self):
        self.bot.stop()
        root.destroy()

    # Botones para mmover robot en la interfaz
    def move_forward(self):
        self.option = 'forward'

    def move_backward(self):
        self.option = 'backward'

    def turn_left(self):
        self.option = 'left'

    def turn_right(self):
        self.option = 'right'

    def stop(self):
        self.option = 'stop'

    def route(self):
        self.distance_route = 0
        self.angle_route = 0
        self.secuence = 0
        self.option = 'route'

    # Mover botones bucle
    def update(self):
        # Variable para leer sensores
        self.sensors = self.bot.get_sensors()

        #Funcion para calcular coordenadas, obtener distancia y angulo de desplazamiento
        self.odometry()

        #Obtencion info de bateria
        self.battery = ((self.sensors.battery_charge)/2697)*100
        self.battery_label.config(text="Battery: {:.1f}%".format(self.battery))

        #print("Distancia ", self.distancia)
        
        # Obtencion datos del sensor para cuando haya un obstaculo
        obstaculo_izquierdo, obstaculo_derecho, sensor_caida = self.is_obstacle_detected()

        # Mostrar los datos en el label de la interfaz
        self.distance_label.config(text="Distance: {:.1f} mm".format(self.distancia))
        self.angle_label.config(text="Angle: {:.1f} º".format(self.angulo))
        self.x_axes_label.config(text="X-Axis: {:.1f}".format(self.eje_x))
        self.y_axes_label.config(text="Y-Axis: {:.1f}".format(self.eje_y))

        # Asignacion de variables para pintarlas en la grafica
        self.trajectory_x.append(self.eje_x)
        self.trajectory_y.append(self.eje_y)

        # Movimiento del robot -----------------------------------------------------------------
        # Evaluacion si hay obstaculo
        if (self.battery < 10):
            print("Cargue el robot")
        else:
            if ((obstaculo_izquierdo or obstaculo_derecho or sensor_caida)):
                self.avoid_obstacle() # Ejecutar evacion de obstaculo del robot
            # Evalua cuando ya no hay obstaculo
            else:
                if self.option == 'forward':
                    self.bot.drive_direct(self.move_speed, self.move_speed)

                elif self.option == 'backward':
                    self.bot.drive_direct(-self.move_speed, -self.move_speed)

                elif self.option == 'left':
                    self.bot.drive_direct(self.turn_speed, -self.turn_speed)

                elif self.option == 'right':
                    self.bot.drive_direct(-self.turn_speed, self.turn_speed)

                elif self.option == 'route':
                    self.distance_route += self.sensors.distance # En mm
                    self.angle_route += self.sensors.angle # En grados
                    if (self.distance_route<400 and self.secuence == 0):
                        self.bot.drive_direct(self.move_speed, self.move_speed)
                    elif (self.distance_route>=400 and self.secuence == 0):
                        self.bot.drive_direct(0, 0)
                        self.secuence = 1
                    else:
                        if (self.angle_route<90 and self.secuence == 1):
                            self.bot.drive_direct(self.turn_speed, -self.turn_speed)
                        elif (self.angle_route>=90 and self.secuence == 1):
                            self.bot.drive_direct(0, 0)
                            self.secuence = 2
                        else:
                            if (self.distance_route<800 and self.secuence == 2):
                                self.bot.drive_direct(self.move_speed, self.move_speed)
                            elif (self.distance_route>=800 and self.secuence == 2):
                                self.bot.drive_direct(0, 0)
                                self.secuence = 3
                            else:
                                if (self.angle_route<180 and self.secuence == 3):
                                    self.bot.drive_direct(self.turn_speed, -self.turn_speed)
                                elif (self.angle_route>=180 and self.secuence == 3):
                                    self.bot.drive_direct(0, 0)
                                    self.secuence = 4
                                else:
                                    if (self.distance_route<1200 and self.secuence == 4):
                                        self.bot.drive_direct(self.move_speed, self.move_speed)
                                    elif (self.distance_route>=1200 and self.secuence == 4):
                                        self.bot.drive_direct(0, 0)
                                        self.secuence = 5
                                    else:
                                        if (self.angle_route<270 and self.secuence == 5):
                                            self.bot.drive_direct(self.turn_speed, -self.turn_speed)
                                        elif (self.angle_route>=270 and self.secuence == 5):
                                            self.bot.drive_direct(0, 0)
                                            self.secuence = 6
                                        else:
                                            if (self.distance_route<1600 and self.secuence == 6):
                                                self.bot.drive_direct(self.move_speed, self.move_speed)
                                            elif (self.distance_route>=1600 and self.secuence == 6):
                                                self.bot.drive_direct(0, 0)
                                                self.secuence = 7
                                            else:
                                                if (self.angle_route<360 and self.secuence == 7):
                                                    self.bot.drive_direct(self.turn_speed, -self.turn_speed)
                                                else:
                                                    self.secuence = 8
                                                    self.bot.drive_direct(0, 0)
                                                    self.option = 'stop'
                else:
                    self.bot.drive_direct(0, 0)

        self.master.after(100, self.update)    

    
    def distance(self, vel_izquierda, vel_derecha, tiempo):
        v_izquierda = vel_izquierda
        v_derecha = vel_derecha

        vel_lineal = (((v_izquierda + v_derecha) / 2) * self.radio_rueda)
        v_angular = (v_derecha - v_izquierda) / self.distancia_entre_ruedas

        # Calcular distancia lineal utilizando el modelo cinemático
        distancia_lineal = vel_lineal * tiempo # Translacion
        distancia_angular = v_angular * tiempo # Rotacion

        return distancia_lineal, distancia_angular
    
    # Odometria
    def odometry(self):
        
        self.distancia += self.sensors.distance
        self.angulo += self.sensors.angle

        self.eje_x += self.sensors.distance * (math.cos(self.angulo * math.pi / 180)) # esta en grados entonces se pasa a radianes
        self.eje_y += self.sensors.distance * (math.sin(self.angulo * math.pi / 180)) # esta en grados entonces se pasa a radianes

        # print("Distancia: ", self.distancia, "Angulo: ", self.angulo, "Ejes: ", self.eje_x, ",", self.eje_y)
        # print("sensor distancia: ", self.sensors.distance, "Total en distancia: ",  self.distancia)

    def is_obstacle_detected(self):
        # Cuando haya una pared
        if self.is_connected and (self.battery > 10):
            self.bumper_status_left = self.sensors.bumps_wheeldrops.bump_left
            self.bumper_status_right = self.sensors.bumps_wheeldrops.bump_right

            #Cuando se va a caer
            self.under_left = self.sensors.cliff_left
            self.under_left_front = self.sensors.cliff_front_left
            self.under_right = self.sensors.cliff_right
            self.under_right_front = self.sensors.cliff_front_right
            #print(self.under_left," .. ", self.under_left_front," .. ", self.under_right_front," .. ", self.under_right)
            if (self.under_left or self.under_left_front or self.under_right_front or self.under_right):
                self.cliff_sensor = True
            else:
                self.cliff_sensor = False

        return self.bumper_status_left, self.bumper_status_right, self.cliff_sensor
    
    def avoid_obstacle(self):
        # Simple avoidance behavior: Turn right and then resume forward
        if self.is_connected and (self.battery > 10):
            self.bot.drive_direct(-50, -50)  # ir atras
            time.sleep(1)  
            self.bot.drive_direct(50, -50)  # girar a la izquierda
            time.sleep(0.5)  # Adjust as needed

    def plot_trajectory(self):
        plt.plot(self.trajectory_x, self.trajectory_y, marker='o', linestyle='-')
        plt.title('Robot Trajectory')
        plt.xlabel('X-Axis (mm)')
        plt.ylabel('Y-Axis (mm)')
        plt.grid(True)
        plt.show()

    def main_loop(self):
        self.master.after(0, self.update)  # La funcion que siempre se esta ejecutando
        self.master.mainloop()

if __name__ == "__main__":
    root = tk.Tk() # Crear interfaz
    controller = RoombaController(root) # Llamar la clase donde se ejecuta el codigo
    controller.main_loop() # Funcion que va permitir que cierto codigo se este ejecutando siempre