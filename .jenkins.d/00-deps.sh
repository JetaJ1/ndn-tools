#!/usr/bin/env bash
set -ex

if has OSX $NODE_LABELS; then
    FORMULAE=(boost openssl pkg-config)

    if [[ -n $GITHUB_ACTIONS ]]; then
        # GitHub Actions runners have a large number of pre-installed
        # Homebrew packages. Don't waste time upgrading all of them.
        brew list --versions "${FORMULAE[@]}" || brew update
        for FORMULA in "${FORMULAE[@]}"; do
            brew list --versions "$FORMULA" || brew install "$FORMULA"
        done
        # Ensure /usr/local/opt/openssl exists
        brew reinstall openssl
    else
        brew update
        brew upgrade
        brew install "${FORMULAE[@]}"
        brew cleanup
    fi

    if [[ $JOB_NAME == *"Docs" ]]; then
        pip3 install --upgrade --upgrade-strategy=eager sphinx
    fi

elif has Ubuntu $NODE_LABELS; then
    sudo apt-get -qq update
    sudo apt-get -qy install build-essential pkg-config python3-minimal \
                             libboost-all-dev libssl-dev libsqlite3-dev \
                             libpcap-dev

    case $JOB_NAME in
        *code-coverage)
            sudo apt-get -qy install lcov python3-pip
            pip3 install --user --upgrade --upgrade-strategy=eager 'gcovr~=5.1'
            ;;
        *Docs)
            sudo apt-get -qy install python3-pip
            pip3 install --user --upgrade --upgrade-strategy=eager sphinx
            ;;
    esac

elif has CentOS $NODE_LABELS; then
    sudo dnf -y install gcc-c++ libasan pkgconf-pkg-config python3 \
                        boost-devel openssl-devel sqlite-devel \
                        libpcap-devel
fi
