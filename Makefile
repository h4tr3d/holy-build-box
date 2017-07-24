VERSION = 2.0.0
MAJOR_VERSION = 2
HUBUSER ?= alexd
PROJECT ?= dyn-hbb
IMGNAME = $(HUBUSER)/$(PROJECT)

.PHONY: all 32 64 test tags tag-32 tag-64 release rel-32 rel-64

all: 64

64:
	docker build --rm -t $(IMGNAME)-64:$(VERSION) -f Dockerfile-64+gcc7+dyn --pull .

tags: tag-64

tag-64:
	docker tag $(IMGNAME)-64:$(VERSION) $(IMGNAME)-64:$(MAJOR_VERSION)
	docker tag $(IMGNAME)-64:$(VERSION) $(IMGNAME)-64:latest

rel-64: tag-64
	docker push $(IMGNAME)-64

release: rel-64
	@echo "*** Don't forget to create a tag:"
	@echo ""
	@echo "   git tag rel-$(VERSION) && git push origin rel-$(VERSION)"
