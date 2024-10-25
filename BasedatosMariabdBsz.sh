# Configuración de conexión a la base de datos
DB_NAME="TU_BASE_DATOS"
DB_USER="root"
DB_PASS="tu_contraseña" # Cambia esto por tu contraseña

# Función para insertar datos
insert_data() {
    echo "Insertando datos..."
    read -p "Ingrese el nombre: " name
    read -p "Ingrese la edad: " age

    mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "INSERT INTO users (name, age) VALUES ('$name', $age);"
    echo "Datos insertados correctamente."
}

# Función para eliminar datos
delete_data() {
    echo "Eliminando datos..."
    read -p "Ingrese el ID del usuario a eliminar: " id

    mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "DELETE FROM users WHERE id = $id;"
    echo "Datos eliminados correctamente."
}

# Función para ver registros
view_data() {
    echo "Registros en la tabla 'users':"
    mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SELECT * FROM users;"
}

# Menú principal
while true; do
    echo "Seleccione una opción:"
    echo "1) Insertar datos"
    echo "2) Eliminar datos"
    echo "3) Ver registros"
    echo "4) Salir"
    read -p "Opción: " option

    case $option in
        1)
            insert_data
            ;;
        2)
            delete_data
            ;;
        3)
            view_data
            ;;
        4)
            echo "Saliendo..."
            exit 0
            ;;
        *)
            echo "Opción no válida. Intente de nuevo."
            ;;
    esac
done
