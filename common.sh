GREEN="\e[32m"
RED="\e[31m"
NC="\e[0m"

echo_success="${GREEN}${app_name} setup successful${NC}"
echo_failed="${RED}${app_name} setup failed${NC}"
copy_success="${GREEN}${component} service file copied successfully${NC}"
copy_failed="${RED}${component} service file copy failed${NC}"
log_file="/tmp/${app_name}.log"

app_setup() {
    if {
        if [ -z "$app_version" ]; then
            dnf install "$app_name" -y
        else
            dnf module disable "$app_name" -y &&
            dnf module enable "$app_name:$app_version" -y &&
            dnf install "$app_name" -y
        fi
    } >> "$log_file" 2>&1; then
        echo -e "$echo_success" >> "$log_file" 2>&1
        return 0
    else
        echo -e "$echo_failed" >> "$log_file" 2>&1
        return 1
    fi
}

copy_app_config_file() {
    if{
        cp "${app_name}.conf" "/etc/${app_name}/${app_name}.conf"
    } >> "$log_file" 2>&1; then
        echo -e "$copy_success" >> "$log_file" 2>&1
        return 0
    else
        echo -e "$copy_failed" >> "$log_file" 2>&1
        return 1
    fi
}

copy_component_service_file() {
    if{
        cp "${component}.service" "/etc/systemd/system/${component}.service"
    } >> "$log_file" 2>&1; then
        echo -e "$copy_success" >> "$log_file" 2>&1
        return 0
    else
        echo -e "$copy_failed" >> "$log_file" 2>&1
        return 1
    fi
}

copy_component_repo() {
    if {
        cp "${component}.repo" /etc/yum.repos.d/${component}.repo
    } >> "$log_file" 2>&1; then
        echo -e "$copy_success" >> "$log_file" 2>&1
        return 0
    else
        echo -e "$copy_failed" >> "$log_file" 2>&1
        return 1
    fi
}

app_enable_and_restart(){
    if {
        systemctl enable "$app_name" &&
        systemctl restart "$app_name"
    } >> "$log_file" 2>&1; then
        echo -e "$echo_success" >> "$log_file" 2>&1
        return 0
    else
        echo -e "$echo_failed" >> "$log_file" 2>&1
        return 1
    fi
}

download_and_extract_frontend() {
    if {
        curl -fL -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &&
        cd /usr/share/nginx/html &&
        unzip -o /tmp/frontend.zip
    } >> "$log_file" 2>&1; then
        echo -e "${GREEN}Frontend download and extraction successful${NC}" >> "$log_file"
        return 0
    else
        echo -e "${RED}Frontend download and extraction failed${NC}" >> "$log_file"
        return 1
    fi
}

setup_component() {
    if {
        id roboshop &>/dev/null || useradd roboshop
        mkdir -p /app &&
        curl -fL -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}-v3.zip &&
        cd /app &&
        unzip -o /tmp/${component}.zip &&
        npm install
    } >> "$log_file" 2>&1; then
        echo -e "${GREEN}${component} setup successful${NC}" >> "$log_file"
        return 0
    else
        echo -e "${RED}${component} setup failed${NC}" >> "$log_file"
        return 1
    fi
}

setup_python() {
    if {
        id roboshop &>/dev/null || useradd roboshop
        mkdir -p /app &&
        curl -fL -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}-v3.zip &&
        cd /app &&
        unzip -o /tmp/${component}.zip &&
        cd /app 
        pip3 install -r requirements.txt
    } >> "$log_file" 2>&1; then
        echo -e "${GREEN}${component} setup successful${NC}" >> "$log_file"
        return 0
    else
        echo -e "${RED}${component} setup failed${NC}" >> "$log_file"
        return 1
    fi
}

setup_dispatch() {
    if {
        cp dispatch.service /etc/systemd/system/dispatch.service &&
        dnf install golang -y &&
        { id roboshop &>/dev/null || useradd roboshop; } &&
        mkdir -p /app &&
        curl -fL -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch-v3.zip &&
        cd /app &&
        unzip -o /tmp/dispatch.zip &&
        { [ -f go.mod ] || go mod init dispatch; } &&
        go get &&
        go build &&
        systemctl daemon-reload &&
        systemctl enable dispatch &&
        systemctl start dispatch
    } >> "$log_file" 2>&1; then
        echo -e "${GREEN}Dispatch setup successful${NC}"
        echo "Dispatch setup successful" >> "$log_file"
        return 0
    else
        echo -e "${RED}Dispatch setup failed${NC}"
        echo "Dispatch setup failed" >> "$log_file"
        return 1
    fi
}

reload_and_start_service() {
    if {
        systemctl daemon-reload &&
        systemctl enable ${component} &&
        systemctl start ${component}
    } >> "$log_file" 2>&1; then
        echo -e "${GREEN}${component} service started successfully${NC}" >> "$log_file"
        return 0
    else
        echo -e "${RED}${component} service failed to start${NC}" >> "$log_file"
        return 1
    fi
}