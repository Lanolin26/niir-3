OUTPUT_DIR ?= output
OUTPUT_FILE ?= report

MAIN_BUILD_FILE=main

BUILD=xelatex
BUILD_OPT=-synctex=1 -interaction=nonstopmode -file-line-error -recorder -output-directory="$(OUTPUT_DIR)" -jobname=$(OUTPUT_FILE)
CLEAN_FILES=*.aux *.fdb_latexmk *.fls *.out *.blg *.bbl *.ps *.synctex.gz *.toc *.nav *.snm *.xdv *.lot *lof

DOCKER_IMAGE_NAME ?= lanolin25/docker-latex
DOCKER_IMAGE_VERSION ?= v1.6
DOCKER_IMAGE ?= $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION)

all: clear build clean

echo:
	@echo $(OUTPUT_DIR)
	@echo $(OUTPUT_FILE)
	@echo $(MAIN_BUILD_FILE)
	@echo $(BUILD_OPT)
	@echo $(DOCKER_IMAGE)
	@echo $(CLEAN_FILES)

clean:
	@cd ./$(OUTPUT_DIR)
	@rm -f $(CLEAN_FILES)
	@cd ../

clear:
	@rm -rf $(OUTPUT_DIR)

create_output_dir:
	@mkdir -p $(OUTPUT_DIR)

build: create_output_dir *.tex
	$(BUILD) $(BUILD_OPT) $(MAIN_BUILD_FILE).tex
	bibtex $(OUTPUT_DIR)/$(OUTPUT_FILE).aux
	$(BUILD) $(BUILD_OPT) $(MAIN_BUILD_FILE).tex
	$(BUILD) $(BUILD_OPT) $(MAIN_BUILD_FILE).tex

docker-create:
	docker build -t $(DOCKER_IMAGE) .

docker-build:
	docker run --rm -ti -v .:/build:Z $(DOCKER_IMAGE) sh -c "make build"