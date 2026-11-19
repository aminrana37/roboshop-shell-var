component=frontend
source common.sh

app_name="nginx"
app_version="1.24"

app_setup &&

copy_app_config_file &&

rm -rf /usr/share/nginx/html/* &&

download_and_extract_frontend &&

app_enable_and_restart