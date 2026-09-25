# datasusr: Fast Access to Brazilian Public Health Data from 'DATASUS'

Provides fast, in-memory reading of 'DATASUS' 'DBC' files using native
'C' code, along with a catalog of public health data sources, 'FTP' file
discovery, caching downloads, and a high-level datasus_fetch() function
that lists, downloads, and reads files in a single call. Bundles the
'blast' decompressor from 'zlib' contrib/blast to decode 'PKWare DCL'
compressed 'DBC' files and parses 'DBF' records directly for efficient
import into tibbles. See the 'DATASUS' file transfer site
<https://datasus.saude.gov.br> and Adler (2003)
<https://github.com/madler/zlib/tree/master/contrib/blast> for details
on the underlying data and compression format.

## See also

Useful links:

- <https://strategicprojects.github.io/datasusr/>

- <https://github.com/StrategicProjects/datasusr>

- Report bugs at <https://github.com/StrategicProjects/datasusr/issues>

## Author

**Maintainer**: Andre Leite <leite@castlab.org>
([ORCID](https://orcid.org/0000-0002-4718-9766))

Authors:

- Andre Leite <leite@castlab.org>
  ([ORCID](https://orcid.org/0000-0002-4718-9766))

- Marcos Wasiliew <marcos.wasilew@gmail.com>
  ([ORCID](https://orcid.org/0009-0004-4694-3159))

- Hugo Vasconcelos <hugo.vasconcelos@ufpe.br>
  ([ORCID](https://orcid.org/0000-0001-6249-0920))

- Carlos Amorim <carlos.agaf@ufpe.br>
  ([ORCID](https://orcid.org/0000-0001-6315-8305))

- Diogo Bezerra <diogo.bezerra@ufpe.br>
  ([ORCID](https://orcid.org/0000-0002-1216-8674))

Other contributors:

- Mark Adler (Author of bundled blast.c and blast.h from zlib
  contrib/blast) \[contributor, copyright holder\]
