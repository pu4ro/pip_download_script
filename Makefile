.PHONY: help setup venv clean clean-venv clean-downloads download install-deps check-python all list-packages

# Python 버전 설정
PYTHON_VERSIONS := 3.8 3.9 3.10 3.11
DEFAULT_PYTHON := python3

# 디렉토리 설정
VENV_DIR := /tmp/venv_runway
OUTPUT_ROOT := /root/pip_runway_download
OUTPUT_DIR := $(OUTPUT_ROOT)/packages

# PyPI 설정
PIP_INDEX_URL := https://pypi.org/simple/

# Requirements 파일
REQUIREMENTS_FILE := requirements.txt

# 색상 출력
COLOR_RESET := \033[0m
COLOR_INFO := \033[36m
COLOR_SUCCESS := \033[32m
COLOR_WARNING := \033[33m
COLOR_ERROR := \033[31m

help:
	@echo "$(COLOR_INFO)Available commands:$(COLOR_RESET)"
	@echo "  make setup              - 모든 Python 버전에 대한 venv 생성 및 설정"
	@echo "  make venv VERSION=X     - 특정 Python 버전(X)에 대한 venv 생성"
	@echo "  make install-deps       - 시스템 의존성 설치 (PostgreSQL dev tools)"
	@echo "  make download           - 모든 Python 버전에 대해 패키지 다운로드"
	@echo "  make download VERSION=X - 특정 Python 버전에 대해서만 다운로드"
	@echo "  make list-packages      - requirements.txt의 패키지 목록 표시"
	@echo "  make clean              - venv 및 다운로드 파일 모두 정리"
	@echo "  make clean-venv         - venv만 정리"
	@echo "  make clean-downloads    - 다운로드 파일만 정리"
	@echo "  make check-python       - 설치된 Python 버전 확인"
	@echo "  make all                - 전체 프로세스 실행 (설정 + 다운로드)"
	@echo ""
	@echo "$(COLOR_INFO)지원 Python 버전:$(COLOR_RESET) $(PYTHON_VERSIONS)"
	@echo "$(COLOR_INFO)패키지 관리:$(COLOR_RESET) $(REQUIREMENTS_FILE)"
	@echo ""
	@echo "$(COLOR_WARNING)추가 패키지 설치 방법:$(COLOR_RESET)"
	@echo "  requirements.txt 파일을 수정하여 패키지를 추가하세요"

check-python:
	@echo "$(COLOR_INFO)Checking available Python versions...$(COLOR_RESET)"
	@for ver in $(PYTHON_VERSIONS); do \
		if command -v python$$ver >/dev/null 2>&1; then \
			echo "$(COLOR_SUCCESS)✓ python$$ver: $$(python$$ver --version)$(COLOR_RESET)"; \
		else \
			echo "$(COLOR_WARNING)✗ python$$ver: Not found$(COLOR_RESET)"; \
		fi; \
	done

list-packages:
	@echo "$(COLOR_INFO)Packages in $(REQUIREMENTS_FILE):$(COLOR_RESET)"
	@if [ -f "$(REQUIREMENTS_FILE)" ]; then \
		grep -v '^#' $(REQUIREMENTS_FILE) | grep -v '^$$' | while read line; do \
			echo "  - $$line"; \
		done; \
	else \
		echo "$(COLOR_ERROR)$(REQUIREMENTS_FILE) not found$(COLOR_RESET)"; \
	fi

install-deps:
	@echo "$(COLOR_INFO)Installing system dependencies...$(COLOR_RESET)"
	@if command -v apt-get >/dev/null 2>&1; then \
		sudo apt-get update && \
		sudo apt-get install -y libpq-dev; \
		echo "$(COLOR_SUCCESS)System dependencies installed$(COLOR_RESET)"; \
	else \
		echo "$(COLOR_WARNING)apt-get not found. Please install libpq-dev manually.$(COLOR_RESET)"; \
	fi

venv:
ifdef VERSION
	@echo "$(COLOR_INFO)Creating venv for Python $(VERSION)...$(COLOR_RESET)"
	@if ! command -v python$(VERSION) >/dev/null 2>&1; then \
		echo "$(COLOR_ERROR)Error: python$(VERSION) not found$(COLOR_RESET)"; \
		exit 1; \
	fi
	@mkdir -p $(VENV_DIR)
	@VENV_PATH="$(VENV_DIR)/python$(VERSION)"; \
	if [ -d "$$VENV_PATH" ]; then \
		echo "$(COLOR_WARNING)Virtualenv already exists at $$VENV_PATH$(COLOR_RESET)"; \
	else \
		python$(VERSION) -m venv "$$VENV_PATH" && \
		echo "$(COLOR_SUCCESS)Created venv at $$VENV_PATH$(COLOR_RESET)"; \
		. "$$VENV_PATH/bin/activate" && \
		python -m pip install --upgrade pip --quiet && \
		echo "$(COLOR_SUCCESS)Upgraded pip for Python $(VERSION)$(COLOR_RESET)" && \
		deactivate; \
	fi
else
	@echo "$(COLOR_ERROR)Error: VERSION not specified. Usage: make venv VERSION=3.9$(COLOR_RESET)"
	@exit 1
endif

setup: install-deps
	@echo "$(COLOR_INFO)Setting up virtualenvs for all Python versions...$(COLOR_RESET)"
	@mkdir -p $(VENV_DIR)
	@for ver in $(PYTHON_VERSIONS); do \
		echo "$(COLOR_INFO)Processing Python $$ver...$(COLOR_RESET)"; \
		if ! command -v python$$ver >/dev/null 2>&1; then \
			echo "$(COLOR_WARNING)python$$ver not found. Skipping.$(COLOR_RESET)"; \
			continue; \
		fi; \
		VENV_PATH="$(VENV_DIR)/python$$ver"; \
		if [ -d "$$VENV_PATH" ] && [ -f "$$VENV_PATH/bin/activate" ]; then \
			echo "$(COLOR_WARNING)Virtualenv already exists at $$VENV_PATH$(COLOR_RESET)"; \
		else \
			echo "$(COLOR_INFO)Creating virtualenv at $$VENV_PATH...$(COLOR_RESET)"; \
			python$$ver -m venv "$$VENV_PATH" && \
			echo "$(COLOR_SUCCESS)Created venv for Python $$ver$(COLOR_RESET)"; \
		fi; \
		if [ -f "$$VENV_PATH/bin/activate" ]; then \
			. "$$VENV_PATH/bin/activate" && \
			python -m pip install --upgrade pip --quiet && \
			echo "$(COLOR_SUCCESS)Upgraded pip for Python $$ver$(COLOR_RESET)" && \
			deactivate; \
		fi; \
	done
	@echo "$(COLOR_SUCCESS)Setup complete!$(COLOR_RESET)"

download:
ifdef VERSION
	@echo "$(COLOR_INFO)Downloading packages for Python $(VERSION)...$(COLOR_RESET)"
	@if [ ! -f "$(REQUIREMENTS_FILE)" ]; then \
		echo "$(COLOR_ERROR)Error: $(REQUIREMENTS_FILE) not found$(COLOR_RESET)"; \
		exit 1; \
	fi
	@mkdir -p $(OUTPUT_DIR)
	@VENV_PATH="$(VENV_DIR)/python$(VERSION)"; \
	if [ ! -f "$$VENV_PATH/bin/activate" ]; then \
		echo "$(COLOR_WARNING)Virtualenv not found for Python $(VERSION). Run 'make setup' first.$(COLOR_RESET)"; \
		exit 1; \
	fi; \
	. "$$VENV_PATH/bin/activate" && \
	python -m pip download -r $(REQUIREMENTS_FILE) \
		-d "$(OUTPUT_DIR)" \
		--index-url "$(PIP_INDEX_URL)" && \
	echo "$(COLOR_SUCCESS)Downloaded packages for Python $(VERSION)$(COLOR_RESET)" && \
	deactivate
else
	@echo "$(COLOR_INFO)Downloading packages for all Python versions...$(COLOR_RESET)"
	@if [ ! -f "$(REQUIREMENTS_FILE)" ]; then \
		echo "$(COLOR_ERROR)Error: $(REQUIREMENTS_FILE) not found$(COLOR_RESET)"; \
		exit 1; \
	fi
	@mkdir -p $(OUTPUT_DIR)
	@for ver in $(PYTHON_VERSIONS); do \
		echo "$(COLOR_INFO)Processing Python $$ver...$(COLOR_RESET)"; \
		VENV_PATH="$(VENV_DIR)/python$$ver"; \
		if [ ! -f "$$VENV_PATH/bin/activate" ]; then \
			echo "$(COLOR_WARNING)Virtualenv not found for Python $$ver. Run 'make setup' first.$(COLOR_RESET)"; \
			continue; \
		fi; \
		. "$$VENV_PATH/bin/activate" && \
		python -m pip download -r $(REQUIREMENTS_FILE) \
			-d "$(OUTPUT_DIR)" \
			--index-url "$(PIP_INDEX_URL)" && \
		echo "$(COLOR_SUCCESS)Downloaded packages for Python $$ver$(COLOR_RESET)" && \
		deactivate; \
	done
	@echo "$(COLOR_SUCCESS)All packages downloaded to: $(OUTPUT_DIR)$(COLOR_RESET)"
endif

clean-venv:
	@echo "$(COLOR_INFO)Cleaning virtualenvs...$(COLOR_RESET)"
	@rm -rf $(VENV_DIR)
	@echo "$(COLOR_SUCCESS)Virtualenvs cleaned$(COLOR_RESET)"

clean-downloads:
	@echo "$(COLOR_INFO)Cleaning downloaded packages...$(COLOR_RESET)"
	@rm -rf $(OUTPUT_DIR)
	@echo "$(COLOR_SUCCESS)Downloaded packages cleaned$(COLOR_RESET)"

clean: clean-venv clean-downloads
	@echo "$(COLOR_SUCCESS)All cleaned!$(COLOR_RESET)"

all: setup download
	@echo "$(COLOR_SUCCESS)All tasks completed!$(COLOR_RESET)"
