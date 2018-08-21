input_files = README.md
format = markdown+fenced_code_attributes
pd_call = pandoc -f $(format) --lua-filter "scripts/$(1).lua" -t plain
pd_list = $(call pd_call,list)
pd_tangle = $(call pd_call,tangle)
targets = $(shell $(pd_list) README.md)

test_runner.py = python3
test_runner.sh = bash

run_tests = $(foreach x,$(targets),\
	echo "Running $(x) ...";\
	$(test_runner$(suffix $(x))) $(x);)

all: $(targets)

$(targets): $(input_files)
	$(pd_tangle) $< | bash

.PHONY: clean test
.SILENT: clean test

clean:
	rm -vf $$($(pd_list) README.md)

test: all
	$(run_tests)