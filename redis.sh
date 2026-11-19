app_name=redis
app_version="7"
source common.sh

app_setup &&

if {
    sed -i 's/127\.0\.0\.1/0.0.0.0/g' /etc/redis/redis.conf &&
    sed -i 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf
} >> "$log_file" 2>&1; then
    echo -e "\e[32mRedis configuration updated successfully\e[0m"
else
    echo -e "\e[31mRedis configuration update failed\e[0m"
    exit 1
fi

app_enable_and_restart
