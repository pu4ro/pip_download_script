#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# .env 파일 로드
if [ -f "${SCRIPT_DIR}/.env" ]; then
    # shellcheck disable=SC1091
    source "${SCRIPT_DIR}/.env"
else
    echo ".env file not found. Copy .env.example to .env and configure it."
    exit 1
fi

# .env 값을 배열로 변환
read -ra PYTHON_VERSIONS <<< "${PYTHON_VERSIONS}"

# requirements.txt 경로
REQUIREMENTS_FILE="${SCRIPT_DIR}/requirements.txt"

# 출력 디렉토리
OUTPUT_DIR="${OUTPUT_ROOT}/$(date +%Y%m%d)"

# PostgreSQL 개발 도구 설치 (psycopg2 빌드용 헤더)
echo "Installing PostgreSQL development tools..."
sudo apt update
sudo apt install -y libpq-dev

# 출력 디렉토리 생성
mkdir -p ${OUTPUT_DIR}
mkdir -p ${VENV_DIR}

# 각 Python 버전에 대해 virtualenv 생성 및 패키지 다운로드
for PYTHON_VER in "${PYTHON_VERSIONS[@]}"; do
    echo "Processing Python ${PYTHON_VER}..."
    
    # 해당 Python 인터프리터 존재 여부 확인
    if ! command -v "python${PYTHON_VER}" >/dev/null 2>&1; then
        echo "python${PYTHON_VER} not found. Skipping this version."
        continue
    fi
    
    # virtualenv 생성
    VENV_PATH="${VENV_DIR}/python${PYTHON_VER}"
    if [ -d "${VENV_PATH}" ] && [ -f "${VENV_PATH}/bin/activate" ]; then
        echo "Existing virtualenv detected at ${VENV_PATH}. Skipping creation."
    else
        echo "Creating virtualenv at ${VENV_PATH}..."
        python${PYTHON_VER} -m venv "${VENV_PATH}"
    fi
    
    # virtualenv 활성화 (존재 확인 후)
    if [ -f "${VENV_PATH}/bin/activate" ]; then
        # shellcheck disable=SC1091
        source "${VENV_PATH}/bin/activate"
    else
        echo "Activate script not found for ${PYTHON_VER}. Skipping."
        continue
    fi
    
    # pip 업그레이드 (해당 venv의 python 사용 보장)
    python -m pip install --upgrade pip
    
    # venv 기본 패키지 다운로드 (pip, setuptools, wheel)
    python -m pip download \
        pip setuptools wheel \
        -d "${OUTPUT_DIR}" \
        --index-url "${PIP_INDEX_URL}"

    # requirements.txt 기반 패키지 다운로드
    python -m pip download \
        -r "${REQUIREMENTS_FILE}" \
        -d "${OUTPUT_DIR}" \
        --index-url "${PIP_INDEX_URL}"
    
    # virtualenv 비활성화
    if type deactivate >/dev/null 2>&1; then
        deactivate
    fi
done

echo "All packages have been downloaded to ${OUTPUT_DIR}."
