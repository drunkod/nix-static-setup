#!/bin/bash

# Вход в оболочку Nix
echo "Запуск оболочки Nix..."
~/nixstatic shell nixpkgs#nix nixpkgs#bashInteractive --command bash -c "
install_chrome() {
    echo 'Установка Google Chrome...'
    export NIXPKGS_ALLOW_UNFREE=1
    nix profile install nixpkgs#google-chrome --impure

    # Проверка успешности установки
    if command -v google-chrome-stable &> /dev/null; then
        echo 'Google Chrome успешно установлен.'

        # Обновление PATH в .bashrc
        echo 'export PATH=\"\$HOME/.nix-profile/bin:\$PATH\"' >> ~/.bashrc
        echo 'Обновлен PATH в ~/.bashrc.'

        # Перезагрузка .bashrc для обновления текущей сессии
        source ~/.bashrc
        google-chrome-stable --no-sandbox
    else
        echo 'Установка Google Chrome не удалась. Пожалуйста, проверьте вывод на наличие ошибок.'
        exit 1
    fi
}

# Проверка, установлен ли Google Chrome
if command -v google-chrome-stable &> /dev/null; then
    echo 'Google Chrome уже установлен. Запуск...'
    google-chrome-stable --no-sandbox
else
    echo 'Google Chrome не установлен.'
    read -p 'Хотите установить Google Chrome? (y/n): ' choice
    if [[ \"\$choice\" == 'y' || \"\$choice\" == 'Y' ]]; then
        install_chrome
    else
        echo 'Установка отменена.'
    fi
fi
"
