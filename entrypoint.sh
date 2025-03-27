#!/bin/bash
set -e

# SSH 서비스 시작
service ssh start

# 사용자 정의 명령 실행
exec "$@"
