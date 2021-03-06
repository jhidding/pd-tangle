# Tangle code from Markdown files

This is a PanDoc filter for extracting source code from Markdown files that were written with *literate programming* in mind, a process known as *tangling*.

This Lua script will filter the Pandoc AST for `CodeBlock` entries and generate a plain text `bash` script that can be used to create the files defined in the input file.

The resulting file tree is first generated in a temporary directory, after which this temporary directory is syncronized with the project directory. In the case of compiled languages this prevents you from having to recompile everything.

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

## TODO

- Work with multiple input files.
- Identify output of generated scripts (raw markdown, figures, etc.) and include them back into the document when generating the report.

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

### Composing should preserve indentation

We'll define the Ackermann function

``` {.python file=test/ackermann.py}
def ackermann(m, n):
    <<ackermann-bounds>>
    <<ackermann-body>>

<<ackermann-test>>
```

$$\begin{cases}
n+1 & {\rm if}~ m = 0 \\
A(m-1, 1) & {\rm if }~ m > 0 ~{\rm and}~ n = 0 \\
A(m-1, A(m, n-1)) & {\rm if}~ m > 0 ~{\rm and }~ n > 0.
\end{cases}$$

Then implement the body of the function

``` {.python #ackermann-body}
if m == 0:
    return n + 1
elif n == 0:
    return ackermann(m - 1, 1)
else:
    return ackermann(m - 1, ackermann(m, n - 1))
```

The function is not defined for values of $n < 0$ or $m <0$.

``` {.python #ackermann-bounds}
if m < 0 or n < 0:
    raise ValueError("`n` and `m` should be > 0")
```

Let's test our Ackermann function

``` {.python #ackermann-test}
print("A(3, 5) = ", ackermann(3, 5))
```

### Repeated named entries are concatenated

We will compute the first hundred primes using the ancient technique of Eratosthenes' sieve.

``` {.python file=test/primes.py}
<<primes-imports>>

def primes(limit):
    <<primes-definition>>

<<primes-test>>
```

For this we will use NumPy.

``` {.python #primes-imports}
import numpy
```

The algorithm keeps a ledger of all numbers that have been identified as primes.

``` {.python #primes-definition}
is_prime = numpy.ones(limit + 1, dtype=numpy.bool)
```

If we encounter a number that is prime, all multiples of that number are not primes.

``` {.python #primes-definition append=true}
for n in range(2, int(limit**(1/2) + 1.5)):
    if is_prime[n]:
        is_prime[n*n::n] = 0
```

As a last step we convert the boolean array to an array of numbers.

``` {.python #primes-definition append=true}
return numpy.nonzero(is_prime)[0][2:]
```

Let's try it!

``` {.python #primes-test}
print("All primes < 100: ", primes(100))
```

## Copying/Contributing

This project is distributed under the Apache 2.0 license. Contributions are welcome and should fall under these same licensing conditions.
