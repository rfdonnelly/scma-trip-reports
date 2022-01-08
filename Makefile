VERSION=$(shell git describe --tags)

MAKEFLAGS=-j2

adocs:=$(wildcard */*.adoc)
pdfs:=$(addsuffix .pdf, $(basename $(adocs)))
htmls:=$(addsuffix .html, $(basename $(adocs)))

.PHONY: all
all: pdfs htmls

.PHONY: pdfs
pdfs: $(pdfs)

.PHONY: htmls
htmls: $(htmls)

%.pdf: %.adoc pdf-theme.yml
	docker run -v $(PWD):/documents asciidoctor/docker-asciidoctor asciidoctor-pdf \
	    -a pdf-theme=./pdf-theme.yml \
	    $<

%.html: %.adoc
	docker run -v $(PWD):/documents asciidoctor/docker-asciidoctor asciidoctor $<

.PHONY: clean
clean:
	rm -f *.pdf
	rm -f *.html

.PHONY: publish
publish:
	rm -rf gh-pages
	git clone --branch gh-pages $(shell git remote get-url origin) gh-pages
	mkdir -p gh-pages/$(VERSION)/images
	cp $(HTML) gh-pages/$(VERSION)/index.html
	cp -R images/*.png gh-pages/$(VERSION)/images
	git -C gh-pages add $(VERSION)
	git -C gh-pages commit -m "Add $(VERSION)"
	echo "Remove commit in gh-pages directory and push if good."
