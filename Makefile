GOLANGCI_LINT_CACHE?=/tmp/praktikum-golangci-lint-cache

.PHONY: golangci-lint-run
golangci-lint-run: _golangci-lint-rm-unformatted-report

.PHONY: _golangci-lint-reports-mkdir
_golangci-lint-reports-mkdir:
	mkdir -p ./golangci-lint

.PHONY: _golangci-lint-run
_golangci-lint-run: _golangci-lint-reports-mkdir
	-docker run --rm \
    -v $(shell pwd):/app \
    -v $(GOLANGCI_LINT_CACHE):/root/.cache \
    -w /app \
    golangci/golangci-lint:v1.57.2 \
        golangci-lint run \
            -c .golangci.yml \
	> ./golangci-lint/report-unformatted.json

.PHONY: _golangci-lint-format-report
_golangci-lint-format-report: _golangci-lint-run
	cat ./golangci-lint/report-unformatted.json | jq > ./golangci-lint/report.json

.PHONY: _golangci-lint-rm-unformatted-report
_golangci-lint-rm-unformatted-report: _golangci-lint-format-report
	rm ./golangci-lint/report-unformatted.json

.PHONY: golangci-lint-clean
golangci-lint-clean:
	sudo rm -rf ./golangci-lint

.PHONY: dev
dev:
	docker-compose down
	docker build -t vpbuyanov/short-url:latest .
	docker-compose up -d

.PHONY: test
test:
	sudo shortenertestbeta-darwin-arm64 -test.v -test.run=^TestIteration$(iter)$$ \
                       -binary-path=cmd/shortener/shortener \
                       -server-port=8080

.PHONY: vet
vet:
	go vet -vettool=$(which ./statictest-darwin-arm64) ./...

.PHONY: build
build:
	rm ./cmd/shortener/shortener
	go build -o ./cmd/shortener/shortener cmd/shortener/main.go