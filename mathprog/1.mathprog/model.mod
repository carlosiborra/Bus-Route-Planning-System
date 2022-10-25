# Heurística y Optimización. Práctica 1.
# Alumnos: 100451170 & 100451258

# Modelo de la Parte 1

# Datos (constantes)
# Conjuntos
set paradas;  # Conjunto de las paradas del problema {"S1","S2","S3"}
set localizacion;  # Conjunto de todas las posibles localizaciones {"P","S1","S2","S3","C"}
set localizaciones := localizacion cross localizacion;  # Matriz de la combinación de todas las localizaciones
set origen;  # Origen de los buses (parking)
set destino;  # Destino de los buses (colegio)


# Parámetros
param mGrande;  # Número arbitrariamente grande, lo definimos en data aunque podría utilizarse directamente en el modelo
param bus_capacidad;  # Número máximo de estudiantes que puede transportar el bus
param bus_coste_fijo;  # Coste fijo por usar cada bus
param bus_coste_km;  # Coste por kilómetro recorrido
param bus_numero_max;  # Número máximo de buses que se pueden utilizar


param estudiantes {i in paradas}; # Num. de estud. en: {S1(0),S2(1),S3(2)}
param longitud {(i,j) in localizaciones}; # Distancia entre paradas


# Variables de decisión
var VISITADO {(i,j) in localizaciones}, binary;  # Si algún bus ha pasado por un tramo: 1: si, 0: no
var FLUJO {(i,j) in localizaciones}, >=0, integer;  # Flujo de estudiantes entre localizaciones


# Función objetivo
minimize Coste: sum{i in origen, j in localizacion} VISITADO[i,j] * bus_coste_fijo + bus_coste_km * sum{(k,l) in localizaciones} (VISITADO[k,l] * longitud[k,l]);


# Restricciones
s.t. UnicaParada {j in paradas}: sum{i in localizacion} VISITADO[i,j] = 1;  # Solo se puede hacer una parada en cada localización

s.t. UnicaSalida {i in paradas}: sum{j in localizacion} VISITADO[i,j] = 1;  # Solo se puede salir de cada localización

s.t. RutasMenosAutobuses {i in origen}: sum{j in localizacion} VISITADO[i,j] <= bus_numero_max;  # No se pueden usar más buses de los disponibles

s.t. ParkingColegio: sum{j in localizacion, i in origen} VISITADO[i,j] - sum{i in localizacion, j in destino} VISITADO[i,j] = 0;  # Las rutas que salen del parking llegan al colegio

s.t. CapacidadAceptable {(i,j) in localizaciones}: FLUJO[i,j] - (bus_capacidad * VISITADO[i,j]) <= 0;  # No se pueden transportar más de 20 estudiantes

s.t. CapacidadExcedida {(i,j) in localizaciones}: -mGrande * VISITADO[i,j] + FLUJO[i,j] <= (bus_capacidad + 1);  # Si suben más de 20, se usa otro bus

s.t. FlujoEntradaSalida {j in paradas}: sum{i in localizacion} (FLUJO[i,j] - FLUJO[j,i]) + estudiantes[j] = 0;  # Flujo de entrada + alumnos en la parada = flujo de salida



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


# Terminar el programa
end;
