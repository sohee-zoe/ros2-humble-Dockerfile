#!/bin/bash
set -e

# mise 환경 로드
eval "$($HOME/.local/bin/mise activate zsh)"

# .zshrc 설정 추가 (중복 실행 방지)
if ! grep -q 'uv generate-shell-completion zsh' ~/.zshrc; then
    echo 'eval "$(uv generate-shell-completion zsh)"' >> ~/.zshrc
    echo 'eval "$(uvx --generate-shell-completion zsh)"' >> ~/.zshrc
fi

if ! grep -q 'function pip()' ~/.zshrc; then
    cat << 'EOF' >> ~/.zshrc

# pip 함수 재정의
function pip() {
  uv pip "$@"
}

# python3 -m pip 리다이렉트
function python3() {
  if [ "$1" = "-m" ] && [ "$2" = "pip" ]; then
    shift 2
    uv pip "$@"
  else
    /usr/bin/python3 "$@"
  fi
}
EOF
fi

# SSH 서비스 시작
service ssh start

# 사용자 정의 명령 실행
exec "$@"
