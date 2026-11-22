; 1. Язык и раскладка (Alt+Shift)
("/sysconfig-base/kbd" language ("ru_RU") action "write" layout "alt_sh_toggle")

; 2. Дата и время
("/datetime-installer" action "write" commit #t name "Europe" zone "Europe/Moscow" utc #t ctime "устанавливается автоматически")

; 3. Сеть (DHCP через NetworkManager)
("/net-eth" action "write" name "" ipv "4" ipv_enabled #t controlled "NetworkManager" configuration "dhcp" default "" search "" dns "" computer_name "alt-edu")
("/net-eth" action "write" commit #t)

; 4. Полная очистка диска и авторазметка (профиль workstation)
("/evms/control" action "write" control open installer #t)
("/evms/control" action "write" control update)
("/evms/profiles/workstation" action apply commit #f clearall #t exclude ())
("/evms/control" action "write" control commit)
("/evms/control" action "write" control close)

; 5. Установка всех выбранных в логе групп пакетов
("pkg-install-init" action "write")
("/pkg-install" action "write" lists "education/cert-espd education/apt-conf-rutoken education/apt-conf-r7 education/apt-conf-netpolice education/libreoffice education/server-apps-edu education/robotics education/teacher education/university education/secondary_vocational education/highschool education/preschool education/kde")
("/preinstall" action "write")

; 6. Загрузчик GRUB (UEFI)
("/grub" action "write" device "efi" passwd #f passwd_1 "*" passwd_2 "*")

; 7. Пароль суперпользователя root 
("/root/change_password" passwd_2 "Admin" passwd_1 "Admin")

; 8. Создание пользователя user с правами администратора (sudo)
("/users/create_account" new_name "user" real_name "" allow_su #t auto #f passwd_1 "user" passwd_2 "user" autologin #f)

; 9. Копирование папки alt_offline с флешки в /opt будущей системы до перезагрузки
("/postinstall/laststate" run "SRC=$(find / -maxdepth 4 -type d -name 'alt_offline' 2>/dev/null | head -n 1); if [ -n \"$SRC\" ]; then mkdir -p ${destdir:-/mnt/destination}/opt && cp -r \"$SRC\" ${destdir:-/mnt/destination}/opt/alt_offline && chmod +x ${destdir:-/mnt/destination}/opt/alt_offline/install_offline.sh; fi")

; 10. Установка имени ПК по MAC-адресу, обновление /etc/hosts и запуск скрипта установки драйверов при первом старте
("/postinstall/firsttime" run "MAC=$(cat /sys/class/net/[ew]*/address 2>/dev/null | grep -v '00:00:00:00:00:00' | head -n 1 | tr -d ':' | tail -c 7); [ -z \"$MAC\" ] && MAC=$((1000 + RANDOM % 9000)); NEW_HOST=\"alt-edu${MAC}\"; hostnamectl set-hostname \"$NEW_HOST\"; grep -q '127.0.1.1' /etc/hosts && sed -i \"s/^127\\.0\\.1\\.1.*/127.0.1.1\\t$NEW_HOST/\" /etc/hosts || echo -e \"127.0.1.1\\t$NEW_HOST\" >> /etc/hosts; if [ -f /opt/alt_offline/install_offline.sh ]; then cd /opt/alt_offline && bash /opt/alt_offline/install_offline.sh > /var/log/install_offline.log 2>&1; fi")
