component=shipping
source=common.sh

copy_component_service_file &&

if {
    dnf install maven -y 
} >> "$log_file" 2>&1; then
    echo -e "\e[32mMaven installed successfully\e[0m"
else
    echo -e "\e[31mMaven installation failed\e[0m"
    exit 1
fi


if {
    useradd roboshop &&
    mkdir /app &&
    curl -L -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}-v3.zip 
    cd /app 
    unzip /tmp/${component}.zip

    cd /app 
    mvn clean package 
    mv target/${component}-1.0.jar ${component}.jar 
} >> "$log_file" 2>&1; then
    echo -e "\e[32m${component} application setup completed successfully\e[0m"
else
    echo -e "\e[31m${component} application setup failed\e[0m"
    exit 1
fi

reload_and_start_service &&

if {
    dnf install mysql -y &&
    mysql -h mysql-dev.mdevsecops.online -uroot -pRoboShop@1 < /app/db/schema.sql &&
    mysql -h mysql-dev.mdevsecops.online -uroot -pRoboShop@1 < /app/db/app-user.sql &&
    mysql -h mysql-dev.mdevsecops.online -uroot -pRoboShop@1 < /app/db/master-data.sql &&
} >> "$log_file" 2>&1; then
    echo -e "\e[32m${component} database setup completed successfully\e[0m"
else
    echo -e "\e[31m${component} database setup failed\e[0m"
    exit 1
fi

if {
    systemctl restart shipping
} >> "$log_file" 2>&1; then
    echo -e "\e[32m${component} service restarted successfully\e[0m"
else
    echo -e "\e[31m${component} service restart failed\e[0m"
    exit 1
fi