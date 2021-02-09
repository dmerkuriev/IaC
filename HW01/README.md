# Домашнее задание № 1.

Подготовка базового образа VM при помощи Packer.  
Цель: В данном дз студент произведет сборку готового образа с установленным nginx при помощи Packer.  
В данном задании тренируются навыки: работы с Packer, работы с Yandex Compute Engine.  

1. Установите Yandex.CLI:  
   Инструкция по установке Yandex CLI доступно по ссылке: https://cloud.yandex.ru/docs/cli/operations/install-cli  
   Интерактивная установка CLI  
   Выполните команду:  
   ```
   $ curl https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
   ```    
   Скрипт установит CLI и добавит путь до исполняемого файла в переменную окружения PATH.  
   После завершения установки перезапустите командную оболочку или перечитайте список переменных пользователей.  
   ```
   $ source "/home/dm/.bashrc"  
   ```

2. Установите Packer https://www.packer.io/  
   Для установки Packer воспользуемся инструкцией: https://learn.hashicorp.com/tutorials/packer/getting-started-install  
   Add the HashiCorp GPG key.  
   ```
   $ curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -  
   ```  
   Add the official HashiCorp Linux repository.  
   ```
   $ sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"  
   ```
   Update and install.  
   ```
   $ sudo apt-get update && sudo apt-get install packer  
   ```  
   проверим что packer установлен  
   ```
   $ packer -v
   1.6.6
   ```

3. Подключитесь при помощи Yandex CLI к облаку и просмотрите конфигурацию:  
   ```
   $ yc init 
   Welcome! This command will take you through the configuration process.
   Please go to https://oauth.yandex.ru/authorize?response_type=token&client_id=YYYYYYYYYYYYYYYYYYYY in order to obtain OAuth token.

   Please enter OAuth token: XXXXXXXXXXXXXXXXXXXXXXXX
   You have one cloud available: 'cloud-dmerkuriev' (id = b1gvvqr9sfgjrro5v11e). It is going to be used by default.
   Please choose folder to use:
   [1] default (id = b1gscu260sct1qcvduhm)
   [2] Create a new folder
   Please enter your numeric choice: 1
   Your current folder has been set to 'default' (id = b1gscu260sct1qcvduhm).
   Do you want to configure a default Compute zone? [Y/n] Y
   Which zone do you want to use as a profile default?
   [1] ru-central1-a
   [2] ru-central1-b
   [3] ru-central1-c
   [4] Don't set default zone
   Please enter your numeric choice: 3
   Your profile default Compute zone has been set to 'ru-central1-c'.
   ```  

   ```
   $ yc config list
   token: XXXXXXXXXXXXXXXXXXXXXXXX
   cloud-id: b1gvvqr9sfgjrro5v11e
   folder-id: b1gscu260sct1qcvduhm
   compute-default-zone: ru-central1-c
   ```  
   ```
   $ yc vpc subnet list
   +----------------------+-----------------------+----------------------+----------------+---------------+-----------------+
   |          ID          |         NAME          |      NETWORK ID      | ROUTE TABLE ID |     ZONE      |      RANGE      |
   +----------------------+-----------------------+----------------------+----------------+---------------+-----------------+
   | b0cvqtcfkubj933v6u8q | default-ru-central1-c | enp1b5tlqv56fmpsrkhf |                | ru-central1-c | [10.128.0.0/24] |
   | e2l27a7ga03ocqm8cv3m | default-ru-central1-b | enp1b5tlqv56fmpsrkhf |                | ru-central1-b | [10.129.0.0/24] |
   | e9bt0tfr209844e521f9 | default-ru-central1-a | enp1b5tlqv56fmpsrkhf |                | ru-central1-a | [10.130.0.0/24] |
   +----------------------+-----------------------+----------------------+----------------+---------------+-----------------+
   ```


