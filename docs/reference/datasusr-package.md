# datasusr: Fast Access to Brazilian Public Health Data from 'DATASUS'

Provides fast, in-memory reading of DATASUS DBC files using native 'C'
code, along with a catalog of public health data sources, 'FTP' file
discovery, caching downloads, and a high-level 'datasus_fetch()'
function that lists, downloads, and reads files in a single call.
Bundles the 'blast' decompressor from 'zlib' contrib/blast to decode
'PKWare DCL'-compressed 'DBC' files and parses 'DBF' records directly
for efficient import into tibbles.

## See also

Useful links:

- <https://strategicprojects.github.io/datasusr/>

- <https://github.com/StrategicProjects/datasusr>

- Report bugs at <https://github.com/StrategicProjects/datasusr/issues>

## Author

**Maintainer**: Andre Leite <leite@castlab.org>

Authors:

- Marcos Wasilew <marcos.wasilew@gmail.com>

- Hugo Vasconcelos <hugo.vasconcelos@ufpe.br>

- Carlos Amorin <carlos.agaf@ufpe.br>

- Diogo Bezerra <diogo.bezerra@ufpe.br>

Other contributors:

- Mark Adler (Author of bundled blast.c and blast.h from zlib
  contrib/blast) \[contributor, copyright holder\]
