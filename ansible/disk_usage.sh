# set the threshold percentage
THRESHOLD=90

# Get the disk usage value
USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')

echo "$USAGE%"

# Check if the disk usage is above the threshold
if [ $USAGE -gt $THRESHOLD ]; then
  ansible-playbook /home/kali/Desktop/ansible/send_mail_playbook.yml -e "subject='Disk usage warning' body='Disk usage is $USAGE%'"
  rm /etc/cron.d/disk_usage
fi

echo "$(date)"
