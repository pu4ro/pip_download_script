# Pip Download Script

Python 패키지를 여러 버전의 Python 환경에서 다운로드하는 도구입니다.

## Description

이 프로젝트는 `mrx_link`, `mrx-runway` 및 기타 Python 패키지를 여러 Python 버전(3.8, 3.9, 3.10, 3.11)에 대해 다운로드합니다. 각 Python 버전별로 격리된 가상 환경(venv)을 사용하여 의존성 충돌을 방지합니다.

## Features

- **다중 Python 버전 지원**: 여러 Python 버전에 대한 패키지 다운로드
- **격리된 가상 환경**: 각 Python 버전별 독립적인 venv 사용
- **유연한 패키지 관리**: requirements.txt를 통한 패키지 추가/관리
- **Makefile 기반 자동화**: 간편한 명령어로 전체 프로세스 실행
- **시스템 의존성 자동 설치**: PostgreSQL 개발 도구 등 자동 설치

## Prerequisites

- Ubuntu/Debian 기반 시스템 (sudo 권한 필요)
- Python 3.8, 3.9, 3.10, 3.11 설치
- 인터넷 연결
- make 설치

## Quick Start

### 1. 전체 프로세스 실행 (권장)
```bash
make all
```

이 명령어는 다음을 순차적으로 실행합니다:
- **Python 버전 설치** (3.8, 3.9, 3.10, 3.11) - deadsnakes PPA 사용
- 시스템 의존성 설치 (libpq-dev 등)
- 모든 Python 버전에 대한 venv 생성
- requirements.txt의 모든 패키지 다운로드

### 2. 단계별 실행

#### Python 버전 설치 (첫 실행 시 필요)
```bash
# deadsnakes PPA를 통해 Python 3.8, 3.9, 3.10, 3.11 설치
make install-python
```

이 명령어는 다음을 수행합니다:
- deadsnakes PPA 저장소 추가
- Python 3.8, 3.9, 3.10, 3.11 및 각각의 venv 패키지 설치
- 설치 완료 후 자동으로 설치된 버전 확인

#### 사용 가능한 Python 버전 확인
```bash
make check-python
```

#### 시스템 의존성 설치
```bash
make install-deps
```

#### 가상 환경 설정
```bash
# 모든 Python 버전에 대해 venv 생성
make setup

# 특정 Python 버전에 대해서만 venv 생성
make venv VERSION=3.9
```

#### 패키지 다운로드
```bash
# 모든 Python 버전에 대해 다운로드
make download

# 특정 Python 버전에 대해서만 다운로드
make download VERSION=3.10
```

## 패키지 관리

### 패키지 추가하기

`requirements.txt` 파일을 수정하여 다운로드할 패키지를 추가/변경할 수 있습니다:

```bash
# requirements.txt
mrx_link==2.4.1
mrx-runway==1.13.1
psycopg2>=2.9.5,<3.0.0

# 추가 패키지 예시
numpy==1.24.0
pandas>=2.0.0
requests
```

### 현재 패키지 목록 확인
```bash
make list-packages
```

## Available Commands

| 명령어 | 설명 |
|--------|------|
| `make help` | 사용 가능한 모든 명령어 표시 |
| `make all` | 전체 프로세스 실행 (Python 설치 + setup + download) |
| `make install-python` | 필요한 모든 Python 버전 설치 (공식 repo) |
| `make check-python` | 설치된 Python 버전 확인 |
| `make install-deps` | 시스템 의존성 설치 |
| `make setup` | 모든 Python 버전에 대한 venv 생성 |
| `make venv VERSION=X` | 특정 Python 버전에 대한 venv 생성 |
| `make download` | 모든 Python 버전에 대해 패키지 다운로드 |
| `make download VERSION=X` | 특정 Python 버전에 대해 패키지 다운로드 |
| `make list-packages` | requirements.txt의 패키지 목록 표시 |
| `make clean` | venv 및 다운로드 파일 모두 삭제 |
| `make clean-venv` | venv만 삭제 |
| `make clean-downloads` | 다운로드 파일만 삭제 |

## Configuration

### Makefile 설정

`Makefile`의 상단에서 다음 설정을 변경할 수 있습니다:

```makefile
PYTHON_VERSIONS := 3.8 3.9 3.10 3.11  # 지원할 Python 버전
VENV_DIR := /tmp/venv_runway            # venv 생성 경로
OUTPUT_ROOT := /root/pip_runway_download # 다운로드 경로
PIP_INDEX_URL := https://pypi.org/simple/ # PyPI 인덱스 URL
```

### 환경 변수 (.env)

`.env.example` 파일을 복사하여 `.env` 파일을 만들고 필요한 설정을 변경할 수 있습니다:

```bash
cp .env.example .env
```

## Output

다운로드된 패키지는 다음 경로에 저장됩니다:
```
/root/pip_runway_download/packages/
```

## 기존 Bash 스크립트

기존의 `pip_download.sh` 스크립트도 여전히 사용 가능합니다:

```bash
chmod +x pip_download.sh
./pip_download.sh
```

## Troubleshooting

### Python 버전이 없는 경우
```bash
# Makefile을 통한 자동 설치 (권장)
make install-python

# 또는 수동 설치
sudo apt-get update
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt-get update
sudo apt-get install python3.X python3.X-venv python3.X-distutils
```

### venv 재생성이 필요한 경우
```bash
make clean-venv
make setup
```

### 다운로드 재시작
```bash
make clean-downloads
make download
```

## 테스트 환경 배포

테스트 서버(192.168.135.72)로 배포하려면:

```bash
# 배포 스크립트 실행
./deploy-to-test.sh

# SSH로 테스트 서버 접속
ssh root@192.168.135.72

# 테스트 서버에서 실행
cd /root/pip_download_script
make all
```

## Notes

- 가상 환경은 기본적으로 `/tmp/venv_runway/`에 생성됩니다
- 각 Python 버전은 독립적인 가상 환경을 사용합니다
- `mrx_link_git`는 `mrx_link`의 의존성으로 자동 다운로드됩니다
- 모든 Python 버전에서 동일한 패키지를 다운로드하지만, 각 버전별 wheel이 다를 수 있습니다
- Python 설치는 deadsnakes PPA(공식 저장소)를 사용합니다
