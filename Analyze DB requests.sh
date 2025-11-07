# в этот лог запишутся все запросы что пришли на муськосервер за отведенное время помогает 
# оценить нагрузку и понять чем вообще муська занята
rm -f /var/log/general.log
touch /var/log/general.log
chmod 0777 /var/log/general.log
mysql -pтутрутовыйпароль -e "SET GLOBAL general_log_file='/var/log/general.log'; SET GLOBAL general_log=1;"
sleep 10800 #3 часа
mysql -pтутрутовыйпароль -e "SET GLOBAL general_log=0;"