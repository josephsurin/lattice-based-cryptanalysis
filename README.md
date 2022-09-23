# Lattice-based Cryptanalysis Toolkit

This repository implements a toolkit for cryptanalysis using lattice reduction built for experimenting and learning. Check out the accompanying [tutorial](./tutorial.pdf) for some background.


## Basic usage

The toolkit can be used with both Python and Sage. To get started, clone the repository:

```
git clone https://github.com/josephsurin/lattice-based-cryptanalysis.git
```

and add the repository's location to the `PYTHONPATH` environment variable:

```sh
export PYTHONPATH="/path/to/lattice-based-cryptanalysis:$PYTHONPATH"
```

The `lbc_toolkit` module is then available to import functions from:

```py
from lbc_toolkit import hnp
```

As an alternative to setting `PYTHONPATH`, modifying `sys.path` works too:

```py
import sys
sys.path.append('path/to/lattice-based-cryptanalysis')

from lbc_toolkit import hnp
```


## Examples

The [`examples/`](./examples) directory contains usage examples of almost all of the available functions.


## Documentation

Some documentation for the available functions can be found at [`docs/`](./docs).
