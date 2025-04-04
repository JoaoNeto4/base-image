#!/bin/bash

set -e

# set the postgres database host, port, user and password according to the environment
# and pass them as arguments to the odoo process if not present in the config file
: ${HOST:=${DB_PORT_5432_TCP_ADDR:='db'}}
: ${PORT:=${DB_PORT_5432_TCP_PORT:=5432}}
: ${USER:=${DB_ENV_POSTGRES_USER:=${POSTGRES_USER:='odoo'}}}
: ${PASSWORD:=${DB_ENV_POSTGRES_PASSWORD:=${POSTGRES_PASSWORD:='odoo'}}}

DB_ARGS=()
function check_config() {
    param="$1"
    value="$2"
    if [[ $value ]]
    then
        if ! grep -q -E "^\s*\b${param}\b\s*=" "$ODOO_RC" ; then
            DB_ARGS+=("--${param}")
            DB_ARGS+=("${value}")
        fi;
    else
        echo "db_NAME is empty"
    fi
}
check_config "db_host" "$HOST"
check_config "db_port" "$PORT"
check_config "db_user" "$USER"
check_config "db_password" "$PASSWORD"

check_config "database" "$DB_NAME"

case "$1" in
    -- | odoo-bin)
        shift
        if [[ "$1" == "scaffold" ]] ; then
            exec odoo-bin "$@"
        else
            exec odoo-bin "$@" "${DB_ARGS[@]}"
        fi
        ;;
    -*)
        exec odoo-bin "$@" "${DB_ARGS[@]}"
        ;;
    *)
        exec "$@"
esac

exit 1



