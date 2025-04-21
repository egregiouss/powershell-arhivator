# PowerShell скрипт для архивирования поддиректорий с проверкой целостности


## 📝 Описание
Скрипт для автоматического создания 7zip-архивов для всех поддиректорий корневой с генерацией контрольных сумм.
Каждый архив сопровождается файлом проверки целостности.
<<<<<<< HEAD

## 📦 Требования
- **PowerShell**
- **7-Zip** (должен быть доступен через PATH)
=======
К скрипту написаны тесты, покрывающие базовый функционал, он работает и на Win и на Linux. Тесты запускаются в Docker

## 📦 Требования
- **PowerShell**
- **7-Zip**
>>>>>>> ee665b1c40d97969ec83b484237ad69ec83381ed
- Для тестов: **Pester**



<<<<<<< HEAD
### Установка
# Клонирование репозитория
git clone https://github.com/ваш-репозиторий.git
cd ваш-репозиторий

# Установка Pester (для тестов)
Install-Module -Name Pester -Force -SkipPublisherCheck
=======
## QuickStart
### Клонирование репозитория
```
git clone https://github.com/powershell-arhivator.git
cd powershell-arhivator
```

### Запуск скрипта
```
make start SOURCE_DIR=./src_dir OUTPUT_DIR=./output_dir
```
При запуске скрипта без параметров SOURCE_DIR=./dev_build  OUTPUT_DIR=./artifacts
### Запуск тестов
```
make test
```
>>>>>>> ee665b1c40d97969ec83b484237ad69ec83381ed
