#!/bin/bash

# 테스트 환경 배포 스크립트
# 테스트 서버: 192.168.135.72

TEST_SERVER="192.168.135.72"
TEST_USER="root"
REMOTE_DIR="/root/pip_download_script"

echo "=== Deploying to Test Environment ==="
echo "Server: ${TEST_SERVER}"
echo "User: ${TEST_USER}"
echo "Remote Directory: ${REMOTE_DIR}"
echo ""

# 현재 디렉토리의 모든 파일을 테스트 서버로 복사
echo "Uploading files to test server..."
scp -r ./* ${TEST_USER}@${TEST_SERVER}:${REMOTE_DIR}/

if [ $? -eq 0 ]; then
    echo "Files uploaded successfully!"
    echo ""
    echo "To run on the test server, SSH and execute:"
    echo "  ssh ${TEST_USER}@${TEST_SERVER}"
    echo "  cd ${REMOTE_DIR}"
    echo "  make all"
else
    echo "Failed to upload files."
    exit 1
fi
