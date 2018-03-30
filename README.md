### Описание
- Старт чистой сессии браузера под выбранной ролью

### Запуск:
+ `ruby run`
+ Указать ссылку для перехода - автоматически определится проект
+ Выбрать роль для авторизации
+ Произойдет авторизация под выбранной ролью, а затем переход на введенный урл.
#### Управление браузером:
- Перезапустить браузер:
 `restart`
- Остановить браузер:
 `stop`
- Запустить браузер (если уже остановлен):
 `start` 
- Разлогиниться:
 `logout`
- Залогиниться под выбранной ролью и перейти на урл (впервые введенный)
 `login`
 
### Логи:
- Selenium: `selenium.log`
- Errors: `errors.log`
- All actions (for debug): `logger.log`

### Структура файла конфигурации:
```yaml
project:
  project_name:   # Название проекта для навигации
    name: ''      # Название проекта для вывода в меню
    mark: ''      # Метка - уникальная строчка для главной страницы проекта
    roles:        # роли
      user: ''    # path для авторизации (добавляется к урлу)
```
