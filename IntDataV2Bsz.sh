#!/bin/bash

# Configuración de conexión a la base de datos
DB_NAME="AVA"
DB_USER="root"
DB_PASS="avastr" # Cambia esto por tu contraseña

# Función para insertar datos
insert_data() {
    name=$(dialog --inputbox "Ingrese el nombre:" 8 40 3>&1 1>&2 2>&3 3>&-)
    age=$(dialog --inputbox "Ingrese la edad:" 8 40 3>&1 1>&2 2>&3 3>&-)

    # Validación de la entrada
    if [[ -z "$name" || ! "$age" =~ ^[0-9]+$ ]]; then
        dialog --msgbox "Entrada no válida. Asegúrate de que el nombre no esté vacío y la edad sea un número." 8 50
        return
    fi

    # Inserción en la base de datos
    if mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "INSERT INTO users (name, age) VALUES ('$name', $age);"; then
        dialog --msgbox "Datos insertados correctamente." 8 50
    else
        dialog --msgbox "Error al insertar datos." 8 50
    fi
}
# Función para eliminar datos
delete_data() {
    id=$(dialog --inputbox "Ingrese el ID del usuario a eliminar:" 8 40 3>&1 1>&2 2>&3 3>&-)

    # Validación de la entrada
    if ! [[ "$id" =~ ^[0-9]+$ ]]; then
        dialog --msgbox "ID no válido. Debe ser un número." 8 50
        return
    fi

    # Eliminación de la base de datos
    if mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "DELETE FROM users WHERE id = $id;"; then
        dialog --msgbox "Datos eliminados correctamente." 8 50
    else
        dialog --msgbox "Error al eliminar datos." 8 50
    fi
}

# Función para ver registros
view_data() {
    # Obtener registros de la base de datos y formatear
    records=$(mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SELECT id, name, age FROM users;" | column -t -s $'\t')

    # Mostrar los registros en una ventana de diálogo
    if [[ -z "$records" ]]; then
        dialog --msgbox "No hay registros disponibles." 8 50
    else
        dialog --msgbox "$records" 20 80
    fi
}

        1 "Insertar datos" \
        2 "Eliminar datos" \
        3 "Ver registros" \
        4 "Salir" 3>&1 1>&2 2>&3)

    case $? in
        0) # Si el usuario presiona OK
            case $option in
                1) insert_data ;;
                2) delete_data ;;
                3) view_data ;;
                4) dialog --msgbox "Saliendo..." 5 30; exit 0 ;;
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

