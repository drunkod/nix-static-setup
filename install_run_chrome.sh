#!/bin/bash

# Вход в оболочку Nix
echo "Запуск оболочки Nix..."
~/nixstatic shell nixpkgs#nix nixpkgs#bashInteractive --command bash -c "
install_chrome() {
    echo 'Установка Google Chrome...'
    export NIXPKGS_ALLOW_UNFREE=1
    nix profile install nixpkgs#google-chrome --impure
    # Проверка наличия google-chrome-stable в ~/.nix-profile/bin
    if [ -f ~/.nix-profile/bin/google-chrome-stable ]; then
        echo 'Google Chrome найден в ~/.nix-profile/bin. Запуск...'
        ~/.nix-profile/bin/google-chrome-stable --no-sandbox
    else
        # Обновление PATH в .bashrc
        echo 'export PATH=\"\$HOME/.nix-profile/bin:\$PATH\"' >> ~/.bashrc
        echo 'Обновлен PATH в ~/.bashrc.'

        # Перезагрузка .bashrc для обновления текущей сессии
        source ~/.bashrc
        google-chrome-stable --no-sandbox
    fi
}

# Проверка наличия google-chrome-stable в ~/.nix-profile/bin
if [ -f ~/.nix-profile/bin/google-chrome-stable ]; then
    echo 'Google Chrome найден в ~/.nix-profile/bin. Запуск...'
    ~/.nix-profile/bin/google-chrome-stable --no-sandbox
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

