component=mysqld
source common.sh

if {
        dnf install mysql-server -y
    } >> "$log_file" 2>&1; then
        echo -e "${GREEN}${component} installed successfully${NC}" >> "$log_file" 2>&1
        return 0
    else
        echo -e "${RED}${component} installation failed${NC}" >> "$log_file" 2>&1
        return 1
    fi

app_enable_and_restart &&

if {
        mysql_secure_installation --set-root-pass RoboShop@1
    } >> "$log_file" 2>&1; then
        echo -e "${GREEN}${component} user addition successfully${NC}" >> "$log_file" 2>&1
        return 0
    else
        echo -e "${RED}${component} user addition failed${NC}" >> "$log_file" 2>&1
        return 1
    fi

