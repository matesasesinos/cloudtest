#!/bin/sh

# Iniciar el servidor web de Laravel
php artisan serve --host=0.0.0.0 --port=8080

php artisan migrate

# Iniciar el worker de la cola
php artisan queue:work --tries=3 --timeout=3600
    
# Mantener el contenedor corriendo
tail -f /dev/null
