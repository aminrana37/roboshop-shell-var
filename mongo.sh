component=mongo
source common.sh

copy_component_repo &&

if {
    dnf install mongodb-org -y
} >> "$log_file" 2>&1; then
    echo -e "\e[32mMongoDB installed successfully\e[0m"
else
    echo -e "\e[31mMongoDB installation failed\e[0m"
    exit 1
fi

if {
    systemctl enable mongod &&
    systemctl start mongod
} >> "$log_file" 2>&1; then
    echo -e "\e[32mMongoDB enabled and started successfully\e[0m"
else
    echo -e "\e[31mMongoDB initialization failed\e[0m"
    exit 1
fi

if {
    sed -i 's/127\.0\.0\.1/0.0.0.0/g' /etc/mongod.conf
} >> "$log_file" 2>&1; then
    echo -e "\e[32mMongoDB configuration updated successfully\e[0m"
else
    echo -e "\e[31mMongoDB configuration update failed\e[0m"
    exit 1
fi

if {
    systemctl restart mongod
} >> "$log_file" 2>&1; then
    echo -e "\e[32mMongoDB restarted successfully\e[0m"
else
    echo -e "\e[31mMongoDB restart failed\e[0m"
    exit 1
fi
