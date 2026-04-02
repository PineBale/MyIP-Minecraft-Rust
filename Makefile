CARGO ?= cargo
PROFILE ?= release
FEATURES ?= --all-features

CLIPPY_PROFILE ?= dev
TEST_PROFILE ?= dev

CLIPPY_FLAGS = $(FEATURES) --all-targets -- -D warnings
TARPAULIN_FLAGS = --run-types AllTargets --out lcov --out stdout

.PHONY: all build test lint lint-fix fmt fmt-check clean ci help

all: fmt-check lint build

build:
	$(CARGO) build --profile $(PROFILE) $(FEATURES)

test:
	$(CARGO) tarpaulin --profile $(TEST_PROFILE) $(FEATURES) $(TARPAULIN_FLAGS)

lint:
	$(CARGO) clippy --profile $(CLIPPY_PROFILE) $(CLIPPY_FLAGS)

lint-fix:
	$(CARGO) clippy --profile $(CLIPPY_PROFILE) $(FEATURES) --fix --allow-dirty --allow-staged

fmt:
	$(CARGO) fmt

fmt-check:
	$(CARGO) fmt -- --check

clean:
	$(CARGO) clean

ci: fmt-check lint build
