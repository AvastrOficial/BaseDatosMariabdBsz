#!/bin/bash

# Configuración de conexión a la base de datos
DB_NAME="AVA"
DB_USER="root"
DB_PASS="avastr" # Cambia esto por tu contraseña

# Carpeta y archivo para guardar el registro
LOG_DIR="./logs"
LOG_FILE="$LOG_DIR/data_log.txt"

# Crear la carpeta si no existe
mkdir -p "$LOG_DIR"

# Función para registrar datos en el archivo
log_data() {
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "$timestamp - $1" >> "$LOG_FILE"
}

# Función para insertar múltiples registros
insert_multiple_data() {
    records=""

    for i in $(seq 1 100); do
        name="Name_$i"
        age=$((RANDOM % 100 + 1))  # Genera una edad aleatoria entre 1 y 100
        records+="('$name', $age),"
    done

    # Eliminar la última coma
    records=${records%,}

    # Inserción en la base de datos
    if mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "INSERT INTO users (name, age) VALUES $records;"; then
        log_data "Insertados múltiples registros."
        dialog --msgbox "Se han insertado 100 registros correctamente." 8 50
    else
        dialog --msgbox "Error al insertar múltiples registros." 8 50
    fi
}

# Función para eliminar datos
delete_data() {
    id=$(dialog --inputbox "Ingrese el ID del usuario a eliminar:" 8 40 3>&1 1>&2 2>&3)

    # Validación de la entrada
    if ! [[ "$id" =~ ^[0-9]+$ ]]; then
        dialog --msgbox "ID no válido. Debe ser un número." 8 50
        return
    fi

    # Eliminación de la base de datos
    if mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "DELETE FROM users WHERE id = $id;"; then
        log_data "Eliminado: ID='$id'"
        dialog --msgbox "Datos eliminados correctamente." 8 50
    else
        dialog --msgbox "Error al eliminar datos." 8 50
    fi
}

# Función para ver registros
view_data() {
    records=$(mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SELECT id, name, age FROM users;")

    if [[ -z "$records" ]]; then
        dialog --msgbox "No hay registros disponibles." 8 50
        return
    fi

    formatted_records=$(echo "$records" | awk '
        BEGIN {
            max_name_length = 20
            print "+----+------------------+-----+"
            print "| ID | Name             | Age |"
            print "+----+------------------+-----+"
        }
        NR>1 {
            name_length = length($2) > max_name_length ? max_name_length : length($2)
            printf("| %-2s | %-*s | %-3s |\n", $1, name_length, $2, $3)
        }
        END {
            print "+----+------------------+-----+"
        }
    ')

    dialog_output=$(center_text "$formatted_records")
    dialog --msgbox "$dialog_output" 20 50
}

# Función para centrar el texto
center_text() {
    local input="$1"
    local term_width=$(tput cols)
    local center
    while IFS= read -r line; do
        center=$(printf "%*s" $(((${#line} + term_width) / 2)) "$line")
        echo "$center"
    done <<< "$input"
}

# Función para ejecutar consultas SQL
execute_query() {
    query=$(dialog --inputbox "Ingrese su consulta SQL:" 10 50 3>&1 1>&2 2>&3)

    # Validar y ejecutar la consulta
    if mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "$query"; then
        log_data "Consulta ejecutada: $query"
        dialog --msgbox "Consulta ejecutada correctamente." 8 50
        view_data  # Llama a la función para ver los registros después de ejecutar la consulta
    else
        dialog --msgbox "Error al ejecutar la consulta." 8 50
    fi
}

# Función para borrar todos los registros
delete_all_data() {
    if dialog --yesno "¿Está seguro de que desea borrar todos los registros?" 7 60; then
        # Simulación de carga
        (
            for i in $(seq 1 10); do
                sleep 0.5  # Simulación de carga
                progress_bar $i
            done
        ) | dialog --progressbox "Borrando registros..." 10 60
        
        # Borrar todos los registros
        mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "DELETE FROM users;"
        log_data "Todos los registros han sido borrados."
        dialog --msgbox "Todos los registros han sido borrados." 8 50
    else
        dialog --msgbox "Operación cancelada." 8 50
    fi
}

# Función para mostrar la barra de progreso
progress_bar() {
    local progress=$1
    local bar=""
    for ((j=1; j<=progress; j++)); do
        bar+="=="
    done
    printf "Carga: [%s%s] %d%%\n" "$bar" "$(printf ' ' $((20-progress*2)))" $((progress*10))
}

# Bucle principal
while true; do
    option=$(dialog --menu "Seleccione una opción:" 15 50 6 \
        1 "Insertar un solo registro" \
        2 "Eliminar datos" \
        3 "Ver registros" \
        4 "Ejecutar consulta SQL" \
        5 "Insertar múltiples registros" \
        6 "Borrar todos los registros" \
        7 "Salir" 3>&1 1>&2 2>&3)

    case $? in
        0) # Si el usuario presiona OK
            case $option in
                1) insert_data ;;
                2) delete_data ;;
                3) view_data ;;
                4) execute_query ;;
                5) insert_multiple_data ;;  # Opción para insertar múltiples registros
                6) delete_all_data ;;  # Opción para borrar todos los registros
                7) dialog --msgbox "Saliendo..." 5 30; exit 0 ;;
                *) dialog --msgbox "Opción no válida. Intente de nuevo." 5 30 ;;
            esac
            ;;
        1) # Si el usuario presiona Cancelar
            dialog --msgbox "Saliendo..." 5 30
            exit 0
            ;;
        255) # Si se cierra la ventana
            dialog --msgbox "Saliendo..." 5 30
            exit 0
            ;;
    esac
done
