SOURCE_DIR ?= ./zxc
OUTPUT_DIR ?= ./artifacts

build:
	docker build .

run-tests:
	docker run --rm -it $(shell docker build .)

start:
	pwsh ./archive-artifacts.ps1 -SourceDir "$(SOURCE_DIR)" -OutputDir "$(OUTPUT_DIR)"
