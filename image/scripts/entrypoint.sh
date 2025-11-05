#!/bin/bash
set -e

# Export all environment variables to make them available to cron
printenv | sed 's/^\(.*\)$/export \1/g' | grep -E '^export [A-Z_]' > /etc/cron_env.sh
chmod +x /etc/cron_env.sh

# Set default backup schedule if not provided
BACKUP_SCHEDULE="${BACKUP_SCHEDULE:-0 0 * * *}"

# Create cron job dynamically with environment sourcing
# Note: cron requires a newline at the end of the file
echo "${BACKUP_SCHEDULE} root . /etc/cron_env.sh; /opt/backup.sh >> /var/log/cron.log 2>&1" > /etc/cron.d/backup
echo "" >> /etc/cron.d/backup

# Set proper permissions for cron job file
chmod 0644 /etc/cron.d/backup

# Apply cron job
crontab /etc/cron.d/backup

# Touch the log file so it exists
touch /var/log/cron.log

# Start cron in foreground
exec cron -f
