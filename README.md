# Tangle code from Markdown files

This is a PanDoc filter for extracting source code from Markdown files that were written with *literate programming* in mind, a process known as *tangling*.

This Lua script will filter the Pandoc AST for `CodeBlock` entries and generate a plain text `bash` script that can be used to create the files defined in the input file.

## Syntax

This `pandoc` filter relies on the use of *fenced code attributes*. To tangle a code block to a file:

~~~markdown
``` {.bash file=src/count.sh}
...
```
~~~

Composing a file using multiple code blocks is done through *noweb* syntax. You can reference a named code block in another code block by putting something like `<<named-code-block>>` on a single line. This reference may be indented. Such an indentation is then prefixed to each line in the final result.

A named code block is should have an identifier given:

~~~markdown
``` {.python #named-code-block}
...
```
~~~

## Running

There is a `Makefile` that runs `pandoc` for you, and pipes the output through `bash`.

```sh
make
```

You can run the tests in this `README` by running:

```sh
make test
```

### Using this in your project

Copy the Lua files in the `scripts` directory to your own project and use and adapt the `Makefile` to absorb them into your workflow. I may in the future create a more user-friendly script.

## Complete Tangle Test

The following code snippets are the testing suite for this Markdown tangler. To see their source look at this `README.md` in raw text.

### Single block to single file

The simplest case is a single code section with a single target file:

``` {.bash file=test/count.sh}
for i in $(seq 10)
do
    echo "${i}"
done
```

### Composing a file using noweb reference

``` {.python file=test/factorial.py}
<<factorial-function>>

for i in range(10):
    print(f"{i:2}! = {factorial(i):6}")
```

So that we can define the factorial function later on in the document.

``` {.python #factorial-function}
from functools import reduce
from operator import mul

def factorial(n):
    return reduce(mul, range(1, n + 1), 1)
```

## TODO

- Include syntax to append to existing named code blocks.
- Work with multiple input files.
- Update tangled files only where content changed.
- Identify output of generated scripts (raw markdown, figures, etc.) and include them back into the document when generating the report.

## Copying/Contributing

This project is distributed under the Apache 2.0 license. Contributions are welcome and should fall under these same licensing conditions.