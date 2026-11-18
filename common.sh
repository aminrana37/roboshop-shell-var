GREEN="\e[32m"
RED="\e[31m"
NC="\e[0m"

echo_success="${GREEN}${app_name} setup successful${NC}"
echo_failed="${RED}${app_name} setup failed${NC}"
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
    cp "${app_name}.conf" "/etc/${app_name}/${app_name}.conf" >> "$log_file" 2>&1
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