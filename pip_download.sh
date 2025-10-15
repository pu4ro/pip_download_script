#!/bin/bash

# Python 버전 목록
PYTHON_VERSIONS=("3.8" "3.9" "3.10" "3.11" )

# 타깃 패키지 버전
# mrx_link 설치 시 mrx_link_git(현재 2.2.0)은 의존성으로 자동 포함/업데이트 됩니다.
MRX_LINK_VERSION="2.4.1"
MRX_RUNWAY_VERSION="1.13.1"

# 다운로드 대상 패키지 목록 (필요 시 추가)
PACKAGES=(
  "mrx_link==${MRX_LINK_VERSION}"
  "mrx-runway==${MRX_RUNWAY_VERSION}"
)

# 출력 디렉토리 루트 및 조합 버전 디렉토리명
OUTPUT_ROOT="/root/pip_runway_download"
OUTPUT_DIR_NAME="mrx_link_${MRX_LINK_VERSION}__mrx-runway_${MRX_RUNWAY_VERSION}"
OUTPUT_DIR="${OUTPUT_ROOT}/${OUTPUT_DIR_NAME}"

PIP_INDEX_URL="https://pypi.org/simple/"

# virtualenv 작업 디렉토리
VENV_DIR="/tmp/venv_runway"

# PostgreSQL 개발 도구 설치 (psycopg2 빌드용 헤더)
echo "Installing PostgreSQL development tools..."
sudo apt update
sudo apt install -y libpq-dev

# 출력 디렉토리 생성
mkdir -p ${OUTPUT_DIR}

# 각 Python 버전에 대해 virtualenv 생성 및 패키지 다운로드
for PYTHON_VER in "${PYTHON_VERSIONS[@]}"; do
    echo "Processing Python ${PYTHON_VER}..."
    
    # virtualenv 생성
    VENV_PATH="${VENV_DIR}/python${PYTHON_VER}"
    python${PYTHON_VER} -m venv ${VENV_PATH}
    
    # virtualenv 활성화
    source ${VENV_PATH}/bin/activate
    
    # pip 업그레이드
    pip install --upgrade pip
    
    # 패키지 다운로드 (의존성 문자열을 따옴표로 감쌈)
    pip download "${PACKAGES[@]}" "psycopg2<3.0.0,>=2.9.5" \
        -d "${OUTPUT_DIR}" \
        --index-url "${PIP_INDEX_URL}"
    
    # virtualenv 비활성화
    deactivate
done

echo "All packages have been downloaded to ${OUTPUT_DIR}."
