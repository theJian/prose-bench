# prose-bench

Small, working projects for evaluating `as-prose`. Each project has multiple
runtime source units. Source comments and Python docstrings have been removed;
license and attribution notices are retained separately.

| Project | Languages | Runtime source units |
| --- | --- | --- |
| [TCP socket](projects/tcp-socket/) | Java | 3 classes across 2 packages |
| [Password generator](projects/password-generator/) | Python | 2 modules |
| [Make text uppercase](projects/make-text-uppercase/) | JavaScript, HTML, CSS | 2 JavaScript files, plus HTML and CSS |
| [Huffman compressor](projects/huffman-compressor/) | C++, Python | 3 cooperating programs |

The stripped fixtures contain 380 source lines in total, including blank lines
and the HTML/CSS files. Dependency manifests, licenses, and this repo's metadata
are excluded from that count. Original source paths and pinned revisions are in
[SOURCES.json](SOURCES.json); author credits are in [NOTICE](NOTICE).

## Run the projects

Commands below start from the repository root. Build products and installed
dependencies are ignored by Git.

### TCP socket

Requires a JDK. In one terminal:

```sh
cd projects/tcp-socket
mkdir -p build
javac -d build src/com/saif/tcp/client/Main.java src/com/saif/tcp/server/*.java
java -cp build com.saif.tcp.server.Main
```

In another terminal:

```sh
cd projects/tcp-socket
java -cp build com.saif.tcp.client.Main
```

The upstream programs use port 5000. Enter `exit` to close the client and stop
the server with Ctrl+C.

### Password generator

Requires Python 3 with Tkinter and a desktop display.

```sh
cd projects/password-generator
python3 main.py
```

### Make text uppercase

Requires Node.js and npm.

```sh
cd projects/make-text-uppercase
npm install
npm start
```

Open <http://localhost:3000>. The upstream page loads Bootstrap styles from a CDN.

### Huffman compressor

Requires a C++17 compiler and Python 3.

```sh
cd projects/huffman-compressor
c++ -std=c++17 huffman.cpp -o huffman
./huffman
python3 compressor.py
python3 decompressor.py
```

Run the programs in this order and supply the input, codebook, and output
filenames at their prompts.

## License

The copied fixtures use the upstream [GNU GPL version 3](LICENSE). Their original
authors and local modifications are listed in [NOTICE](NOTICE).
