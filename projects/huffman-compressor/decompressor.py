"""
Decode the text bit stream written by compressor.py. Run this script with
the compressed path, the same huffman.cpp codebook used for encoding, and
the destination path. The prompts run at module load and pass those paths to
decompress. The output contains the symbols selected and uppercased by the
encoder. Use a codebook generated from at least two distinct symbols so
every occurrence has a nonempty bit string.
"""

def decompress(ifile, codes,ofile):
    """
    Read the first line of ifile and write a symbol to the output text for
    each matching prefix from codes. Any unmatched suffix is discarded.
    """
    symbol_codes = {}
    with open(codes, 'r') as f:
        for line in f:
            # Split at the last space so a space symbol survives parsing.
            last_space_index = line.rfind(' ')
            if last_space_index != -1:
                symbol = line[:last_space_index]
                code = line[last_space_index + 1:].strip()
                symbol_codes[code] = symbol
    with open(ifile, 'r') as f:
        compressed = f.readline()
    decompressed = ''
    current = ''
    for bit in compressed:
        current += bit
        if current in symbol_codes.keys():
            decompressed += symbol_codes[current]
            current = ''
    with open(ofile, 'w') as f:
        f.write(decompressed)

ifile = input("Enter your input (compressed) filename: ")
codes = input("Enter the filename where you have saved your codes: ")
ofile = input("Enter the filename where you want your decompressed document saved: ")
decompress(ifile, codes,ofile)
print("Decompressed code has been written to:", ofile)
