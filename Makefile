SOURCE_DIR ?= ./dev_build
OUTPUT_DIR ?= ./artifacts

build:
	docker build . -t archivator-tests

test:
	docker run --rm archivator-tests

start:
	pwsh ./archive-artifacts.ps1 -SourceDir "$(SOURCE_DIR)" -OutputDir "$(OUTPUT_DIR)"
