OUTPUT_DIR ?= output
OUTPUT_FILE ?= report
ARTIFACT_DIR ?= artifact

MAIN_BUILD_FILE=main

BUILD=xelatex
BUILD_OPT=-synctex=1 -interaction=nonstopmode -file-line-error -recorder -output-directory="$(OUTPUT_DIR)" -jobname="$(OUTPUT_FILE)"
CLEAN_FILES=*.aux *.fdb_latexmk *.fls *.log *.out *.blg *.bbl *.ps *.synctex.gz *.toc *.nav *.snm *.xdv *.lot *.lof

DOCKER_IMAGE ?= lanolin25/docker-latex
DOCKER_IMAGE_VERSION ?= v1.6
DOCKER_IMAGE_ALL ?= $(DOCKER_IMAGE):$(DOCKER_IMAGE_VERSION)

TIMESTAMP=$(shell date +"%Y%m%d%H%M%S")

.PHONY: clean clear docker-create

all: clear build clean

clean:
	@cd ./$(OUTPUT_DIR)
	@rm -f $(CLEAN_FILES)
	@cd ../

clear:
	@rm -rf $(OUTPUT_DIR)
	@rm -rf $(ARTIFACT_DIR)

create_output_dir:
	@mkdir -p $(OUTPUT_DIR)

create_artifacts:
	@mkdir -p $(ARTIFACT_DIR)

build: create_output_dir *.tex
	@echo "Build stage 1"
	$(BUILD) $(BUILD_OPT) $(MAIN_BUILD_FILE).tex
	@mv $(OUTPUT_DIR)/$(OUTPUT_FILE).log $(OUTPUT_DIR)/$(OUTPUT_FILE)_1.log
	
	@echo "Build stage 2"
	bibtex $(OUTPUT_DIR)/$(OUTPUT_FILE).aux
	
	@echo "Build stage 3"
	$(BUILD) $(BUILD_OPT) $(MAIN_BUILD_FILE).tex
	@mv $(OUTPUT_DIR)/$(OUTPUT_FILE).log $(OUTPUT_DIR)/$(OUTPUT_FILE)_2.log
	
	@echo "Build stage 4"
	$(BUILD) $(BUILD_OPT) $(MAIN_BUILD_FILE).tex
	@mv $(OUTPUT_DIR)/$(OUTPUT_FILE).log $(OUTPUT_DIR)/$(OUTPUT_FILE)_3.log

artifacts: build create_artifacts
	@cp -f $(OUTPUT_DIR)/$(OUTPUT_FILE).pdf $(ARTIFACT_DIR)/$(OUTPUT_FILE).pdf
	@cat $(OUTPUT_DIR)/$(OUTPUT_FILE)_*.log > $(ARTIFACT_DIR)/$(OUTPUT_FILE).log

docker-create:
	docker build -t $(DOCKER_IMAGE_NAME) .

docker-build:
	docker run --rm -ti -v .:/build:Z $(DOCKER_IMAGE_ALL) sh -c "make artifacts"