4. Склонируйте к себе репозиторий https://github.com/timurb/otus-packer и создайте у себя в облаке образ:  
   packer build json/template.json (понадобится установить переменные)  
   Склонируем репозиторий:  
   ```
   $ git clone git@github.com:timurb/otus-packer.git
   Клонирование в «otus-packer»…
   remote: Enumerating objects: 40, done.
   remote: Counting objects: 100% (40/40), done.
   remote: Compressing objects: 100% (26/26), done.
   remote: Total 40 (delta 16), reused 35 (delta 11), pack-reused 0
   Получение объектов: 100% (40/40), 5.10 KiB | 5.10 MiB/s, готово.
   Определение изменений: 100% (16/16), готово.
   ```  

   Документацию Packer по Yandex Compute Builder:  
   https://www.packer.io/docs/builders/yandex  
   Документация Packer по переменным:  
   https://www.packer.io/docs/templates/user-variables  
   https://www.packer.io/docs/templates/engine

   Отредактируем файл с переменными: 
   ```
   $ vim ./otus-packer/json/variables.json
   {
      "folder_id": "b1gscu260sct1qcvduhm",
      "subnet_id": "b0cvqtcfkubj933v6u8q"
   }
   ```

   Запустим сборку образа:  
   ```
   packer build -var-file json/variable.json json/template.json
   ```  

   Дожидаемся окончания сборки и проверяем собраный образ командой:  
   ```
   $ yc compute image list
   +----------------------+--------------------------------------------+-------------------+----------------------+--------+
   |          ID          |                    NAME                    |      FAMILY       |     PRODUCT IDS      | STATUS |
   +----------------------+--------------------------------------------+-------------------+----------------------+--------+
   | fd83bv773suencuut3k4 | ubuntu-2004-lts-nginx-2021-02-08t16-37-45z | ubuntu-web-server | f2e2omleq2p9hqm60avu | READY  |
   +----------------------+--------------------------------------------+-------------------+----------------------+--------+
   ```  
   Удалим образ командой:  
   ``` 
   $ yc compute image delete ubuntu-2004-lts-nginx-2021-02-08t16-37-45z
   ```  

5. (*) Создайте сервисную учетную запись для packer:  
   Подробнее про сервисные аккаунты можно прочитать по ссылке https://cloud.yandex.ru/docs/iam/operations/sa/create  
   ```
   $ yc iam service-account create --name packer --folder-id b1gscu260sct1qcvduhm
   id: ajekk1t7957dkmlus3cl
   folder_id: b1gscu260sct1qcvduhm
   created_at: "2021-02-08T16:50:18.318851Z"
   name: packer
   $
   $ yc resource-manager folder add-access-binding --id b1gscu260sct1qcvduhm --role editor --service-account-id ajekk1t7957dkmlus3cl
   done (1s)
   $
   $ yc iam key create --service-account-id ajekk1t7957dkmlus3cl --output key.json
   id: ajepb5qfdvo8aso7fgiu
   service_account_id: ajekk1t7957dkmlus3cl
   created_at: "2021-02-08T16:56:19.404208Z"
   key_algorithm: RSA_2048
   ```  

6. (*) Вставьте путь к вашему ключу в template.json в "service_account_key_file" в блок builders и создайте из этого шаблона образ (вероятно понадобится удалить из шаблона параметр token).  
   
   Из template.json в блоке variables удаляем строчку:  
   "token": "{{env \`YC_TOKEN\`}}",  
   в блоке builders удаляем строчку:  
   "token": "{{user \`token\`}}",  
   в блоке builders указываем переменную "service_account_key_file" в которой указываем путь до ключа key.json, который мы создали выше:  
   "service_account_key_file": "key.json",  


7. (*) Параметризуйте сборку, например добавьте установку image_description пользователем.  
   В template.json в блоке "variables" добавляем строку: "image_description": null  
   в блоке builders меняем строку  
   "image_description": "my custom ubuntu with nginx",  
   на строку:  
   "image_description": "{{user \`image_description`}}",  

   Тогда при запуске сборки можно будет определить перменную image_description на свое значение, например запустив сборку следующей командой:  
   ```  
   $ packer build -var-file variables.json -var image_description="user image description from cli" template.json
   ```  
   Посмотреть результат подстановки переменной image_description можно выполнив команду:
   ```
   $ yc compute image get fd8aq8orin5a0uof3iqa
   id: fd8aq8orin5a0uof3iqa
   folder_id: b1gscu260sct1qcvduhm
   created_at: "2021-02-08T19:08:01Z"
   name: ubuntu-2004-lts-nginx-2021-02-08t19-05-40z
   description: user image description from cli
   family: ubuntu-web-server
   storage_size: "3451912192"
   min_disk_size: "10737418240"
   product_ids:
   - f2e2omleq2p9hqm60avu
   status: READY
   os:
     type: LINUX
   ```

8. Удалите созданные образы:
   ```
   yc compute image list
   yc compute image delete "имя образа"
   ```

9. Пришлите последние строчки вывода packer build (те, в которых указан id) и получившийся в финале template.json

   Вывод команды packer build c id:  
   ```
   ==> Builds finished. The artifacts of successful builds are:
   --> yandex: A disk image was created: ubuntu-2004-lts-nginx-2021-02-08t19-05-40z (id: fd8aq8orin5a0uof3iqa) with family name ubuntu-web-server
   ```
   Получившийся в финале template.json: https://github.com/dmerkuriev/IaC/otus-packer/json/template.json

   Как вариант задания со (*) реализуйте это не на Yandex.Cloud, а на любом другом облаке или системе виртуализациию  
   Делать не стал.