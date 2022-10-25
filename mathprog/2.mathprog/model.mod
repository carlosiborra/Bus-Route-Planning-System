# Heurística y Optimización. Práctica 1.
# Alumnos: 100451170 & 100451258

# Modelo de la Parte 2

# Datos (constantes)
# Conjuntos
set paradas;  # Conjunto de las paradas del problema {"S1","S2","S3"}
set localizacion;  # Conjunto de todas las posibles localizaciones {"P","S1","S2","S3","C"}
set localizaciones := localizacion cross localizacion;  # Matriz de la combinación de todas las localizaciones
set origen;  # Origen de los buses (parking)
set destino;  # Destino de los buses (colegio)

set alumnos;  # Conjunto de los distintos alumnos {"A1","A2","A3","A4","A5","A6","A7","A8"}
set hermano := alumnos cross alumnos;  # Matriz de la combinación de todos los alumnos
set paradaAlumno := alumnos cross paradas;  # Matriz de la combinación entre alumnos y paradas

# Parámetros
param mGrande;  # Número arbitrariamente grande, lo definimos en data aunque podría utilizarse directamente en el modelo
param bus_capacidad;  # Número máximo de estudiantes que puede transportar el bus
param bus_coste_fijo;  # Coste fijo por usar cada bus
param bus_coste_km;  # Coste por kilómetro recorrido
param bus_numero_max;  # Número máximo de buses que se pueden utilizar
param longitud {(i,j) in localizaciones}; # Parámetro que contiene las distancias entre las paradas

param hermanos {(i,j) in hermano}, binary; # Parámetro que tiene valor 1 si son hermanos dos alumnos, 0 si no
param paradasAlumnos {(i,j) in paradaAlumno}, binary; # Parámetro que tiene valor 1 si el estudiante podría ir a una parada, 0 si no


# Variables de decisión
var VISITADO {(i,j) in localizaciones}, binary;  # Si algún bus ha pasado por un tramo: 1: si, 0: no
var FLUJO {(i,j) in localizaciones}, >=0, integer;  # Flujo de estudiantes entre localizaciones
var PARADA {(i,j) in paradaAlumno}, binary;  # 1 Si el alumno i va a la parada j, 0 en caso contrario


# Función objetivo
minimize Coste: sum{i in origen, j in localizacion} VISITADO[i,j] * bus_coste_fijo + bus_coste_km * sum{(k,l) in localizaciones} (VISITADO[k,l] * longitud[k,l]);


# Restricciones
s.t. UnicaParada {j in paradas}: sum{i in localizacion} VISITADO[i,j] <= 1;  # Se puede parar o no en una localización, ya que ahora pueden existir paradas vacías

s.t. UnicaSalida {i in paradas}: sum{j in localizacion} VISITADO[i,j] <= 1;  # Se puede llegar o no a una localización, ya que ahora pueden existir paradas vacías

s.t. EntradaSalida {i in paradas}: sum{j in localizacion} (VISITADO[i,j] - VISITADO[j,i]) = 0;  # Restricción para que las rutas sean cerradas, si se entra en una parada, se debe salir

s.t. RutasMenosAutobuses {i in origen}: sum{j in localizacion} VISITADO[i,j] <= bus_numero_max;  # No se pueden usar más buses de los disponibles

s.t. ParkingColegio: sum{i in origen, j in localizacion} VISITADO[i,j] - sum{i in localizacion, j in destino} VISITADO[i,j] = 0;  # Las rutas que salen del parking llegan al colegio

s.t. CapacidadAceptable {(i,j) in localizaciones}: FLUJO[i,j] - (bus_capacidad * VISITADO[i,j]) <= 0;  # No se pueden transportar más de 20 estudiantes

s.t. CapacidadExcedida {(i,j) in localizaciones}: -mGrande * VISITADO[i,j] + FLUJO[i,j] <= (bus_capacidad + 1);  # Si suben más de 20, se usa otro bus

s.t. FlujoEntradaSalida {j in paradas}: sum{i in localizacion} (FLUJO[i,j] - FLUJO[j,i]) + sum{k in alumnos} (PARADA[k,j]) = 0; # El flujo de estudiantes es igual a los que entran mas los que esperan menos los que salen

s.t. UnEstudianteUnaParada {i in alumnos}: sum{j in paradas} PARADA[i,j] = 1;  # Cada estudiante solo puede ir a una parada

s.t. EstudiantesSoloParadaAlcanzable {i in alumnos}: sum{j in paradas} PARADA[i,j] * paradasAlumnos[i,j] = 1;  # Los estudiantes solo pueden ir a una parada que puedan alcanzar

s.t. UnaMismaParadaHermanos {i in alumnos, j in alumnos, k in paradas}: hermanos[i,j] * (PARADA[i,k] - PARADA[j,k]) = 0;  # Los hermanos solo pueden ir a la misma parada


# Resolución del modelo
solve;

# Impresión
printf "\n\nResolución del modelo...\n\n";

printf "Coste óptimo: %g\n\n", Coste;

printf "Tramos visitados:\n";
printf {i in localizacion, j in localizacion :  VISITADO[i,j] > 0} "Se ha pasado por el tramo %s-%s\n", i, j;
printf "\n";

printf "Flujo de estudiantes en cada tramo:\n";
printf {i in localizacion, j in localizacion :  FLUJO[i,j] > 0} "Se han transportado %d estudiantes de %s a %s\n", FLUJO[i,j], i, j;
printf "\n";

printf "Paradas a las que va cada estudiante:\n";
printf {i in alumnos, j in paradas :  PARADA[i,j] > 0} "El estudiante %s va a la parada %s\n", i, j;
printf "\n";


# Terminar el programa
end;
