SOURCE_DIR ?= ./dev_build
OUTPUT_DIR ?= ./artifacts

build:
	docker build .

test:
	docker run --rm -it $(shell docker build -q .)

start:
	pwsh ./archive-artifacts.ps1 -SourceDir "$(SOURCE_DIR)" -OutputDir "$(OUTPUT_DIR)"
