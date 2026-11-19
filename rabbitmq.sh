component=rabbitmq
source=common.sh

copy_component_repo &&

if {
    dnf install rabbitmq-server -y
} >> "$log_file" 2>&1; then
    echo -e "\e[32mRabbitMQ installed successfully\e[0m"
else
    echo -e "\e[31mRabbitMQ installation failed\e[0m"
    exit 1
fi

if {
    systemctl enable rabbitmq-server &&
    systemctl start rabbitmq-server
} >> "$log_file" 2>&1; then
    echo -e "\e[32mRabbitMQ enabled and started successfully\e[0m"
else
    echo -e "\e[31mRabbitMQ initialization failed\e[0m"
    exit 1
fi

if {
    rabbitmqctl add_user roboshop roboshop123 &&
    rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
} >> "$log_file" 2>&1; then
    echo -e "\e[32mRabbitMQ user added successfully\e[0m"
else
    echo -e "\e[31mRabbitMQ user creation failed\e[0m"
    exit 1
fi