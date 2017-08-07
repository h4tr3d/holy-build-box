VERSION = 2.1.0
MAJOR_VERSION = 2
HUBUSER ?= alexd
PROJECT ?= dyn-hbb
IMGNAME = $(HUBUSER)/$(PROJECT)

.PHONY: all 64 test tags tag-64 release rel-64

all: 64

64:
	docker build --rm -t $(IMGNAME):$(VERSION) -f Dockerfile-64+gcc7+dyn --pull .

tags: tag-64

tag-64:
	docker tag $(IMGNAME):$(VERSION) $(IMGNAME):$(MAJOR_VERSION)
	docker tag $(IMGNAME):$(VERSION) $(IMGNAME):latest

rel-64: tag-64
	docker push $(IMGNAME)

release: rel-64
	@echo "*** Don't forget to create a tag:"
	@echo ""
	@echo "   git tag rel-$(VERSION) && git push origin rel-$(VERSION)"
